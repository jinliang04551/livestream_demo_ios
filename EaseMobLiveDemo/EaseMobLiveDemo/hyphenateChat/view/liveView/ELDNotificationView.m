//
//  ELDNotificationView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/20.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDNotificationView.h"

#define kBgViewWidth 30.0
#define kBgViewHeight 16.0

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
        make.edges.equalTo(self);
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
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = GenderSecretBgColor;
        
        [_bgView addSubview:self.iconImageView];
        [_bgView addSubview:self.contentLabel];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bgView);
            make.left.equalTo(_bgView).offset(3.0);
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

