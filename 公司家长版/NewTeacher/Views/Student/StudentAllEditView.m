//
//  StudentAllEditView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StudentAllEditView.h"

@implementation StudentAllEditView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self addButtons:frame];
    }
    
    return self;
}

- (void)addButtons:(CGRect)frame
{
    UIView *butFather = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 225)];
    [butFather setBackgroundColor:[UIColor whiteColor]];
    
    NSArray *titles = @[@"拍 照",@"从手机相册选择",@"视 频",@"取消"];
    NSArray *colors = @[CreateColor(138, 216, 71),CreateColor(233, 169, 45),CreateColor(89, 132, 220),CreateColor(228, 229, 231)];
    CGFloat yOri = 15;
    for (int i = 0; i < titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button.layer setMasksToBounds:YES];
        button.layer.cornerRadius = 5.0;
        [button setTitleColor:(i == titles.count-1) ? [UIColor blackColor] : [UIColor whiteColor] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(25, yOri, frame.size.width - 50, 40)];
        [button addTarget:self action:@selector(editStudentPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:colors[i]];
        [button setTag:i + 1];
        [butFather addSubview:button];
        
        yOri += 40 + 10;
    }
    
    [self addSubview:butFather];
}

- (void)editStudentPhoto:(id)sender
{
    NSInteger index = [sender tag] - 1;
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectEditIndex:)]) {
            [_delegate selectEditIndex:index];
        }
        [self removeFromSuperview];
    }];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - butRec.size.height, butRec.size.width, butRec.size.height)];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
