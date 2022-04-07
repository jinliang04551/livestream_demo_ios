//
//  ELDLiveContainerViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/29.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDLiveContainerViewController.h"
#import "ELDLiveViewController.h"
#import "ELDPreLivingViewController.h"
#import "ELDLivingCountdownView.h"

@interface ELDLiveContainerViewController ()
@property (nonatomic, strong) ELDPreLivingViewController *preLivingViewController;
@property (nonatomic, strong) ELDLiveViewController *liveViewController;
@property (nonatomic, strong) EaseLiveRoom *liveRoom;
@property (nonatomic, strong) ELDLivingCountdownView *livingCountDownView;

@end

@implementation ELDLiveContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ViewControllerBgBlackColor;
    [self placeAndLayoutSubviews];
}

- (void)placeAndLayoutSubviews {
    [self.view addSubview:self.preLivingViewController.view];
    [self.preLivingViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.livingCountDownView];
    [self.livingCountDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];

}

#pragma mark getter and setter
- (ELDPreLivingViewController *)preLivingViewController {
    if (_preLivingViewController == nil) {
        _preLivingViewController = [[ELDPreLivingViewController alloc] init];
        ELD_WS
        _preLivingViewController.closeBlock = ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        _preLivingViewController.createSuccessBlock = ^(EaseLiveRoom * _Nonnull liveRoom) {
            [weakSelf goLiveingPageWithLiveRoom:liveRoom];
        };
    }
    return _preLivingViewController;
}


- (void)goLiveingPageWithLiveRoom:(EaseLiveRoom *)liveRoom {
    self.liveRoom = liveRoom;
    self.preLivingViewController.view.hidden = YES;
    [self.livingCountDownView startCountDown];
}


- (ELDLivingCountdownView *)livingCountDownView {
    if (_livingCountDownView == nil) {
        _livingCountDownView = [[ELDLivingCountdownView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        ELD_WS
        _livingCountDownView.CountDownFinishBlock = ^{
            [weakSelf.livingCountDownView removeFromSuperview];
            
            ELDLiveViewController *livingVC = [[ELDLiveViewController alloc] initWithLiveRoom:weakSelf.liveRoom];
            livingVC.modalPresentationStyle =  UIModalPresentationFullScreen;
            [weakSelf presentViewController:livingVC
                                   animated:YES
                                 completion:^{
                [livingVC setFinishBroadcastCompletion:^(BOOL isFinish) {
                    if (isFinish)
                        [weakSelf dismissViewControllerAnimated:false completion:nil];
                }];
            }];
        };
    }
    return _livingCountDownView;
}


@end
