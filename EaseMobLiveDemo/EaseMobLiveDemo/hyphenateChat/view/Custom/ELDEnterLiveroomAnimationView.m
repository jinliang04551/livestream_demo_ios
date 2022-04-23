//
//  ELDEnterLiveroomAnimationView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/21.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDEnterLiveroomAnimationView.h"

#define kIconMaxSize 20.0

@interface ELDEnterLiveroomAnimationView ()
@property (nonatomic, strong)UIImageView *blueImageView;
@property (nonatomic, strong)UIImageView *redImageView;

@property (nonatomic, strong)NSTimer *timer;

@end


@implementation ELDEnterLiveroomAnimationView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
}


- (void)placeAndLayoutSubviews {
    [self addSubview:self.blueImageView];
    [self addSubview:self.redImageView];

    [self.blueImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(10.0);
    }];
    
    [self.redImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.blueImageView.mas_right).offset(20.0);
        make.right.equalTo(self).offset(-10.0);
    }];
    
}

#pragma mark animation
- (void)startAnimation {
    [self.blueImageView startAnimating];
    [self.redImageView startAnimating];
}

- (void)stopAnimation {
    [self.blueImageView stopAnimating];
    [self.redImageView stopAnimating];
    [self removeFromSuperview];
}


- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startAnimation) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
    
#pragma mark getter and setter
- (UIImageView *)blueImageView {
    if (_blueImageView == nil) {
        _blueImageView = [[UIImageView alloc] init];
        _blueImageView.contentMode = UIViewContentModeScaleAspectFill;
        _blueImageView.animationImages = @[ImageWithName(@"bluepoint_small"),ImageWithName(@"bluepoint_large")];
        _blueImageView.animationDuration = 0.5;
        _blueImageView.animationRepeatCount = 0;
        _blueImageView.backgroundColor = UIColor.grayColor;
    }
    return _blueImageView;
}


- (UIImageView *)redImageView {
    if (_redImageView == nil) {
        _redImageView = [[UIImageView alloc] init];
        _redImageView.contentMode = UIViewContentModeScaleAspectFill;
        _redImageView.animationImages = @[ImageWithName(@"redpoint_large"),ImageWithName(@"redpoint_small")];
        _redImageView.animationDuration = 0.5;
        _redImageView.animationRepeatCount = 0;
    }
    return _redImageView;
}


@end

#undef kIconMaxSize


