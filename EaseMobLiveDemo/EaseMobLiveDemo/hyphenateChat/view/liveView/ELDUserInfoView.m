//
//  ELDContactView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDUserInfoView.h"
#import "ELDGenderView.h"
#import "ELDTitleSwitchCell.h"

#define kUserInfoCellTitle @"kUserInfoCellTitle"
#define kUserInfoCellActionType @"kUserInfoCellActionType"

#define kMeHeaderImageViewHeight 72.0

static NSString *reusecellIndentify = @"reusecellIndentify";

@interface ELDUserInfoView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *avatarBgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ELDGenderView *genderView;
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UIImageView *roleImageView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) AgoraChatUserInfo *userInfo;
@property (nonatomic, strong) NSString *currentUsername;
@property (nonatomic, strong) AgoraChatroom *chatroom;
@property (nonatomic, strong) NSString *chatroomId;
@property (nonatomic, assign) ELDMemberRoleType roleType;
@property (nonatomic, assign) BOOL isMute;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) ELDTitleSwitchCell *titleSwitchCell;

@property (nonatomic, strong) NSMutableDictionary *actionTypeDic;

//owner check oneself
@property (nonatomic, assign) BOOL ownerSelf;


@end


@implementation ELDUserInfoView
- (instancetype)initWithUsername:(NSString *)username
                        chatroom:(AgoraChatroom *)chatroom {
    self = [super init];
    if (self) {
        
        self.currentUsername = username;
        self.chatroom = chatroom;
        self.chatroomId = self.chatroom.chatroomId;
        [self fetchUserInfoWithUsername:username];
     
    }
    return self;
}

- (void)fetchUserInfoWithUsername:(NSString *)username {
    [AgoraChatClient.sharedClient.userInfoManager fetchUserInfoById:@[username] completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
        if (aError == nil) {
            self.userInfo = aUserDatas[username];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self placeAndlayoutSubviews];
                [self updateHeaderView];
                [self buildCells];
            });
        }
    }];
}

- (void)placeAndlayoutSubviews {
    [self addSubview:self.table];

    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(200.0f, 0, 0, 0));
    }];
    
}


- (void)updateHeaderView {
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:ImageWithName(@"avatat_2")];
    self.nameLabel.text = self.userInfo.nickName ?:self.userInfo.userId;
    [self.genderView updateWithGender:self.userInfo.gender birthday:self.userInfo.birth];
    
    
    self.roleImageView.hidden = self.roleType == ELDMemberRoleTypeMember ? YES :NO;
    if (self.roleType == ELDMemberRoleTypeOwner) {
        [self.roleImageView setImage:ImageWithName(@"live_streamer")];
    }
    
    if (self.roleType == ELDMemberRoleTypeAdmin) {
        [self.roleImageView setImage:ImageWithName(@"live_moderator")];
    }
  
    self.muteImageView.hidden = ![self isMute];
}


- (void)buildCells {
    NSMutableArray *tempArray = NSMutableArray.new;
    
    //owner check oneself
    if (self.chatroom.permissionType == AgoraChatroomPermissionTypeOwner) {
        if (self.roleType == ELDMemberRoleTypeOwner) {
            self.ownerSelf = YES;
            [tempArray addObject:@{kUserInfoCellTitle:@"Ban All"}];
        }else {
            [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];

        }
    }
    
    if (self.chatroom.permissionType == AgoraChatroomPermissionTypeAdmin) {
        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];

        
    }
    
    if (self.chatroom.permissionType == AgoraChatroomPermissionTypeMember) {
       
    }
        
    [self.table reloadData];
}

#pragma mark operation
//全体禁言
- (void)allTheSilence:(BOOL)isAllTheSilence
{
    if (isAllTheSilence) {
        [[AgoraChatClient sharedClient].roomManager muteAllMembersFromChatroom:self.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
//            if (aError == nil) {
//
//            }
        }];
    } else {
        [[AgoraChatClient sharedClient].roomManager unmuteAllMembersFromChatroom:self.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
//            if (aError == nil) {
//
//            }
        }];
    }
}

- (void)addAdminAction
{
    [[AgoraChatClient sharedClient].roomManager addAdmin:self.currentUsername
                                       toChatroom:self.chatroom.chatroomId
                                       completion:^(AgoraChatroom *aChatroomp, AgoraChatError *aError) {
                                           if (!aError) {
                                               
                                           } else {
                                              
                                           }
                                       }];
}

- (void)removeAdminAction {
    if (_chatroom) {
        ELD_WS
        [[AgoraChatClient sharedClient].roomManager removeAdmin:self.currentUsername
                                            fromChatroom:_chatroomId
                                              completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
                                                  if (!aError) {

                                                  } else {
//                                                      [weakHud setLabelText:aError.errorDescription];
                                                  }
                                              }];
    }
}



- (void)muteAction {
    [[AgoraChatClient sharedClient].roomManager muteMembers:@[self.currentUsername]
                                    muteMilliseconds:-1
                                        fromChatroom:self.chatroom.chatroomId
                                          completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
                                              if (!aError) {
                                                 
                                              } else {
                                                  
                                              }
                                          }];
}

//解除禁言
- (void)removeMuteAction
{
    ELD_WS
    [[AgoraChatClient sharedClient].roomManager unmuteMembers:@[self.currentUsername]
                                          fromChatroom:self.chatroomId
                                            completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
                                                if (!aError) {
                                                    
                                                
                                                } else {

                                                }
                                            }];
}




- (void)addBlockAction
{
    [[AgoraChatClient sharedClient].roomManager blockMembers:@[self.currentUsername]
                                         fromChatroom:self.chatroom.chatroomId
                                           completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
                                               if (!aError) {
                                                   
                                               } else {
                                                   
                                               }
                                           }];
}


- (void)unBlockAction {
    [[AgoraChatClient sharedClient].roomManager unblockMembers:@[self.currentUsername] fromChatroom:self.chatroom.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
            
    }];
    
}

- (void)addWhiteAction {
    [[AgoraChatClient sharedClient].roomManager addWhiteListMembers:@[self.currentUsername] fromChatroom:self.chatroom.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
            
    }];
}


//从白名单移除
- (void)removeWhiteAction
{
       [[AgoraChatClient sharedClient].roomManager removeWhiteListMembers:@[self.currentUsername]
                                           fromChatroom:self.chatroom.chatroomId
                                             completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
                                                 if (!aError) {
                                                     
                                                 } else {
                                                
                                                 }
                                             }];
}

- (void)kickAction
{
    [[AgoraChatClient sharedClient].roomManager removeMembers:@[self.currentUsername]
                                          fromChatroom:self.chatroom.chatroomId
                                            completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
                                                if (!aError) {
                                                    
                                                } else {
                                                   
                                                }
                                            }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:reusecellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusecellIndentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = NFont(14.0);
    }
    
    NSDictionary *dic = self.dataArray[indexPath.row];
    NSString *title = dic[kUserInfoCellTitle];
    
    if (self.ownerSelf) {
        self.titleSwitchCell.nameLabel.text = title;
        return self.titleSwitchCell;
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

- (UIView *)avatarBgView {
    if (_avatarBgView == nil) {
        _avatarBgView = [[UIView alloc] init];
        _avatarBgView.backgroundColor = UIColor.whiteColor;
        _avatarBgView.layer.cornerRadius = (kMeHeaderImageViewHeight + 2)* 0.5;
        
        [_avatarBgView addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_avatarBgView).insets(UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0));
        }];
    }
    return _avatarBgView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = NFont(16.0f);
        _nameLabel.textColor = TextLabelBlackColor;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.text = @"123";
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
        _table.backgroundColor = UIColor.redColor;
    }
    return _table;
}


- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 150.0)];
        
        UIView *headerBgView = UIView.alloc.init;
        headerBgView.layer.cornerRadius = 10.0f;
        headerBgView.backgroundColor = UIColor.whiteColor;
        [_headerView addSubview:headerBgView];
        
        [_headerView addSubview:self.avatarBgView];
        [_headerView addSubview:self.nameLabel];
        [_headerView addSubview:self.genderView];
        [_headerView addSubview:self.roleImageView];
        [_headerView addSubview:self.muteImageView];
        
        CGFloat topPadding = (kMeHeaderImageViewHeight + 2) * 0.5;
        
        [headerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerView).insets(UIEdgeInsetsMake(topPadding, 0, 0, 0));
        }];
        
        [self.avatarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView);
            make.centerX.equalTo(_headerView);
            make.size.equalTo(@(kMeHeaderImageViewHeight + 2));
        }];
                
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarBgView.mas_bottom).offset(15.0f);
            make.centerX.equalTo(self.avatarBgView).offset(-kEaseLiveDemoPadding);
            make.height.equalTo(@16.0);
        }];

        [self.genderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
        }];
                
        [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(7.0);
            make.centerX.equalTo(self.avatarImageView).offset(-kEaseLiveDemoPadding);
        }];
        
        [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.roleImageView);
            make.left.equalTo(self.roleImageView.mas_right).offset(5.0);
            make.bottom.equalTo(_headerView).offset(-kEaseLiveDemoPadding);
        }];
    }
    return _headerView;
}


- (ELDMemberRoleType)roleType {
    NSString *currentUserId = self.userInfo.userId;
    if ([self.chatroom.owner isEqualToString:currentUserId]) {
        return ELDMemberRoleTypeOwner;
    }else  if ([self.chatroom.adminList containsObject:currentUserId]) {
        return ELDMemberRoleTypeAdmin;
    }else {
        return ELDMemberRoleTypeMember;
    }
}

- (BOOL)isMute {
    return [self.chatroom.muteList containsObject:self.userInfo.userId];
}

- (ELDTitleSwitchCell *)titleSwitchCell {
    if (_titleSwitchCell == nil) {
        _titleSwitchCell = [[ELDTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ELDTitleSwitchCell reuseIdentifier]];
        _titleSwitchCell.selectionStyle = UITableViewCellSelectionStyleNone;
        ELD_WS
        _titleSwitchCell.switchActionBlock = ^(BOOL isOn) {
            [weakSelf allTheSilence:isOn];
        };
    }
    return _titleSwitchCell;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}

- (NSMutableDictionary *)actionTypeDic {
    if (_actionTypeDic == nil) {
        _actionTypeDic = NSMutableDictionary.new;
        
        _actionTypeDic[kMemberActionTypeMakeAdmin] = @{kUserInfoCellTitle:@"Assign as Moderator",kUserInfoCellActionType:@(ELDMemberActionTypeMakeAdmin)};
        _actionTypeDic[kMemberActionTypeRemoveAdmin] = @{kUserInfoCellTitle:@"Remove as Moderator",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveAdmin)};
        _actionTypeDic[kMemberActionTypeMakeMute] = @{kUserInfoCellTitle:@"Mute",kUserInfoCellActionType:@(ELDMemberActionTypeMakeMute)};
        _actionTypeDic[kMemberActionTypeRemoveMute] = @{kUserInfoCellTitle:@"Unmute",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveMute)};
        _actionTypeDic[kMemberActionTypeMakeWhite] = @{kUserInfoCellTitle:@"Move to Allowed List",kUserInfoCellActionType:@(ELDMemberActionTypeMakeWhite)};
        _actionTypeDic[kMemberActionTypeRemoveWhite] = @{kUserInfoCellTitle:@"Remove from Allowed List",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveWhite)};
        _actionTypeDic[kMemberActionTypeMakeBlock] = @{kUserInfoCellTitle:@"Ban",kUserInfoCellActionType:@(ELDMemberActionTypeMakeBlock)};
        _actionTypeDic[kMemberActionTypeRemoveBlock] = @{kUserInfoCellTitle:@"Unban",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveBlock)};

    }
    return _actionTypeDic;
}


@end

#undef kMeHeaderImageViewHeight
#undef kUserInfoCellTitle
#undef kUserInfoCellActionType
