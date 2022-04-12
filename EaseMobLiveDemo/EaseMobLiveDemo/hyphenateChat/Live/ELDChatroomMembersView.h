//
//  ELDChatroomMembersView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/12.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseSubView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELDChatroomMembersView : EaseBaseSubView
- (instancetype)initWithChatroom:(AgoraChatroom *)aChatroom;

- (void)showFromParentView:(UIView *)view;
- (void)removeFromParentView;



@end

NS_ASSUME_NONNULL_END
