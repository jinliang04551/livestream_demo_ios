//
//  ELDCountCaculateView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/13.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDCountCaculateView.h"

#define kPlusButtonHeight 36.0f

@interface ELDCountCaculateView ()

@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) UIButton *minusButton;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, assign) NSInteger giftCount;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation ELDCountCaculateView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.giftCount = 1;
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {

    self.backgroundColor = UIColor.yellowColor;
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
//    [self addSubview:self.bgImageView];
    [self addSubview:self.minusButton];
    [self addSubview:self.countLabel];
    [self addSubview:self.plusButton];
    
//    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self).insets(UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0));
//    }];
    
    [self.minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(kPlusButtonHeight));
        make.left.equalTo(self).offset(5.0);
        make.right.equalTo(self.countLabel.mas_left).offset(-10.0);
        make.centerY.equalTo(self.countLabel);
    }];

    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.width.equalTo(@(24.0));
    }];

    [self.plusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.minusButton);
        make.centerY.equalTo(self.countLabel);
        make.left.equalTo(self.countLabel.mas_right).offset(10.0);
        make.right.equalTo(self).offset(-5.0);
    }];
    
}

#pragma mark action
- (void)tapAction {
    NSLog(@"%s",__func__);
    
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)minusButtonAction {
    self.giftCount--;
    if (self.giftCount <= 0) {
        self.giftCount = 0;
    }
    
    if (self.countBlock) {
        self.countBlock(self.giftCount);
    }
    
    self.countLabel.text = [@(self.giftCount) stringValue];
}

- (void)plusButtonAction {
    self.giftCount++;
    if (self.giftCount >= 99) {
        self.giftCount = 99;
    }
    
    if (self.countBlock) {
        self.countBlock(self.giftCount);
    }
    self.countLabel.text = [@(self.giftCount) stringValue];
}



#pragma mark getter and setter
- (UIButton *)plusButton {
    if (_plusButton == nil) {
        _plusButton = [[UIButton alloc]init];
        [_plusButton setTitle:@"+" forState:UIControlStateNormal];
        [_plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _plusButton.titleLabel.font = NFont(14.0f);
        [_plusButton addTarget:self action:@selector(plusButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _plusButton.backgroundColor = UIColor.blueColor;

    }
    return _plusButton;
}

- (UIButton *)minusButton {
    if (_minusButton == nil) {
        _minusButton = [[UIButton alloc]init];
        [_minusButton setTitle:@"-" forState:UIControlStateNormal];
        [_minusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _minusButton.titleLabel.font = NFont(14.0f);
        [_minusButton addTarget:self action:@selector(minusButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _minusButton.backgroundColor = UIColor.blueColor;
        
    }
    return _minusButton;
}

- (UILabel *)countLabel {
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = NFont(14.0f);
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.text = [@(self.giftCount) stringValue];
        _countLabel.backgroundColor = UIColor.redColor;
    }
    return _countLabel;
}

- (UIImageView *)bgImageView {
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"caculate_bg")];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.layer.masksToBounds = YES;
    }
    return _bgImageView;
}


- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}


@end

#undef kPlusButtonHeight
