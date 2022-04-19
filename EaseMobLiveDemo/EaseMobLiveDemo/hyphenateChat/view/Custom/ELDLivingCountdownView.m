//
//  ELDLivingCountdownView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/7.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDLivingCountdownView.h"

@interface ELDLivingCountdownView ()
@property (nonatomic, strong)UILabel *countLabel;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger maxCountDown;

@end


@implementation ELDLivingCountdownView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = UIColor.whiteColor;
        [self addSubview:bgView];
        [bgView addSubview:self.countLabel];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(bgView);
            make.top.bottom.equalTo(self);
            make.centerX.centerY.equalTo(self);
            make.height.equalTo(@80);
        }];
        
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
}

- (void)updateCountLabel {
    NSLog(@"%s self.maxCountDown:%@",__func__,@(self.maxCountDown));
    self.countLabel.text = [@(self.maxCountDown) stringValue];
    self.maxCountDown--;
    if (self.maxCountDown <= 0) {
        [self stopCountDown];
    }
}


- (void)startCountDown {
    self.maxCountDown = 3;
    [self startTimer];
}

- (void)stopCountDown {
    [self stopTimer];
    if (self.CountDownFinishBlock) {
        self.CountDownFinishBlock();
    }
}

#pragma mark getter and setter
- (UILabel *)countLabel {
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = NFont(72.0);
        _countLabel.textColor = TextLabelWhiteColor;
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _countLabel;
}

- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateCountLabel) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
    
@end
