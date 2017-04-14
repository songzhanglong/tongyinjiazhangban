//
//  DJTPieChart.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DJTPieChart;
@protocol DJTPieChartDataSource <NSObject>
@required
- (NSUInteger)numberOfSlicesInPieChart:(DJTPieChart *)pieChart;
- (CGFloat)pieChart:(DJTPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index;
@optional
- (UIColor *)pieChart:(DJTPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index;
- (NSString *)pieChart:(DJTPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index;
@end

@protocol DJTPieChartDelegate <NSObject>
@optional
- (void)pieChart:(DJTPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(DJTPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(DJTPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(DJTPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index;
@end

@interface DJTPieChart : UIView
{
    int countNum;
}
@property(nonatomic, weak) id<DJTPieChartDataSource> dataSource;
@property(nonatomic, weak) id<DJTPieChartDelegate> delegate;
@property(nonatomic, assign) CGFloat startPieAngle;
@property(nonatomic, assign) CGFloat animationSpeed;
@property(nonatomic, assign) CGPoint pieCenter;
@property(nonatomic, assign) CGFloat pieRadius;
@property(nonatomic, assign) BOOL    showLabel;
@property(nonatomic, strong) UIFont  *labelFont;
@property(nonatomic, strong) UIColor *labelColor;
@property(nonatomic, strong) UIColor *labelShadowColor;
@property(nonatomic, assign) CGFloat labelRadius;
@property(nonatomic, assign) CGFloat selectedSliceStroke;
@property(nonatomic, assign) CGFloat selectedSliceOffsetRadius;
@property(nonatomic, assign) BOOL    showPercentage;
- (id)initWithFrame:(CGRect)frame Center:(CGPoint)center Radius:(CGFloat)radius;
- (void)reloadData;
- (void)setPieBackgroundColor:(UIColor *)color;

- (void)setSliceSelectedAtIndex:(NSInteger)index;
- (void)setSliceDeselectedAtIndex:(NSInteger)index;

@end;