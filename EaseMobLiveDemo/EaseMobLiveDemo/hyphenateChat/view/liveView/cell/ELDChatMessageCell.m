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
    self.nameLabel.textColor = COLOR_HEX(0xFFFFFFBD);
    self.iconImageView.layer.cornerRadius = kIconImageViewHeight * 0.5;

}

- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kCellVPadding);
        make.left.equalTo(self.contentView).offset(10.0f);
        make.size.equalTo(@(kIconImageViewHeight));
    }];
        
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(10.0f);
    }];
    
    
    [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0f);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(5.0);
        make.left.equalTo(self.nameLabel);
        make.bottom.equalTo(self.contentView).offset(-kCellVPadding);
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
    if (message) {
        CGRect rect = [[ELDChatMessageCell _attributedStringWithMessage:message] boundingRectWithSize:CGSizeMake(KCustomerWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        
        if (rect.size.height < 25.f) {
            return 25.f;
        }
        return rect.size.height;
    }
    return 25.f;
}

+ (NSMutableAttributedString*)_attributedStringWithMessage:(AgoraChatMessage*)message
{
    NSMutableAttributedString *text = [ELDChatMessageCell latestMessageTitleForConversationModel:message];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paraStyle,NSFontAttributeName :BFont(14.0f)};
    [text addAttributes:attributes range:NSMakeRange(0, text.length)];
    return text;
}

extern NSMutableDictionary *audienceNickname;
extern NSArray<NSString*> *nickNameArray;
extern NSMutableDictionary *anchorInfoDic;

+ (NSMutableAttributedString *)latestMessageTitleForConversationModel:(AgoraChatMessage*)lastMessage;
{
    NSString *latestMessageTitle = @"";
    if (lastMessage) {
        AgoraChatMessageBody *messageBody = lastMessage.body;
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
    
    int random = (arc4random() % 100);
    NSString *randomNickname = nickNameArray[random];
    if (![audienceNickname objectForKey:lastMessage.from]) {
        [audienceNickname setObject:randomNickname forKey:lastMessage.from];
    } else {
        randomNickname = [audienceNickname objectForKey:lastMessage.from];
    }
    if ([lastMessage.from isEqualToString:_chatroom.owner]) {
        NSMutableDictionary *anchorInfo = [anchorInfoDic objectForKey:_chatroom.chatroomId];
        if (anchorInfo && [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR] && ![[anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR] isEqualToString:@""]) {
            randomNickname = [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];
        }
    }
    if ([lastMessage.from isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
        randomNickname = EaseDefaultDataHelper.shared.defaultNickname;
    }
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@""];
    if (lastMessage.ext) {
        if ([lastMessage.ext objectForKey:@"em_leave"] || [lastMessage.ext objectForKey:@"em_join"]) {
            latestMessageTitle = [NSString stringWithFormat:@"%@ %@",randomNickname,latestMessageTitle];
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
            [attributedStr setAttributes:@{NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.6]} range:NSMakeRange(randomNickname.length + 1, latestMessageTitle.length - randomNickname.length - 1)];
        } else {
            latestMessageTitle = [NSString stringWithFormat:@"%@: %@",randomNickname,latestMessageTitle];
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
            NSRange range = [[attributedStr string] rangeOfString:[NSString stringWithFormat:@"%@: " ,randomNickname] options:NSCaseInsensitiveSearch];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(255, 199, 0, 1) range:NSMakeRange(range.length + range.location, attributedStr.length - (range.length + range.location))];
        }
    } else {
        latestMessageTitle = [NSString stringWithFormat:@"%@: %@",randomNickname,latestMessageTitle];
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        NSRange range = [[attributedStr string] rangeOfString:[NSString stringWithFormat:@"%@: " ,randomNickname] options:NSCaseInsensitiveSearch];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(255, 199, 0, 1) range:NSMakeRange(range.length + range.location, attributedStr.length - (range.length + range.location))];
        if (lastMessage.body.type == AgoraChatMessageBodyTypeCustom) {
            AgoraChatCustomMessageBody *customBody = (AgoraChatCustomMessageBody*)lastMessage.body;
            if ([customBody.event isEqualToString:kCustomMsgChatroomPraise] || [customBody.event isEqualToString:kCustomMsgChatroomGift]) {
                [attributedStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(104, 255, 149, 1) range:NSMakeRange(range.length + range.location, attributedStr.length - (range.length + range.location))];
            }
        }
    }
    return attributedStr;
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
        _contentLabel.font = BFont(14.0f);
        _contentLabel.textColor = TextLabelWhiteColor;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.numberOfLines = 0;
        _contentLabel.preferredMaxLayoutWidth = KScreenWidth - 28.0 - 10.0 * 2;
    }
    return _contentLabel;
}

@end

#undef kIconImageViewHeight

#undef kCellVPadding
