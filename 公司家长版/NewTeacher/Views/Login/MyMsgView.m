//
//  MyMsgView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/2/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyMsgView.h"

@implementation MyMsgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        _headImg.layer.cornerRadius = 20;
        _headImg.layer.masksToBounds = YES;
        [self addSubview:_headImg];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 20)];
        [_nameLab setFont:[UIFont systemFontOfSize:16]];
        [_nameLab setTextColor:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0]];
        [self addSubview:_nameLab];
        
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, [UIScreen mainScreen].bounds.size.width - 70, 20)];
        [_contentLab setNumberOfLines:0];
        [_contentLab setFont:[UIFont systemFontOfSize:16]];
        [_contentLab setTextColor:[UIColor blackColor]];
        [self addSubview:_contentLab];
        
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 50, [UIScreen mainScreen].bounds.size.width - 70, 18)];
        [_timeLab setFont:[UIFont systemFontOfSize:14]];
        [_timeLab setTextColor:[UIColor darkGrayColor]];
        [self addSubview:_timeLab];
    }
    return self;
}

@end
