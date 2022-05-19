//
//  EaseLiveHeaderListView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/15.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveHeaderListView.h"
#import "EaseLiveCastView.h"
#import "EaseLiveRoom.h"
#import "ELDWatchMemberAvatarsView.h"

#define kNumberBtnHeight 36.0f

#define kCollectionIdentifier @"collectionCell"

@interface EaseLiveHeaderCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *headerImage;

- (void)setHeadImage:(UIImage*)image;

@end

@implementation EaseLiveHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _headerImage = [[UIImageView alloc] init];
        _headerImage.frame = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame));
        _headerImage.layer.cornerRadius = CGRectGetHeight(self.frame)/2;
        _headerImage.layer.masksToBounds = YES;
        [self.contentView addSubview:_headerImage];
    }
    return self;
}

- (void)setHeadImage:(UIImage*)image
{
    _headerImage.image = image;
}

@end

@interface EaseLiveHeaderListView () <UICollectionViewDelegate,UICollectionViewDataSource>
{
    EasePublishModel *_model;
    NSTimer *_timer;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ELDWatchMemberAvatarsView *watchMemberAvatarsView;
@property (nonatomic, strong) AgoraChatroom *chatroom;


@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger occupantsCount;
@property (nonatomic, strong) UIButton *numberBtn;
@property (nonatomic, strong) UIButton *closeButton;


@end

@implementation EaseLiveHeaderListView

- (instancetype)initWithFrame:(CGRect)frame model:(EasePublishModel*)model
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        [self addSubview:self.collectionView];
        [self addSubview:self.liveCastView];
        
        [self.liveCastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.equalTo(@kNumberBtnHeight);
            make.left.equalTo(self).offset(12.0f);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.bottom.equalTo(self.liveCastView);
            make.left.equalTo(self.liveCastView.mas_right).offset(kEaseLiveDemoPadding * 4);
            make.right.equalTo(self).offset(-12.0);
        }];
        
        [self startTimer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame chatroom:(AgoraChatroom*)aChatroom
{
    self = [super initWithFrame:frame];
    if (self) {
        self.chatroom = aChatroom;
        [self addSubview:self.watchMemberAvatarsView];
        [self addSubview:self.liveCastView];
        [self addSubview:self.numberBtn];
        
        
        [self.liveCastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.equalTo(@kNumberBtnHeight);
            make.left.equalTo(self).offset(12.0f);
        }];
        
        [self.watchMemberAvatarsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.bottom.equalTo(self.liveCastView);
            make.right.equalTo(self.numberBtn.mas_left).offset(-8.0);
        }];

        //when chatroom owner is living
        if ([AgoraChatClient.sharedClient.currentUsername isEqualToString:self.chatroom.owner]) {
            [self.numberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.bottom.equalTo(self.liveCastView);
                make.height.equalTo(self.liveCastView);
                make.width.greaterThanOrEqualTo(@70.0);
                make.right.equalTo(self).offset(-12.0);
            }];
        }else {
            
            [self addSubview:self.closeButton];
            
            [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.bottom.equalTo(self.liveCastView);
                make.size.equalTo(@kNumberBtnHeight);
                make.right.equalTo(self).offset(-12.0);
            }];
            
            [self.numberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.bottom.equalTo(self.liveCastView);
                make.height.equalTo(self.liveCastView);
                make.width.greaterThanOrEqualTo(@70.0);
                make.right.equalTo(self.closeButton.mas_left).offset(-10.0);
//                make.right.equalTo(self).offset(-10.0);

            }];
        }

        
        [self startTimer];
    }
    return self;
}

- (void)dealloc
{
    [self stopTimer];
}

- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateHeaderView) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - getter

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        CGFloat width = 135;
        if (KScreenWidth > 320) {
            width = 170;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(width, 0, self.width - width - 65, CGRectGetHeight(self.frame)) collectionViewLayout:flowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseLiveHeaderCell class] forCellWithReuseIdentifier:kCollectionIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), 0);
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
    }
    return _collectionView;
}

- (ELDWatchMemberAvatarsView *)watchMemberAvatarsView {
    if (_watchMemberAvatarsView == nil) {
        _watchMemberAvatarsView = [[ELDWatchMemberAvatarsView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    }
    return _watchMemberAvatarsView;
}

- (EaseLiveCastView*)liveCastView
{
    if (_liveCastView == nil) {
        _liveCastView = [[EaseLiveCastView alloc] initWithFrame:CGRectMake(10, 0, self.width, kNumberBtnHeight)];
        _liveCastView.backgroundColor = AlphaBlackColor;

    }
    return _liveCastView;
}


- (void)setLiveCastDelegate
{
    self.liveCastView.delegate = self.delegate;
}

- (UIButton*)numberBtn
{
    if (_numberBtn == nil) {
        _numberBtn = [[UIButton alloc] init];
        _numberBtn.frame = CGRectMake(self.frame.size.width - 60.f, 5.f, 50.f, 30.f);
        _numberBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _numberBtn.titleLabel.textColor = [UIColor whiteColor];
        _numberBtn.backgroundColor = AlphaBlackColor;
        _numberBtn.layer.cornerRadius = kNumberBtnHeight *0.5;
        [_numberBtn setImage:ImageWithName(@"liveroom_people_icon") forState:UIControlStateNormal];
        [_numberBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)];
        [_numberBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5.0, 0, 0)];
        [_numberBtn addTarget:self action:@selector(memberListAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _numberBtn;
}


- (UIButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma Action

- (void)memberListAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMemberListButton:currentMemberList:)]) {
        BOOL isOwner = NO;
        if (self.chatroom && [self.chatroom.owner isEqualToString:[AgoraChatClient sharedClient].currentUsername]) {
            isOwner = YES;
        }
        [self.delegate didSelectMemberListButton:isOwner currentMemberList:[self.chatroom.memberList mutableCopy]];
        _numberBtn.selected = !_numberBtn.selected;
    }
}

- (void)closeAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(willCloseChatroom)]) {
        [self.delegate willCloseChatroom];
    }

}

#pragma mark - public
- (void)updateHeaderView {
    [self updateHeaderViewWithChatroom:self.chatroom];
}

- (void)updateHeaderViewWithChatroom:(AgoraChatroom*)aChatroom
{
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:aChatroom.adminList];
    [self.dataArray addObjectsFromArray:aChatroom.memberList];
    [self.numberBtn setTitle:[NSString stringWithFormat:@"%@ %@",@(self.dataArray.count) ,NSLocalizedString(@"profile.people", @"")] forState:UIControlStateNormal];
        
    [self fetchAllUserInfoWithChatroom:aChatroom];
}

- (void)fetchAllUserInfoWithChatroom:(AgoraChatroom*)aChatroom {
        
    NSMutableArray *tempArray = NSMutableArray.array;
    if (aChatroom.owner) {
        [tempArray addObject:aChatroom.owner];
    }
    [tempArray addObjectsFromArray:aChatroom.adminList];
    [tempArray addObjectsFromArray:aChatroom.memberList];
    
    if (tempArray.count > 0) {
        [EaseUserInfoManagerHelper fetchUserInfoWithUserIds:tempArray completion:^(NSDictionary * _Nonnull userInfoDic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for (NSString *userId in userInfoDic.allKeys) {
                    AgoraChatUserInfo *userInfo = userInfoDic[userId];
                    if (userInfo) {
                        if ([userId isEqualToString:aChatroom.owner]) {
                            [self.liveCastView updateUIWithUserInfo:userInfo];
                        }else {
                            //members
                            if (userInfo.avatarUrl) {
                                [tempArray addObject:userInfo.avatarUrl];
                            }else {
                                [tempArray addObject:kDefaultAvatarURL];
                            }
                        }
                    }
                }
                
                if (tempArray.count > 0) {
                    [self.watchMemberAvatarsView updateWatchersAvatarWithUrlArray:tempArray];
                }

            });
        }];
    }

}




/*
- (void)joinChatroomWithUsername:(NSString *)username
{
    if ([self.dataArray containsObject:username]) {
        return;
    }
    [self.dataArray insertObject:[username copy] atIndex:0];
    self.occupantsCount++;
    [_numberBtn setTitle:[NSString stringWithFormat:@"%ld人",(long)self.occupantsCount] forState:UIControlStateNormal];
    [self.collectionView reloadData];
}

- (void)leaveChatroomWithUsername:(NSString *)username
{
    for (int index = 0; index < [self.dataArray count]; index ++) {
        NSString *name = [self.dataArray objectAtIndex:index];
        if ([name isEqualToString:username]) {
            [self.dataArray removeObjectAtIndex:index];
        }
    }
    self.occupantsCount--;
    if (self.occupantsCount < 0) {
        self.occupantsCount = 0;
    }
    [_numberBtn setTitle:[NSString stringWithFormat:@"%ld人",(long)self.occupantsCount] forState:UIControlStateNormal];
    [self.collectionView reloadData];
}
*/
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseLiveHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionIdentifier forIndexPath:indexPath];
    
    int random = (arc4random() % 7) + 1;
    [cell setHeadImage:[UIImage imageNamed:[NSString stringWithFormat:@"avatat_%d",random]]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(0, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview = headerView;
        
    }
    if (kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        reusableview = footerview;
    }
    return reusableview;
}

#pragma mark --UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetHeight(self.frame), CGRectGetHeight(self.frame));
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSString *username = [self.dataArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectHeaderWithUsername:)]) {
        [self.delegate didSelectHeaderWithUsername:username];
    }*/
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end

#undef kNumberBtnHeight


