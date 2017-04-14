//
//  DelStudentPhoto.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DelStudentPhoto.h"

@implementation DelStudentPhoto

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        for (int i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(6 + (66 + 6) * i, (frame.size.height - 33) / 2, 66, 33)];
            [button setTag:i + 1];
            [button setTitle:(i == 0) ? @"全选" : @"反选" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundColor:[UIColor darkGrayColor]];
            [self addSubview:button];
            if (i == 0) {
                _allButton = button;
            }
            else
            {
                _otherButton = button;
            }
        }
        //delete
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(frame.size.width - 90 - 6, (frame.size.height - 33) / 2, 90, 33)];
        [button setTag:3];
        [button setTitle:[NSString stringWithFormat:@"删除(0)"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:[UIColor redColor]];
        _delBut = button;
        [self addSubview:_delBut];
    }
    return self;
}

- (void)setDelNum:(NSInteger)delNum
{
    [_delBut setTitle:[NSString stringWithFormat:@"删除(%ld)",(long)delNum] forState:UIControlStateNormal];
}
/*
- (void)pressButton:(id)button
{
    NSInteger index = [button tag] - 1;
    if (_delegate && [_delegate respondsToSelector:@selector(selectDeleteIdx:)]) {
        [_delegate selectDeleteIdx:index];
    }
}*/

- (void)pressButton:(id)button
{
    if([button tag]==3){
        NSInteger index = [button tag] - 1;
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"是否删除消息？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag=index;
        [alertView show];
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(selectDeleteIdx:)]) {
            [_delegate selectDeleteIdx:[button tag]-1];
        }
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectDeleteIdx:)]) {
            [_delegate selectDeleteIdx:alertView.tag];
        }
    }
    
}

@end
