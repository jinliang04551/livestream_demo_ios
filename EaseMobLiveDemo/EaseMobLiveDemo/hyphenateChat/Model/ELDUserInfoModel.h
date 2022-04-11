//
//  ELDUserInfoModel.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDUserInfoModel : NSObject
@property (nonatomic, strong, readonly) NSString *hyphenateId;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, assign) BOOL  isMuted;
@property (nonatomic, assign) BOOL  isStreamer;
@property (nonatomic, assign) BOOL  isAdmin;

- (instancetype)initWithHyphenateId:(NSString *)hyphenateId;

@end

NS_ASSUME_NONNULL_END
