//
//  ACDSettingsViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ELDSettingViewController.h"
#import "ELDInfoDetailCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ELDEditUserInfoViewController.h"
#import "ELDUserHeaderView.h"
#import "ELDAboutViewController.h"


#define kInfoHeaderViewHeight 200.0
#define kHeaderInSection  30.0


@interface ELDSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) ELDUserHeaderView *userHeaderView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) ELDInfoDetailCell *aboutCell;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) AgoraChatUserInfo *userInfo;


@end

@implementation ELDSettingViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:ELDUSERINFO_UPDATE object:nil];
        
    }
    return self;
}

- (void)dealloc {
    EASELIVEDEMO_REMOVENOTIFY(self);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ViewControllerBgBlackColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavbar];
    [self.view addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self fetchUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)setupNavbar {
    self.prompt.text = @"Profile";
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.prompt];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
}

- (void)fetchUserInfo {
    [[AgoraChatClient.sharedClient userInfoManager] fetchUserInfoById:@[@""] completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
        if(!aError) {
            self.userInfo = [aUserDatas objectForKey:[AgoraChatClient sharedClient].currentUsername];
            if(self.userInfo && self.userInfo.avatarUrl) {
                NSURL* url = [NSURL URLWithString:self.userInfo.avatarUrl];
                [self.userHeaderView.avatarImageView sd_setImageWithURL:url placeholderImage:ImageWithName(@"")];
                self.userHeaderView.nameLabel.text = self.userInfo.nickname;
            }
        }

    }];
}

#pragma mark Notification
- (void)updateUserInfo:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        AgoraChatUserInfo *userInfo = notify.object;
        self.userInfo = userInfo;
        self.userHeaderView.nameLabel.text = self.userInfo.nickname;

    });
}

#pragma mark public method
- (void)goAboutPage {    
    ELDAboutViewController *vc = [[ELDAboutViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goEditUserInfoPage {
    ELDEditUserInfoViewController *vc = [[ELDEditUserInfoViewController alloc] init];
    vc.userInfo = self.userInfo;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderInSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kHeaderInSection)];
    
    UILabel *label = [self sectionTitleLabel];
    label.text = @"Settings";
    [sectionView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sectionView);
        make.left.equalTo(sectionView).offset(16.0);
    }];
    
    return sectionView;
}

- (UILabel *)sectionTitleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = TextLabelGrayColor;
    label.text = @"setting";
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.aboutCell;
}



#pragma mark getter and setter
- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = ViewControllerBgBlackColor;
        _table.tableHeaderView = [self headerView];
        [_table registerClass:[ELDInfoDetailCell class] forCellReuseIdentifier:[ELDInfoDetailCell reuseIdentifier]];
        _table.rowHeight = [ELDInfoDetailCell height];
    }
    return _table;
}


- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kInfoHeaderViewHeight)];
        [_headerView addSubview:self.userHeaderView];
        [self.userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerView);
        }];
        _headerView.backgroundColor = UIColor.yellowColor;
    }
    return _headerView;
}


- (ELDUserHeaderView *)userHeaderView {
    if (_userHeaderView == nil) {
        _userHeaderView = [[ELDUserHeaderView alloc] initWithFrame:CGRectZero isEditable:NO];
    }
    return _userHeaderView;
}


- (ELDInfoDetailCell *)aboutCell {
    if (_aboutCell == nil) {
        _aboutCell = [[ELDInfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ELDInfoDetailCell reuseIdentifier]];
        _aboutCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [_aboutCell.iconImageView setImage:ImageWithName(@"about_icon")];
        _aboutCell.nameLabel.text= @"About";
        _aboutCell.detailLabel.text = @"V1.0";
        ELD_WS
        _aboutCell.tapCellBlock = ^{
            [weakSelf goAboutPage];
        };
    }
    return  _aboutCell;
}

- (UIButton*)editButton
{
    if (_editButton == nil) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(0, 0, 44.f, 44.f);
        [_editButton setImage:[UIImage imageNamed:@"setting_edit"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(goEditUserInfoPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}


@end
#undef kInfoHeaderViewHeight
#undef kHeaderInSection




