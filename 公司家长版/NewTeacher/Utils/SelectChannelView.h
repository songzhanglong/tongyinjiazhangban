//
//  SelectChannelView.h
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectChannelBlock)(NSInteger index);

@interface SelectChannelView : UIView

@property (nonatomic,copy)SelectChannelBlock selectBlock;
@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,assign)NSUInteger nCurIdx;
@property (nonatomic,strong)UIColor *titleColor;
@property (nonatomic,strong)UIColor *lineColor;

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array Line:(BOOL)hasLine;

@end
