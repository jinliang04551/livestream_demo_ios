//
//  ELDGenderView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/7.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDGenderView.h"
@interface ELDGenderView ()
@property (nonatomic, strong)UILabel *ageLabel;
@property (nonatomic, strong)UIImageView *genderImageView;
@property (nonatomic, strong)UIView *bgView;

@end


@implementation ELDGenderView
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
- (UILabel*)ageLabel
{
    if (_ageLabel == nil) {
        _ageLabel = [[UILabel alloc] init];
        _ageLabel.font = [UIFont systemFontOfSize:10.0f];
        _ageLabel.textColor = [UIColor whiteColor];
        _ageLabel.textAlignment = NSTextAlignmentLeft;
        _ageLabel.shadowColor = [UIColor blackColor];
        _ageLabel.shadowOffset = CGSizeMake(1, 1);
        _ageLabel.text = @"20";
    }
    return _ageLabel;
}


- (UIImageView *)genderImageView {
    if (_genderImageView == nil) {
        _genderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gender_male"]];
        _genderImageView.contentMode = UIViewContentModeScaleAspectFill;
        _genderImageView.layer.masksToBounds = YES;
    }
    return _genderImageView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 8.0;
        
        [_bgView addSubview:self.genderImageView];
        [_bgView addSubview:self.ageLabel];
        
        [self.genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bgView);
            make.left.equalTo(_bgView).offset(3.0);
        }];
        
        [self.ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bgView);
            make.left.equalTo(self.genderImageView.mas_right).offset(3.0);
        }];
    }
    return _bgView;
}

@end
