//
//  ELDCountCaculateView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/13.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDCountCaculateView : UIView
@property (nonatomic, strong, readonly) UILabel *countLabel;
@property (nonatomic, copy) void(^countBlock)(NSInteger count);
@property (nonatomic, copy) void(^tapBlock)();

@end

NS_ASSUME_NONNULL_END
