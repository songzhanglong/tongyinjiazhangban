//
//  SelectChannelView.m
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectChannelView.h"

@implementation SelectChannelView
{
    NSInteger _numCount;
}

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array Line:(BOOL)hasLine
{
    self = [super initWithFrame:frame];
    if (self) {
        _numCount = array.count;
        CGFloat butWei = frame.size.width / _numCount;
        for (NSInteger i = 0; i < _numCount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(butWei * i, 0, butWei, frame.size.height)];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            button.selected = (_nCurIdx == i);
            [button setTag:i + 1];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            button.contentEdgeInsets = UIEdgeInsetsMake(5,0, 0, 0);
            [button addTarget:self action:@selector(tabAt:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
        
        if (hasLine) {
            _lineView = [[UIView alloc] init];
            [_lineView setBackgroundColor:CreateColor(227, 167, 116)];
            [_lineView setFrame:CGRectMake(butWei * _nCurIdx, frame.size.height - 2, butWei, 2)];
            [self addSubview:_lineView];
        }
    }
    
    return self;
}

- (void)setTitleColor:(UIColor *)titleColor{
    for (NSInteger i = 0; i < _numCount; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:i + 1];
        [button setTitleColor:titleColor forState:UIControlStateSelected];
    }
}

- (void)setLineColor:(UIColor *)lineColor{
    [_lineView setBackgroundColor:lineColor];
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
        
        CGFloat butWei = preBut.frame.size.width;
        
        __weak typeof(self)weakSelf = self;
        __weak typeof(_lineView)weakLine = _lineView;
        //self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.1 animations:^{
            [weakLine setFrame:CGRectMake(butWei * _nCurIdx, self.frame.size.height - 2, butWei, 2)];
        } completion:^(BOOL finished) {
            //weakSelf.userInteractionEnabled = YES;
            if (weakSelf.selectBlock) {
                weakSelf.selectBlock(index);
            }

        }];
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
    CGFloat butWei = curBut.frame.size.width;
    [_lineView setFrame:CGRectMake(butWei * _nCurIdx, self.frame.size.height - 2, butWei, 2)];

}

@end
