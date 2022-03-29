//
//  ELDPreLivingView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/29.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDPreLivingView.h"

@interface ELDPreLivingView ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *changeAvatarButton;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UILabel *flipHintLabel;
@property (nonatomic, strong) UIButton *goLiveButton;

@end

@implementation ELDPreLivingView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    UIView *headerBgView = [[UIView alloc] init];
    headerBgView.backgroundColor = UIColor.grayColor;
    headerBgView.alpha = 0.5;
    
    [headerBgView addSubview:self.changeAvatarButton];
    [headerBgView addSubview:self.editButton];

    [self addSubview:self.closeButton];
    [self addSubview:headerBgView];
    [self addSubview:self.flipButton];
    [self addSubview:self.goLiveButton];
    [self addSubview:self.roomNameLabel];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kEaseLiveDemoPadding * 2.6);
        make.right.equalTo(self).offset(-kEaseLiveDemoPadding * 1.6);
        make.size.equalTo(@14.0);
    }];

    
    [headerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.closeButton).offset(kEaseLiveDemoPadding * 2.6);
        make.left.equalTo(self).offset(kEaseLiveDemoPadding * 1.6);
        make.right.equalTo(self).offset(-kEaseLiveDemoPadding * 1.6);

    }];
    
    [self.changeAvatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerBgView).offset(8.0);
        make.left.equalTo(headerBgView).offset(8.0);
        make.bottom.equalTo(headerBgView).offset(-8.0);
        make.size.equalTo(@84.0);
    }];
    
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-kEaseLiveDemoPadding * 1.6);
        make.right.equalTo(self).offset(-kEaseLiveDemoPadding * 1.6);
        make.size.equalTo(@14.0);
    }];
    
    [self.flipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.flipHintLabel.mas_top).offset(14.0);
    }];
    
    [self.flipHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@17.0);
        make.height.equalTo(@12.0);
        make.bottom.equalTo(self.goLiveButton.mas_top).offset(26.0);
    }];

    
    [self.goLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@48.0);
        make.left.equalTo(self).offset(kEaseLiveDemoPadding * 4.8);
        make.right.equalTo(self).offset(-kEaseLiveDemoPadding * 4.8);
        make.bottom.equalTo(self).offset(62.0);
    }];
    
}

#pragma mark action
- (void)closeAction {
    
}

- (void)changeAvatarAction {
    
}

- (void)editAction {
    
}

- (void)flipAction {
    
}

- (void)goLiveAction {
    
}

#pragma mark gette and setter
- (UIButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.layer.cornerRadius = 35;
    }
    return _closeButton;
}

- (UIButton *)changeAvatarButton
{
    if (_changeAvatarButton == nil) {
        _changeAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeAvatarButton setImage:[UIImage imageNamed:@"strat_live_stream"] forState:UIControlStateNormal];
        [_changeAvatarButton addTarget:self action:@selector(changeAvatarAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeAvatarButton;
}

- (UIButton *)editButton
{
    if (_editButton == nil) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"Live_edit_name"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)flipButton
{
    if (_flipButton == nil) {
        _flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flipButton setImage:[UIImage imageNamed:@"camera_flip"] forState:UIControlStateNormal];
        [_flipButton addTarget:self action:@selector(flipAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flipButton;
}

- (UIButton *)goLiveButton
{
    if (_goLiveButton == nil) {
        _goLiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goLiveButton setImage:[UIImage imageNamed:@"goLive_button_bg"] forState:UIControlStateNormal];
        [_goLiveButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goLiveButton;
}


- (UILabel *)roomNameLabel {
    if (_roomNameLabel == nil) {
        _roomNameLabel = UILabel.new;
        _roomNameLabel.textColor = COLOR_HEX(0xFFFFFF);
        _roomNameLabel.font = NFont(16.0);
        _roomNameLabel.textAlignment = NSTextAlignmentLeft;
        _roomNameLabel.text = @"Start your Livestream!";
    }
    return _roomNameLabel;
}

- (UILabel *)flipHintLabel {
    if (_flipHintLabel == nil) {
        _flipHintLabel = UILabel.new;
        _flipHintLabel.textColor = COLOR_HEX(0xFFFFFF);
        _flipHintLabel.font = NFont(10.0);
        _flipHintLabel.textAlignment = NSTextAlignmentCenter;
        _flipHintLabel.text = @"Start your Livestream!";
    }
    return _flipHintLabel;
}

@end
