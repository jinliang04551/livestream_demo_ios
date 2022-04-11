//
//  ELDLiveroomMemberAllViewController.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/8.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELDContainerTableViewController.h"

typedef enum : NSUInteger {
    ELDMemberVCTypeAll = 1,
    ELDMemberVCTypeAdmin,
    ELDMemberVCTypeAllow,
    ELDMemberVCTypeMute,
    ELDMemberVCTypeBlock,
} ELDMemberVCType;

NS_ASSUME_NONNULL_BEGIN

@interface ELDLiveroomMembersViewController : ELDContainerTableViewController

- (instancetype)initWithChatroom:(AgoraChatroom *)aChatroom withMemberType:(ELDMemberVCType)memberVCType;

@end

NS_ASSUME_NONNULL_END
