//
//  AgoraChatUserInfoManagerHelper.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraChatUserInfoManagerHelper.h"
#import "ELDUserInfoModel.h"

#define kExpireSeconds 60

@interface AgoraChatUserInfoManagerHelper ()
@property (nonatomic, strong)NSMutableDictionary *userInfoCacheDic;
@property (nonatomic, strong)NSMutableDictionary *userModelCacheDic;
@property (nonatomic, strong)dispatch_queue_t ioQueue;

@end


@implementation AgoraChatUserInfoManagerHelper
static AgoraChatUserInfoManagerHelper *instance = nil;
+ (AgoraChatUserInfoManagerHelper *)sharedHelper {
static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[AgoraChatUserInfoManagerHelper alloc]init];
    });
    return instance;
}

+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedHelper] fetchUserInfoWithUserIds:userIds completion:completion];
}


+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedHelper] fetchUserInfoWithUserIds:userIds userInfoTypes:userInfoTypes completion:completion];
}


+ (void)updateUserInfo:(AgoraChatUserInfo *)userInfo completion:(void (^)(AgoraChatUserInfo * _Nonnull))completion {
    [[self sharedHelper] updateUserInfo:userInfo completion:completion];
}

+ (void)updateUserInfoWithUserId:(NSString *)userId withType:(AgoraChatUserInfoType)type completion:(void (^)(AgoraChatUserInfo * _Nonnull))completion {
    [[self sharedHelper] updateUserInfoWithUserId:userId withType:type completion:completion];
}

+ (void)fetchOwnUserInfoCompletion:(void(^)(AgoraChatUserInfo *ownUserInfo))completion {
    [[self sharedHelper] fetchOwnUserInfoCompletion:completion];
}

+ (void)fetchUserInfoModelsWithUserId:(NSArray *)userIds completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedHelper] fetchUserInfoModelsWithUserId:userIds completion:completion];
}

#pragma mark instance method
- (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    
    if (userIds.count == 0) {
        return;
    }
    
    
    [self splitUserIds:userIds completion:^(NSMutableDictionary<NSString *,AgoraChatUserInfo *> *resultDic, NSMutableArray<NSString *> *reqIds) {
        if (reqIds.count == 0) {
            if (resultDic && completion) {
                completion(resultDic);
            }
            return;
        }else {
            [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:reqIds completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
                for (NSString *userKey in aUserDatas.allKeys) {
                    AgoraChatUserInfo *user = aUserDatas[userKey];
                    user.expireTime = [[NSDate date] timeIntervalSince1970];
                    if (user) {
                        resultDic[userKey] = user;
                        self.userInfoCacheDic[userKey] = user;
                    }
                }
                
                [self downloadAvatars];

                if (resultDic && completion) {
                    completion(resultDic);
                }
            }];
        }
    }];

}

- (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                   userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    
    if (userIds.count == 0) {
        return;
    }
    
    [self splitUserIds:userIds completion:^(NSMutableDictionary<NSString *,AgoraChatUserInfo *> *resultDic, NSMutableArray<NSString *> *reqIds) {
        if (reqIds.count == 0) {
            if (resultDic && completion) {
                completion(resultDic);
            }
            return;
        }else {

            [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:userIds type:userInfoTypes completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
                for (NSString *userKey in aUserDatas.allKeys) {
                    AgoraChatUserInfo *user = aUserDatas[userKey];
                    user.expireTime = [[NSDate date] timeIntervalSince1970];
                    if (user) {
                        resultDic[userKey] = user;
                        self.userInfoCacheDic[userKey] = user;
                    }
                }
                if (resultDic && completion) {
                    completion(resultDic);
                }
            }];
            
        }
    }];
    
    
}

- (void)updateUserInfo:(AgoraChatUserInfo *)userInfo
                       completion:(void(^)(AgoraChatUserInfo *aUserInfo))completion {
    
    [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userInfo completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

- (void)updateUserInfoWithUserId:(NSString *)userId
                        withType:(AgoraChatUserInfoType)type
                      completion:(void(^)(AgoraChatUserInfo *aUserInfo))completion {
    [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userId withType:type completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

- (void)fetchUserInfoModelsWithUserId:(NSArray *)userIds completion:(void (^)(NSDictionary * _Nonnull))completion {
    if (userIds.count == 0) {
        return;
    }
    
    if (self.userInfoCacheDic.count > 0 && completion) {
        completion(self.userInfoCacheDic);
    }
}

#pragma mark private method
- (void)splitUserIds:(NSArray *)userIds
          completion:(void(^)(NSMutableDictionary<NSString *,AgoraChatUserInfo *> *resultDic,NSMutableArray<NSString *> *reqIds))completion {
    
    NSMutableDictionary<NSString *,AgoraChatUserInfo *> *resultDic = NSMutableDictionary.new;
    NSMutableArray<NSString *> *reqIds = NSMutableArray.new;
    
    for (NSString *userId in userIds) {
        AgoraChatUserInfo *user = self.userInfoCacheDic[userId];
        NSTimeInterval delta = [[NSDate date] timeIntervalSince1970] - user.expireTime;
        if (delta > kExpireSeconds || !user) {
            [reqIds addObject:userId];
        }else {
            resultDic[userId] = user;
        }
    }
    if (completion) {
        completion(resultDic,reqIds);
    }
}


- (void)fetchOwnUserInfoCompletion:(void(^)(AgoraChatUserInfo *ownUserInfo))completion {
    NSString *userId = [AgoraChatClient sharedClient].currentUsername;
    if (userId == nil) {
        userId = @"";
    }
    [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:@[userId] completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
        AgoraChatUserInfo *user = aUserDatas[userId];
        if (completion) {
            completion(user);
        }
    }];
}

- (void)downloadAvatars {
    dispatch_async(self.ioQueue, ^{
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        for (NSString *userKey in self.userInfoCacheDic.allKeys) {
            @autoreleasepool {
                AgoraChatUserInfo *userInfo = self.userInfoCacheDic[userKey];
                if (userInfo) {
                        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                            
                            if (error == nil) {
                                ELDUserInfoModel *model = [[ELDUserInfoModel alloc] initWithUserInfo:userInfo];
                                model.avatarImage = image;
                                tempDic[userInfo.userId] = model;
                            }
                        }];
                    }
                }
            }
        if (tempDic.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userModelCacheDic = tempDic;
            });
        }
    });
}


#pragma mark getter and setter
- (NSMutableDictionary *)userInfoCacheDic {
    if (_userInfoCacheDic == nil) {
        _userInfoCacheDic = NSMutableDictionary.new;
    }
    return _userInfoCacheDic;
}


- (NSMutableDictionary *)userModelCacheDic {
    if (_userModelCacheDic == nil) {
        _userModelCacheDic = NSMutableDictionary.new;
    }
    return _userModelCacheDic;
}

- (dispatch_queue_t)ioQueue {
    if (_ioQueue == nil) {
        _ioQueue = dispatch_queue_create("com.dispatch.downloadAvatar", DISPATCH_QUEUE_SERIAL);
    }
    return _ioQueue;
}

@end

#undef kExpireSeconds

