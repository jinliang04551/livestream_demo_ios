//
//  ELDUserInfoHeaderView.m
//  EaseMobLiveDemo
//
//  Created by liang on 2022/4/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDUserInfoHeaderView.h"
#import "ELDGenderView.h"

#define kMeHeaderImageViewHeight 72.0

@interface ELDUserInfoHeaderView ()
@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *avatarBgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ELDGenderView *genderView;
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UIImageView *roleImageView;
@property (nonatomic, strong) AgoraChatUserInfo *userInfo;


@end

@implementation ELDUserInfoHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndlayoutSubviews];
    }
    return self;
}

- (void)placeAndlayoutSubviews {
      UIView *headerBgView = UIView.alloc.init;
      headerBgView.layer.cornerRadius = 10.0f;
      headerBgView.backgroundColor = UIColor.whiteColor;
      [self addSubview:headerBgView];

      [self addSubview:self.avatarBgView];
      [self addSubview:self.nameLabel];
      [self addSubview:self.genderView];
      [self addSubview:self.roleImageView];
      [self addSubview:self.muteImageView];

      CGFloat topPadding = (kMeHeaderImageViewHeight + 2) * 0.5;

      [headerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self).insets(UIEdgeInsetsMake(topPadding, 0, 0, 0));
      }];

      [self.avatarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self);
          make.centerX.equalTo(self);
          make.size.equalTo(@(kMeHeaderImageViewHeight + 2));
      }];

      [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.avatarBgView.mas_bottom).offset(15.0f);
          make.centerX.equalTo(self.avatarBgView).offset(-kEaseLiveDemoPadding);
          make.height.equalTo(@16.0);
      }];

      [self.genderView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(self.nameLabel);
          make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
      }];

      [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.nameLabel.mas_bottom).offset(7.0);
          make.centerX.equalTo(self.avatarImageView).offset(-kEaseLiveDemoPadding);
      }];

      [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(self.roleImageView);
          make.left.equalTo(self.roleImageView.mas_right).offset(5.0);
          make.bottom.equalTo(self).offset(-kEaseLiveDemoPadding);
      }];
    
}



- (void)updateUIWithUserInfo:(AgoraChatUserInfo *)userInfo
                    roleType:(ELDMemberRoleType)roleType
                      isMute:(BOOL)isMute {
    self.userInfo = userInfo;
    self.roleType = roleType;
    self.isMute = isMute;
    
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:ImageWithName(@"avatat_2")];
    self.nameLabel.text = self.userInfo.nickName ?:self.userInfo.userId;
    [self.genderView updateWithGender:self.userInfo.gender birthday:self.userInfo.birth];
    
    
    self.roleImageView.hidden = self.roleType == ELDMemberRoleTypeMember ? YES :NO;
    if (self.roleType == ELDMemberRoleTypeOwner) {
        [self.roleImageView setImage:ImageWithName(@"live_streamer")];
    }
    
    if (self.roleType == ELDMemberRoleTypeAdmin) {
        [self.roleImageView setImage:ImageWithName(@"live_moderator")];
    }
  
    self.muteImageView.hidden = !self.isMute;
}


#pragma mark getter and setter
- (UIImageView*)topBgImageView
{
    if (_topBgImageView == nil) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.image = [UIImage imageNamed:@"member_bg_top"];
        _topBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBgImageView.layer.masksToBounds = YES;
    }
    return _topBgImageView;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = kMeHeaderImageViewHeight * 0.5;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.backgroundColor = UIColor.greenColor;
    }
    return _avatarImageView;
}

- (UIView *)avatarBgView {
    if (_avatarBgView == nil) {
        _avatarBgView = [[UIView alloc] init];
        _avatarBgView.backgroundColor = UIColor.whiteColor;
        _avatarBgView.layer.cornerRadius = (kMeHeaderImageViewHeight + 2)* 0.5;
        
        [_avatarBgView addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_avatarBgView).insets(UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0));
        }];
    }
    return _avatarBgView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = NFont(16.0f);
        _nameLabel.textColor = TextLabelBlackColor;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.text = @"123";
    }
    return _nameLabel;
}


- (ELDGenderView *)genderView {
    if (_genderView == nil) {
        _genderView = [[ELDGenderView alloc] initWithFrame:CGRectZero];
        [_genderView updateWithGender:2 birthday:@""];
    }
    return _genderView;
}


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

#undef kMeHeaderImageViewHeight
