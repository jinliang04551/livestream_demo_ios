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

@interface ELDLiveContainerViewController ()
@property (nonatomic, strong) ELDPreLivingViewController *preLivingViewController;
@property (nonatomic, strong) ELDLiveViewController *liveViewController;
@property (nonatomic, strong) EaseLiveRoom *liveRoom;

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
    ELDLiveViewController *livingVC = [[ELDLiveViewController alloc] initWithLiveRoom:liveRoom];
    [self presentViewController:livingVC
                           animated:YES
                         completion:^{
        [livingVC setFinishBroadcastCompletion:^(BOOL isFinish) {
            if (isFinish)
                [self dismissViewControllerAnimated:false completion:nil];
        }];
    }];
}

@end
