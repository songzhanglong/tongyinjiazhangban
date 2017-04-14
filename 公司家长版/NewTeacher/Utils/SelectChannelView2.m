//
//  SelectChannelView2.m
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectChannelView2.h"

@implementation SelectChannelView2

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        NSInteger numCount = array.count;
        CGFloat butWei = frame.size.width / numCount;
        for (NSInteger i = 0; i < numCount; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (frame.size.height - 9 ) / 2, 9, 9)];
            imgView.image = CREATE_IMG((i == 0) ? @"theme_31" : @"theme_31_1");
            imgView.tag = 10;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(butWei * i, 0, butWei, frame.size.height)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
            [button setTitleColor:CreateColor(153, 153, 153) forState:UIControlStateNormal];
            button.selected = (_nCurIdx == i);
            [button setTag:i + 1];
            [button addSubview:imgView];
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
        UIButton *lastBtn = (UIButton *)[self viewWithTag:_nCurIdx + 1];
        if (lastBtn) {
            UIImageView *imgView = (UIImageView *)[lastBtn viewWithTag:10];
            if (imgView) {
                imgView.image = CREATE_IMG(@"theme_31_1");
            }
        }
        ((UIButton *)sender).selected = YES;
        UIImageView *imgView = (UIImageView *)[((UIButton *)sender) viewWithTag:10];
        if (imgView) {
            imgView.image = CREATE_IMG(@"theme_31");
        }
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
    if (preBut) {
        UIImageView *imgView = (UIImageView *)[preBut viewWithTag:10];
        if (imgView) {
            imgView.image = CREATE_IMG(@"theme_31_1");
        }
    }
    
    UIButton *curBut = (UIButton *)[self viewWithTag:nCurIdx + 1];
    _nCurIdx = nCurIdx;
    curBut.selected = YES;
    
    UIImageView *imgView = (UIImageView *)[curBut viewWithTag:10];
    if (imgView) {
        imgView.image = CREATE_IMG(@"theme_31");
    }
}


@end
