//
//  LXCalendarOneController.m
//  LXCalendar
//
//  Created by chenergou on 202117/11/3.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXCalendarOneController.h"
#import "LXCalender.h"
#import "LXCalendarCategoryHeader.h"

@interface LXCalendarOneController ()
@property(nonatomic,strong)LXCalendarView *calenderView;

@end

@implementation LXCalendarOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor =[UIColor whiteColor];
    
    self.title = @"";
    self.calenderView =[[LXCalendarView alloc]initWithFrame:CGRectMake(20, 80, KScreenWidth - 40, 0)];
    
    self.calenderView.currentMonthTitleColor =[UIColor hexStringToColor:@"2c2c2c"];
    self.calenderView.lastMonthTitleColor =[UIColor hexStringToColor:@"8a8a8a"];
    self.calenderView.nextMonthTitleColor =[UIColor hexStringToColor:@"8a8a8a"];
    
    self.calenderView.isHaveAnimation = NO;
    
    self.calenderView.isCanScroll = YES;
    self.calenderView.isShowLastAndNextBtn = YES;
    
    self.calenderView.isShowLastAndNextDate = YES;

    self.calenderView.todayTitleColor =[UIColor redColor];
    
    self.calenderView.selectBackColor =[UIColor greenColor];
    
    [self.calenderView dealData];
    
    self.calenderView.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:self.calenderView];
    
    ELD_WS
    self.calenderView.selectBlock = ^(NSInteger year, NSInteger month, NSInteger day, NSInteger selectedIndex) {
        NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@",[@(year) stringValue],[weakSelf convert2StringWithInt:month],[weakSelf convert2StringWithInt:day]];
        NSLog(@"%ld年 - %ld月 - %ld日",year,month,day);

        if (weakSelf.selectedBlock) {
            weakSelf.selectedBlock(dateString);
        }
        
        if (selectedIndex %2 == 0) {
            [weakSelf.calenderView updateCalendarWithIndex:selectedIndex isNormal:YES];

        }else {
            [weakSelf.calenderView updateCalendarWithIndex:selectedIndex isNormal:NO];

        }
    };
    
}

- (NSString *)convert2StringWithInt:(NSInteger)intValue {
    NSString *result = [@(intValue) stringValue];
    if (result.length == 1) {
        result = [NSString stringWithFormat:@"0%@",result];
    }
    return result;
}


@end
