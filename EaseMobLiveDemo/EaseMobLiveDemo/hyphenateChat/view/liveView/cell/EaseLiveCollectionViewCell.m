//
//  EaseCollectionViewCell.m
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveCollectionViewCell.h"

#import "EaseLiveRoom.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Masonry.h"

#define kLabelDefaultHeight 22.f
#define kCellSpace 5.f


@interface EaseLiveCollectionViewCell ()
{
    BOOL isBroadcasting; //房间是否正直播
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIImageView *liveWatcherCountBgImageView;
@property (nonatomic, strong) UIImageView *liveImageView;
@property (nonatomic, strong) UIView *broadcastView;
@property (nonatomic, strong) UIView *liveFooter;
@property (nonatomic, strong) UIView *liveHeader;
@property (nonatomic, strong) UILabel *roomTitleLabel;
@property (nonatomic, strong) UILabel *liveroomNameLabel;
@property (nonatomic, strong) UILabel *watchNumberLabel;
@property (nonatomic, strong) UILabel *liveStreamerNameLabel;

@property (nonatomic, strong) UIView *studioOccupancy;//直播间正直播

@property (nonatomic, strong) CAGradientLayer *broadcastGl;

@property (nonatomic, strong) UIImageView *liveStreamerImageView;

@end

@implementation EaseLiveCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.liveImageView];
    }
    return self;
}

- (UILabel*)roomTitleLabel
{
    if (_roomTitleLabel == nil) {
        _roomTitleLabel = [[UILabel alloc] init];
        _roomTitleLabel.frame = CGRectMake(8.f, 0, CGRectGetWidth(self.frame)/2, 14.f);
        _roomTitleLabel.font = [UIFont systemFontOfSize:10.f];
        _roomTitleLabel.textColor = [UIColor whiteColor];
        _roomTitleLabel.textAlignment = NSTextAlignmentLeft;
        _roomTitleLabel.layer.masksToBounds = YES;
        _roomTitleLabel.shadowColor = [UIColor blackColor];
        _roomTitleLabel.shadowOffset = CGSizeMake(1, 1);
    }
    return _roomTitleLabel;
}

- (UILabel*)liveroomNameLabel
{
    if (_liveroomNameLabel == nil) {
        _liveroomNameLabel = [[UILabel alloc] init];
        _liveroomNameLabel.font = [UIFont systemFontOfSize:14.0f];
        _liveroomNameLabel.textColor = [UIColor whiteColor];
        _liveroomNameLabel.textAlignment = NSTextAlignmentLeft;
        _liveroomNameLabel.backgroundColor = [UIColor clearColor];
        _liveroomNameLabel.shadowColor = [UIColor blackColor];
        _liveroomNameLabel.shadowOffset = CGSizeMake(1, 1);
        _liveroomNameLabel.textAlignment = NSTextAlignmentLeft;
        _liveroomNameLabel.text = @"Chats Casually";
    }
    return _liveroomNameLabel;
}

- (UILabel *)liveStreamerNameLabel
{
    if (_liveStreamerNameLabel == nil) {
        _liveStreamerNameLabel = [[UILabel alloc] init];
        _liveStreamerNameLabel.font = [UIFont systemFontOfSize:10.f];
        _liveStreamerNameLabel.textColor = [UIColor whiteColor];
        _liveStreamerNameLabel.textAlignment = NSTextAlignmentLeft;
        _liveStreamerNameLabel.backgroundColor = [UIColor clearColor];
        _liveStreamerNameLabel.shadowColor = [UIColor blackColor];
        _liveStreamerNameLabel.shadowOffset = CGSizeMake(1, 1);
        _liveStreamerNameLabel.text = @"Paulo Apollo";
    }
    return _liveStreamerNameLabel;
}

- (UILabel*)watchNumberLabel
{
    if (_watchNumberLabel == nil) {
        _watchNumberLabel = [[UILabel alloc] init];
        _watchNumberLabel.font = [UIFont systemFontOfSize:12.f];
        _watchNumberLabel.textColor = [UIColor whiteColor];
        _watchNumberLabel.textAlignment = NSTextAlignmentLeft;
        _watchNumberLabel.shadowColor = [UIColor blackColor];
        _watchNumberLabel.shadowOffset = CGSizeMake(1, 1);
        _watchNumberLabel.text = @"32K";
    }
    return _watchNumberLabel;
}

- (UIView*)liveFooter
{
    if (_liveFooter == nil) {
        _liveFooter = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kLabelDefaultHeight, CGRectGetWidth(self.frame), kLabelDefaultHeight)];
        _liveFooter.backgroundColor = [UIColor clearColor];
        
        [_liveFooter addSubview:self.liveroomNameLabel];
        [_liveFooter addSubview:self.liveStreamerImageView];
        [_liveFooter addSubview:self.liveStreamerNameLabel];

        [self.liveStreamerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.liveFooter).offset(-kEaseLiveDemoPadding);
            make.left.equalTo(_liveFooter).offset(kEaseLiveDemoPadding);
        }];

        [self.liveStreamerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.liveStreamerImageView);
            make.left.equalTo(self.liveStreamerImageView.mas_right).offset(kEaseLiveDemoPadding * 0.5);
            make.width.equalTo(@100.0);
            make.height.equalTo(@12);
        }];
        
        [self.liveroomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.liveStreamerImageView.mas_top).offset(-2.0);
            make.left.equalTo(self.liveStreamerImageView);
            make.right.equalTo(_liveFooter).offset(-kEaseLiveDemoPadding);
//            make.height.equalTo(@12);
        }];
        
    }
    return _liveFooter;
}


- (UIView*)liveHeader
{
    if (_liveHeader == nil) {
        _liveHeader = [[UIView alloc] initWithFrame:CGRectMake(8.f, 8.f, 75.f, 14.0f)];
        _liveHeader.backgroundColor = [UIColor clearColor];
        _liveHeader.layer.cornerRadius = 7.0f;
        _liveHeader.clipsToBounds = YES;
        [_liveHeader addSubview:self.liveWatcherCountBgImageView];
        [_liveHeader addSubview:self.headImageView];
        [_liveHeader addSubview:self.watchNumberLabel];

        [self.liveWatcherCountBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_liveHeader);
        }];

        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_liveHeader);
            make.width.height.equalTo(@6.0);
            make.left.equalTo(_liveHeader.mas_left).offset(5.f);
        }];
        
        [self.watchNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.headImageView);
            make.left.equalTo(self.headImageView.mas_right).offset(5.f);
            make.right.equalTo(_liveHeader).offset(-5.0f);
        }];
        
    }
    return _liveHeader;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Live_watch"]];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.layer.masksToBounds = YES;
    }
    return _headImageView;
}


- (UIImageView *)liveWatcherCountBgImageView {
    if (_liveWatcherCountBgImageView == nil) {
        _liveWatcherCountBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LiveStreamer_watch_bg"]];
        _liveWatcherCountBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveWatcherCountBgImageView.layer.masksToBounds = YES;
    }
    return _liveWatcherCountBgImageView;
}

- (UIImageView*)liveImageView {
    if (_liveImageView == nil) {
        _liveImageView = [[UIImageView alloc] init];
        _liveImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        _liveImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveImageView.layer.cornerRadius = 16.0f;
        _liveImageView.layer.masksToBounds = YES;
        _liveImageView.backgroundColor = RGBACOLOR(200, 200, 200, 1);
        
        [_liveImageView addSubview:self.liveHeader];
        [_liveImageView addSubview:self.liveFooter];
        [_liveImageView addSubview:self.studioOccupancy];//正在直播
        [_liveImageView addSubview:self.broadcastView];//开播
        
        [self.liveHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_liveImageView).offset(8.0f);
            make.left.equalTo(_liveImageView).offset(8.0f);
        }];
        
        
    }
    return _liveImageView;
}

- (UIView*)broadcastView
{
    if (_broadcastView == nil) {
        _broadcastView = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width / 2.f - 55, self.frame.size.height / 2.f - 17.5, 110.f, 35.f)];
        _broadcastView.layer.cornerRadius = 17;
        [_broadcastView.layer addSublayer:self.broadcastGl];
        _broadcastView.backgroundColor = [UIColor clearColor];
        UIImageView *broadcastImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-broadcast"]];
        broadcastImg.contentMode = UIViewContentModeScaleAspectFill;
        broadcastImg.layer.masksToBounds = YES;
        [_broadcastView addSubview:broadcastImg];
        [broadcastImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@13.f);
            make.height.equalTo(@15.f);
            make.left.equalTo(_broadcastView.mas_left).offset(10.f);
            make.top.equalTo(_broadcastView.mas_top).offset(10.f);
        }];
        UILabel *broadcastLabel = [[UILabel alloc]init];
        broadcastLabel.text = @"start live";
        broadcastLabel.textColor = [UIColor whiteColor];
        broadcastLabel.font = [UIFont systemFontOfSize:16.f];
        [_broadcastView addSubview:broadcastLabel];
        [broadcastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@70);
            make.height.equalTo(@20);
            make.right.equalTo(_broadcastView.mas_right).offset(-7.5);
            make.top.equalTo(_broadcastView.mas_top).offset(7.5);
        }];
    }
    return _broadcastView;
}

- (UIView *)studioOccupancy
{
    if (_studioOccupancy == nil) {
        _studioOccupancy = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _studioOccupancy.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.34];
        UILabel *broadcastingTag = [[UILabel alloc]init];
        broadcastingTag.text = @"The anchor is liveing cannot choose";
        broadcastingTag.lineBreakMode = NSLineBreakByTruncatingTail;
        broadcastingTag.numberOfLines = 2;
        broadcastingTag.font = [UIFont systemFontOfSize:12.f];
        broadcastingTag.textColor = [UIColor whiteColor];
        broadcastingTag.textAlignment = NSTextAlignmentCenter;
        broadcastingTag.layer.borderWidth = 2;
        broadcastingTag.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
        broadcastingTag.layer.cornerRadius = 12.5;
        [_studioOccupancy addSubview:broadcastingTag];
        [broadcastingTag mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@40);
            make.center.equalTo(_studioOccupancy);
        }];
    }
    return _studioOccupancy;
}


- (CAGradientLayer *)broadcastGl{
    if(_broadcastGl == nil){
        _broadcastGl = [CAGradientLayer layer];
        _broadcastGl.frame = CGRectMake(0,0,_broadcastView.frame.size.width,_broadcastView.frame.size.height);
        _broadcastGl.startPoint = CGPointMake(0.76, 0.84);
        _broadcastGl.endPoint = CGPointMake(0.26, 0.1);
        _broadcastGl.colors = @[(__bridge id)[UIColor colorWithRed:90/255.0 green:208/255.0 blue:130/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:4/255.0 green:239/255.0 blue:240/255.0 alpha:1.0].CGColor];
        _broadcastGl.locations = @[@(0), @(1.0f)];
        _broadcastGl.cornerRadius = 17;
    }
    return _broadcastGl;
}

- (UIImageView *)liveStreamerImageView {
    if (_liveStreamerImageView == nil) {
        _liveStreamerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LiveStreamer"]];
        _liveStreamerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveStreamerImageView.layer.masksToBounds = YES;
    }
    return _liveStreamerImageView;
}

- (void)setLiveRoom:(EaseLiveRoom*)room liveBehavior:(kTabbarItemBehavior)liveBehavior
{
    self.liveStreamerNameLabel.text = room.anchor;
    
    self.liveroomNameLabel.text = room.title;
    
    if (room.coverPictureUrl.length > 0) {
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:room.coverPictureUrl];
        if (!image) {
            __weak typeof(self) weakSelf = self;
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:room.coverPictureUrl]
                                                                  options:SDWebImageDownloaderUseNSURLCache
                                                                 progress:NULL
                                                                completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                    UIImage *backimage = nil;
                                                                    NSString *key = nil;
                                                                    if (image) {
                                                                        backimage = image;
                                                                        key = room.coverPictureUrl;
                                                                    } else {
                                                                        backimage = [UIImage imageNamed:@"default_back_image"];
                                                                        key = @"default_back_image";
                                                                    }
                                                                    [[SDImageCache sharedImageCache] storeImage:backimage forKey:key toDisk:NO completion:^{
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            weakSelf.liveImageView.image = backimage;
                                                                        });
                                                                    }];
                                                                }];
        } else {
            _liveImageView.image = image;
        }
    } else {
        _liveImageView.image = [UIImage imageNamed:@"default_back_image"];
    }
    self.watchNumberLabel.text  = [NSString stringWithFormat:@"%ld",(long)room.currentUserCount];
    
    //判断房间状态
    if (liveBehavior == kTabbarItemTag_Live) {
        self.studioOccupancy.hidden = YES;
        self.broadcastView.hidden = YES;
    } else if (liveBehavior == kTabbarItemTag_Broadcast) {
        self.liveHeader.hidden = YES;
        if (room.status == ongoing) {
            self.studioOccupancy.hidden = NO;
            self.broadcastView.hidden = YES;
            self.liveFooter.hidden = NO;
            self.userInteractionEnabled = YES;
        } else if (room.status == offline) {
            self.studioOccupancy.hidden = YES;
            self.broadcastView.hidden = NO;
            self.liveFooter.hidden = YES;
            self.userInteractionEnabled = YES;
        }
    }
}


@end
