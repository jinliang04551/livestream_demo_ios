//
//  ELDLiveroomMemberAllViewController.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/8.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELDContainerTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELDLiveroomMembersViewController : ELDContainerTableViewController

- (instancetype)initWithChatroom:(AgoraChatroom *)aChatroom;

@end

NS_ASSUME_NONNULL_END
