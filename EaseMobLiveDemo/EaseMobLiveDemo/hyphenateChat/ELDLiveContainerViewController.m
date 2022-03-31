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
    [self.view addSubview:self.liveViewController.view];

    [self.preLivingViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.liveViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
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
    }
    return _preLivingViewController;
}

- (ELDLiveViewController *)liveViewController {
    if (_liveViewController == nil) {
        _liveViewController = [[ELDLiveViewController alloc] init];
        _liveViewController.view.hidden = YES;
    }
    return _liveViewController;
}


@end
