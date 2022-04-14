//
//  ELDWatchMemberAvatarsView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDWatchMemberAvatarsView : UIView
@property (nonatomic, strong) UIImageView *firstMemberImageView;
@property (nonatomic, strong) UIImageView *secondMemberImageView;

- (void)updateWatchersAvatarWithUserIds:(NSArray *)userIds;

@end

NS_ASSUME_NONNULL_END
