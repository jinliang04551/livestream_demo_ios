//
//  ELDEditUserInfoViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/31.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDEditUserInfoViewController.h"
#import "ACDInfoDetailCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ELDEditUserInfoViewController.h"
#import "ELDUserHeaderView.h"
#import "ACDTitleDetailCell.h"


#define kInfoHeaderViewHeight 200.0
#define kHeaderInSection  30.0


@interface ELDEditUserInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) ELDUserHeaderView *userHeaderView;
@property (nonatomic, strong) UITableView *table;

@end

@implementation ELDEditUserInfoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ViewControllerBgBlackColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavbar];
    [self.view addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
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
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [ELDUtil customLeftButtonItem:@"Edit Profile" action:@selector(backAction) actionTarget:self];
    
}

#pragma mark actions
- (void)modifyAlias {
    
}

- (void)modifyAvatar {
    
}

- (void)modifyBirth {
    
}



#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDTitleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[ACDTitleDetailCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    if (indexPath.row == 0) {
        cell.nameLabel.text = @"Username";
        cell.detailLabel.text = @"111";
        
        ELD_WS
        cell.tapCellBlock = ^{
            [weakSelf modifyAlias];
            [weakSelf.table reloadData];
        };
    }
    
    if (indexPath.row == 1) {
        cell.nameLabel.text = @"Gender";
        cell.detailLabel.text = @"111";
        ELD_WS
        cell.tapCellBlock = ^{
            [weakSelf modifyBirth];
            [weakSelf.table reloadData];

        };
    }

    if (indexPath.row == 2) {
        cell.nameLabel.text = @"Brithday";
        cell.detailLabel.text = @"111";
        ELD_WS
        cell.tapCellBlock = ^{
            [weakSelf modifyBirth];
            [weakSelf.table reloadData];

        };
    }
    return cell;
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
        [_table registerClass:[ACDInfoDetailCell class] forCellReuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        _table.rowHeight = [ACDInfoDetailCell height];
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
        _userHeaderView = [[ELDUserHeaderView alloc] initWithFrame:CGRectZero isEditable:YES];
        _userHeaderView.tapHeaderViewBlock = ^{
            
        };
    }
    return _userHeaderView;
}




@end
#undef kInfoHeaderViewHeight
#undef kHeaderInSection




