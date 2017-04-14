//
//  SegmentOfMileageView.h
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SegmentBlock)(NSInteger index);

@interface SegmentOfMileageView : UIView

@property (nonatomic,copy)SegmentBlock selectBlock;
@property (nonatomic,assign)NSUInteger nCurIdx;

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array;

@end
