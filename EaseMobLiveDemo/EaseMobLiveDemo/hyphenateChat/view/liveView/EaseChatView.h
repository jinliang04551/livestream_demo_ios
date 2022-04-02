//
//  EaseChatView.h
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseCustomMessageHelper.h"

@class AgoraChatMessage;
@class EaseLiveRoom;
@protocol EaseChatViewDelegate <NSObject>

@optional

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight;

- (void)didReceiveGiftWithCMDMessage:(AgoraChatMessage*)message;

- (void)didReceiveBarrageWithCMDMessage:(AgoraChatMessage*)message;

- (void)didSelectUserWithMessage:(AgoraChatMessage*)message;

- (void)didSelectChangeCameraButton;

- (void)didSelectGiftButton:(BOOL)isOwner;//礼物

- (void)didSelectedExitButton;

- (void)liveRoomOwnerDidUpdate:(AgoraChatroom *)aChatroom newOwner:(NSString *)aNewOwner;

- (void)liveRoomDidDEstory;

@end

@interface EaseChatView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId;

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId
                    isPublish:(BOOL)isPublish;

- (instancetype)initWithFrame:(CGRect)frame
                         room:(EaseLiveRoom*)room
                    isPublish:(BOOL)isPublish
              customMsgHelper:(EaseCustomMessageHelper*)customMsgHelper;

@property (nonatomic, weak) id<EaseChatViewDelegate> delegate;

- (void)joinChatroomWithIsCount:(BOOL)aIsCount
                     completion:(void (^)(BOOL success))aCompletion;

- (void)leaveChatroomWithIsCount:(BOOL)aIsCount
                      completion:(void (^)(BOOL success))aCompletion;

- (void)sendGiftAction:(NSString *)giftId num:(NSInteger)num completion:(void (^)(BOOL success))aCompletion;

@end
