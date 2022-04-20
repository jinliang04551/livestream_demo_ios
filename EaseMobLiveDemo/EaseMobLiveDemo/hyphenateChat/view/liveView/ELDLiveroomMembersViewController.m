//
//  ELDLiveroomMemberAllViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/8.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDLiveroomMembersViewController.h"
#import "ELDLiveroomMemberCell.h"

@interface ELDLiveroomMembersViewController ()

@property (nonatomic, strong) AgoraChatroom *chatroom;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) ELDMemberVCType memberVCType;
@end



@implementation ELDLiveroomMembersViewController
- (instancetype)initWithChatroom:(AgoraChatroom *)aChatroom withMemberType:(ELDMemberVCType)memberVCType {
    self = [super init];
    if (self) {
        self.chatroom = aChatroom;
        self.memberVCType = memberVCType;
    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDatas];
}

- (void)placeSubViews {
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadDatas {
    
    NSMutableArray *tempArray = NSMutableArray.new;
    
    switch (self.memberVCType) {
        case 1:
        {
            [tempArray addObject:self.chatroom.owner];
            if (self.chatroom.adminList.count > 0) {
                [tempArray addObjectsFromArray:self.chatroom.adminList];
            }
            if (self.chatroom.memberList.count > 0) {
                [tempArray addObjectsFromArray:self.chatroom.memberList];
            }
        }
            break;
        case 2:
        {
            [tempArray addObject:self.chatroom.owner];
            if (self.chatroom.adminList.count > 0) {
                [tempArray addObjectsFromArray:self.chatroom.adminList];
            }
        }
            break;
        case 3:
        {
            if (self.chatroom.whitelist.count > 0) {
                [tempArray addObjectsFromArray:self.chatroom.whitelist];
            }
        }
            break;

        case 4:
        {
            if (self.chatroom.muteList.count > 0) {
                [tempArray addObjectsFromArray:self.chatroom.muteList];
            }
        }
            break;

        case 5:
        {
            if (self.chatroom.blacklist.count > 0) {
                [tempArray addObject:self.chatroom.blacklist];
            }
        }
            break;

        default:
        {
            [tempArray addObject:self.chatroom.owner];
            if (self.chatroom.adminList) {
                [tempArray addObjectsFromArray:self.chatroom.adminList];
            }
            if (self.chatroom.memberList) {
                [tempArray addObjectsFromArray:self.chatroom.memberList];
            }
        }
            break;
    }
    
    NSLog(@"tempArray:%@ vcType:%@",tempArray,@(self.memberVCType));
    
    [AgoraChatUserInfoManagerHelper fetchUserInfoWithUserIds:tempArray completion:^(NSDictionary * _Nonnull userInfoDic) {
        NSMutableArray *userInfos = NSMutableArray.new;
        for (NSString *key in userInfoDic.allKeys) {
            AgoraChatUserInfo *uInfo = userInfoDic[key];
            [userInfos addObject:uInfo];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataArray removeAllObjects];
            self.dataArray = userInfos;
            NSLog(@"self.type:%@ self.dataArray:%@",@(self.memberVCType),self.dataArray);
            [self.table reloadData];
        });
    }];
    
}

#pragma mark public method
- (void)updateUIWithChatroom:(AgoraChatroom *)chatroom {
    self.chatroom = chatroom;
    [self loadDatas];
    [self.table reloadData];
}

#pragma mark refresh and load more
- (void)didStartRefresh {
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didStartLoadMore {
    [self tableViewDidTriggerFooterRefresh];
}


#pragma mark NSNotification
- (void)updateGroupMemberWithNotification:(NSNotification *)aNotification {
//    NSDictionary *dic = (NSDictionary *)aNotification.object;
//    NSString* groupId = dic[kACDGroupId];
//    ACDGroupMemberListType type = [dic[kACDGroupMemberListType] integerValue];
//
//    if (![self.group.groupId isEqualToString:groupId] || type != ACDGroupMemberListTypeBlock) {
//        return;
//    }
    
    [self tableViewDidTriggerHeaderRefresh];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ELDLiveroomMemberCell height];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ELDLiveroomMemberCell *cell = (ELDLiveroomMemberCell *)[tableView dequeueReusableCellWithIdentifier:[ELDLiveroomMemberCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ELDLiveroomMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ELDLiveroomMemberCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.chatroom = self.chatroom;
    AgoraChatUserInfo *userInfo = self.dataArray[indexPath.row];

    [cell updateWithObj:userInfo];
    
    ELD_WS
    cell.tapCellBlock = ^{
        if (self.selectedUserBlock) {
            self.selectedUserBlock(userInfo.userId, self.memberVCType);
        }
        
    };
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    
    BOOL isAdmin = (self.chatroom.permissionType == AgoraChatGroupPermissionTypeOwner ||self.chatroom.permissionType == AgoraChatGroupPermissionTypeAdmin);
    if (!isAdmin) {
        return;
    }
    
    self.page = 1;
    [self fetchBlocksWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchBlocksWithPage:self.page isHeader:NO];
}

- (void)fetchBlocksWithPage:(NSInteger)aPage
                 isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
//    ACD_WS

//    [[AgoraChatClient sharedClient].groupManager getGroupBlacklistFromServerWithId:self.group.groupId pageNumber:self.page pageSize:pageSize completion:^(NSArray *aMembers, AgoraChatError *aError) {
//
//        [self endRefresh];
//        if (!aError) {
//            [self updateUIWithResultList:aMembers IsHeader:aIsHeader];
//        } else {
//            NSString *errorStr = [NSString stringWithFormat:NSLocalizedString(@"group.ban.fetchFail", @"Fail to get blacklist: %@"), aError.errorDescription];
//            [weakSelf showHint:errorStr];
//        }
//
//        if ([aMembers count] < pageSize) {
//            [self endLoadMore];
//        } else {
//            [self useLoadMore];
//        }
//    }];
    
    
}

#pragma mark gette and setter


@end
