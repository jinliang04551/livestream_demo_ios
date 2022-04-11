//
//  ELDLiveroomMemberContainerViewController.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/8.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDLiveroomMembersContainerViewController : UIViewController
- (instancetype)initWithChatroom:(AgoraChatroom *)aChatroom;
- (void)showFromParentView:(UIView *)view;
- (void)removeFromParentView;

@end

NS_ASSUME_NONNULL_END
