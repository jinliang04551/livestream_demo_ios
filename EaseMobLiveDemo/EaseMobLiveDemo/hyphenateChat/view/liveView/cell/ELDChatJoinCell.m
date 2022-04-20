//
//  ELDChatJoinCell.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/20.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDChatJoinCell.h"

@interface ELDChatJoinCell ()
@property (nonatomic, strong) UIImageView *joinImageView;
@property (nonatomic, strong) UILabel *joinLabel;
@property (nonatomic, strong) AgoraChatUserInfo *userInfo;

@end


@implementation ELDChatJoinCell

- (void)prepare {
    self.backgroundColor = UIColor.clearColor;

    self.nameLabel.textColor = TextLabelGrayColor;
    self.nameLabel.font = NFont(12.0f);
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.joinLabel];
    [self.contentView addSubview:self.joinImageView];
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
    
    [self.joinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
    }];
    
    [self.joinImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.joinLabel.mas_right).offset(2.0);
    }];
}

- (void)updateWithObj:(id)obj {
    AgoraChatMessage *message = (AgoraChatMessage *)obj;
    [self fetchUserInfoWithUserId:message.from];
}

- (void)fetchUserInfoWithUserId:(NSString *)userId {
    [AgoraChatUserInfoManagerHelper fetchUserInfoWithUserIds:@[userId] completion:^(NSDictionary * _Nonnull userInfoDic) {
        self.userInfo = [userInfoDic objectForKey:userId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:ImageWithName(@"avatat_2")];
            self.nameLabel.text = self.userInfo.nickName ?:self.userInfo.userId;
        });
    }];
    
}

#pragma mark getter and setter
- (UIImageView *)joinImageView {
    if (_joinImageView == nil) {
        _joinImageView = [[UIImageView alloc] init];
        _joinImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_joinImageView setImage:ImageWithName(@"live_join")];
    }
    return _joinImageView;
}

- (UILabel *)joinLabel {
    if (_joinLabel == nil) {
        _joinLabel = [[UILabel alloc] init];
        _joinLabel.font = NFont(12.0);
        _joinLabel.textColor = TextLabelWhiteColor;
        _joinLabel.textAlignment = NSTextAlignmentLeft;
        _joinLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _joinLabel.text = @"Joined";
    }
    return _joinLabel;
}



@end

