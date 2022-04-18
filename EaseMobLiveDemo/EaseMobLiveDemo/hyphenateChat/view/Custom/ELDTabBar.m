//
//  MISTabBar.m
//  AFNetworking
//
//  Created by liujinliang on 2020/7/24.
//

#import "ELDTabBar.h"
#import <Masonry/Masonry.h>



@interface ELD_TabItem()
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIImage* selectedImage;
@end
@implementation ELD_TabItem


- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                selectedImage:(UIImage *)selectedImage {
    self = [super init];
    if (self) {
        _image = image;
        _selectedImage = selectedImage;
        _selected = NO;
        
        _titleLabel = UILabel.new;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = NFont(11.0f);
        _titleLabel.textColor = COLOR_HEX(0xC9CFCF);
        _titleLabel.text = title;
        
        _iconImageView = UIImageView.new;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.image = image;
        
        [self addSubview:_titleLabel];
        [self addSubview:_iconImageView];
        
        [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(7.0f);
            make.centerX.equalTo(self);
        }];
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView.mas_bottom).offset(2.0);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-7.0f);
        }];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf)]];
    }
    return self;
}

- (void)tapSelf {
    self.selected = !self.selected;
}

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        if (self.selectedBlock)
            self.selectedBlock(self.tag);
    }
    
    _iconImageView.image = selected ? _selectedImage : _image;
    _titleLabel.textColor = selected ? COLOR_HEX(0x3BD5F1) : COLOR_HEX(0xC9CFCF);
}

- (void)updateTabbarItemWithImage:(UIImage *)image
                    selectedImage:(UIImage *)selectedImage {
    _image = image;
    _selectedImage = selectedImage;
    
}

@end


@interface ELDTabBar()
@property (strong, nonatomic) UIButton *broadCastBtn;
@property (nonatomic,strong) UIView *bottomBarBgView;

@end

@implementation ELDTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = UIColor.whiteColor;
        _selectedIndex = -1;
//        self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
//        self.layer.shadowColor = [UIColor colorWithRed:224/255.0 green:231/255.0 blue:239/255.0 alpha:0.5].CGColor;
//        self.layer.shadowOffset = CGSizeMake(0,0);
//        self.layer.shadowOpacity = 1;
//        self.layer.shadowRadius = 13;
        [self addSubview:self.bottomBarBgView];
        
        [self.bottomBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark updateItem
- (void)updateTabbarItemIndex:(NSInteger )itemIndex
                    withImage:(UIImage *)image
                selectedImage:(UIImage *)selectedImage {
    if (itemIndex < self.tabItems.count) {
        ELD_TabItem *tabItem = self.tabItems[itemIndex];
        if (tabItem) {
            [tabItem updateTabbarItemWithImage:image selectedImage:selectedImage];
        }
    }
}


#pragma mark getter and setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        if (selectedIndex >= 0 && selectedIndex < self.tabItems.count) {
            ELD_TabItem* lastItem = nil;
            ELD_TabItem* currentItem = self.tabItems[selectedIndex];
            if (_selectedIndex != -1) {
                lastItem = self.tabItems[_selectedIndex];
            }
            
            //effect
            lastItem.selected = NO;
            currentItem.selected = YES;
            
            //update index
            _selectedIndex = selectedIndex;
            
            //event callback
            if (self.selectedBlock)
                self.selectedBlock(selectedIndex);
        }
    }
}


- (void)setTabItems:(NSArray<ELD_TabItem *> *)tabItems {
    if (_tabItems != tabItems) {
        if (_tabItems.count > 0) {
            [_tabItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        _tabItems = tabItems.copy;
        if (tabItems.count == 0)
            return;
        
        NSInteger tag = 1000;
        for (ELD_TabItem* item in tabItems) {
            ELD_WS
            item.selectedBlock = ^(NSInteger tag) {
                NSInteger index = tag - 1000;
                weakSelf.selectedIndex = index;
            };
            item.tag = tag++;
            [self addSubview:item];
        }
        
        UIView* lastView = nil;
        for (ELD_TabItem* item in tabItems) {
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.left.equalTo(lastView.mas_right);
                    make.width.equalTo(lastView);
                }else {
                    make.left.equalTo(self);
                }
                if (item == tabItems.lastObject) {
                    make.right.equalTo(self);
                }
                make.top.and.bottom.equalTo(self);
            }];
            lastView = item;
        }
    }
}


- (UIView *)bottomBarBgView {
    if (_bottomBarBgView == nil) {
 
        _bottomBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0,100,KScreenWidth, 49)];
        _bottomBarBgView.backgroundColor = UIColor.clearColor;
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"TabbarBg")];
        
        UIView *alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth,49)];
        alphaView.alpha = 0.0;
        
        [_bottomBarBgView addSubview:alphaView];
        [_bottomBarBgView addSubview:bgImageView];
//        [_bottomBarBgView addSubview:self.broadCastBtn];
        
        [alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_bottomBarBgView);
        }];
        
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_bottomBarBgView);
        }];
        
//        [self.broadCastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.height.equalTo(@70);
//            make.centerY.equalTo(_bottomBarBgView.mas_top);
//            make.centerX.equalTo(_bottomBarBgView);
//        }];
    }
    return _bottomBarBgView;
}

- (UIButton *)broadCastBtn
{
    if (_broadCastBtn == nil) {
        _broadCastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_broadCastBtn setImage:[UIImage imageNamed:@"strat_live_stream"] forState:UIControlStateNormal];
        [_broadCastBtn addTarget:self action:@selector(broadCastBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _broadCastBtn.layer.cornerRadius = 35;

    }
    return _broadCastBtn;
}


- (void)broadCastBtnAction
{
    NSLog(@"%s",__func__);
}

@end
