//
//  SelectChannelView2.h
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectChannelView.h"

@interface SelectChannelView2 : UIView

@property (nonatomic,copy)SelectChannelBlock selectBlock;
@property (nonatomic,assign)NSUInteger nCurIdx;

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array;

@end
