//
//  ELDLiveroomMemberCell.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/8.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDLiveroomMemberCell.h"
@interface ELDLiveroomMemberCell ()
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UIImageView *roleImageView;
@property (nonatomic, strong) AgoraChatUserInfo *userInfo;

@end



@implementation ELDLiveroomMemberCell

- (void)prepare {
    
    self.nameLabel.textColor = COLOR_HEX(0x0D0D0D);
    self.nameLabel.font = NFont(14.0f);
    self.contentView.backgroundColor = UIColor.whiteColor;
    
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.roleImageView];
    [self.contentView addSubview:self.muteImageView];
}


- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12.0f);
        make.size.mas_equalTo(kAvatarHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kEaseLiveDemoPadding);
        make.width.lessThanOrEqualTo(@100);
    }];
    
    [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.nameLabel.mas_right).offset(10.0);
    }];
    
    [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.roleImageView.mas_right).offset(10.0);
    }];
}


- (void)updateWithObj:(id)obj {
    self.userInfo = (AgoraChatUserInfo *)obj;
  
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:kDefultUserImage];
    
    self.nameLabel.text = self.userInfo.nickName ?: self.userInfo.userId;

    if ([self.userInfo.userId isEqualToString:self.chatroom.owner]) {
        [self.roleImageView setImage:ImageWithName(@"live_streamer")];
    }else if ([self.chatroom.adminList containsObject:self.userInfo.userId]){
        [self.roleImageView setImage:ImageWithName(@"live_moderator")];
    }else {
        [self.roleImageView setImage:ImageWithName(@"")];
    }
    
    
    if ([self.chatroom.muteList containsObject:self.userInfo.userId]) {
        self.muteImageView.hidden = NO;
    }else {
        self.muteImageView.hidden = YES;
    }
    
}


#pragma mark getter and setter
- (UIImageView *)muteImageView {
    if (_muteImageView == nil) {
        _muteImageView = [[UIImageView alloc] init];
        _muteImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_muteImageView setImage:ImageWithName(@"member_mute_icon")];
    }
    return _muteImageView;
}

- (UIImageView *)roleImageView {
    if (_roleImageView == nil) {
        _roleImageView = [[UIImageView alloc] init];
        _roleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _roleImageView;
}


@end
