//
//  ELDContactView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDContactView.h"
#import "ELDGenderView.h"

#define kMeHeaderImageViewHeight 90.0

static NSString *reusecellIndentify = @"reusecellIndentify";

@interface ELDContactView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ELDGenderView *genderView;
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UIImageView *roleImageView;
@property (nonatomic, strong) UITableView *table;

@end


@implementation ELDContactView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndlayoutSubviews];
    }
    return self;
}

- (void)placeAndlayoutSubviews {
    [self addSubview:self.table];

    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}


- (void)buildCells {
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 10.0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:reusecellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusecellIndentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = @"111";
    
    return cell;
}


#pragma mark getter and setter
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

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = kMeHeaderImageViewHeight * 0.5;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.backgroundColor = UIColor.greenColor;
    }
    return _avatarImageView;
}


- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = BFont(12.0f);
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}


- (ELDGenderView *)genderView {
    if (_genderView == nil) {
        _genderView = [[ELDGenderView alloc] initWithFrame:CGRectZero];
        [_genderView updateWithGender:2 birthday:@""];
    }
    return _genderView;
}


- (UIImageView *)muteImageView {
    if (_muteImageView == nil) {
        _muteImageView = [[UIImageView alloc] init];
        _muteImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_muteImageView setImage:ImageWithName(@"member_mute_icon")];
    }
    return _muteImageView;
}

- (UIImageView *)roleImageView {
    if (_roleImageView == nil) {
        _roleImageView = [[UIImageView alloc] init];
        _roleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _roleImageView;
}


- (UITableView*)table
{
    if (_table == nil) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        //ios9.0+
        if ([_table respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
            _table.cellLayoutMarginsFollowReadableWidth = NO;
        }
        _table.dataSource = self;
        _table.delegate = self;
        _table.backgroundView = nil;
        _table.rowHeight = 44.0;
        _table.tableHeaderView = self.headerView;
    }
    return _table;
}


- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        [_headerView addSubview:self.topBgImageView];
        [_headerView addSubview:self.avatarImageView];
        [_headerView addSubview:self.nameLabel];
        [_headerView addSubview:self.genderView];
        [_headerView addSubview:self.roleImageView];
        [_headerView addSubview:self.muteImageView];

        [self.topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView).offset(100.0);
            make.left.right.equalTo(_headerView);
        }];
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headerView);
            make.left.equalTo(_headerView).offset(2.0);
            make.size.equalTo(@32.0);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(4.0);
            make.left.equalTo(self.avatarImageView.mas_right).offset(kEaseLiveDemoPadding);
            make.height.equalTo(@16.0);
        }];

        [self.genderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
            make.right.equalTo(self).offset(-8.0);
        }];
    }
    return _headerView;
}


@end

#undef kMeHeaderImageViewHeight

