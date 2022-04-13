//
//  EaseGiftCell.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseGiftCell.h"

#define kGiftIconHeight 56.0

@interface EaseGiftCell ()
@property (nonatomic, strong) UIImageView *giftValueImageView;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) ELDGiftModel *giftModel;


@end

@implementation EaseGiftCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
        self.layer.cornerRadius = 2;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapAction:)];
        [self.contentView addGestureRecognizer:tap];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    
    [self addSubview:self.selectedImageView];
    [self addSubview:self.giftImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.giftValueImageView];
    [self addSubview:self.priceLabel];

    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10.0);
        make.centerX.equalTo(self);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.giftImageView.mas_bottom).offset(5.0);
        make.centerX.equalTo(self);
    }];

    
    [self.giftValueImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.priceLabel);
        make.right.equalTo(self.priceLabel.mas_left).offset(-5.0);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(5.0);
        make.left.equalTo(self.mas_centerX).offset(-10.0);
        make.right.equalTo(self).offset(-10.0);
    }];
    
}

#pragma mark getter and setter
- (UIImageView *)giftValueImageView {
    if (_giftValueImageView == nil) {
        _giftValueImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"receive_gift_icon")];
        _giftValueImageView.contentMode = UIViewContentModeScaleAspectFill;
        _giftValueImageView.layer.masksToBounds = YES;
    }
    return _giftValueImageView;
}

- (UIImageView*)giftImageView
{
    if (_giftImageView == nil) {
        _giftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kGiftIconHeight, kGiftIconHeight)];
        _giftImageView.layer.masksToBounds = YES;
        _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _giftImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _giftImageView.bottom, self.width, (self.height - self.width)/2)];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:10.0f];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel*)priceLabel
{
    if (_priceLabel == nil) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _nameLabel.bottom, self.width, (self.height - self.width)/2)];
        _priceLabel.textColor = COLOR_HEX(0xCCCCCCBD);
        _priceLabel.font = [UIFont systemFontOfSize:12.0f];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _priceLabel;
}


- (UIImageView*)selectedImageView
{
    if (_selectedImageView == nil) {
        _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        _selectedImageView.layer.masksToBounds = YES;
        _selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_selectedImageView setImage:ImageWithName(@"gift_selected")];
        _selectedImageView.hidden = YES;
    }
    return _selectedImageView;
}

#pragma mark - public
- (void)updateWithGiftModel:(ELDGiftModel *)giftModel {
    self.giftModel = giftModel;
    
    if (giftModel.giftname.length > 0) {
        _giftImageView.image = [UIImage imageNamed:giftModel.giftname];
    }
    if (giftModel.giftname.length > 0) {
        _nameLabel.text = [giftModel.giftname stringByReplacingOccurrencesOfString:@"gift." withString:@""];
    }
    _priceLabel.text = [@(giftModel.giftValue) stringValue];
    
    self.selectedImageView.hidden = !self.giftModel.selected;
}


#pragma mark - Action

- (void)cellTapAction:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(giftCellDidSelected:)]) {
        [self.delegate giftCellDidSelected:self];
    }
}

@end

#undef kGiftIconHeight

