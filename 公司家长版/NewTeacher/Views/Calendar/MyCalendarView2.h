//
//  MyCalendarView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyCalendarView2;
@protocol MyCalendarView2Delegate <NSObject>

@optional
- (void)changeMonth:(MyCalendarView2 *)calendar;
- (void)changeDay:(MyCalendarView2 *)calendar;

@end

@interface MyCalendarView2 : UIView

@property (nonatomic,assign)id<MyCalendarView2Delegate> delegate;
@property (nonatomic,assign)BOOL  isCircle;//圆圈样式,不显示农历
@property (nonatomic,strong)NSDate *curDate;
@property (nonatomic,strong)NSDate *indexDate;
@property (nonatomic,assign)NSInteger year;
@property (nonatomic,assign)NSInteger month;
@property (nonatomic,assign)NSInteger day;
@property (nonatomic,strong)NSMutableArray *curDateArray;

- (void)changeToToday;

@end
