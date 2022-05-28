//
//  EaseLiveGiftView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#define kDEfaultGiftSelectedColor RGBACOLOR(19,84,254,0.2)
#define kDEfaultGiftBorderSelectedColor RGBACOLOR(91,148,255,1)

#import "EaseLiveGiftView.h"

#import "EaseGiftCell.h"
#import "EaseLiveGiftHelper.h"
#import "ELDCountCaculateView.h"
#import "ELDGiftModel.h"
#import "ELDLivingCountdownView.h"

#define kBottomViewHeight 320.0f
#define kSendButtonHeight 32.0f
#define kCollectionCellWidth 80.0
#define kCollectionCellHeight 110.0


@interface EaseLiveGiftView () <UICollectionViewDelegate,UICollectionViewDataSource,EaseGiftCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *sendGiftButton;
@property (nonatomic, strong) UILabel *giftNameLabel;


@property (nonatomic, strong) ELDCountCaculateView *countCaculateView;
@property (nonatomic, strong) NSArray *giftArray;
@property (nonatomic, strong) ELDGiftModel *selectedGiftModel;

@property (nonatomic, strong) NSString *sendSuccessGiftName;

@property (nonatomic, strong) UIImageView *giftTotalValueImageView;
@property (nonatomic, strong) UILabel *giftTotalValueLabel;
@property (nonatomic, strong) ELDLivingCountdownView *countDownView;


@end

@implementation EaseLiveGiftView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.giftArray = [EaseLiveGiftHelper sharedInstance].giftArray;
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.giftNameLabel];
    [self.bottomView addSubview:self.collectionView];
    [self.bottomView addSubview:self.countCaculateView];
    [self.bottomView addSubview:self.giftTotalValueImageView];
    [self.bottomView addSubview:self.giftTotalValueLabel];
    [self.bottomView addSubview:self.sendGiftButton];

    
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(kBottomViewHeight + bottom *3, 0, 0, 0));
    }];
    
    
    [self.giftNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(15.0);
        make.height.equalTo(@(20));
        make.centerX.equalTo(self.bottomView);
        make.bottom.equalTo(self.collectionView.mas_top).offset(-20.0);
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sendGiftButton.mas_top).offset(-20.0);
        make.left.right.equalTo(self.bottomView);
        make.height.equalTo(@(_collectionView.height));
    }];
    
    [self.sendGiftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_bottom).offset(-10.0 - bottom);
        make.right.equalTo(self.bottomView).offset(-20.0);
        make.height.equalTo(@(kSendButtonHeight));
    }];

    [self.giftTotalValueImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftButton);
        make.right.equalTo(self.giftTotalValueLabel.mas_left).offset(-5.0);
        make.size.equalTo(@(20.0));
    }];
    
    [self.giftTotalValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftButton);
        make.right.equalTo(self.sendGiftButton.mas_left).offset(-15.0);
    }];

    [self.countCaculateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftButton);
        make.left.equalTo(self.bottomView.mas_left).offset(20.0);
        make.height.equalTo(@(kSendButtonHeight));
    }];
    
}


- (void)resetWitGiftName:(NSString *)giftName {
    [self.countCaculateView resetCaculateView];
    [self.collectionView reloadData];
    self.sendSuccessGiftName = giftName;
    [self startShowCountDown];
}

- (void)startShowCountDown {
    [self addSubview:self.countDownView];
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kCollectionCellWidth));
        make.height.equalTo(@(kCollectionCellHeight));
        
    }];
    
    self.countDownView.hidden = NO;
    [self.countDownView startCountDown];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.giftArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    EaseGiftCell *cell = (EaseGiftCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"giftCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
        
    ELDGiftModel *giftModel = self.giftArray[row];
    giftModel.selected = [giftModel.giftname isEqualToString:self.selectedGiftModel.giftname];
    
    [cell updateWithGiftModel:giftModel];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    return CGSizeMake((_collectionView.width - 40)/4, (_collectionView.height - 10)/2);
    return CGSizeMake(kCollectionCellWidth, kCollectionCellHeight);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5.0, 0, 5.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - EaseGiftCellDelegate

- (void)giftCellDidSelected:(EaseGiftCell *)aCell
{
    [self.countCaculateView resetCaculateView];
    self.selectedGiftModel = aCell.giftModel;
    [self.collectionView reloadData];
}



#pragma mark - action
//刷礼物
- (void)sendGiftAction {
    if (self.selectedGiftModel) {
        if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(didConfirmGiftModel:giftNum:)]) {
            [self.giftDelegate didConfirmGiftModel:self.selectedGiftModel giftNum:self.countCaculateView.giftCount];
            
            [self.countCaculateView resetCaculateView];
        }
    }

}

//自定义礼物数量
- (void)giftNumCustom
{
    if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(giftNumCustom:)]) {
        [self.giftDelegate giftNumCustom:self];
    }
}

#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, _bottomView.height - 54.f) collectionViewLayout:flowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseGiftCell class] forCellWithReuseIdentifier:@"giftCollectionCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), 0);
        _collectionView.pagingEnabled = YES;
        _collectionView.userInteractionEnabled = YES;
    }
    return _collectionView;
}

- (UIView*)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kBottomViewHeight, self.width, kBottomViewHeight)];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _bottomView.userInteractionEnabled = YES;
    }
    return _bottomView;
}


- (UILabel *)giftNameLabel {
    if (_giftNameLabel == nil) {
        _giftNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(40.f, 10.f, 40.f, 20.f)];
        _giftNameLabel.text = @"Gifts";
        _giftNameLabel.font = BFont(16.0f);
        _giftNameLabel.textColor = [UIColor whiteColor];
        _giftNameLabel.backgroundColor = [UIColor clearColor];
        _giftNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _giftNameLabel;
}

- (ELDCountCaculateView *)countCaculateView {
    if (_countCaculateView == nil) {
        _countCaculateView = [[ELDCountCaculateView alloc] init];
        _countCaculateView.layer.cornerRadius = kSendButtonHeight* 0.5;
        _countCaculateView.layer.borderWidth = 1.0;
        _countCaculateView.layer.borderColor = TextLabelGrayColor.CGColor;
        
        ELD_WS
        _countCaculateView.tapBlock = ^{
            
        };
        
        _countCaculateView.countBlock = ^(NSInteger count) {
            [weakSelf updateGiftTotalValueWithCount:count];
        };
        
    }
    return _countCaculateView;
}

- (void)updateGiftTotalValueWithCount:(NSInteger)count {
    if (self.selectedGiftModel) {
        NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *attributeString = [ELDUtil attributeContent:@"Subtotal:" color:TextLabelGrayColor font:Font(@"PingFang SC",14.0)];
        
        NSAttributedString *totalAttString = [ELDUtil attributeContent:[NSString stringWithFormat:@" %@",@(self.selectedGiftModel.giftValue * count)] color:TextLabelWhiteColor font:Font(@"PingFang SC",14.0)];
        
        [mutableAttString appendAttributedString:attributeString];
        [mutableAttString appendAttributedString:totalAttString];

        self.giftTotalValueLabel.attributedText = mutableAttString;
    
    }

}



- (UIButton*)sendGiftButton
{
    if (_sendGiftButton == nil) {
        _sendGiftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendGiftButton.frame = CGRectMake(self.width - 94.f, _collectionView.bottom + 10.f, 80.f, 34.f);
        [_sendGiftButton setImage:ImageWithName(@"sendGift") forState:UIControlStateNormal];
        _sendGiftButton.layer.cornerRadius = 10.f;
        [_sendGiftButton addTarget:self action:@selector(sendGiftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendGiftButton;
}

- (UIImageView *)giftTotalValueImageView {
    if (_giftTotalValueImageView == nil) {
        _giftTotalValueImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"receive_gift_icon")];
        _giftTotalValueImageView.contentMode = UIViewContentModeScaleAspectFill;
        _giftTotalValueImageView.layer.masksToBounds = YES;
    }
    return _giftTotalValueImageView;
}

- (UILabel*)giftTotalValueLabel
{
    if (_giftTotalValueLabel == nil) {
        _giftTotalValueLabel = [[UILabel alloc] init];
        _giftTotalValueLabel.textColor = [UIColor whiteColor];
        _giftTotalValueLabel.font = [UIFont systemFontOfSize:14.f];
        _giftTotalValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _giftTotalValueLabel;
}

- (ELDLivingCountdownView *)countDownView {
    if (_countDownView == nil) {
        _countDownView = [[ELDLivingCountdownView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        _countDownView.backgroundColor = UIColor.clearColor;
        
        ELD_WS
        _countDownView.CountDownFinishBlock = ^{
            [weakSelf.countDownView removeFromSuperview];
           
        };
        
        _countDownView.backgroundColor = UIColor.yellowColor;
        _countDownView.hidden = YES;
    }
    return _countDownView;
}



@end

#undef kBottomViewHeight
#undef kSendButtonHeight
#undef kCollectionCellSize
#undef kCollectionCellWidth
#undef kCollectionCellHeight
