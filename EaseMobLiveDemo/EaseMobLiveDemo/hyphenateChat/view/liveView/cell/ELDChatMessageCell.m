//
//  ELDChatMessageCell.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDChatMessageCell.h"
#import "EaseEmojiHelper.h"
#import "EaseDefaultDataHelper.h"
#import "EaseCustomMessageHelper.h"

#define kIconImageViewHeight 30.0f

#define kCellVPadding  5.0

#define KCustomerWidth [[UIScreen mainScreen] bounds].size.width - 32

#define kContentLabelMaxWidth KScreenWidth -kIconImageViewHeight -kEaseLiveDemoPadding *3

#define kNameLabelHeight 14.0

static AgoraChatroom *_chatroom;

@interface ELDChatMessageCell ()

@property (nonatomic, strong) UIImageView *roleImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) NSString *msgFrom;
@property (nonatomic, strong) AgoraChatUserInfo *userInfo;
@property (nonatomic, strong) AgoraChatroom *chatroom;


@end

@implementation ELDChatMessageCell
- (void)prepare {
    
    self.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.roleImageView];
    [self.contentView addSubview:self.contentLabel];
    
    self.nameLabel.font = NFont(12.0f);
    self.nameLabel.textColor = TextLabelGrayColor;
    self.iconImageView.layer.cornerRadius = kIconImageViewHeight * 0.5;

}

- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kCellVPadding);
        make.left.equalTo(self.contentView).offset(kEaseLiveDemoPadding);
        make.size.equalTo(@(kIconImageViewHeight));
    }];
        
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView);
        make.height.equalTo(@(kNameLabelHeight));
        make.left.equalTo(self.iconImageView.mas_right).offset(kEaseLiveDemoPadding);
    }];
    
    
    [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0f);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(kCellVPadding);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-kEaseLiveDemoPadding);
    }];
    
}


#pragma mark
- (void)setMesssage:(AgoraChatMessage*)message chatroom:(AgoraChatroom*)chatroom
{
    
    self.chatroom = chatroom;
    NSString *chatroomOwner = self.chatroom.owner;
    
    self.msgFrom = message.from;
    
    [self fetchUserInfo];
    
    if ([message.from isEqualToString:chatroomOwner]) {
        [self.roleImageView setImage:ImageWithName(@"live_streamer")];
    }else if ([self.chatroom.adminList containsObject:message.from]){
        [self.roleImageView setImage:ImageWithName(@"live_moderator")];
    }else {
        [self.roleImageView setImage:ImageWithName(@"")];
    }
    
    self.contentLabel.attributedText = [ELDChatMessageCell _attributedStringWithMessage:message];
    _chatroom = chatroom;
}

- (void)fetchUserInfo {
    [AgoraChatUserInfoManagerHelper fetchUserInfoWithUserIds:@[self.msgFrom] completion:^(NSDictionary * _Nonnull userInfoDic) {
        self.userInfo = [userInfoDic objectForKey:self.msgFrom];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:ImageWithName(@"avatat_2")];
            self.nameLabel.text = self.userInfo.nickName ?:self.userInfo.userId;
        });
    }];
}


+ (CGFloat)heightForMessage:(AgoraChatMessage *)message
{
    CGFloat height = 0;
    CGSize textBlockMinSize = {kContentLabelMaxWidth, CGFLOAT_MAX};
    CGSize retSize;
    NSString *text = [ELDChatMessageCell contentWithMessage:message];
    retSize = [text boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{
                                           NSFontAttributeName:[ELDChatMessageCell contentFont],
                                           NSParagraphStyleAttributeName:[ELDChatMessageCell contentLabelParaStyle]
                                           }
                                 context:nil].size;
    height = retSize.height;
    height += kCellVPadding * 3 + kNameLabelHeight;

    
    return height;
}


+ (NSMutableAttributedString*)_attributedStringWithMessage:(AgoraChatMessage*)message
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[ELDChatMessageCell contentWithMessage:message]];
    
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: [ELDChatMessageCell contentLabelParaStyle],NSFontAttributeName :[ELDChatMessageCell contentFont]};
    [text addAttributes:attributes range:NSMakeRange(0, text.length)];
    return text;
}


+ (NSString *)contentWithMessage:(AgoraChatMessage *)message {
    NSString *latestMessageTitle = @"";
    if (message) {
        AgoraChatMessageBody *messageBody = message.body;
        switch (messageBody.type) {
            case AgoraChatMessageBodyTypeImage:{
                latestMessageTitle = @"[图片]";
            } break;
            case AgoraChatMessageBodyTypeText:{
                NSString *didReceiveText = [EaseEmojiHelper
                                            convertEmoji:((AgoraChatTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
            } break;
            case AgoraChatMessageBodyTypeVoice:{
                latestMessageTitle = @"[语音]";
            } break;
            case AgoraChatMessageBodyTypeLocation: {
                latestMessageTitle = @"[位置]";
            } break;
            case AgoraChatMessageBodyTypeVideo: {
                latestMessageTitle = @"[视频]";
            } break;
            case AgoraChatMessageBodyTypeFile: {
                latestMessageTitle = @"[文件]";
            } break;
            case AgoraChatMessageBodyTypeCustom: {
                latestMessageTitle = [EaseCustomMessageHelper getMsgContent:messageBody];
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}


+ (NSMutableParagraphStyle *)contentLabelParaStyle {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.lineSpacing = [ELDChatMessageCell lineSpacing];
    return paraStyle;
}

+ (CGFloat)lineSpacing{
    return 4.0f;
}

+ (UIFont *)contentFont {
    return BFont(14.0);
}


#pragma mark getter and setter
- (UIImageView *)roleImageView {
    if (_roleImageView == nil) {
        _roleImageView = [[UIImageView alloc] init];
        _roleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _roleImageView;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [ELDChatMessageCell contentFont];
        _contentLabel.textColor = TextLabelWhiteColor;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _contentLabel.numberOfLines = 0;
        _contentLabel.preferredMaxLayoutWidth = KScreenWidth -kIconImageViewHeight -kEaseLiveDemoPadding *3;
    }
    return _contentLabel;
}

@end

#undef kIconImageViewHeight

#undef kCellVPadding

#undef kContentLabelMaxWidth

#undef kNameLabelHeight
