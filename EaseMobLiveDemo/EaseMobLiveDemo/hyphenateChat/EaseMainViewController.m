//
//  MainViewController.m
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseMainViewController.h"

#import "EaseLiveTVListViewController.h"
#import "EasePublishViewController.h"
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

@interface EaseMainViewController () <UITabBarDelegate>
{
    EaseBroadCastTabViewController *_broadCastTabViewController;
    ELDLiveListViewController *_liveListVC;
    ELDSettingViewController *_settingVC;
    CGFloat broadCastBtnScale;//比例
}

@property (nonatomic, strong) UIView *addView;
@property (nonatomic, strong) UITabBar *tabBar;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIButton *broadCastBtn;
@end

@implementation EaseMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
//    if (@available(iOS 15.0, *)) {
//        UINavigationBarAppearance * bar = [UINavigationBarAppearance new];
//        bar.backgroundColor = [UIColor whiteColor];
//        bar.backgroundEffect = nil;
//        self.navigationController.navigationBar.scrollEdgeAppearance = bar;
//                self.navigationController.navigationBar.standardAppearance = bar;
//
//        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//        UIColor* color = [UIColor blackColor];
//        NSDictionary* dict=[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
//        self.navigationController.navigationBar.titleTextAttributes = dict;
//    }else{
//        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//        UIColor* color = [UIColor blackColor];
//        NSDictionary* dict=[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
//        self.navigationController.navigationBar.titleTextAttributes = dict;
//    }
    
    broadCastBtnScale = 0.9;
    [self loadViewControllers];
    [self fetchLiveroomStatus];
}

//判断之前直播的直播间owner是否是自己
- (void)fetchLiveroomStatus
{
    __weak typeof(self) weakSelf = self;
    [[EaseHttpManager sharedInstance] fetchLiveroomDetail:EaseDefaultDataHelper.shared.currentRoomId completion:^(EaseLiveRoom *room, BOOL success) {
        if (success) {
            if (room.status == ongoing && [room.anchor isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
                [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOngoing:room completion:^(EaseLiveRoom *room, BOOL success) {
                    EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:room];
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
    
//    UIView *lineView = [[UIView alloc] init];
//    lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
//    [self.tabBar addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.tabBar.mas_top);
//        make.left.equalTo(self.tabBar.mas_left);
//        make.right.equalTo(self.tabBar.mas_right);
//        make.height.equalTo(@1);
//    }];
    
    [self _setupChildController];
    [self.view addSubview:self.broadCastBtn];
    [self.broadCastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@70);
        make.top.equalTo(self.tabBar.mas_top).offset(-30);
        make.centerX.equalTo(self.view);
    }];
}

- (UIButton *)broadCastBtn
{
    if (_broadCastBtn == nil) {
        _broadCastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_broadCastBtn setImage:[UIImage imageNamed:@"strat_live_stream"] forState:UIControlStateNormal];
        [_broadCastBtn addTarget:self action:@selector(broadCastFeedBack:) forControlEvents:UIControlEventTouchDown];
        [_broadCastBtn addTarget:self action:@selector(createBroadcastRoom) forControlEvents:UIControlEventTouchUpInside];
        _broadCastBtn.layer.cornerRadius = 35;

    }
    return _broadCastBtn;
}

- (void)broadCastFeedBack:(UIButton *)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        sender.transform = CGAffineTransformMakeScale(broadCastBtnScale, broadCastBtnScale);
    }];
}

- (void)createBroadcastRoom
{
//    EaseLiveCreateViewController *createLiveVC = [[EaseLiveCreateViewController alloc] init];
    
    ELDLiveContainerViewController *vc = [[ELDLiveContainerViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:true completion:nil];
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
    
    [self customTabbar];
    
    [self.view addSubview:self.broadCastBtn];
    [self.broadCastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabBar.mas_top).offset(-30);
        make.centerX.equalTo(self.view);
    }];

}


- (void)customTabbar {
    UIImageView *ima = [[UIImageView alloc] initWithImage:ImageWithName(@"TabbarBg")];
    ima.frame = CGRectMake(0,0,self.view.frame.size.width, 49);
    
    UIView *alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ima.frame.size.width,ima.frame.size.height)];
    alphaView.alpha = 0.0;
    [self.tabBar insertSubview:ima atIndex:0];

    self.tabBar.opaque = YES;
    [self.tabBar insertSubview:ima atIndex:0];
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

    
    
    _settingVC = [[EaseSettingsViewController alloc] init];
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

@end
