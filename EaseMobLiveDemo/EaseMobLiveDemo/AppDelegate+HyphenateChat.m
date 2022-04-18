//
//  AppDelegate+HyphenateChat.m
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "AppDelegate+HyphenateChat.h"
#import "EaseDefaultDataHelper.h"

#import <AgoraChat/AgoraChatOptions+PrivateDeploy.h>
#import "Reachability.h"


NSArray<NSString*> *nickNameArray;//本地昵称库

NSMutableDictionary *anchorInfoDic;//直播间主播本应用显示信息库

@implementation AppDelegate (HyphenateChat)

- (void)initHyphenateChatSDK
{
    AgoraChatOptions *options = [AgoraChatOptions optionsWithAppkey:Appkey];
    /*
    [options setEnableDnsConfig:NO];
    [options setRestServer:@"a1-hsb.easemob.com"];
    [options setChatPort:6717];
    [options setChatServer:@"106.75.100.247"];*/
    
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"ChatDemoDevPush";
#else
    apnsCertName = @"ChatDemoProPush";

#endif
    options.apnsCertName = apnsCertName;
    options.isAutoAcceptGroupInvitation = NO;
    options.enableConsoleLog = YES;
    
    [[AgoraChatClient sharedClient] initializeSDKWithOptions:options];
    
    [self _setupAppDelegateNotifications];
    
    [self _registerRemoteNotification];
    
    [self _initNickNameArray];
    
    anchorInfoDic = [[NSMutableDictionary alloc]initWithCapacity:16];//初始化本地直播间主播昵称库

    BOOL isAutoLogin = [AgoraChatClient sharedClient].isAutoLogin;
    if (isAutoLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@YES];
    } else {
        if (!EaseDefaultDataHelper.shared.isInitiativeLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ELDautoRegistAccount object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@NO];
        }
    }
    
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
}


- (void)_initNickNameArray
{
    nickNameArray = @[@"东方漆",@"孟闾裆",@"曹秆",@"游龙纸",@"熊龛",@"元阊",@"闵茂",@"姚宠",@"印虹",@"尚仕",@"蔚光",@"钦亭",@"京俳",@"牧奖",
                    @"解笋",@"耿丁艮",@"牛菊",@"侯薇",@"习适袁",@"关阡",@"管致",@"聂焚",@"焦岸",@"米而",@"竺莜",@"黎轾",@"邓贰",@"周铎",@"闾丘裳",
                    @"程毗",@"南郭货",@"雍椿",@"康由",@"蔺晶",@"庞浈",@"辛芥",@"邢萧丹",@"谷梁深",@"宾彩",@"吴莛",@"贺扬",@"慕容岽",@"阎邮",@"萧由",
                    @"吕梆",@"高钓",@"西门韩赤",@"元真",@"司司",@"司空晰",@"万麦",@"姜戒",@"武抚",@"苍柳",@"季汶",@"周门",@"公孙褫",@"李乙",@"茹宁",
                    @"楼恕",@"司马穴",@"公孙赦",@"那伊",@"冼觊",@"丰核",@"钟创",@"沙迈",@"单寇",@"屋庐丘",@"李李",@"惠婷",@"池学",@"冯貂",@"东乡期",
                    @"毋丘出",@"左颀",@"宰绝",@"谷唐",@"萧格",@"谈草",@"商炅",@"米秀",@"习垂",@"黄崔",@"单遇观",@"茹启",@"田瓮",@"蒋蹯苻",@"呼延汶",
                    @"林犍",@"左丘芍",@"东宅蜇",@"谭七",@"徐仙",@"欧阳使",@"龙偃",@"山鹰",@"况梁",@"江胭",@"展思"];
}


- (BOOL)conecteNetwork
{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}


//- (void)doLogin {
//
//    if (![self conecteNetwork]) {
//        [self showAlertControllerWithTitle:@"" message:@"Network disconnected."];
//        return;
//    }
//
//    void (^finishBlock) (NSString *aName, NSString *nickName, AgoraChatError *aError) = ^(NSString *aName, NSString *nickName, AgoraChatError *aError) {
//        if (!aError) {
//            if (nickName) {
//                [AgoraChatClient.sharedClient.userInfoManager updateOwnUserInfo:nickName withType:AgoraChatUserInfoTypeNickName completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
//                    if (!aError) {
//
//                        [[NSNotificationCenter defaultCenter] postNotificationName:ELDUSERINFO_UPDATE  object:aUserInfo userInfo:nil];
//                    }
//                }];
//            }
//
//            [self saveLoginUserInfoWithUserName:aName nickName:nickName];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@YES userInfo:@{@"userName":aName,@"nickName":!nickName ? @"" : nickName}];
//            });
//            return ;
//        }
//
//        NSString *errorDes = NSLocalizedString(@"login.failure", @"login failure");
//        switch (aError.code) {
//            case AgoraChatErrorServerNotReachable:
//                errorDes = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
//                break;
//            case AgoraChatErrorNetworkUnavailable:
//                errorDes = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
//                break;
//            case AgoraChatErrorServerTimeout:
//                errorDes = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
//                break;
//            case AgoraChatErrorUserAlreadyExist:
//                errorDes = NSLocalizedString(@"login.taken", @"Username taken");
//                break;
//            default:
//                errorDes = NSLocalizedString(@"login.failure", @"login failure");
//                break;
//        }
//
//        [self showAlertControllerWithTitle:@"" message:errorDes];
//    };
//
//
//    NSString *userName = @"";
//    NSString *nickName = @"";
//
//    NSDictionary *loginDic = [self getLoginUserInfo];
//    if (loginDic.count > 0) {
//        userName = loginDic[USER_NAME];
//        nickName = loginDic[USER_NICKNAME];
//    }else {
//        userName = @"eld_002";
//        nickName = userName;
//    }
//
//
//    //unify token login
//    [[EaseHttpManager sharedInstance] loginToApperServer:userName nickName:nickName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *alertStr = nil;
//            if (response && response.length > 0 && statusCode) {
//                NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
//                NSString *token = [responsedict objectForKey:@"accessToken"];
//                NSString *loginName = [responsedict objectForKey:@"chatUserName"];
//                NSString *nickName = [responsedict objectForKey:@"chatUserNickname"];
//                if (token && token.length > 0) {
//                    [[AgoraChatClient sharedClient] loginWithUsername:[loginName lowercaseString] agoraToken:token completion:^(NSString *aUsername, AgoraChatError *aError) {
//                        finishBlock(aUsername, nickName, aError);
//                    }];
//                    return;
//                } else {
//                    alertStr = NSLocalizedString(@"login analysis token failure", @"analysis token failure");
//                }
//            } else {
//                alertStr = NSLocalizedString(@"login appserver failure", @"Sign in appserver failure");
//            }
//
//
//            [self showAlertControllerWithTitle:@"" message:alertStr];
//
//        });
//    }];
//
//}



- (void)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
    [alertControler addAction:conform];
    [self.window.rootViewController presentViewController:alertControler animated:YES completion:nil];

}

- (NSDictionary *)getLoginUserInfo {
    NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [shareDefault objectForKey:LAST_LOGINUSER];
    return dic;
}

- (void)saveLoginUserInfoWithUserName:(NSString *)userName nickName:(NSString *)nickName {
    NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = @{USER_NAME:userName,USER_NICKNAME:nickName};
    [shareDefault setObject:dic forKey:LAST_LOGINUSER];
    [shareDefault synchronize];
}



#pragma mark - app delegate notifications
// 监听系统生命周期回调，以便将需要的事件传给SDK
// Listen the life cycle of the system so that it will be passed to the SDK
- (void)_setupAppDelegateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)appDidEnterBackgroundNotif:(NSNotification*)notif
{
    [[AgoraChatClient sharedClient] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[AgoraChatClient sharedClient] applicationWillEnterForeground:notif.object];
}

#pragma mark - register apns
// 注册推送
// regist push
- (void)_registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    //iOS8 注册APNS
    //iOS8 regist APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
#endif
}

#pragma mark - App Delegate

// 将得到的deviceToken传给SDK
// Get deviceToken to pass SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AgoraChatClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
// Regist deviceToken failed,not HyphenateChat SDK Business,generally have something wrong with your environment configuration or certificate configuration
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
//                                                    message:error.description
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                          otherButtonTitles:nil];
//    [alert show];
}

@end
