//
//  ACDTitleDetailCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/17.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDTitleDetailCell.h"

@implementation ACDTitleDetailCell

- (void)prepare {
    
    self.contentView.backgroundColor = ViewControllerBgBlackColor;
    self.backgroundColor = ViewControllerBgBlackColor;
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.bottomLine];
}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kEaseLiveDemoPadding * 1.6);
        make.right.equalTo(self.detailLabel.mas_left);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kEaseLiveDemoPadding * 1.6);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@ELD_ONE_PX);
        make.bottom.equalTo(self.contentView);
    }];
}

#pragma mark getter and setter
- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = Font(@"PingFang SC", 16.0);
        _detailLabel.textColor = TextLabelGrayColor;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}

@end
