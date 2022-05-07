//
//  AgoraChatUserInfoManager.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraChatUserInfo+expireTime.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraChatUserInfoManagerHelper : NSObject

@property (nonatomic, strong, readonly)NSMutableDictionary *userInfoCacheDic;
@property (nonatomic, strong, readonly)NSMutableDictionary *userModelCacheDic;

+ (AgoraChatUserInfoManagerHelper *)sharedHelper;


+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void(^)(NSDictionary *userInfoDic))completion;

+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                   userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes
                      completion:(void(^)(NSDictionary *userInfoDic))completion;

+ (void)updateUserInfo:(AgoraChatUserInfo *)userInfo
            completion:(void(^)(AgoraChatUserInfo *aUserInfo))completion;


+ (void)updateUserInfoWithUserId:(NSString *)userId
                        withType:(AgoraChatUserInfoType)type
                      completion:(void(^)(AgoraChatUserInfo *aUserInfo))completion;

+ (void)fetchOwnUserInfoCompletion:(void(^)(AgoraChatUserInfo *ownUserInfo))completion;


+ (void)fetchUserInfoModelsWithUserId:(NSArray *)userIds completion:(void(^)(NSDictionary *dic))completion;

@end

NS_ASSUME_NONNULL_END
