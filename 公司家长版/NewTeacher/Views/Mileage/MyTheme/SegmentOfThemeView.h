//
//  SegmentOfThemeView.h
//  NewTeacher
//
//  Created by 张雪松 on 15/12/10.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SegmentBlock)(NSInteger index);

@interface SegmentOfThemeView : UIView

@property (nonatomic,copy)SegmentBlock selectBlock;
@property (nonatomic,assign)NSUInteger nCurIdx;

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array;

@end