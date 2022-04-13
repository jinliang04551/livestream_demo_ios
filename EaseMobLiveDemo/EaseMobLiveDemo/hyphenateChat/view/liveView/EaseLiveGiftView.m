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

#define kBottomViewHeight 320.0f

@interface EaseLiveGiftView () <UICollectionViewDelegate,UICollectionViewDataSource,EaseGiftCellDelegate>
{
    long _giftNum;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *sendGiftBtn;
@property (nonatomic, strong) UILabel *giftNameLabel;


@property (nonatomic, strong) ELDCountCaculateView *countCaculateView;
@property (nonatomic, strong) UIView *selectedGiftNumView;

@property (nonatomic, strong) UILabel *selectedGiftDesc;
@property (nonatomic, strong) UIButton *giftNumBtn;

@property (nonatomic, strong) NSArray *giftArray;
@property (nonatomic, strong) EaseGiftCell *selectedGiftCell;

@property (nonatomic, strong) UIImageView *giftTotalValueImageView;
@property (nonatomic, strong) UILabel *giftTotalValueLabel;

@property (nonatomic, strong) ELDGiftModel *selectedGiftModel;

@end

@implementation EaseLiveGiftView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.giftArray = [EaseLiveGiftHelper sharedInstance].giftArray;
        _giftNum = 1;
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
    [self.bottomView addSubview:self.sendGiftBtn];


    [self.giftNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.bottomView.mas_top).offset(15.0);
        make.centerX.equalTo(self.bottomView);
        make.bottom.equalTo(self.collectionView.mas_top).offset(-20.0);
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sendGiftBtn.mas_top).offset(-20.0);
        make.left.right.equalTo(self.bottomView);
        make.height.equalTo(@(_collectionView.height));
    }];
    
    [self.sendGiftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_bottom).offset(-20.0);
        make.right.equalTo(self.bottomView).offset(-20.0);
    }];

    [self.giftTotalValueImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftBtn);
        make.right.equalTo(self.giftTotalValueLabel.mas_left).offset(-5.0);
        make.size.equalTo(@(20.0));
    }];
    
    [self.giftTotalValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftBtn);
        make.right.equalTo(self.sendGiftBtn.mas_left).offset(-15.0);
    }];

    [self.countCaculateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftBtn);
        make.left.equalTo(self.bottomView.mas_left).offset(20.0);
    }];
    
    

}


#pragma mark - getter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, _bottomView.height - 54.f) collectionViewLayout:flowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseGiftCell class] forCellWithReuseIdentifier:@"giftCollectionCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
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
        _giftNameLabel.font = [UIFont systemFontOfSize:16.f];
        _giftNameLabel.textColor = [UIColor whiteColor];
        _giftNameLabel.backgroundColor = [UIColor clearColor];
        _giftNameLabel.textAlignment = NSTextAlignmentCenter;
        _giftNameLabel.backgroundColor = UIColor.yellowColor;
    }
    return _giftNameLabel;
}

- (ELDCountCaculateView *)countCaculateView {
    if (_countCaculateView == nil) {
        _countCaculateView = [[ELDCountCaculateView alloc] init];
        
        ELD_WS
        _countCaculateView.tapBlock = ^{
            
        };
        
        _countCaculateView.countBlock = ^(NSInteger count) {
            
        };
        
    }
    return _countCaculateView;
}

- (UIView *)selectedGiftNumView
{
    if (_selectedGiftNumView == nil) {
        _selectedGiftNumView = [[UIView alloc] initWithFrame:CGRectMake(self.width - 120 - 94, _collectionView.bottom + 10.f, 110.f, 32.f)];
//        _selectedGiftNumView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        _selectedGiftNumView.layer.cornerRadius = 16.0f;
        _selectedGiftNumView.backgroundColor = UIColor.yellowColor;

        UIButton *subtractBtn = [[UIButton alloc]init];
        [subtractBtn setTitle:@"-" forState:UIControlStateNormal];
        [subtractBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        subtractBtn.layer.cornerRadius = 15.f;
        subtractBtn.backgroundColor = [UIColor blackColor];
        subtractBtn.titleLabel.font = [UIFont systemFontOfSize:26.f];
        subtractBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 3, 0);
        [subtractBtn addTarget:self action:@selector(subtractGiftNumAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectedGiftNumView addSubview:subtractBtn];
        [subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@30.f);
            make.left.equalTo(_selectedGiftNumView.mas_left);
            make.centerY.equalTo(_selectedGiftNumView);
        }];

        self.giftNumBtn = [[UIButton alloc]init];
        [_giftNumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_giftNumBtn setTitle:@"1" forState:UIControlStateNormal];
        _giftNumBtn.layer.cornerRadius = 15.f;
        _giftNumBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_giftNumBtn addTarget:self action:@selector(giftNumCustom) forControlEvents:UIControlEventTouchUpInside];
        [_selectedGiftNumView addSubview:self.giftNumBtn];
        [self.giftNumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(subtractBtn);
            make.left.equalTo(subtractBtn.mas_right).offset(10.f);
            make.centerY.equalTo(subtractBtn);
        }];

        UIButton *addtBtn = [[UIButton alloc]init];
        [addtBtn setTitle:@"+" forState:UIControlStateNormal];
        [addtBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addtBtn.layer.cornerRadius = 15.f;
        addtBtn.backgroundColor = [UIColor blackColor];
        addtBtn.titleLabel.font = [UIFont systemFontOfSize:26.f];
        addtBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 3, 0);
        [addtBtn addTarget:self action:@selector(addGiftNumAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectedGiftNumView addSubview:addtBtn];
        [addtBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(subtractBtn);
            make.right.equalTo(_selectedGiftNumView.mas_right);
            make.centerY.equalTo(subtractBtn);
        }];
    }
    return _selectedGiftNumView;
}


- (UILabel*)selectedGiftDesc
{
    if (_selectedGiftDesc == nil) {
        _selectedGiftDesc = [[UILabel alloc] initWithFrame:CGRectMake(13.f, _collectionView.bottom, self.width/2, 54.f)];
        _selectedGiftDesc.font = [UIFont systemFontOfSize:18.f];
        _selectedGiftDesc.textColor = [UIColor whiteColor];
    }
    return _selectedGiftDesc;
}

- (UIButton*)sendGiftBtn
{
    if (_sendGiftBtn == nil) {
        _sendGiftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendGiftBtn.frame = CGRectMake(self.width - 94.f, _collectionView.bottom + 10.f, 80.f, 34.f);
        [_sendGiftBtn setImage:ImageWithName(@"sendGift") forState:UIControlStateNormal];
        _sendGiftBtn.layer.cornerRadius = 10.f;
        [_sendGiftBtn addTarget:self action:@selector(sendGiftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendGiftBtn;
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
        _giftTotalValueLabel.text = @"subTotal:10000";
    }
    return _giftTotalValueLabel;
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

    cell.giftId = [NSString stringWithFormat:@"gift_%ld",(long)(row+1)];
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((_collectionView.width - 40)/4, (_collectionView.height - 10)/2);
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
    
    self.selectedGiftDesc.text = aCell.nameLabel.text;
    _giftNum = 1;
    [self.giftNumBtn setTitle:[NSString stringWithFormat:@"%lu",_giftNum] forState:UIControlStateNormal];
    
    //
    self.selectedGiftCell = aCell;
    self.selectedGiftModel = aCell.giftModel;
    [self.collectionView reloadData];
}


#pragma mark - EaseCustomKeyBoardDelegate

//自定义礼物数量
- (void)customGiftNum:(NSString *)giftNum
{
    _giftNum = (long)[giftNum longLongValue];
    [self.giftNumBtn setTitle:[NSString stringWithFormat:@"%lu",_giftNum] forState:UIControlStateNormal];
}

#pragma mark - action
//刷礼物
- (void)sendGiftAction
{
//    self.selectedGiftDesc.hidden = YES;
//    self.selectedGiftNumView.hidden = YES;
    if (self.selectedGiftCell) {
        if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(didConfirmGift:giftNum:)]) {
            [self.giftDelegate didConfirmGift:self.selectedGiftCell giftNum:_giftNum];
            self.selectedGiftCell = nil;
            self.selectedGiftModel = nil;
            
            _giftNum = 1;
            [self.giftNumBtn setTitle:[NSString stringWithFormat:@"%lu",_giftNum] forState:UIControlStateNormal];
            
            self.countCaculateView.countLabel.text = @"1";
            
        }
    }
}

//增加礼物数量
- (void)addGiftNumAction
{
    if (_giftNum >= 999) {
        return;
    }
    _giftNum += 1;
    [self.giftNumBtn setTitle:[NSString stringWithFormat:@"%lu",_giftNum] forState:UIControlStateNormal];
}

//减少礼物数量
- (void)subtractGiftNumAction
{   
    if (_giftNum <= 1) {
        return;
    } else {
        _giftNum -= 1;
        [self.giftNumBtn setTitle:[NSString stringWithFormat:@"%lu",_giftNum] forState:UIControlStateNormal];
    }
}

//自定义礼物数量
- (void)giftNumCustom
{
    if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(giftNumCustom:)]) {
        [self.giftDelegate giftNumCustom:self];
    }
}

@end

#undef kBottomViewHeight

