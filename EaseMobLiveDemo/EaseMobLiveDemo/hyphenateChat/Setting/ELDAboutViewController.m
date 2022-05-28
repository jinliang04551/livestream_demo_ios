/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "ELDAboutViewController.h"
#import "ELDTitleDetailCell.h"
#import <UIKit/UIKit.h>

@interface ELDAboutViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *table;

@end

@implementation ELDAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";
    [self setupNavbar];
    [self.view addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupNavbar {
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [ELDUtil customLeftButtonItem:@"About" action:@selector(backAction) actionTarget:self];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ELDTitleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[ELDTitleDetailCell reuseIdentifier]];
    if (!cell) {
        cell = [[ELDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ELDTitleDetailCell reuseIdentifier]];
    }
    if (indexPath.row == 0) {
        
        cell.nameLabel.attributedText = [self titleAttribute:@"UI Library Version"];
        NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        NSString *detailContent = [NSString stringWithFormat:@"V:%@",ver];
        cell.detailLabel.attributedText = [self detailAttribute:detailContent];
        
    } else if (indexPath.row == 1) {
        
        cell.nameLabel.attributedText = [self titleAttribute:@"SDK Version"];
        NSString *detailContent = [NSString stringWithFormat:@"V:%@",[[AgoraChatClient sharedClient] version]];
        cell.detailLabel.attributedText = [self detailAttribute:detailContent];
    }else if (indexPath.row == 2) {
        
        cell.nameLabel.attributedText = [self titleAttribute:@"More"];
        
        NSAttributedString *attributeString = [ELDUtil attributeContent:@"Agora.io" color:TextLabelBlueColor font:Font(@"PingFang SC",16.0)];
        cell.detailLabel.attributedText = attributeString;
        ELD_WS
        cell.tapCellBlock = ^{
            [weakSelf goAgoraOffical];
        };
    }
    
    return cell;
}


- (void)goAgoraOffical {
    NSString *urlString = @"https://www.agora.io/en";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}

- (NSAttributedString *)titleAttribute:(NSString *)title {
    return [ELDUtil attributeContent:title color:TextLabelWhiteColor font:Font(@"PingFang SC",16.0)];
}

- (NSAttributedString *)detailAttribute:(NSString *)detail {
    return [ELDUtil attributeContent:detail color:TextLabelGrayColor font:Font(@"PingFang SC",16.0)];
}

- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = ViewControllerBgBlackColor;
        [_table registerClass:[ELDTitleDetailCell class] forCellReuseIdentifier:[ELDTitleDetailCell reuseIdentifier]];
        _table.rowHeight = [ELDTitleDetailCell height];
    }
    return _table;
}


@end
