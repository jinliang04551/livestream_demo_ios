//
//  EaseLiveCastView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/26.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveCastView.h"
#import "EaseLiveRoom.h"
#import "EaseDefaultDataHelper.h"
#import <Masonry/Masonry.h>
#import "ELDGenderView.h"


@interface EaseLiveCastView ()
{
    EaseLiveRoom *_room;
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
//@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *praiseLabel;
@property (nonatomic, strong) UILabel *giftValuesLabel;
@property (nonatomic, strong) ELDGenderView *genderView;
@property (nonatomic, strong) UIImageView *giftIconImageView;

@end

extern NSArray<NSString*> *nickNameArray;
extern NSMutableDictionary *anchorInfoDic;

@implementation EaseLiveCastView

- (instancetype)initWithFrame:(CGRect)frame room:(EaseLiveRoom*)room
{
    self = [super initWithFrame:frame];
    if (self) {
        _room = room;
        self.layer.cornerRadius = frame.size.height / 2;
        
        [self placeAndlayoutSubviews];
        [self _setviewData];
        [self addTapGesture];
    }
    return self;
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHeadImage)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
}


- (void)placeAndlayoutSubviews {

    [self addSubview:self.headImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.genderView];
    [self addSubview:self.giftIconImageView];
    [self addSubview:self.giftValuesLabel];

    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(2.0);
        make.size.equalTo(@32.0);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(4.0);
        make.left.equalTo(self.headImageView.mas_right).offset(kEaseLiveDemoPadding);
        make.width.lessThanOrEqualTo(@80.0);
        make.height.equalTo(@16.0);
    }];

    [self.genderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
        make.right.equalTo(self).offset(-8.0);
        make.width.equalTo(@(30));
        make.height.equalTo(@(kGenderViewHeight));
    }];

    [self.giftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-4.0);
        make.left.equalTo(self.nameLabel);
        make.size.equalTo(@10.0);
    }];
    
    [self.giftValuesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.giftIconImageView.mas_right).offset(5.0);
        make.centerY.equalTo(self.giftIconImageView);
        make.right.equalTo(self.genderView);
    }];
}

- (void)updateUIWithUserInfo:(AgoraChatUserInfo *)userInfo {
    
    self.nameLabel.text = userInfo.nickName ?:userInfo.userId;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:kDefultUserImage];
    [self.genderView updateWithGender:userInfo.gender birthday:userInfo.birth];
    
}

#pragma mark getter and setter
- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(2, 2, self.height - 4, self.height - 4);
        _headImageView.image = [UIImage imageNamed:@"Logo"];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = (self.height - 4)/2;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(_headImageView.width + 10.f, self.height / 4, self.width - (_headImageView.width + 10.f), self.height/2);
        _nameLabel.font = BFont(12.0f);
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)praiseLabel
{
    if (_praiseLabel == nil) {
        _praiseLabel = [[UILabel alloc] init];
        //_praiseLabel.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.height + 5, self.width / 2, self.height / 2);
        _praiseLabel.font = [UIFont systemFontOfSize:12.f];
        _praiseLabel.textColor = [UIColor colorWithRed:255/255.0 green:199/255.0 blue:0/255.0 alpha:1.0];
        _praiseLabel.text = [NSString stringWithFormat:@"赞:%d",[EaseDefaultDataHelper.shared.praiseStatisticstCount intValue]];
        _praiseLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _praiseLabel;
}

- (UILabel*)giftValuesLabel
{
    if (_giftValuesLabel == nil) {
        _giftValuesLabel = [[UILabel alloc] init];
        _giftValuesLabel.font = [UIFont systemFontOfSize:10.0f];
        _giftValuesLabel.textColor = [UIColor colorWithRed:255/255.0 green:199/255.0 blue:0/255.0 alpha:0.74];
        _giftValuesLabel.text = [NSString stringWithFormat:@"%d",[EaseDefaultDataHelper.shared.totalGifts intValue]];
        _giftValuesLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _giftValuesLabel;
}

- (ELDGenderView *)genderView {
    if (_genderView == nil) {
        _genderView = [[ELDGenderView alloc] initWithFrame:CGRectZero];
        _genderView.layer.cornerRadius = kGenderViewHeight * 0.5;
        _genderView.clipsToBounds = YES;
    }
    return _genderView;
}

- (UIImageView *)giftIconImageView {
    if (_giftIconImageView == nil) {
        _giftIconImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"receive_gift_icon")];
        _giftIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _giftIconImageView.layer.masksToBounds = YES;
    }
    return _giftIconImageView;
}



- (void)_setviewData
{
    extern NSArray<NSString*>*nickNameArray;
    if (_room) {
        if ([_room.anchor isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
            if (![EaseDefaultDataHelper.shared.defaultNickname isEqualToString:@""]) {
                _nameLabel.text = EaseDefaultDataHelper.shared.defaultNickname;
            } else {
                int random = (arc4random() % 100);
                EaseDefaultDataHelper.shared.defaultNickname = nickNameArray[random];
                [EaseDefaultDataHelper.shared archive];
                _nameLabel.text = EaseDefaultDataHelper.shared.defaultNickname;
            }
        } else {
            NSMutableDictionary *anchorInfo = [anchorInfoDic objectForKey:_room.roomId];
            if (anchorInfo && [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR] && ![[anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR] isEqualToString:@""]) {
                _nameLabel.text = [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];
            } else {
                anchorInfo = [[NSMutableDictionary alloc]initWithCapacity:3];
                [anchorInfo setObject:_room.anchor forKey:kBROADCASTING_CURRENT_ANCHOR];//当前房间主播
                int random = (arc4random() % 100);
                NSString *randomNickname = nickNameArray[random];
                _nameLabel.text = randomNickname;
                [anchorInfo setObject:_nameLabel.text forKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];//当前房间主播昵称
                random = (arc4random() % 7) + 1;
                [anchorInfo setObject:[NSString stringWithFormat:@"avatat_%d",random] forKey:kBROADCASTING_CURRENT_ANCHOR_AVATAR];//当前房间主播头像
                [anchorInfoDic setObject:anchorInfo forKey:_room.roomId];
            }
        }
    }
}

/*
- (UILabel*)numberLabel
{
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.frame = CGRectMake(_headImageView.width + 10.f, self.height/2, self.width - (_headImageView.width + 10.f), self.height/2);
        _numberLabel.font = [UIFont systemFontOfSize:12.f];
        _numberLabel.textColor = [UIColor whiteColor];
    }
    return _numberLabel;
}*/

#pragma mark - action
- (void)didSelectHeadImage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAnchorCard:)]) {
        [self.delegate didClickAnchorCard:_room];
    }
}

#pragma mark - public

- (void)setNumberOfPraise:(NSInteger)number
{
    _praiseLabel.text = [NSString stringWithFormat:@"赞：%ld",(long)number];
}

- (void)setNumberOfGift:(NSInteger)number
{
    _giftValuesLabel.text = [NSString stringWithFormat:@"礼物：%ld",(long)number];
}

@end
