//
//  ELDChatroomMembersView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/12.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDChatroomMembersView.h"
#import "ELDLiveroomMembersViewController.h"

@interface ELDChatroomMembersView ()

@property (nonatomic,strong) ELDLiveroomMembersViewController *blockListVC;

@property (nonatomic, strong) UIView *alphaBgView;

@end


@implementation ELDChatroomMembersView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    [self addSubview:self.alphaBgView];

    [self.alphaBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    UIView *testView = [[UIView alloc] init];
    testView.backgroundColor = UIColor.yellowColor;
    [self addSubview:testView];
    
    [self.alphaBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(100, 0, 0, 100));
    }];

    
}


- (void)tapGestureAction {
    NSLog(@"%s",__func__);
}


- (UIView *)alphaBgView {
    if (_alphaBgView == nil) {
        _alphaBgView = [[UIView alloc] init];
        _alphaBgView.backgroundColor = UIColor.blackColor;
        _alphaBgView.alpha = 0.01;

        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self    action:@selector(tapGestureAction)];
        [_alphaBgView addGestureRecognizer:tap];

    }
    return _alphaBgView;
}

- (ELDLiveroomMembersViewController *)blockListVC {
    if (_blockListVC == nil) {
        _blockListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:nil withMemberType:ELDMemberVCTypeBlock];
    }
    return _blockListVC;
}

- (void)showFromParentView:(UIView *)view
{
    view.userInteractionEnabled = YES;

    [view addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{

    } completion:^(BOOL finished) {
        view.userInteractionEnabled = YES;
    }];
}

- (void)removeFromParentView
{
    [UIView animateWithDuration:0.5 animations:^{

    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
