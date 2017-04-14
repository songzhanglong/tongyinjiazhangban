//
//  MileageAllEditView.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageAllEditView.h"

@implementation MileageAllEditView
{
    NSArray *_titles,*_nimgNames,*_himgNames;
    UIView *_bgView,*_butFather;
    int _toFromIndex;
}

- (id)initWithFrame:(CGRect)frame Titles:(NSArray *)titles
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        _titles = titles;
        _toFromIndex = 1;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.3;
        [self addSubview:view];
        
        [self addButtonsNoImage:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame Titles:(NSArray *)titles NImageNames:(NSArray *)nimgNames HImageNames:(NSArray *)himgNames
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        _titles = titles;
        _nimgNames = nimgNames;
        _himgNames = himgNames;
        _toFromIndex = 0;
        [self addButtons:frame];
    }
    
    return self;
}

- (void)addButtonsNoImage:(CGRect)frame
{
    UIView *butFather = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 45*([_titles count] + 1) + 5)];
    [butFather setBackgroundColor:CreateColor(226, 227, 230)];
    _butFather = butFather;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, (45 + 0.5)*[_titles count])];
    bgView.backgroundColor = [UIColor whiteColor];
    _bgView = bgView;
    bgView.userInteractionEnabled = YES;
    [butFather addSubview:bgView];
    
    for (int i = 0; i < [_titles count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, (45 + 0.5) * i, frame.size.width, 45)];
        [button setTitle:[_titles objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:(i == 0) ? [UIColor redColor] : [UIColor blackColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button addTarget:self action:@selector(editStudentPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i + 1];
        [butFather addSubview:button];
        
        if (i != [_titles count] - 1) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 45 * (i + 1), frame.size.width, 0.5)];
            label.backgroundColor = CreateColor(226, 227, 230);
            [butFather addSubview:label];
        }
    }
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, butFather.frame.size.height - 45, frame.size.width, 45)];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [cancelBtn setTag:[_titles count] + 1];
    [cancelBtn addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [butFather addSubview:cancelBtn];
    
    [self addSubview:butFather];
}

- (void)cancelPressed:(id)sender
{
    UIView *butFather = [[self subviews] objectAtIndex:_toFromIndex];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(cancelEditIndex)]) {
            [_delegate cancelEditIndex];
        }
        [self removeFromSuperview];
    }];
}

- (void)addButtons:(CGRect)frame
{
    UIView *butFather = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 136)];
    [butFather setBackgroundColor:CreateColor(226, 227, 230)];
    _butFather = butFather;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 90)];
    bgView.backgroundColor = [UIColor whiteColor];
    _bgView = bgView;
    bgView.userInteractionEnabled = YES;
    [butFather addSubview:bgView];
    
    CGFloat butWei = 43;
    CGFloat col = (bgView.frame.size.width - butWei * [_titles count]) / ([_titles count] + 1);
    for (int i = 0; i < [_titles count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(col + (col + butWei) * i, (bgView.frame.size.height - butWei - 20) / 2, butWei, butWei)];
        [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_nimgNames[i] ofType:@"png"]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_himgNames[i] ofType:@"png"]] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(editStudentPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i + 1];
        [butFather addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y + button.frame.size.height + 5, butWei, 15)];
        label.backgroundColor = [UIColor clearColor];
        label.text = _titles[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        [butFather addSubview:label];
    }
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, butFather.frame.size.height - 45, frame.size.width, 45)];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cancelBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [cancelBtn setTag:[_titles count] + 1];
    [cancelBtn addTarget:self action:@selector(editStudentPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [butFather addSubview:cancelBtn];
    
    [self addSubview:butFather];
}

- (void)editStudentPhoto:(id)sender
{
    NSInteger index = [sender tag] - 1;
    UIView *butFather = [[self subviews] objectAtIndex:_toFromIndex];
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
    UIView *butFather = [[self subviews] objectAtIndex:_toFromIndex];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - butRec.size.height, butRec.size.width, butRec.size.height)];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *butFather = [[self subviews] objectAtIndex:_toFromIndex];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)resetColorOfGrowAlbum
{
    [_butFather setBackgroundColor:CreateColor(33.0, 27.0, 25.0)];
    [_bgView setBackgroundColor:[UIColor blackColor]];
    for (UIView *subView in _butFather.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [(UILabel *)subView setTextColor:[UIColor whiteColor]];
            [subView setBackgroundColor:_bgView.backgroundColor];
        }
        else if ([subView isKindOfClass:[UIButton class]]){
            [(UIButton *)subView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [subView setBackgroundColor:_bgView.backgroundColor];
        }
    }
}

@end
