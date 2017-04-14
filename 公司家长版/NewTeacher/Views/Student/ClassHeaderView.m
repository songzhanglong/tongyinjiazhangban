//
//  ClassHeaderView.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/4/24.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassHeaderView.h"

@implementation ClassHeaderView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //head
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 20;
        [self addSubview:_headImg];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, frame.size.width - 60, 20)];
        [_nameLab setTextColor:[UIColor darkGrayColor]];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        _nameLab.opaque = YES;
        [self addSubview:_nameLab];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchSelf:)]];
    }
    return self;
}

- (void)touchSelf:(UITapGestureRecognizer *)tap
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchHeadView:)]) {
        [_delegate touchHeadView:self];
    }
}

@end
