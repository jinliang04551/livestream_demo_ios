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



@property (nonatomic, strong) EaseBroadCastTabViewController *_broadCastTabViewController;
@property (nonatomic, strong) ELDLiveListViewController *liveListVC;
@property (nonatomic, strong) ELDSettingViewController *settingVC;
@property (nonatomic, assign) CGFloat broadCastBtnScale;//比例


@property (nonatomic, strong) UIView *addView;
@property (nonatomic, strong) UITabBar *tabBar;
@property (strong, nonatomic) NSArray *viewControllers;

@property (strong, nonatomic) UIButton *broadCastBtn;
@property (nonatomic,strong) ELDTabBar *bottomBar;
@property (nonatomic,strong) UINavigationController* nav1;
@property (nonatomic,strong) UINavigationController* nav2;


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
    
    
    self.broadCastBtnScale = 0.9;
//    [self loadViewControllers];
    [self fetchLiveroomStatus];
    
    [self placeAndLayoutSubNavs];
    
//    [self placeAndLayoutSuviews];
}


- (void)placeAndLayoutSuviews {
    self.view.backgroundColor = UIColor.blueColor;
    
    _liveListVC = [[ELDLiveListViewController alloc]initWithBehavior:kTabbarItemTag_Live video_type:kLiveBroadCastingTypeLIVE];
    ELD_WS
    _liveListVC.goNextBlock = ^{

    };
    
    
    _settingVC = [[ELDSettingViewController alloc] init];


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
        make.top.equalTo(_bottomBar.mas_top).offset(-kBroadCastBtnHeight *0.5);
        make.centerX.equalTo(self.view);
    }];

}

- (void)placeAndLayoutSubNavs {
    self.view.backgroundColor = UIColor.blueColor;
    
    _liveListVC = [[ELDLiveListViewController alloc]initWithBehavior:kTabbarItemTag_Live video_type:kLiveBroadCastingTypeLIVE];
    ELD_WS
    _liveListVC.goNextBlock = ^{

    };
    
    
    _settingVC = [[ELDSettingViewController alloc] init];

    
    self.nav1 = [[UINavigationController alloc] initWithRootViewController:_liveListVC];
    self.nav2 = [[UINavigationController alloc] initWithRootViewController:_settingVC];
    [self.view addSubview:self.nav1.view];
    [self.view addSubview:self.nav2.view];
    
    [self.view addSubview:self.bottomBar];
    [self.view addSubview:self.broadCastBtn];


    self.nav1.view.backgroundColor = UIColor.yellowColor;
    self.nav2.view.backgroundColor = UIColor.redColor;

    [self.nav1.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.nav2.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.nav1.view);
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
        make.top.equalTo(_bottomBar.mas_top).offset(-kBroadCastBtnHeight *0.5);
        make.centerX.equalTo(self.view);
    }];

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
//    self.title = @"环信直播聊天室";
//    NSInteger tag = item.tag;
//    UIView *tmpView = nil;
//    if (tag == kTabbarItemTag_Live) {
//        tmpView = _broadCastTabViewController.view;
//    } else if (tag == kTabbarItemTag_Broadcast) {
//        //tmpView = broadCastViewController.view;
//    } else if (tag == kTabbarItemTag_Settings) {
//        self.title = @"设置";
//        tmpView = _settingVC.view;
//    }
//
//    if (self.addView == tmpView) {
//        return;
//    } else {
//        [self.addView removeFromSuperview];
//        self.addView = nil;
//    }
//
//    self.addView = tmpView;
//    if (self.addView) {
//        //[self.view addSubview:self.addView];
//        [self.view insertSubview:self.addView belowSubview:self.broadCastBtn];
//        [self.addView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view);
//            make.left.equalTo(self.view);
//            make.right.equalTo(self.view);
//            make.bottom.equalTo(self.tabBar.mas_top);
//        }];
//    }
    
    if (item.tag == 10001) {
        
    }else {
        
    }
}


- (void)setupSubviews
{
    self.tabBar = [[UITabBar alloc] init];
    self.tabBar.delegate = self;
    self.tabBar.translucent = NO;
    self.tabBar.backgroundColor = ViewControllerBgBlackColor;
    [self.tabBar setTintColor:UIColor.yellowColor];
    [self.tabBar setBarTintColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.tabBar];
    [self.tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-EMVIEWBOTTOMMARGIN);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(50);
    }];

    
    [self _setupChildController];
    [self.view addSubview:self.broadCastBtn];
    [self.broadCastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@70);
        make.top.equalTo(self.tabBar.mas_top).offset(-30);
        make.centerX.equalTo(self.view);
    }];
}


- (void)loadViewControllers
{
    _liveListVC = [[ELDLiveListViewController alloc]initWithBehavior:kTabbarItemTag_Live video_type:kLiveBroadCastingTypeLIVE];

    _liveListVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
                                                   image:[ImageWithName(@"Channel_normal")
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                           selectedImage:[ImageWithName(@"Channels_focus")
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _liveListVC.tabBarItem.tag = 10001;

    
    
    _settingVC = [[ELDSettingViewController alloc] init];
    _settingVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
                                                   image:[ImageWithName(@"Channel_normal")
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                           selectedImage:[ImageWithName(@"Channels_focus")
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _settingVC.tabBarItem.tag = 10002;

    //占位item
    UITabBarItem *blankBar = [[UITabBarItem alloc]init];
    blankBar.enabled = NO;
      
    UINavigationController* nav1 = [[UINavigationController alloc] initWithRootViewController:_liveListVC];
    UINavigationController* nav2 = [[UINavigationController alloc] initWithRootViewController:_settingVC];
    
    self.viewControllers = @[nav1, nav2];
    
//    [self customTabbar];
    
//    [self.view addSubview:self.broadCastBtn];
//    [self.broadCastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.tabBar.mas_top).offset(-30);
//        make.centerX.equalTo(self.view);
//    }];

    [self customTransTabbar];
}


- (void)customTabbar {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,100,KScreenWidth, 49)];
    bgView.backgroundColor = UIColor.clearColor;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"TabbarBg")];
    
    UIView *alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth,49)];
    alphaView.alpha = 0.0;
    
    [bgView addSubview:alphaView];
    [bgView addSubview:bgImageView];
    [bgView addSubview:self.broadCastBtn];
    
    [alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bgView);
    }];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bgView);
    }];
    
    [self.broadCastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@70);
        make.centerY.equalTo(bgView.mas_top);
        make.centerX.equalTo(bgView);
    }];

    
     [self.tabBar insertSubview:bgView atIndex:0];

}

    
- (void)_setupChildController
{
    _liveListVC = [[ELDLiveListViewController alloc]initWithBehavior:kTabbarItemTag_Live video_type:kLiveBroadCastingTypeLIVE];

    _liveListVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
                                                   image:[ImageWithName(@"Channel_normal")
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                           selectedImage:[ImageWithName(@"Channels_focus")
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _liveListVC.tabBarItem.tag = 10001;

    
    
    _settingVC = [[ELDSettingViewController alloc] init];
    _settingVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
                                                   image:[ImageWithName(@"Channel_normal")
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                           selectedImage:[ImageWithName(@"Channels_focus")
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _settingVC.tabBarItem.tag = 10002;

    //占位item
    UITabBarItem *blankBar = [[UITabBarItem alloc]init];
    blankBar.enabled = NO;
    
    [self.tabBar setItems:@[_liveListVC.tabBarItem,blankBar,_settingVC.tabBarItem]];
    self.tabBar.selectedItem = _liveListVC.tabBarItem;
    [self tabBar:self.tabBar didSelectItem:_liveListVC.tabBarItem];
    
    [self customTabbar];
}

- (void)customTransTabbar {
    __weak UIView *wkView = self.bottomBar;
    
    [self.view addSubview:self.bottomBar];
    
   [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@49.0f);
        if (@available(iOS 11.0, *)) {
            [wkView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:0].active = YES;
        } else {
            make.bottom.equalTo(self.view);
        }
    }];
}



- (UITabBarItem *)_setupTabBarItemWithTitle:(NSString *)aTitle
                                    imgName:(NSString *)aImgName
                            selectedImgName:(NSString *)aSelectedImgName
                                        tag:(NSInteger)aTag
{
    UITabBarItem *retItem = [[UITabBarItem alloc] initWithTitle:aTitle image:[UIImage imageNamed:aImgName] selectedImage:[[UIImage imageNamed:aSelectedImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    retItem.tag = aTag;
 
    return retItem;
}

/*
#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController.tabBarItem.tag == 1) {
        EasePublishViewController *publishViewController = [[EasePublishViewController alloc] init];
        [self presentViewController:publishViewController animated:YES completion:NULL];
        return NO;
    }
    return YES;
}*/



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
            [weakSelf updateNavBottomBarWithSelectedIndex:index];
//            [weakSelf updateBottomBarWithSelectedIndex:index];
            
        };
        _bottomBar.selectedIndex = 0;
    }
    return _bottomBar;
}

- (void)updateBottomBarWithSelectedIndex:(NSInteger)index {
    if (index == 0) {
        self.liveListVC.view.hidden = NO;
        self.settingVC.view.hidden = YES;
    }else {
        self.liveListVC.view.hidden = YES;
        self.settingVC.view.hidden = NO;
    }
}

- (void)updateNavBottomBarWithSelectedIndex:(NSInteger)index {
    if (index == 0) {
        self.nav1.view.hidden = NO;
        self.nav2.view.hidden = YES;
    }else {
        self.nav1.view.hidden = YES;
        self.nav2.view.hidden = NO;
    }
}




- (UIButton *)broadCastBtn
{
    if (_broadCastBtn == nil) {
        _broadCastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_broadCastBtn setImage:[UIImage imageNamed:@"strat_live_stream"] forState:UIControlStateNormal];
        [_broadCastBtn addTarget:self action:@selector(broadCastFeedBack:) forControlEvents:UIControlEventTouchDown];
        [_broadCastBtn addTarget:self action:@selector(createBroadcastRoom) forControlEvents:UIControlEventTouchUpInside];
        _broadCastBtn.layer.cornerRadius = kBroadCastBtnHeight * 0.5;
        _broadCastBtn.backgroundColor = UIColor.cyanColor;

    }
    return _broadCastBtn;
}

- (void)broadCastFeedBack:(UIButton *)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        sender.transform = CGAffineTransformMakeScale(self.broadCastBtnScale, self.broadCastBtnScale);
    }];
}

- (void)createBroadcastRoom
{
//    EaseLiveCreateViewController *createLiveVC = [[EaseLiveCreateViewController alloc] init];
    
    ELDLiveContainerViewController *vc = [[ELDLiveContainerViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:true completion:nil];
}


@end

#undef kBroadCastBtnHeight
