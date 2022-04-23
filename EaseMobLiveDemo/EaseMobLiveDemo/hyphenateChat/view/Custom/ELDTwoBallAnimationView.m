//
//  ELDTwoBallAnimationView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/23.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDTwoBallAnimationView.h"
#import "TwoBallRotationProgressBar.h"

@interface ELDTwoBallAnimationView ()
@property (nonatomic, strong) TwoBallRotationProgressBar *progressBar;

@end


@implementation ELDTwoBallAnimationView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.redColor;
        [self placeAndLayoutSubviews];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    [self addSubview:self.progressBar];
    
    [self.progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}

#pragma mark animation
- (void)startAnimation {
    [self.progressBar startAnimator];
}

- (void)stopAnimation {
    [self.progressBar stopAnimator];
}

    
#pragma mark getter and setter
- (TwoBallRotationProgressBar *)progressBar {
    if (_progressBar == nil) {
        _progressBar = [[TwoBallRotationProgressBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30.0)];
        [_progressBar setOneBallColor:UIColor.blueColor twoBallColor:UIColor.yellowColor];
        [_progressBar setBallRadius:6];
        [_progressBar setAnimatorDuration:0.5];
        _progressBar.backgroundColor = UIColor.grayColor;
    }
    return _progressBar;
}


@end



