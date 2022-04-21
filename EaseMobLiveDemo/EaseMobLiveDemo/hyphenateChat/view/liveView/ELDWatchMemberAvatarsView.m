//
//  ELDWatchMemberAvatarsView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDWatchMemberAvatarsView.h"

@interface ELDWatchMemberAvatarsView ()
@property (nonatomic, strong) NSMutableArray *watchArray;

@end


@implementation ELDWatchMemberAvatarsView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndlayoutSubviews];
    }
    return self;
}

- (void)placeAndlayoutSubviews {

    [self addSubview:self.firstMemberImageView];
    [self addSubview:self.secondMemberImageView];

    [self.firstMemberImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(5.0);
        make.size.equalTo(@(kAvatarHeight));
    }];
    
    [self.firstMemberImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.firstMemberImageView.mas_left).offset(10.0);
        make.size.equalTo(self.firstMemberImageView);
        make.right.equalTo(self).offset(-5.0);
    }];
}

- (void)updateWatchersAvatarWithUserIds:(NSArray *)userIds {
    
    self.hidden = [userIds count] > 0 ? NO : YES;

    [AgoraChatUserInfoManagerHelper fetchUserInfoWithUserIds:userIds userInfoTypes:@[@(AgoraChatUserInfoTypeAvatarURL)] completion:^(NSDictionary * _Nonnull userInfoDic) {
        NSMutableArray *tempArray = NSMutableArray.array;
        for (NSString *key in userInfoDic.allKeys) {
            AgoraChatUserInfo *userInfo = userInfoDic[key];
            if (userInfo.avatarUrl.length > 0) {
                [tempArray addObject:userInfo.avatarUrl];
            }else {
                [tempArray addObject:@""];
            }
        }
        
        if (tempArray.count == 0) {
            return;
        }
        
        if (tempArray.count == 1) {
            self.watchArray = [tempArray mutableCopy];
        }else {
            self.watchArray = [[tempArray subarrayWithRange:NSMakeRange(0, 2)] mutableCopy];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.firstMemberImageView sd_setImageWithURL:[NSURL URLWithString:self.watchArray.firstObject] placeholderImage:ImageWithName(@"avatat_2")];
            if (self.watchArray.count == 2) {
                [self.secondMemberImageView sd_setImageWithURL:[NSURL URLWithString:self.watchArray[1]] placeholderImage:ImageWithName(@"avatat_2")];
            }
        });
    }];
    
}

#pragma mark getter and setter
- (UIImageView *)firstMemberImageView {
    if (_firstMemberImageView == nil) {
        _firstMemberImageView = [[UIImageView alloc] init];
        _firstMemberImageView.contentMode = UIViewContentModeScaleAspectFit;
        _firstMemberImageView.layer.cornerRadius = kAvatarHeight * 0.5;
        _firstMemberImageView.clipsToBounds = YES;
        _firstMemberImageView.layer.masksToBounds = YES;
    }
    return _firstMemberImageView;
}

- (UIImageView *)secondMemberImageView {
    if (_secondMemberImageView == nil) {
        _secondMemberImageView = [[UIImageView alloc] init];
        _secondMemberImageView.contentMode = UIViewContentModeScaleAspectFit;
        _secondMemberImageView.layer.cornerRadius = kAvatarHeight * 0.5;
        _secondMemberImageView.clipsToBounds = YES;
        _secondMemberImageView.layer.masksToBounds = YES;
    }
    return _secondMemberImageView;
}

- (NSMutableArray *)watchArray {
    if (_watchArray == nil) {
        _watchArray = NSMutableArray.new;
    }
    return _watchArray;
}


@end
