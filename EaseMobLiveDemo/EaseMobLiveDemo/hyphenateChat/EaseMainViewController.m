//
//  MainViewController.m
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseMainViewController.h"

#import "EaseLiveTVListViewController.h"
#import "UIImage+Color.h"
#import "EaseCreateLiveViewController.h"
#import "EaseLiveCreateViewController.h"
#import "EaseSearchDisplayController.h"
#import "Masonry.h"
#import "EaseSettingsViewController.h"
#import "EaseDefaultDataHelper.h"
#import "EaseBroadCastTabViewController.h"
#import "ELDLiveListViewController.h"
#import "ELDLiveContainerViewController.h"
#import "ELDSettingViewController.h"
#import "ELDLiveViewController.h"

#import "ELDTabBar.h"

#import "EaseLiveViewController.h"
#import "EasePublishViewController.h"
#import "ELDAboutViewController.h"


#define IS_iPhoneX (\
{\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);}\
)
#define EMVIEWTOPMARGIN (IS_iPhoneX ? 22.f : 0.f)
#define EMVIEWBOTTOMMARGIN (IS_iPhoneX ? 34.f : 0.f)

#define kBroadCastBtnHeight  70.0

@interface EaseMainViewController () <UITabBarDelegate>

@property (nonatomic, strong) ELDLiveListViewController *liveListVC;
@property (nonatomic, strong) ELDSettingViewController *settingVC;
@property (strong, nonatomic) UIButton *broadCastBtn;
@property (nonatomic,strong) ELDTabBar *bottomBar;

@end

@implementation EaseMainViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAvatarUpdateNotification:) name:ELDUserAvatarUpdateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    EASELIVEDEMO_REMOVENOTIFY(self);
}

#pragma mark NOtification
- (void)userAvatarUpdateNotification:(NSNotification *)notify {
    UIImage *userImage = (UIImage *)notify.object;
    [self.bottomBar updateTabbarItemIndex:1 withImage:userImage selectedImage:userImage];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self fetchLiveroomStatus];
        
    [self setupLiveNavbar];
    
    [self placeAndLayoutSuviews];
    
}

- (void)setupLiveNavbar {
    self.prompt.text = @"Stream Channels";
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.prompt];
    self.navigationItem.rightBarButtonItem = [ELDUtil customBarButtonItemImage:@"search" action:@selector(searchAction) actionTarget:self];
}


- (void)setupSettingNavbar {
    self.prompt.text = @"Profile";
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.prompt];
    self.navigationItem.rightBarButtonItem = [ELDUtil customBarButtonItemImage:@"setting_edit" action:@selector(goEditUserInfoPageWithUserInfo) actionTarget:self];
}


- (void)placeAndLayoutSuviews {
    self.view.backgroundColor = UIColor.blueColor;
        
    [self.view addSubview:self.liveListVC.view];
    [self.view addSubview:self.settingVC.view];
    
    [self.view addSubview:self.bottomBar];
    [self.view addSubview:self.broadCastBtn];

    [self.liveListVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.settingVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.liveListVC.view);
    }];
    
    
    __weak UIView *wkView = self.bottomBar;
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@(kCustomTabbarHeight));
        if (@available(iOS 11.0, *)) {
            [wkView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:0].active = YES;
        } else {
            make.bottom.equalTo(self.view);
        }
    }];
    
    [self.broadCastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(kBroadCastBtnHeight));
        make.top.equalTo(_bottomBar.mas_top).offset(-kBroadCastBtnHeight *0.5-3.0);
        make.centerX.equalTo(self.view);
    }];

}

#pragma mark actions
- (void)searchAction
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    EaseSearchDisplayController *searchDisplay = [[EaseSearchDisplayController alloc] initWithCollectionViewLayout:flowLayout];
    searchDisplay.searchSource = [NSMutableArray arrayWithArray:self.liveListVC.dataArray];
    [self.navigationController pushViewController:searchDisplay animated:YES];
}

- (void)goLiveRoomWithRoom:(EaseLiveRoom *)liveroom {
    
    EaseLiveViewController *vc = [[EaseLiveViewController alloc] initWithLiveRoom:liveroom];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    ELD_WS
    [vc setChatroomUpdateCompletion:^(BOOL isUpdate, EaseLiveRoom *liveRoom) {
        if (isUpdate) {
            EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:liveRoom];
            publishView.modalPresentationStyle = 0;
            [weakSelf.navigationController presentViewController:publishView animated:YES completion:nil];
        }
    }];
    
    [self.navigationController presentViewController:vc animated:YES completion:nil];

}

- (void)goAboutPage {
    ELDAboutViewController *vc = [[ELDAboutViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goEditUserInfoPageWithUserInfo {
    ELD_WS
    ELDEditUserInfoViewController *vc = [[ELDEditUserInfoViewController alloc] init];
    vc.userInfo = self.settingVC.userInfo;
    
    vc.updateUserInfoBlock = ^(AgoraChatUserInfo * _Nonnull userInfo) {
        [weakSelf.settingVC updateUIWithUserInfo:userInfo];
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


//判断之前直播的直播间owner是否是自己
- (void)fetchLiveroomStatus
{
    __weak typeof(self) weakSelf = self;
    [[EaseHttpManager sharedInstance] fetchLiveroomDetail:EaseDefaultDataHelper.shared.currentRoomId completion:^(EaseLiveRoom *room, BOOL success) {
        if (success) {
            if (room.status == ongoing && [room.anchor isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
                [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOngoing:room completion:^(EaseLiveRoom *room, BOOL success) {
                    ELDLiveViewController *publishView = [[ELDLiveViewController alloc] initWithLiveRoom:room];
                    publishView.modalPresentationStyle = 0;
                    [weakSelf presentViewController:publishView animated:YES completion:^{
                        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                    }];
                    
                }];
            }
        }
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 10001) {
        
    }else {
        
    }
}


#pragma mark getter and setter
- (ELDTabBar *)bottomBar {
    if (_bottomBar == nil) {
        _bottomBar = ELDTabBar.new;
        
        ELD_TabItem* item1 = [[ELD_TabItem alloc] initWithTitle:@""
                                                                image:ImageWithName(@"Channel_normal")
                                                        selectedImage:ImageWithName(@"Channels_focus")];

        ELD_TabItem* item2 = [[ELD_TabItem alloc] initWithTitle:@""
                                                                image:ImageWithName(@"Channel_normal")
                                                        selectedImage:ImageWithName(@"Channels_focus")];
        _bottomBar.tabItems = @[item1, item2];

        ELD_WS
        _bottomBar.selectedBlock = ^(NSInteger index) {
            [weakSelf updateBottomBarWithSelectedIndex:index];
            
        };
        _bottomBar.selectedIndex = 0;
    }
    return _bottomBar;
}

- (void)updateBottomBarWithSelectedIndex:(NSInteger)index {
    if (index == 0) {
        self.liveListVC.view.hidden = NO;
        self.settingVC.view.hidden = YES;
        [self setupLiveNavbar];
    }else {
        self.liveListVC.view.hidden = YES;
        self.settingVC.view.hidden = NO;
        [self setupSettingNavbar];
    }
}



- (UIButton *)broadCastBtn
{
    if (_broadCastBtn == nil) {
        _broadCastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_broadCastBtn setImage:[UIImage imageNamed:@"strat_live_stream"] forState:UIControlStateNormal];
        [_broadCastBtn addTarget:self action:@selector(createBroadcastRoom) forControlEvents:UIControlEventTouchUpInside];
        _broadCastBtn.layer.cornerRadius = kBroadCastBtnHeight * 0.5;

    }
    return _broadCastBtn;
}


- (void)createBroadcastRoom
{
    ELDLiveContainerViewController *vc = [[ELDLiveContainerViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:true completion:nil];
}

- (ELDLiveListViewController *)liveListVC {
    if (_liveListVC == nil) {
        _liveListVC = [[ELDLiveListViewController alloc]initWithBehavior:kTabbarItemTag_Live video_type:kLiveBroadCastingTypeLIVE];
        ELD_WS
        _liveListVC.liveRoomSelectedBlock = ^(EaseLiveRoom * _Nonnull room) {
            [weakSelf goLiveRoomWithRoom:room];
        };
    }
    return _liveListVC;
}

- (ELDSettingViewController *)settingVC {
    if (_settingVC == nil) {
        _settingVC = [[ELDSettingViewController alloc] init];
        ELD_WS
        _settingVC.goAboutBlock = ^{
            [weakSelf goAboutPage];
        };
    }
    return _settingVC;
}


@end

#undef kBroadCastBtnHeight
