//
//  SelectItemView.m
//  ChildrenKing
//
//  Created by songzhanglong on 15/3/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectItemView.h"
#import "DJTGlobalDefineKit.h"

#define ITEM_TAG    100

@implementation SelectItemView
{
    NSInteger _nCount;
}

- (void)setItems:(NSArray *)array
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _nCount = array.count;
    CGFloat margin = 20.0;
    CGFloat labHei = 21;
    CGFloat butWei = (self.frame.size.width - margin * 2) / 2;
    CGFloat xOri = (2 - _nCount) * butWei + margin,yOri = (self.frame.size.height - labHei) / 2;
    for (NSInteger i = 0; i < _nCount; i++) {
        CGRect butRec = CGRectMake((butWei + margin) * i + xOri, 0, butWei, self.frame.size.height);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTag:i + 1];
        [button setFrame:butRec];
        [button setBackgroundColor:[UIColor clearColor]];
        [button addTarget:self action:@selector(changeSelectIndex:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        //label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(butRec.origin.x, yOri, butRec.size.width - butRec.size.height, labHei)];
        //[label setTextAlignment:2];
        [label setText:array[i]];
        [label setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:label];
        
        //image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(butRec.origin.x + butRec.size.width - butRec.size.height, butRec.origin.y, butRec.size.height, butRec.size.height)];
        [imageView setTag:ITEM_TAG + i];
        [imageView setImage:(_nCurIndex == i) ? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RadioboxH" ofType:@"png"]] : [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Radiobox" ofType:@"png"]]];
        [self addSubview:imageView];
    }
}

- (void)changeSelectIndex:(id)sender
{
    NSInteger index = [sender tag] - 1;
    if (_nCurIndex != index) {
        
        UIImageView *imageView1 = (UIImageView *)[self viewWithTag:ITEM_TAG + _nCurIndex];
        [imageView1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Radiobox" ofType:@"png"]]];
        
        UIImageView *imageView2 = (UIImageView *)[self viewWithTag:ITEM_TAG + index];
        [imageView2 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RadioboxH" ofType:@"png"]]];
        
        _nCurIndex = index;
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeSelectItem)]) {
            [_delegate changeSelectItem];
        }
    }
}

- (void)setNCurIndex:(NSInteger)nCurIndex
{
    if (_nCurIndex != nCurIndex) {
        UIImageView *imageView1 = (UIImageView *)[self viewWithTag:ITEM_TAG + _nCurIndex];
        [imageView1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Radiobox" ofType:@"png"]]];
        
        UIImageView *imageView2 = (UIImageView *)[self viewWithTag:ITEM_TAG + nCurIndex];
        [imageView2 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RadioboxH" ofType:@"png"]]];
        
        _nCurIndex = nCurIndex;
    }
}

@end
