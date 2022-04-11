//
//  ELDLiveroomMemberContainerViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/8.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDLiveroomMembersContainerViewController.h"
#import "MISScrollPage.h"
#import "ELDLiveroomMembersViewController.h"

#define kViewTopPadding  200.0f

@interface ELDLiveroomMembersContainerViewController ()<MISScrollPageControllerDataSource,
MISScrollPageControllerDelegate>
@property (nonatomic, strong) MISScrollPageController *pageController;
@property (nonatomic, strong) MISScrollPageSegmentView *segView;
@property (nonatomic, strong) MISScrollPageContentView *contentView;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic,strong) ELDLiveroomMembersViewController *allVC;
@property (nonatomic,strong) ELDLiveroomMembersViewController *adminListVC;
@property (nonatomic,strong) ELDLiveroomMembersViewController *allowListVC;
@property (nonatomic,strong) ELDLiveroomMembersViewController *mutedListVC;
@property (nonatomic,strong) ELDLiveroomMembersViewController *blockListVC;

@property (nonatomic, strong) UIView *alphaBgView;
@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) AgoraChatroom *chatroom;

@property (nonatomic, strong) NSMutableArray *navTitleArray;
@property (nonatomic, strong) NSMutableArray *contentVCArray;
@property (nonatomic, strong) UILabel *viewerTitleLabel;



@end

@implementation ELDLiveroomMembersContainerViewController
- (instancetype)initWithChatroom:(AgoraChatroom *)aChatroom {
    self = [self init];
    if (self) {
        self.chatroom = aChatroom;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNotification:) name:KAgora_REFRESH_GROUP_INFO object:nil];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self    action:@selector(tapGestureAction)];
        [self.view addGestureRecognizer:tap];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.yellowColor;
    
    [self placeAndLayoutSubviews];
    
    [self.pageController reloadData];
}

- (void)placeAndLayoutSubviewsForMember {
    UIView *container = UIView.new;
    container.backgroundColor = UIColor.whiteColor;
    container.clipsToBounds = YES;
    
    [self.view addSubview:container];
    [self.view addSubview:self.topBgImageView];
    [container addSubview:self.allVC.view];
    
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    [self.topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kViewTopPadding);
        make.left.right.equalTo(self.view);
    }];
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBgImageView.mas_bottom).offset(5);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}


- (void)placeAndLayoutSubviewsForAdmin {
    UIView *container = UIView.new;
    container.backgroundColor = UIColor.whiteColor;
    container.clipsToBounds = YES;
    
    [self.view addSubview:container];
    [self.view addSubview:self.topBgImageView];
    [container addSubview:self.segView];
    [container addSubview:self.contentView];
    
    CGFloat bottom = 0;;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    [self.topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kViewTopPadding);
        make.left.right.equalTo(self.view);
    }];
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBgImageView.mas_bottom).offset(5);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-bottom);
    }];
}


- (void)placeAndLayoutSubviews {
    if ([self isAdmin]) {
        [self placeAndLayoutSubviewsForAdmin];
    }else {
        [self placeAndLayoutSubviewsForMember];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark private method
- (void)tapGestureAction {
    [self removeFromParentView];
}


- (BOOL)isAdmin {
    return (self.chatroom.permissionType == AgoraChatGroupPermissionTypeOwner || self.chatroom.permissionType == AgoraChatGroupPermissionTypeAdmin );
}


#pragma mark show view
- (void)showFromParentView:(UIView *)view
{
    view.userInteractionEnabled = NO;

    [view addSubview:self.view];
    [UIView animateWithDuration:0.5 animations:^{
        
    } completion:^(BOOL finished) {
        view.userInteractionEnabled = YES;
    }];
}

- (void)removeFromParentView
{
    [UIView animateWithDuration:0.5 animations:^{

    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}


#pragma mark Notification
- (void)updateUIWithNotification:(NSNotification *)aNotification
{
//    id obj = aNotification.object;
//    if (obj && [obj isKindOfClass:[AgoraChatGroup class]]) {
//        AgoraChatGroup *group = (AgoraChatGroup *)obj;
//        if ([group.groupId isEqualToString:self.group.groupId]) {
//            self.group = group;
//            [self updateNavTitle];
//        }
//    }
}

- (void)updateWithGroup:(AgoraChatGroup *)agoraGroup {
//    self.group = agoraGroup;
//    [self updateNavTitle];
//    [self.allVC updateUI];
//    [self.adminListVC updateUI];
//    [self.blockListVC updateUI];
//    [self.mutedListVC updateUI];
}

#pragma mark action
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - scrool pager data source and delegate
- (NSUInteger)numberOfChildViewControllers {
    return self.navTitleArray.count;
}

- (NSArray*)titlesOfSegmentView {
    return self.navTitleArray;
}


- (NSArray*)childViewControllersOfContentView {
    return self.contentVCArray;
}

#pragma mark -
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController didAppearForIndex:(NSUInteger)index {
    self.currentPageIndex = index;
}


#pragma mark - setter or getter
- (MISScrollPageController*)pageController{
    if(!_pageController){
        MISScrollPageStyle* style = [[MISScrollPageStyle alloc] init];
        style.showCover = YES;
        style.coverBackgroundColor = COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = COLOR_HEX(0x999999);
        style.selectedTitleColor = COLOR_HEX(0x000000);
        style.scrollLineColor = COLOR_HEXA(0x000000, 0.5);

        style.scaleTitle = YES;
        style.titleBigScale = 1.05;
        style.titleFont = NFont(13);
        style.autoAdjustTitlesWidth = YES;
        style.showSegmentViewShadow = YES;
        _pageController = [MISScrollPageController scrollPageControllerWithStyle:style dataSource:self delegate:self];
    }
    return _pageController;
}

- (MISScrollPageSegmentView*)segView{
    if(!_segView){
        _segView = [self.pageController segmentViewWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    }
    return _segView;
}

- (MISScrollPageContentView*)contentView {
    if(!_contentView){
        _contentView = [self.pageController contentViewWithFrame:CGRectMake(0, 50, KScreenWidth, KScreenHeight-64-50-5)];
    }
    return _contentView;
}


- (ELDLiveroomMembersViewController *)allVC {
    if (_allVC == nil) {
        _allVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom];
        _allVC.view.backgroundColor = UIColor.yellowColor;
    }
    return _allVC;
}

- (ELDLiveroomMembersViewController *)adminListVC {
    if (_adminListVC == nil) {
        _adminListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom];
    }
    return _adminListVC;
}

- (ELDLiveroomMembersViewController *)allowListVC {
    if (_allowListVC == nil) {
        _allowListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom];
    }
    return _allowListVC;
}

- (ELDLiveroomMembersViewController *)mutedListVC {
    if (_mutedListVC == nil) {
        _mutedListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom];
    }
    return _mutedListVC;
}

- (ELDLiveroomMembersViewController *)blockListVC {
    if (_blockListVC == nil) {
        _blockListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom];
    }
    return _blockListVC;
}

- (UIImageView*)topBgImageView
{
    if (_topBgImageView == nil) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.image = [UIImage imageNamed:@"member_bg_top"];
        _topBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBgImageView.layer.masksToBounds = YES;
    }
    return _topBgImageView;
}


- (NSMutableArray *)navTitleArray {
    if (_navTitleArray == nil) {
        _navTitleArray = NSMutableArray.new;
    }
    return _navTitleArray;
}

- (NSMutableArray *)contentVCArray {
    if (_contentVCArray == nil) {
        _contentVCArray = NSMutableArray.new;
    }
    return _contentVCArray;
}

- (void)setChatroom:(AgoraChatroom *)chatroom {
    _chatroom = chatroom;
    self.navTitleArray = [@[@"All",@"Moderators",@"Allowed",@"Mute",@"Banned"] mutableCopy];

    self.contentVCArray = [@[self.allVC,self.adminListVC,self.allowListVC,self.mutedListVC,self.blockListVC] mutableCopy];
}



- (UIView *)alphaBgView {
    if (_alphaBgView == nil) {
        _alphaBgView = [[UIView alloc] init];
        _alphaBgView.backgroundColor = UIColor.redColor;
        _alphaBgView.alpha = 0.5;
    }
    return _alphaBgView;
}


- (UILabel *)viewerTitleLabel {
    if (_viewerTitleLabel == nil) {
        _viewerTitleLabel = [[UILabel alloc] init];
//        PingFangSC-Semibold
        _viewerTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
        _viewerTitleLabel.textColor = TextLabelBlackColor;
        _viewerTitleLabel.textAlignment = NSTextAlignmentLeft;
        _viewerTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _viewerTitleLabel.text = @"All Viewers";
    }
    return _viewerTitleLabel;
}


@end

#undef kViewTopPadding
