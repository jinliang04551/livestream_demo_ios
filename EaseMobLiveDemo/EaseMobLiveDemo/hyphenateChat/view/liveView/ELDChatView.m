//
//  ELDChatView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/5/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDChatView.h"
#import "JPGiftCellModel.h"
#import "JPGiftModel.h"
#import "JPGiftShowManager.h"
#import "EaseLiveGiftHelper.h"
#import "EaseBarrageFlyView.h"
#import "EaseHeartFlyView.h"

#define kExitButtonHeight 25.0
#define kEaseChatViewBottomOffset 20.0


@interface ELDChatView ()<EaseChatViewDelegate>


@property (strong, nonatomic) UIView *functionAreaView;

@property (strong, nonatomic) UIButton *changeCameraButton;
@property (strong, nonatomic) UIButton *chatListShowButton;

@property (strong, nonatomic) UIButton *exitButton;
@property (strong, nonatomic) UIButton *giftButton;


@property (assign, nonatomic) BOOL isPublish;
@property (assign, nonatomic) BOOL isHiddenChatListView;

@property (strong, nonatomic) EaseLiveRoom *room;

//custom chatView UI with option
@property (nonatomic, strong) EaseChatViewCustomOption *customOption;

@end


@implementation ELDChatView
#pragma mark life cycle
- (instancetype)initWithFrame:(CGRect)frame
                         room:(EaseLiveRoom *)room
                    isPublish:(BOOL)isPublish
              customMsgHelper:(EaseCustomMessageHelper *)customMsgHelper {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.room = room;
        self.isPublish = isPublish;
        
        self.customOption = [EaseChatViewCustomOption customOption];
        
        self.easeChatView = [[EaseChatView alloc] initWithFrame:frame chatroomId:room.chatroomId customMsgHelper:customMsgHelper customOption:self.customOption];
        self.easeChatView.delegate = self;
        
        [self placeAndLayoutBottomView];
    
        
    }
    return self;
}


- (void)placeAndLayoutBottomView {
    [self addSubview:self.easeChatView];
    [self addSubview:self.functionAreaView];
        
    [self.functionAreaView addSubview:self.chatListShowButton];
    
    [self.easeChatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
    }];

    [self.functionAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.easeChatView.sendTextButton);
        make.left.lessThanOrEqualTo(self.easeChatView.sendTextButton.mas_right);
        make.right.equalTo(self);
        make.height.equalTo(self.easeChatView.sendTextButton);
    }];
    
    
    if (self.isPublish) {
        [self.functionAreaView addSubview:self.exitButton];
        [self.functionAreaView addSubview:self.changeCameraButton];
        
        [self.exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.functionAreaView.mas_right).offset(-15.0);
            make.size.equalTo(@(kExitButtonHeight));
        }];

        [self.changeCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.exitButton.mas_left).offset(-15.0);
            make.size.equalTo(self.exitButton);
        }];
        
        [self.chatListShowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.changeCameraButton.mas_left).offset(-15.0);
//            make.left.equalTo(self.bottomView).offset(5.0);
            make.size.equalTo(self.exitButton);
        }];
    }else {
        [self.functionAreaView addSubview:self.giftButton];
        [self.giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.functionAreaView.mas_right).offset(-15.0);
            make.size.equalTo(@(kExitButtonHeight));
        }];

        [self.chatListShowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.giftButton.mas_left).offset(-15.0);
//            make.left.equalTo(self.bottomView).offset(5.0);
            make.size.equalTo(self.giftButton);
        }];
        
    }

}


#pragma mark EaseChatViewDelegate
- (void)chatViewDidBottomOffset:(CGFloat)offset {
    
    BOOL hidden = offset > 0 ? YES : NO;
    
    if (self.isPublish) {
        self.chatListShowButton.hidden = hidden;
        self.changeCameraButton.hidden = hidden;
        self.exitButton.hidden = hidden;
    }else {
        self.chatListShowButton.hidden = hidden;
        self.giftButton.hidden = hidden;
    }
        
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewDidBottomOffset:)]) {
        [self.delegate chatViewDidBottomOffset:offset];
    }
}

- (void)didSelectUserWithMessage:(AgoraChatMessage *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectUserWithMessage:)]) {
        [self.delegate didSelectUserWithMessage:message];
    }

}


- (void)chatViewDidSendMessage:(AgoraChatMessage *)message error:(AgoraChatError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewDidSendMessage:error:)]) {
        [self.delegate chatViewDidSendMessage:message error:error];
    }
}

#pragma mark user join chatroom
- (void)insertJoinMessageWithChatroom:(AgoraChatroom *)aChatroom user:(NSString *)aUsername {
    AgoraChatTextMessageBody *body = [[AgoraChatTextMessageBody alloc] initWithText:@"join the live room"];
    NSMutableDictionary *ext = [[NSMutableDictionary alloc]init];
    [ext setObject:EaseKit_chatroom_join forKey:EaseKit_chatroom_join];
    AgoraChatMessage *joinMsg = [[AgoraChatMessage alloc] initWithConversationID:aChatroom.chatroomId from:aUsername to:aChatroom.chatroomId body:body ext:ext];
    joinMsg.chatType = AgoraChatTypeChatRoom;
    if ([self.easeChatView.datasource count] >= 200) {
        [self.easeChatView.datasource removeObjectsInRange:NSMakeRange(0, 190)];
    }
    [self.easeChatView.datasource addObject:joinMsg];
    [self.easeChatView.tableView reloadData];
    [self.easeChatView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.easeChatView.datasource count] - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark chatroom operation
- (void)joinChatroomWithCompletion:(void (^)(AgoraChatroom *aChatroom, AgoraChatError *aError))aCompletion
{
    [[EaseHttpManager sharedInstance] joinLiveRoomWithRoomId:_room.roomId
                                                  chatroomId:_room.chatroomId
                                                  completion:aCompletion];
}

- (void)leaveChatroomWithCompletion:(void (^)(BOOL success))aCompletion
{
    __weak typeof(self) weakSelf = self;
    [[EaseHttpManager sharedInstance] leaveLiveRoomWithRoomId:_room.roomId
                                                   chatroomId:_room.chatroomId
                                                   completion:^(BOOL success) {
                                                       BOOL ret = NO;
                                                       if (success) {
                                                           [weakSelf.easeChatView.datasource removeAllObjects];
                                                           [[AgoraChatClient sharedClient].chatManager deleteConversation:_room.chatroomId isDeleteMessages:YES completion:NULL];
                                                           ret = YES;
                                                       }
                                                       aCompletion(ret);
                                                   }];
}



//礼物动画
- (void)sendGiftAction:(JPGiftCellModel*)cellModel backView:(UIView*)backView
{
    JPGiftModel *giftModel = [[JPGiftModel alloc]init];
    giftModel.userAvatarURL = cellModel.userAvatarURL;
    giftModel.userName = cellModel.username;
    giftModel.giftName = cellModel.name;
    giftModel.giftImage = cellModel.icon;
    giftModel.defaultCount = 0;
    giftModel.sendCount = cellModel.count;
    [[JPGiftShowManager sharedManager] showGiftViewWithBackView:backView info:giftModel completeBlock:^(BOOL finished) {
               //结束
        } completeShowGifImageBlock:^(JPGiftModel *giftModel) {
    }];
}

//有观众送礼物
- (void)userSendGiftId:(NSString *)giftId
               giftNum:(NSInteger)giftNum
                userId:(NSString *)userId
              backView:(UIView*)backView {
        
    int giftIndex = [[giftId substringFromIndex:5] intValue];
    ELDGiftModel *model = EaseLiveGiftHelper.sharedInstance.giftArray[giftIndex-1];
    
    [EaseUserInfoManagerHelper fetchUserInfoWithUserIds:@[userId] completion:^(NSDictionary * _Nonnull userInfoDic) {
        if (userInfoDic.count > 0) {
            AgoraChatUserInfo *userInfo = userInfoDic[userId];
            JPGiftCellModel *cellModel = [[JPGiftCellModel alloc]init];
            cellModel.userAvatarURL = userInfo.avatarUrl;
            cellModel.icon = ImageWithName(model.giftname);
            cellModel.name = model.giftname;
            cellModel.username = userInfo.nickName ?: userInfo.userId;
            cellModel.count = giftNum;
            
            [self sendGiftAction:cellModel backView:backView];
        }
    }];
}


//弹幕动画
- (void)barrageAction:(AgoraChatMessage*)msg backView:(UIView*)backView
{
    EaseBarrageFlyView *barrageView = [[EaseBarrageFlyView alloc]initWithMessage:msg];
    [backView addSubview:barrageView];
    [barrageView animateInView:backView];
}

//点赞动画
- (void)praiseAction:(UIView*)backView
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [backView addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), backView.height);
    heart.center = fountainSource;
    [heart animateInView:backView];
}


#pragma mark actions
- (void)changeCameraAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectChangeCameraButton)]) {
        [_delegate didSelectChangeCameraButton];
        _changeCameraButton.selected = !_changeCameraButton.selected;
    }
}

- (void)chatListShowButtonAction:(id)sender {
  
    self.isHiddenChatListView = !self.isHiddenChatListView;
    
    if (self.isHiddenChatListView) {
        [_chatListShowButton setImage:ImageWithName(@"live_chatlist_normal") forState:UIControlStateNormal];
    }else {
        [_chatListShowButton setImage:ImageWithName(@"live_chatlist_hidden") forState:UIControlStateNormal];
    }
        
    [self.easeChatView updateChatViewWithHidden:self.isHiddenChatListView];
}


- (void)exitAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedExitButton)]) {
        [self.delegate didSelectedExitButton];
    }
}

- (void)giftAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectGiftButton)]) {
        [_delegate didSelectGiftButton];
    }
}


#pragma mark getter and setter
- (UIView*)functionAreaView
{
    if (_functionAreaView == nil) {
        _functionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 40.0)];
        _functionAreaView.backgroundColor = [UIColor clearColor];
    }
    return _functionAreaView;
}


- (UIButton*)changeCameraButton
{
    if (_changeCameraButton == nil) {
        _changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeCameraButton.frame = CGRectMake(0, 0, KScreenWidth, 100);
        [_changeCameraButton setImage:[UIImage imageNamed:@"flip_camera_ios"] forState:UIControlStateNormal];
        [_changeCameraButton addTarget:self action:@selector(changeCameraAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return _changeCameraButton;
}

- (UIButton *)chatListShowButton {
    if (_chatListShowButton == nil) {
        _chatListShowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chatListShowButton.frame = CGRectMake(0, 0, KScreenWidth, 100);
        [_chatListShowButton setImage:ImageWithName(@"live_chatlist_hidden") forState:UIControlStateNormal];
        [_chatListShowButton addTarget:self action:@selector(chatListShowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatListShowButton;
}

- (UIButton*)exitButton
{
    if (_exitButton == nil) {
        _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitButton.frame = CGRectMake(0, 0, KScreenWidth, 100);
        [_exitButton setImage:[UIImage imageNamed:@"stop_live"] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _exitButton;
}


- (UIButton*)giftButton
{
    if (_giftButton == nil) {
        _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _giftButton.frame = CGRectMake(0, 0, KScreenWidth, 100);
        [_giftButton setImage:[UIImage imageNamed:@"live_gift"] forState:UIControlStateNormal];
        [_giftButton addTarget:self action:@selector(giftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _giftButton;
}


@end

#undef kExitButtonHeight
#undef kEaseChatViewBottomOffset
