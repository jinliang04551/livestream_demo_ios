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
#import "ELDUserInfoHeaderView.h"

#define kUserInfoCellTitle @"kUserInfoCellTitle"
#define kUserInfoCellActionType @"kUserInfoCellActionType"


static NSString *reusecellIndentify = @"reusecellIndentify";

@interface ELDUserInfoView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) ELDUserInfoHeaderView *headerView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) ELDTitleSwitchCell *titleSwitchCell;

@property (nonatomic, strong) AgoraChatUserInfo *userInfo;
@property (nonatomic, strong) NSString *currentUsername;
@property (nonatomic, strong) AgoraChatroom *chatroom;
@property (nonatomic, strong) NSString *chatroomId;
@property (nonatomic, assign) ELDMemberRoleType roleType;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableDictionary *actionTypeDic;

//owner check oneself
@property (nonatomic, assign) BOOL ownerSelf;

//whether isMute
@property (nonatomic, assign) BOOL isMute;


@property (nonatomic, assign) ELDMemberVCListType memberVCListType;


@end


@implementation ELDUserInfoView
- (instancetype)initWithUsername:(NSString *)username
                        chatroom:(AgoraChatroom *)chatroom
                memberVCListType:(ELDMemberVCListType)memberVCListType {
    self = [super init];
    if (self) {
        
        self.currentUsername = username;
        self.chatroom = chatroom;
        self.chatroomId = self.chatroom.chatroomId;
        self.memberVCListType = memberVCListType;

        [self placeAndlayoutSubviews];
        [self fetchUserInfoWithUsername:username];
     
    }
    return self;
}

- (instancetype)initWithOwnerId:(NSString *)ownerId
                       chatroom:(AgoraChatroom *)chatroom {
    self = [super init];
    if (self) {
        self.currentUsername = ownerId;
        self.chatroom = chatroom;
        
        if ([AgoraChatClient.sharedClient.currentUsername isEqualToString:ownerId]) {
            self.ownerSelf = YES;
            self.roleType = ELDMemberRoleTypeOwner;
            self.isMute = NO;
        }
        
        [self placeAndlayoutSubviews];
        [self fetchUserInfoWithUsername:self.currentUsername];
     
    }
    return self;
}


- (void)fetchUserInfoWithUsername:(NSString *)username {
    [AgoraChatClient.sharedClient.userInfoManager fetchUserInfoById:@[username] completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
        if (aError == nil) {
            self.userInfo = aUserDatas[username];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.headerView updateUIWithUserInfo:self.userInfo roleType:self.roleType isMute:self.isMute];
                [self buildCells];
                
            });
        }
    }];
}

- (void)placeAndlayoutSubviews {
    [self addSubview:self.table];

    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kChatViewHeight);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-[self bottomPadding]);
    }];
}


- (void)buildCells {
    NSMutableArray *tempArray = NSMutableArray.new;

    if (self.ownerSelf) {
        [tempArray addObject:@{kUserInfoCellTitle:@"Ban All"}];
    }else {
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
           // no operate permission
        }
    }

    self.dataArray = tempArray;
    [self.table reloadData];
}


#pragma mark operation
//全体禁言
- (void)allTheSilence:(BOOL)isAllTheSilence
{
    if (isAllTheSilence) {
        [[AgoraChatClient sharedClient].roomManager muteAllMembersFromChatroom:self.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
            if (aError == nil) {
                
            }
        }];
    } else {
        [[AgoraChatClient sharedClient].roomManager unmuteAllMembersFromChatroom:self.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
            if (aError == nil) {

            }
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
        _table.tableHeaderView = [self headerView];
        _table.backgroundColor = UIColor.redColor;
    }
    return _table;
}


- (ELDUserInfoHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[ELDUserInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 150.0)];
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

#undef kUserInfoCellTitle
#undef kUserInfoCellActionType
