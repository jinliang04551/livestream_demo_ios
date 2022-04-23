//
//  ELDNotificationView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/20.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDNotificationView.h"

#define kBgViewWidth 30.0
#define kBgViewHeight 24.0

@interface ELDNotificationView ()
@property (nonatomic, strong)UILabel *contentLabel;
@property (nonatomic, strong)UIImageView *iconImageView;
@property (nonatomic, strong)UIView *bgView;

@end


@implementation ELDNotificationView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12.0);
        make.centerY.equalTo(self);
        make.height.equalTo(@(kBgViewHeight));
    }];
}


#pragma mark getter and setter
- (UILabel*)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:12.0];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.shadowColor = [UIColor blackColor];
        _contentLabel.shadowOffset = CGSizeMake(1, 1);
        _contentLabel.text = @"Streamer has set Banned on all Chats";
    }
    return _contentLabel;
}


- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_notify"]];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _iconImageView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth - 12 * 2, kBgViewHeight)];
        _bgView.layer.cornerRadius = kBgViewHeight * 0.5;

        [_bgView addTransitionColorLeftToRight:COLOR_HEX(0x0148FE) endColor:COLOR_HEX(0x02C3EC)];
        
        
        [_bgView addSubview:self.iconImageView];
        [_bgView addSubview:self.contentLabel];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bgView);
            make.left.equalTo(_bgView).offset(3.0);
            make.size.equalTo(@(10.0));
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bgView);
            make.left.equalTo(self.iconImageView.mas_right).offset(3.0);
            make.right.equalTo(_bgView).offset(-2.0);
        }];
    }
    return _bgView;
}

@end

#undef kBgViewWidth
#undef kBgViewHeight

