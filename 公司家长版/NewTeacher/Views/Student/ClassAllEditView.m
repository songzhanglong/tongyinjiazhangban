//
//  ClassAllEditView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/14.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassAllEditView.h"

@implementation ClassAllEditView

- (void)addButtons:(CGRect)frame
{
    UIView *butFather = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 175)];
    [butFather setBackgroundColor:[UIColor whiteColor]];
    
    NSArray *titles = @[@"上传照片",@"删除图片",@"取消"];
    NSArray *colors = @[[UIColor greenColor],[UIColor redColor],[UIColor lightGrayColor]];
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

@end
