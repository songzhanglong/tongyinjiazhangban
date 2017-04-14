//
//  SegmentOfMileageView.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SegmentOfMileageView.h"

@implementation SegmentOfMileageView

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *backImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [backImg setImage:CREATE_IMG(@"segmentBack")];
        [backImg setBackgroundColor:[UIColor clearColor]];
        [self addSubview:backImg];
        
        CGFloat butWei = frame.size.width / 2;
        for (NSInteger i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(butWei * i, 0, butWei, frame.size.height)];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            NSString *name = (i == 0) ? @"segmentLeft" : @"segmentRight";
            [button setBackgroundImage:CREATE_IMG(name) forState:UIControlStateSelected];
            button.selected = (_nCurIdx == i);
            [button setTag:i + 1];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
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
