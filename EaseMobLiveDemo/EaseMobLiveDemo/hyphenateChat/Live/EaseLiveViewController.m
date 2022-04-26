//
//  EaseLiveViewController.m
//
//  Created by EaseMob on 16/6/4.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveViewController.h"

#import "EaseChatView.h"
#import "EaseHeartFlyView.h"
#import "EaseGiftFlyView.h"
#import "EaseBarrageFlyView.h"
#import "EaseLiveHeaderListView.h"
#import "UIImage+Color.h"
#import "EaseProfileLiveView.h"
#import "EaseLiveGiftView.h"
#import "EaseLiveRoom.h"
#import "EaseAnchorCardView.h"
#import "EaseLiveGiftView.h"
#import "EaseGiftConfirmView.h"
#import "EaseGiftCell.h"
#import "EaseCustomKeyBoardView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "EaseDefaultDataHelper.h"

#import "UIImageView+WebCache.h"
#import "EaseCustomMessageHelper.h"

#import <PLPlayerKit/PLPlayerKit.h>

#import <AgoraRtcKit/AgoraRtcEngineKit.h>

#import "ELDChatroomMembersView.h"

#import "ELDUserInfoView.h"

#import "EaseLiveCastView.h"

#import "ELDNotificationView.h"

#import "ELDEnterLiveroomAnimationView.h"

#import "ELDTwoBallAnimationView.h"

#define kDefaultTop 35.f
#define kDefaultLeft 10.f

@interface EaseLiveViewController () <EaseChatViewDelegate,EaseLiveHeaderListViewDelegate,TapBackgroundViewDelegate,EaseLiveGiftViewDelegate,AgoraChatroomManagerDelegate,EaseProfileLiveViewDelegate,AgoraChatClientDelegate,EaseCustomMessageHelperDelegate,PLPlayerDelegate,AgoraRtcEngineDelegate,ELDChatroomMembersViewDelegate,ELDUserInfoViewDelegate>
{
    NSTimer *_burstTimer;
    EaseLiveRoom *_room;
    BOOL _enableAdmin;
    EaseCustomMessageHelper *_customMsgHelper;
    NSTimer *_timer;
    NSInteger _clock; //重复次数时钟
    id _observer;
}

@property (nonatomic, strong) AgoraChatroom *chatroom;

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) EaseChatView *chatview;
@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *liveView;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGR;

/** gifimage */
@property(nonatomic,strong) UIImageView *backgroudImageView;

@property (nonatomic, strong) PLPlayer  *player;

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avLayer;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIView *agoraRemoteVideoView;

@property (nonatomic, strong) ELDChatroomMembersView *memberView;
@property (nonatomic, strong) ELDUserInfoView *userInfoView;
@property (nonatomic, strong) EaseLiveGiftView *giftView;

@property (nonatomic, strong) ELDNotificationView *notificationView;

@property (nonatomic, strong) ELDEnterLiveroomAnimationView *enterAnimationView;

@property (nonatomic, strong) ELDTwoBallAnimationView *twoBallAnimationView;


@end

@implementation EaseLiveViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room
{
    self = [super init];
    if (self) {
        _room = room;
        _customMsgHelper = [[EaseCustomMessageHelper alloc]initWithCustomMsgImp:self chatId:_room.chatroomId];
        _clock = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view insertSubview:self.backgroudImageView atIndex:0];
    
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    [self joinChatroom];
    
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
    
    [self setupForDismissKeyboard];
    
    [self _setupAgoreKit];
}

- (void)joinChatroom {
    ELD_WS
    
    [self.chatview joinChatroomWithCompletion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (aError == nil) {
            [[AgoraChatClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_room.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
                if (aError == nil) {
                    weakSelf.chatroom = aChatroom;
                    
                    [self.view addSubview:self.liveView];
                    [weakSelf.view bringSubviewToFront:weakSelf.liveView];
                    [weakSelf updateUI];

                }else {
                    [self showHint:aError.description];
                }
            }];

        } else {
            [self showHint:aError.errorDescription];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    

}

- (void)updateUI {
    [self.headerListView updateHeaderViewWithChatroom:self.chatroom];
    [self updateChatView];
}

- (void)updateChatView {
    self.chatview.chatroom = self.chatroom;
    
    if ([self.chatroom.muteList containsObject:AgoraChatClient.sharedClient.currentUsername] ||self.chatroom.isMuteAllMembers) {
        self.chatview.isMuted = YES;
    }
}



- (void)viewWillLayoutSubviews
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AgoraChatClient sharedClient].roomManager removeDelegate:self];
    [[AgoraChatClient sharedClient] removeDelegate:self];
    [_headerListView stopTimer];
    _chatview.delegate = nil;
    _chatview = nil;
    if (self.avPlayer)
        [self.avPlayer removeTimeObserver:_observer];
    [self stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.chatview endEditing:YES];
}



#pragma mark - fetchlivingstream

//拉取直播流
- (void)fetchLivingStream
{
    __weak typeof(self) weakSelf = self;
    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {

        return;
    }
    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeVOD] || [_room.liveroomType isEqualToString:kLiveBroadCastingTypeAgoraVOD]) {
        NSURL *pushUrl = [NSURL URLWithString:[[_room.liveroomExt objectForKey:@"play"] objectForKey:@"m3u8"]];
        if (!pushUrl) {
            pushUrl = [NSURL URLWithString:[[_room.liveroomExt objectForKey:@"play"] objectForKey:@"rtmp"]];
            [self startPLayVideoStream:pushUrl];
        } else {
            [self startPlayVodStream:pushUrl];
        }
        return;
    }
    [EaseHttpManager.sharedInstance getLiveRoomPullStreamUrlWithRoomId:_room.chatroomId completion:^(NSString *pullStreamStr) {
        NSURL *pullStreamUrl = [NSURL URLWithString:pullStreamStr];
        [weakSelf startPLayVideoStream:pullStreamUrl];
    }];
}


#pragma mark - configAgroaKit

- (void)_setupAgoreKit
{
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:AppId delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    AgoraClientRoleOptions *options = [[AgoraClientRoleOptions alloc]init];
    options.audienceLatencyLevel = AgoraAudienceLatencyLevelLowLatency;
    [self.agoraKit setClientRole:AgoraClientRoleAudience options:options];
    [self.agoraKit enableVideo];
    [self.agoraKit enableAudio];
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:agoraUserId joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
            if ([_room.liveroomType isEqualToString:kLiveBoardCastingTypeAGORA_CDN_LIVE]) {
                NSDictionary *paramtars = @{
                    @"protocol":@"rtmp",
                    @"domain":@"ws-rtmp-pull.easemob.com",
                    @"pushPoint":@"live",
                    @"streamKey":_room.channel ? _room.channel : _room.chatroomId
                };
                [EaseHttpManager.sharedInstance getAgroLiveRoomPlayStreamUrlParamtars:paramtars Completion:^(NSString *playStreamStr) {
                    NSLog(@"%s  playStreamStr:%@",__func__,playStreamStr);

                    AgoraLiveInjectStreamConfig *config = [[AgoraLiveInjectStreamConfig alloc] init];
                    config.videoGop=30;
                    config.videoBitrate=400;
                    config.videoFramerate=15;
                    config.audioBitrate=48;
                    config.audioSampleRate= AgoraAudioSampleRateType44100;
                    config.audioChannels=1;
                    [self.agoraKit addInjectStreamUrl:playStreamStr config:config];
                }];
                
            }
        }];
    }];
    self.agoraRemoteVideoView = [[UIView alloc]init];
    self.agoraRemoteVideoView.frame = self.view.bounds;
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine
remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state reason:(AgoraVideoRemoteReason)reason elapsed:(NSInteger)elapsed {
    if (state == AgoraVideoRemoteStateFailed || state == AgoraVideoRemoteStateStopped) {
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
    } else {
        [self.view insertSubview:self.agoraRemoteVideoView atIndex:0];
        [self.backgroudImageView removeFromSuperview];
        
    }
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.view = self.agoraRemoteVideoView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    // 设置远端视图。
    [self.agoraKit setupRemoteVideo:videoCanvas];
}


- (PLPlayerOption *)_getPlayerOPtion
{
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    [option setOptionValue:@(3) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogDebug) forKey:PLPlayerOptionKeyLogLevel];
    return option;
}

//点播
- (void)startPlayVodStream:(NSURL *)vodStreamUrl
{
    //设置播放的项目
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:vodStreamUrl];
    //初始化player对象
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    //设置播放页面
    self.avLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    //设置播放页面的大小
    self.avLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.avLayer.backgroundColor = [UIColor clearColor].CGColor;
    //设置播放窗口和当前视图之间的比例显示内容
    self.avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.backgroudImageView removeFromSuperview];
    //添加播放视图到self.view
    [self.view.layer insertSublayer:self.avLayer atIndex:0];
    //设置播放的默认音量值
    self.avPlayer.volume = 1.0f;
    [self.avPlayer play];
    [self addProgressObserver: [vodStreamUrl absoluteString]];
}

// 视频循环播放
- (void)vodPlayDidEnd:(NSDictionary*)dic{
    [self.avLayer removeFromSuperlayer];
    self.avPlayer = nil;
    NSURL *pushUrl = [NSURL URLWithString:[dic objectForKey:@"pushurl"]];
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(0, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    AVPlayerItem *item = [dic objectForKey:@"playItem"];
    [item seekToTime:kCMTimeZero];
    [self startPlayVodStream:pushUrl];
}

-(void)addProgressObserver:(NSString*)url {
    __weak typeof(self) weakSelf = self;
    AVPlayerItem *playerItem=self.avPlayer.currentItem;
    _observer = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        if ((current > 0 && total > 0) && ((int)current == (int)total)) {
            [weakSelf vodPlayDidEnd:@{@"pushurl":url, @"playItem":weakSelf.avPlayer.currentItem}];
        }
    }];
}


//看直播
- (void)startPLayVideoStream:(NSURL *)streamUrl
{
    self.player = [PLPlayer playerLiveWithURL:streamUrl option:[self _getPlayerOPtion]];
    self.player.delegate = self;
    [self.view insertSubview:self.player.playerView atIndex:0];
    [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
    self.player.delegateQueue = dispatch_get_main_queue();
    if ([_room.liveroomType isEqual:kLiveBroadCastingTypeVOD])
        self.player.playerView.contentMode = UIViewContentModeScaleAspectFit;
    [self.player play];
}

#pragma mark - AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine
                    connectionStateChanged:(AgoraConnectionState)state
           reason:(AgoraConnectionChangedReason)reason {
    
    if (reason == AgoraConnectionChangedReasonTokenExpired || reason == AgoraConnectionChangedReasonInvalidToken) {
        __weak typeof(self) weakSelf = self;
        [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
            [weakSelf.agoraKit renewToken:rtcToken];
        }];
    }
    if (state == AgoraConnectionStateConnected) {
        if (_clock > 0) {
            _clock = 0;
            [self stopTimer];
        }
    }
    if (state == AgoraConnectionStateConnecting || state == AgoraConnectionStateReconnecting) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"正在连接..." toView:self.view];
        [hud hideAnimated:YES afterDelay:1.5];
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
    }
    if (state == AgoraConnectionStateFailed) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"连接失败,请退出重进直播间。" toView:self.view];
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
        [hud hideAnimated:YES afterDelay:2.0];
        if (_clock >= 5)
            return;
        ++_clock;
        [self startTimer];
    }
}



- (void)rtcEngine:(AgoraRtcEngineKit *)engine tokenPrivilegeWillExpire:(NSString *)token
{
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
        [weakSelf.agoraKit renewToken:rtcToken];
    }];
}

- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *)engine
{
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        }];
    }];
}

- (void)fetchAgoraRtcToken:(void (^)(NSString *rtcToken ,NSUInteger agoraUserId))aCompletionBlock;
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/token/rtcToken/v1?userAccount=%@&channelName=%@&appkey=%@",[AgoraChatClient sharedClient].currentUsername, _room.channel, [AgoraChatClient sharedClient].options.appkey];
    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[AgoraChatClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",body);
            if(body) {
                NSString* resCode = [body objectForKey:@"code"];
                if([resCode isEqualToString:@"RES_0K"]) {
                    NSString* rtcToken = [body objectForKey:@"accessToken"];
                    NSUInteger agoraUserId = [[body objectForKey:@"agoraUserId"] integerValue];
                    if (aCompletionBlock)
                        aCompletionBlock(rtcToken,agoraUserId);
                }
            }
        }
    }];

    [task resume];
}

#pragma mark - PLPlayerDelegate

- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state
{
    NSLog(@"status %ld",(long)state);
    if (state == PLPlayerStatusPlaying) {
        [self.backgroudImageView removeFromSuperview];
        if (_clock > 0) {
            _clock = 0;
            [self stopTimer];
        }
    } else if (state == PLPlayerStatusCaching) {
    } else if (state == PLPlayerStateAutoReconnecting) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"正在重新连接..." toView:self.view];
        [hud hideAnimated:YES afterDelay:1.5];
    } else if (state == PLPlayerStatusError) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"播放出错,请退出重进直播间。" toView:self.view];
        [self.player.playerView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
        [hud hideAnimated:YES afterDelay:1.5];
    }
}

- (void)player:(PLPlayer *)player stoppedWithError:(NSError *)error
{
    NSString *info = error.userInfo[@"NSLocalizedDescription"];
    MBProgressHUD *hud = [MBProgressHUD showMessag:info toView:self.view];
    [self.player.playerView removeFromSuperview];
    [self.view insertSubview:self.backgroudImageView atIndex:0];
    [hud hideAnimated:YES afterDelay:2.0];
    if (_clock >= 5)
        return;
    ++_clock;
    [self startTimer];
}

- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(updateCountLabel) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)updateCountLabel {
    
}

#pragma mark - getter and setter

- (UIWindow*)window
{
    if (_window == nil) {
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 290.f)];
    }
    return _window;
}

- (UIImageView*)backgroudImageView
{
    if (_backgroudImageView == nil) {
        _backgroudImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _backgroudImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_backgroudImageView sd_setImageWithURL:[NSURL URLWithString:_room.coverPictureUrl] placeholderImage:ImageWithName(@"default_back_image")];
        
//        [_backgroudImageView addSubview:self.enterAnimationView];
//
//        [self.enterAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(_backgroudImageView);
//            make.centerY.equalTo(_backgroudImageView);
//            make.height.equalTo(@(50.0));
//        }];
//
//        [self.enterAnimationView startAnimation];

    }
    return _backgroudImageView;
}

- (UIView*)liveView
{
    if (_liveView == nil) {
        _liveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        _liveView.backgroundColor = [UIColor clearColor];
        
        [_liveView addSubview:self.headerListView];
        [_liveView addSubview:self.chatview];
        [_liveView addSubview:self.notificationView];

    }
    return _liveView;
}

- (EaseLiveHeaderListView*)headerListView
{
    if (_headerListView == nil) {
        _headerListView = [[EaseLiveHeaderListView alloc] initWithFrame:CGRectMake(0, kDefaultTop, CGRectGetWidth(self.view.frame), 50.0f) chatroom:self.chatroom];
        _headerListView.delegate = self;
        [_headerListView setLiveCastDelegate];
    }
    return _headerListView;
}

- (EaseChatView*)chatview
{
    if (_chatview == nil) {
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - kChatViewHeight, CGRectGetWidth(self.view.frame), kChatViewHeight) room:_room isPublish:NO customMsgHelper:_customMsgHelper];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (void)didSelectedExitButton
{
    [self closeButtonAction];
}


- (ELDChatroomMembersView *)memberView {
    if (_memberView == nil) {
        _memberView = [[ELDChatroomMembersView alloc] initWithChatroom:self.chatroom];
        _memberView.delegate = self;
        _memberView.selectedUserDelegate = self;
    }
    return _memberView;
}

- (EaseLiveGiftView *)giftView {
    if (_giftView == nil) {
        _giftView = [[EaseLiveGiftView alloc]init];
        _giftView.giftDelegate = self;
        _giftView.delegate = self;
    }
    return _giftView;
}

- (ELDNotificationView *)notificationView {
    if (_notificationView == nil) {
        _notificationView = [[ELDNotificationView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerListView.frame), KScreenWidth, 30)];
        _notificationView.hidden = YES;
    }
    return _notificationView;
}

- (ELDEnterLiveroomAnimationView *)enterAnimationView {
    if (_enterAnimationView == nil) {
        _enterAnimationView = [[ELDEnterLiveroomAnimationView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50.0)];
        _enterAnimationView.backgroundColor = UIColor.yellowColor;
    }
    return _enterAnimationView;
}

- (ELDTwoBallAnimationView *)twoBallAnimationView {
    if (_twoBallAnimationView == nil) {
        _twoBallAnimationView = [[ELDTwoBallAnimationView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50.0)];
        [_twoBallAnimationView startAnimation];
    }
    return _twoBallAnimationView;
}


#pragma mark - EaseLiveHeaderListViewDelegate

- (void)didSelectHeaderWithUsername:(NSString *)username
{
    if ([self.window isKeyWindow]) {
        [self closeAction];
        return;
    }
    
    ELDUserInfoView *userInfoView = [[ELDUserInfoView alloc] initWithUsername:username chatroom:_chatroom memberVCType:ELDMemberVCTypeAll];
    userInfoView.delegate = self;
    userInfoView.userInfoViewDelegate = self;
    [userInfoView showFromParentView:self.view];
}

//主播信息卡片
- (void)didClickAnchorCard:(AgoraChatUserInfo*)userInfo
{
    [self.view endEditing:YES];

    ELDUserInfoView *userInfoView = [[ELDUserInfoView alloc] initWithOwnerId:userInfo.userId chatroom:self.chatroom];
    userInfoView.delegate = self;
    [userInfoView showFromParentView:self.view];
}

//成员列表
- (void)didSelectMemberListButton:(BOOL)isOwner currentMemberList:(NSMutableArray*)currentMemberList
{
    [self.view endEditing:YES];
    [self.memberView showFromParentView:self.view];
    
}


- (void)willCloseChatroom {
    [self closeButtonAction];
}

#pragma  mark - TapBackgroundViewDelegate

- (void)didTapBackgroundView:(EaseBaseSubView *)profileView
{
    [profileView removeFromParentView];
}

#pragma  mark ELDChatroomMembersViewDelegate
- (void)selectedUser:(NSString *)userId memberVCType:(ELDMemberVCType)memberVCType chatRoom:(AgoraChatroom *)chatroom {
    
    [self.memberView removeFromParentView];
    
    self.userInfoView = [[ELDUserInfoView alloc] initWithUsername:userId chatroom:chatroom memberVCType:memberVCType];
    self.userInfoView.delegate = self;
    self.userInfoView.userInfoViewDelegate = self;
    [self.userInfoView showFromParentView:self.view];

}

#pragma mark ELDUserInfoViewDelegate
- (void)showAlertWithTitle:(NSString *)title messsage:(NSString *)messsage actionType:(ELDMemberActionType)actionType {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.userInfoView confirmActionWithActionType:actionType];
    }];

    [alertController addAction:okAction];

    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - EaseChatViewDelegate

- (void)liveRoomOwnerDidUpdate:(AgoraChatroom *)aChatroom newOwner:(NSString *)aNewOwner
{
    self.chatroom = aChatroom;
    _room.anchor = aNewOwner;
    [self fetchLivingStream];
}

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight
{
    if ([self.window isKeyWindow]) {
        return;
    }
    
    if (toHeight == 200) {
        [self.view removeGestureRecognizer:self.singleTapGR];
    } else {
        [self.view addGestureRecognizer:self.singleTapGR];
    }
    
    if (!self.chatview.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.chatview.frame;
            rect.origin.y = self.view.frame.size.height - toHeight;
            self.chatview.frame = rect;
        }];
    }
}

- (void)didSelectGiftButton:(BOOL)isOwner
{
    if (!isOwner) {
        [self.giftView showFromParentView:self.view];
    }
}

#pragma mark - EaseCustomMessageHelperDelegate

//有观众送礼物
- (void)steamerReceiveGiftMessage:(AgoraChatMessage *)msg {
    [_customMsgHelper userSendGifts:msg backView:self.view];
}

//弹幕
- (void)didSelectedBarrageSwitch:(AgoraChatMessage*)msg
{
    [_customMsgHelper barrageAction:msg backView:self.view];
}

//点赞
- (void)didReceivePraiseMessage:(AgoraChatMessage *)message
{
    [_customMsgHelper praiseAction:_chatview];
}

#pragma mark - EaseLiveGiftViewDelegate
- (void)didConfirmGiftModel:(ELDGiftModel *)giftModel giftNum:(long)num {
    EaseGiftConfirmView *confirmView = [[EaseGiftConfirmView alloc] initWithGiftModel:giftModel giftNum:num titleText:@"是否赠送"];
    confirmView.delegate = self;
    [confirmView showFromParentView:self.view];
    
    ELD_WS
    [confirmView setDoneCompletion:^(BOOL aConfirm,JPGiftCellModel *giftModel) {
        if (aConfirm) {
            //发送礼物消息
            [weakSelf.chatview sendGiftAction:giftModel.id num:giftModel.count completion:^(BOOL success) {
                if (success) {
                    //显示礼物UI
                    giftModel.username = [weakSelf randomNickName:giftModel.username];
                    [weakSelf.giftView resetGiftView];
                    [_customMsgHelper sendGiftAction:giftModel backView:self.view];
                }
            }];
        }
    }];
}

extern NSMutableDictionary *audienceNickname;
extern NSArray<NSString*> *nickNameArray;
extern NSMutableDictionary *anchorInfoDic;
- (NSString *)randomNickName:(NSString *)userName
{
    int random = (arc4random() % 100);
    NSString *randomNickname = nickNameArray[random];
    if (![audienceNickname objectForKey:userName]) {
        [audienceNickname setObject:randomNickname forKey:userName];
    } else {
        randomNickname = [audienceNickname objectForKey:userName];
    }
    if ([userName isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
        randomNickname = EaseDefaultDataHelper.shared.defaultNickname;
    }
    
    return randomNickname;
}

//自定义礼物数量
- (void)giftNumCustom:(EaseLiveGiftView *)liveGiftView
{
    EaseCustomKeyBoardView *keyBoardView = [[EaseCustomKeyBoardView alloc]init];
    keyBoardView.customGiftNumDelegate = liveGiftView;
    keyBoardView.delegate = self;
    [keyBoardView showFromParentView:self.view];
}


#pragma mark - AgoraChatroomManagerDelegate
- (void)userDidJoinChatroom:(AgoraChatroom *)aChatroom user:(NSString *)aUsername {
    NSLog(@"userDidJoinChatroom: %s",__func__);
    if ([aChatroom.chatroomId isEqualToString:self.chatroom.chatroomId]) {
        [self fetchChatroomSpecificationWithRoomId:self.chatroom.chatroomId];
    }
}

- (void)userDidLeaveChatroom:(AgoraChatroom *)aChatroom user:(NSString *)aUsername {
    if ([aChatroom.chatroomId isEqualToString:self.chatroom.chatroomId]) {
        [self fetchChatroomSpecificationWithRoomId:self.chatroom.chatroomId];
    }
}

- (void)didDismissFromChatroom:(AgoraChatroom *)aChatroom reason:(AgoraChatroomBeKickedReason)aReason
{
    if (aReason == 0)
        [MBProgressHUD showMessag:[NSString stringWithFormat:@"被移出直播聊天室 %@", aChatroom.subject] toView:nil];
    if (aReason == 1)
        [MBProgressHUD showMessag:[NSString stringWithFormat:@"直播聊天室 %@ 已解散", aChatroom.subject] toView:nil];
    if (aReason == 2)
        [MBProgressHUD showMessag:@"您的账号已离线" toView:nil];
    [self closeButtonAction];
}

- (void)chatroomAllMemberMuteChanged:(AgoraChatroom *)aChatroom isAllMemberMuted:(BOOL)aMuted
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if (aMuted) {
            [self showHint:@"主播已开启全员禁言状态，不可发言！"];
            self.chatview.isMuted = YES;
        } else {
            [self showHint:@"主播已解除全员禁言，尽情发言吧！"];
            self.chatview.isMuted = NO;
        }
        
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
    }
}


- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin;
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if ([aAdmin isEqualToString:[AgoraChatClient sharedClient].currentUsername]) {
            _enableAdmin = YES;
            [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
        }
    }
}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if ([aAdmin isEqualToString:[AgoraChatClient sharedClient].currentUsername]) {
            _enableAdmin = NO;
            [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
        }
    }
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMutes) {
            [text appendString:name];
        }
        
        self.chatview.isMuted = YES;
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
        [self showHint:@"已被禁言"];
        
    }
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMutes) {
            [text appendString:name];
        }
        self.chatview.isMuted = NO;
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
        [self showHint:[NSString stringWithFormat:@"已解除禁言"]];
    }
}

- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom addedWhiteListMembers:(NSArray *)aMembers
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMembers) {
            [text appendString:name];
        }
        [self showHint:@"被加入白名单"];
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
    }
}

- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom removedWhiteListMembers:(NSArray *)aMembers
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMembers) {
            [text appendString:name];
        }
        [self showHint:@"已被从白名单中移除"];
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
    }
}

- (void)chatroomOwnerDidUpdate:(AgoraChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    __weak typeof(self) weakSelf =  self;
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"聊天室创建者有更新:%@",aChatroom.chatroomId] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([aNewOwner isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
                [_burstTimer invalidate];
                _burstTimer = nil;
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    _room.anchor = aChatroom.owner;
                    if (_chatroomUpdateCompletion) {
                        _chatroomUpdateCompletion(YES,_room);
                    }
                    [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
                }];
            }
        }];
        
        [alert addAction:ok];
        alert.modalPresentationStyle = 0;
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void)fetchChatroomSpecificationWithRoomId:(NSString *)roomId {
    [[AgoraChatClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:roomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (aError == nil) {
            self.chatroom = aChatroom;
            //reset memberView
            self.memberView = nil;
            [self.headerListView updateHeaderViewWithChatroom:self.chatroom];
        }else {
            [self showHint:aError.description];
        }
    }];
}


#pragma mark - AgoraChatClientDelegate

- (void)userAccountDidLoginFromOtherDevice
{
    [self closeButtonAction];
}

#pragma mark - Action

- (void)closeAction
{
    [self.window resignKeyWindow];
    [UIView animateWithDuration:0.3 animations:^{
        self.window.top = KScreenHeight;
    } completion:^(BOOL finished) {
        self.window.hidden = YES;
        [self.view.window makeKeyAndVisible];
    }];
}

- (void)closeButtonAction
{
    __weak typeof(self) weakSelf =  self;
    NSString *chatroomId = [_room.chatroomId copy];
    [weakSelf.chatview leaveChatroomWithCompletion:^(BOOL success) {
                                         if (success) {
                                             [[AgoraChatClient sharedClient].chatManager deleteConversation:chatroomId isDeleteMessages:YES completion:NULL];
                                         }
        
                                         [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        
                                     }];
    [self.agoraKit leaveChannel:nil];
    [_burstTimer invalidate];
    _burstTimer = nil;
}


- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = endFrame.origin.y;
    
    if ([self.window isKeyWindow]) {
        if (y == KScreenHeight) {
            [UIView animateWithDuration:0.3 animations:^{
                self.window.top = KScreenHeight - 290.f;
                self.window.height = 290.f;
            }];
        } else  {
            [UIView animateWithDuration:0.3 animations:^{
                self.window.top = 0;
                self.window.height = KScreenHeight;
            }];
        }
    }
}

#pragma mark - override

- (void)setupForDismissKeyboard
{
    _singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
    [self.chatview endEditing:YES];
}


@end
