//
//  ELDContactView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseSubView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELDUserInfoView : EaseBaseSubView

- (instancetype)initWithUsername:(NSString *)username
                        chatroom:(AgoraChatroom *)chatroom;

@end

NS_ASSUME_NONNULL_END
