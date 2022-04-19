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
#import "ELDTitleDetailCell.h"

#define kUserInfoCellTitle @"kUserInfoCellTitle"
#define kUserInfoCellActionType @"kUserInfoCellActionType"
#define kUserInfoAlertTitle @"kUserInfoAlertTitle"


@interface ELDUserInfoView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) ELDUserInfoHeaderView *headerView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) ELDTitleSwitchCell *muteCell;

@property (nonatomic, strong) AgoraChatUserInfo *userInfo;
@property (nonatomic, strong) NSString *currentUsername;
@property (nonatomic, strong) AgoraChatroom *chatroom;
@property (nonatomic, strong) NSString *chatroomId;
@property (nonatomic, assign) ELDMemberRoleType beOperationedMemberRoleType;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableDictionary *actionTypeDic;

//owner check oneself
@property (nonatomic, assign) BOOL ownerSelf;

//whether isMute
@property (nonatomic, assign) BOOL isMute;


@property (nonatomic, assign) ELDMemberVCType memberVCType;

@property (nonatomic, strong) NSString *displayName;

@end


@implementation ELDUserInfoView
- (instancetype)initWithUsername:(NSString *)username
                        chatroom:(AgoraChatroom *)chatroom
                    memberVCType:(ELDMemberVCType)memberVCType {
    self = [super init];
    if (self) {
        
        self.currentUsername = username;
        self.chatroom = chatroom;
        self.chatroomId = self.chatroom.chatroomId;
        self.memberVCType = memberVCType;

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
            self.beOperationedMemberRoleType = ELDMemberRoleTypeOwner;
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
                [self.headerView updateUIWithUserInfo:self.userInfo roleType:self.beOperationedMemberRoleType isMute:self.isMute];
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
            if (self.beOperationedMemberRoleType == ELDMemberRoleTypeOwner) {
                self.ownerSelf = YES;
                [tempArray addObject:@{kUserInfoCellTitle:@"Ban All"}];
            }else if(self.beOperationedMemberRoleType == ELDMemberRoleTypeAdmin){
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveAdmin]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
            }else {
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeAdmin]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
            }
        }
        
        if (self.chatroom.permissionType == AgoraChatroomPermissionTypeAdmin) {
            if (self.beOperationedMemberRoleType == ELDMemberRoleTypeOwner || self.beOperationedMemberRoleType == ELDMemberRoleTypeAdmin) {
                // no operate permission
            }else {
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeAdmin]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
            }
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
                                       completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                       }];
}

- (void)removeAdminAction {
    if (_chatroom) {
        ELD_WS
        [[AgoraChatClient sharedClient].roomManager removeAdmin:self.currentUsername
                                            fromChatroom:_chatroomId
                                              completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
                [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
            }
                                              }];
    }
}



- (void)addMuteAction {
    [[AgoraChatClient sharedClient].roomManager muteMembers:@[self.currentUsername]
                                    muteMilliseconds:-1
                                        fromChatroom:self.chatroom.chatroomId
                                          completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
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
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                            }];
}




- (void)addBlockAction
{
    [[AgoraChatClient sharedClient].roomManager blockMembers:@[self.currentUsername]
                                         fromChatroom:self.chatroom.chatroomId
                                           completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                           }];
}


- (void)removeBlockAction {
    [[AgoraChatClient sharedClient].roomManager unblockMembers:@[self.currentUsername] fromChatroom:self.chatroom.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }

    }];
    
}

- (void)addWhiteAction {
    [[AgoraChatClient sharedClient].roomManager addWhiteListMembers:@[self.currentUsername] fromChatroom:self.chatroom.chatroomId completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }

    }];
}


//从白名单移除
- (void)removeWhiteAction
{
[[AgoraChatClient sharedClient].roomManager removeWhiteListMembers:@[self.currentUsername]
                                           fromChatroom:self.chatroom.chatroomId
                                             completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
    if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
        [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
    }
                                             }];
}

- (void)kickAction
{
    [[AgoraChatClient sharedClient].roomManager removeMembers:@[self.currentUsername]
                                                 fromChatroom:self.chatroom.chatroomId
                                                   completion:^(AgoraChatroom *aChatroom, AgoraChatError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError];
        }
                                            }];
}




- (void)confirmActionWithActionType:(ELDMemberActionType)actionType {
    switch (actionType) {
        case ELDMemberActionTypeMakeAdmin:
        {
            [self addAdminAction];
        }
            break;
        case ELDMemberActionTypeRemoveAdmin:
        {
            [self removeAdminAction];
        }
            break;
        case ELDMemberActionTypeMakeMute:
        {
            [self addMuteAction];
        }
            break;
        case ELDMemberActionTypeRemoveMute:
        {
            [self removeMuteAction];
        }
            break;

        case ELDMemberActionTypeMakeWhite:
        {
            [self addWhiteAction];
        }
            break;
        case ELDMemberActionTypeRemoveWhite:
        {
            [self removeWhiteAction];
        }
            break;
        case ELDMemberActionTypeMakeBlock:
        {
            [self addBlockAction];
        }
            break;
        case ELDMemberActionTypeRemoveBlock:
        {
            [self removeBlockAction];
        }
            break;

        default:
            break;
    }
    
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ELDTitleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[ELDTitleDetailCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ELDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ELDTitleDetailCell reuseIdentifier]];
        cell.contentView.backgroundColor = ViewControllerBgWhiteColor;
        cell.backgroundColor = ViewControllerBgWhiteColor;

        cell.nameLabel.font = NFont(14.0);
        cell.nameLabel.textColor = TextLabelBlackColor;
    }

    NSDictionary *dic = self.dataArray[indexPath.row];
    NSString *title = dic[kUserInfoCellTitle];
    NSString *alertTitle = dic[kUserInfoAlertTitle];
    NSInteger actionType = [dic[kUserInfoCellActionType] integerValue];

    if (self.ownerSelf) {
        self.muteCell.nameLabel.text = title;
        return self.muteCell;
    }else {
        cell.nameLabel.text = title;
        
        cell.tapCellBlock = ^{
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(showAlertWithTitle:messsage:actionType:)]) {
                [self.userInfoViewDelegate showAlertWithTitle:alertTitle messsage:@"" actionType:actionType];
            }
        };
    }
    
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

- (ELDMemberRoleType)beOperationedMemberRoleType {
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

- (ELDTitleSwitchCell *)muteCell {
    if (_muteCell == nil) {
        _muteCell = [[ELDTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ELDTitleSwitchCell reuseIdentifier]];
        _muteCell.selectionStyle = UITableViewCellSelectionStyleNone;
        ELD_WS
        _muteCell.switchActionBlock = ^(BOOL isOn) {
            [weakSelf allTheSilence:isOn];
        };
    }
    return _muteCell;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}


//解禁：Want to unban Username?  添加白名单：Want to Move Username From the Allowed List? 从白名单移出：Want to Remove Username From the Allowed List? 设定管理员：Want to Move Username as a Moderator? 罢免管理员：Want to Remove Username as Moderator?

- (NSMutableDictionary *)actionTypeDic {
    if (_actionTypeDic == nil) {
        _actionTypeDic = NSMutableDictionary.new;
        
        _actionTypeDic[kMemberActionTypeMakeAdmin] = @{kUserInfoCellTitle:@"Assign as Moderator",kUserInfoCellActionType:@(ELDMemberActionTypeMakeAdmin),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Move %@ as a Moderator?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveAdmin] = @{kUserInfoCellTitle:@"Remove as Moderator",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveAdmin),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Remove %@ as Moderator?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeMute] = @{kUserInfoCellTitle:@"Mute",kUserInfoCellActionType:@(ELDMemberActionTypeMakeMute),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Mute %@?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveMute] = @{kUserInfoCellTitle:@"Unmute",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveMute),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Unmute %@?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeWhite] = @{kUserInfoCellTitle:@"Move to Allowed List",kUserInfoCellActionType:@(ELDMemberActionTypeMakeWhite),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Move %@ From the Allowed List?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveWhite] = @{kUserInfoCellTitle:@"Remove from Allowed List",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveWhite),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Remove %@ From the Allowed List?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeBlock] = @{kUserInfoCellTitle:@"Ban",kUserInfoCellActionType:@(ELDMemberActionTypeMakeBlock),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Ban %@?",self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveBlock] = @{kUserInfoCellTitle:@"Unban",kUserInfoCellActionType:@(ELDMemberActionTypeRemoveBlock),kUserInfoAlertTitle:[NSString stringWithFormat:@"Want to Unban %@?",self.displayName]};

    }
    return _actionTypeDic;
}

- (NSString *)displayName {
    if (self.userInfo) {
        return self.userInfo.nickName ?: self.userInfo.userId;
    }
    return @"";
}


@end

#undef kUserInfoCellTitle
#undef kUserInfoCellActionType
#undef kUserInfoAlertTitle

