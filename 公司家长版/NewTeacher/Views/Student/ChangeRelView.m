//
//  ChangeRelView.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/8.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ChangeRelView.h"

@implementation ChangeRelView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        _relativeHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 50, 50)];
        _relativeHeaderView.layer.cornerRadius = 25;
        _relativeHeaderView.layer.masksToBounds  = YES;
        [self addSubview:_relativeHeaderView];
        
        _relNameLab = [[UILabel alloc]initWithFrame:CGRectMake(_relativeHeaderView.frame.origin.x+_relativeHeaderView.frame.size.width + 20, _relativeHeaderView.frame.origin.y, 50, 40)];
        _relNameLab.font = [UIFont systemFontOfSize:18];
        _relNameLab.textColor = [UIColor blackColor];
        _relNameLab.textAlignment = 1;
        _relNameLab.text = @"爷爷";
        [self addSubview:_relNameLab];
        
        _updateBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _updateBut.frame = CGRectMake(0, _relativeHeaderView.frame.origin.y+_relativeHeaderView.frame.size.height +10, width, 60);
        [_updateBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _updateBut.backgroundColor = [UIColor darkGrayColor];
        [_updateBut setTitle:@"给他看看宝宝最新动态" forState:UIControlStateNormal];
        [self addSubview:_updateBut];
        
        _phoneView = [UIButton buttonWithType:UIButtonTypeCustom];
        _phoneView.frame =CGRectMake(10, _updateBut.frame.size.height+_updateBut.frame.origin.y+10, 30, 30);
        [_phoneView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"w10" ofType:@"png"]] forState:UIControlStateNormal];
        [_phoneView addTarget:self action:@selector(readPhoneNumFormPhone) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_phoneView];
        
        _phoneNumberLab = [[UITextField alloc]initWithFrame:CGRectMake(_phoneView.frame.size.width+_phoneView.frame.origin.x + 5, _phoneView.frame.origin.y, 150, 30)];
        _phoneNumberLab.textColor = [UIColor colorWithRed:34.0/255.0 green:112.0/255.0 blue:246.0/255.0 alpha:1];
        _phoneNumberLab.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
        _phoneNumberLab.placeholder = @"填写手机号码";
        _phoneNumberLab.textAlignment = 1;
        [self addSubview:_phoneNumberLab];
        
        _RightBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _RightBut.frame = CGRectMake(self.bounds.size.width-100, _phoneNumberLab.frame.origin.y , 100, 40);
        [_RightBut setTitleColor:[UIColor colorWithRed:61/255.0 green:(197/255.0) blue:16/255.0 alpha:1] forState:UIControlStateNormal];
        [_RightBut setTitle:@"确定" forState:UIControlStateNormal];
        [_RightBut addTarget:self action:@selector(makeSure:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_RightBut];
        
        _deleteBut = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-15,-10, 30, 30)];
        [_deleteBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"closed2" ofType:@"png"]]];
        _deleteBut.layer.cornerRadius =20;
        _deleteBut.layer.masksToBounds =YES;
        [self addSubview:_deleteBut];
        
    }
    return self;
}

#pragma mark - 确认信息 确认信息之后视图从父视图移除
- (void)makeSure:(UIButton *)sender{
    if (_changeRelDelegate && [_changeRelDelegate respondsToSelector:@selector(makeSureRelativeInfo:)]) {
        [_changeRelDelegate makeSureRelativeInfo:self];
    }
    [self removeFromSuperview];
}

#pragma mark - 从手机通讯录读取联系人信息
- (void)readPhoneNumFormPhone{
    if (_changeRelDelegate &&[_changeRelDelegate respondsToSelector:@selector(readiPhoneNumFromPhone:)]) {
        [_changeRelDelegate readiPhoneNumFromPhone:self];
    }
}
@end
