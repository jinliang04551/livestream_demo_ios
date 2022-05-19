//
//  ELDChatView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/5/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPGiftCellModel;

NS_ASSUME_NONNULL_BEGIN

@protocol ELDChatViewDelegate <NSObject>
@optional

- (void)chatViewDidChangeFrameToHeight:(CGFloat)toHeight;

- (void)didSelectChangeCameraButton;

- (void)didSelectGiftButton:(BOOL)isOwner;//礼物

- (void)didSelectedExitButton;

@end



@interface ELDChatView : UIView

@property (nonatomic,strong) EaseChatView *easeChatView;

@property (nonatomic,strong) AgoraChatroom *chatroom;

@property (nonatomic, weak) id<ELDChatViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame
                         room:(EaseLiveRoom *)room
                    isPublish:(BOOL)isPublish
              customMsgHelper:(EaseCustomMessageHelper *)customMsgHelper;


- (void)joinChatroomWithCompletion:(void (^)(AgoraChatroom *aChatroom, AgoraChatError *aError))aCompletion;

- (void)leaveChatroomWithCompletion:(void (^)(BOOL success))aCompletion;


/// 显示gift view
/// @param cellModel giftcell 模型
/// @param backView   显示的view
- (void)sendGiftAction:(JPGiftCellModel*)cellModel backView:(UIView*)backView;

//有观众送礼物
- (void)userSendGiftId:(NSString *)giftId
               giftNum:(NSInteger)giftNum
                userId:(NSString *)userId
              backView:(UIView*)backView;


/*
 @param msg             接收的消息
 @param backView        展示在哪个页面
 */
//弹幕动画
- (void)barrageAction:(AgoraChatMessage*)msg backView:(UIView*)backView;

/*
 @param backView        展示在哪个页面
 */
//点赞动画
- (void)praiseAction:(UIView*)backView;


@end

NS_ASSUME_NONNULL_END
