//
//  SegmentOfThemeView.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/10.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SegmentOfThemeView.h"

@implementation SegmentOfThemeView

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat butWei = frame.size.width / 2;
        for (NSInteger i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(butWei * i, 0, butWei, frame.size.height)];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:CreateColor(50, 164, 198) forState:UIControlStateSelected];
            NSString *name = (i == 0) ? @"segment_left" : @"segment_right";
            NSString *name1 = (i == 0) ? @"segment_left_1" : @"segment_right_1";
            [button setBackgroundImage:CREATE_IMG(name1) forState:UIControlStateNormal];
            [button setBackgroundImage:CREATE_IMG(name) forState:UIControlStateSelected];
            button.selected = (_nCurIdx == i);
            [button setTag:i + 1];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button addTarget:self action:@selector(tabAt:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
    
    return self;
}

- (void)tabAt:(id)sender
{
    NSUInteger index = [sender tag] - 1;
    BOOL isSame = (index == _nCurIdx);
    if (!isSame) {
        ((UIButton *)sender).selected = YES;
        
        UIButton *preBut = (UIButton *)[self viewWithTag:_nCurIdx + 1];
        preBut.selected = NO;
        _nCurIdx = index;
        
        if (self.selectBlock) {
            self.selectBlock(index);
        }
    }
}

- (void)setNCurIdx:(NSUInteger)nCurIdx
{
    if (nCurIdx == _nCurIdx) {
        return;
    }
    
    UIButton *preBut = (UIButton *)[self viewWithTag:_nCurIdx + 1];
    preBut.selected = NO;
    
    UIButton *curBut = (UIButton *)[self viewWithTag:nCurIdx + 1];
    _nCurIdx = nCurIdx;
    curBut.selected = YES;
    
}

@end
