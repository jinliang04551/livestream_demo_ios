//
//  EaseTransitionViewController.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/7.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseTransitionViewController.h"
#import "Masonry.h"
NSString *defaultPwd = @"000000";//默认密码

@interface EaseTransitionViewController ()

@end

@implementation EaseTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
    [self autoRegistAccount];
}

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
    CGFloat position = [UIScreen mainScreen].bounds.size.height / 2;
    UIImageView *LogoView = [[UIImageView alloc]init];
    [self.view addSubview:LogoView];
    [LogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@80);
        make.bottom.equalTo(self.view.mas_centerY).offset(-(position - 80)/2);
        make.centerX.equalTo(self.view);
    }];
    LogoView.image = [UIImage imageNamed:@"Logo"];
    
    UILabel *welcomeLabel = [[UILabel alloc]init];
    [self.view addSubview:welcomeLabel];
    [welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-120);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableDictionary *textDict = [NSMutableDictionary dictionary];
    textDict[NSForegroundColorAttributeName] = RGBACOLOR(86, 86, 86, 1);
    textDict[NSFontAttributeName] = [UIFont fontWithName:@"Alibaba-PuHuiTi" size:16.f];
    textDict[NSKernAttributeName] = @(3.56);
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentCenter;
    textDict[NSParagraphStyleAttributeName] = paraStyle;
    welcomeLabel.attributedText = [[NSAttributedString alloc]initWithString:@"Welcome to Huanxin Live Chat Room" attributes:textDict];
}

- (void)autoRegistAccount
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"" toView:nil];
    __weak MBProgressHUD *weakHud = hud;
    NSString *uuidAccount = [UIDevice currentDevice].identifierForVendor.UUIDString;//默认账户id
    uuidAccount = [[uuidAccount stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [[AgoraChatClient sharedClient] registerWithUsername:uuidAccount password:defaultPwd completion:^(NSString *aUsername, AgoraChatError *aError) {
             [[AgoraChatClient sharedClient] loginWithUsername:(NSString *)uuidAccount password:defaultPwd completion:^(NSString *aUsername, AgoraChatError *aError) {
                 //set avatar url
                 if (aError == nil) {
                     [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:kDefaultAvatarURL withType:AgoraChatUserInfoTypeAvatarURL completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
                        
                         //通知 接收所在的线程 是基于 发送通知 所在的线程。由于接收通知在appdelegate主线程里，所以发送通知必须切换到主线程。
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [weakHud hideAnimated:YES];
                              if (!aError) {
                                  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                                  [ud setObject:[AgoraChatClient sharedClient].currentUsername forKey:kLiveLastLoginUsername];
                                  [ud synchronize];
                                  [[AgoraChatClient sharedClient].options setIsAutoLogin:YES];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@YES];
                             }
                         });
                         
                     }];
                 }else {
                     [self showHint:aError.errorDescription];
                 }
                 
             }];
         }];
     });
}

@end
