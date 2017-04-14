//
//  AddRelView.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "AddRelView.h"

@implementation AddRelView

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
        _relNameLab.text = @"亲人";
        [self addSubview:_relNameLab];
        
        _relNameField = [[UITextField alloc]initWithFrame:CGRectMake(_relativeHeaderView.frame.origin.x+_relativeHeaderView.frame.size.width + 20, _relativeHeaderView.frame.origin.y, 50, 40)];
        _relNameField.font = [UIFont systemFontOfSize:18];
        _relNameField.textColor = [UIColor blackColor];
        _relNameField.textAlignment = 1;
        _relNameField.hidden = YES;
        _relNameField.placeholder = @"姓名";
        [self addSubview:_relNameField];
        
        _modNameBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _modNameBut.frame = CGRectMake(frame.size.width - 40, _relNameField.frame.origin.y, 20, 20);
        [_modNameBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_modNameBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"W11" ofType:@"png"]] forState:UIControlStateNormal];
        [_modNameBut addTarget:self action:@selector(changeName:) forControlEvents:UIControlEventTouchUpInside];
        _modNameBut.hidden = YES;
        [self addSubview:_modNameBut];
        
        _makeSureBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _makeSureBut.frame = CGRectMake(frame.size.width - 100, _relNameField.frame.origin.y +10, 80, 20);
        [_makeSureBut setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_makeSureBut setTitle:@"修改名称" forState:UIControlStateNormal];
        [_makeSureBut addTarget:self action:@selector(modeName:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_makeSureBut];
        
        _updateBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _updateBut.frame = CGRectMake(0, _relativeHeaderView.frame.origin.y+_relativeHeaderView.frame.size.height +10, width, 60);
        [_updateBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _updateBut.backgroundColor = [UIColor darkGrayColor];
        [_updateBut setTitle:@"给他看看宝宝最新动态" forState:UIControlStateNormal];
        [_updateBut addTarget:self action:@selector(lookBabyInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_updateBut];
        
        _phoneView = [UIButton buttonWithType:UIButtonTypeCustom];
        _phoneView.frame =CGRectMake(10, _updateBut.frame.size.height+_updateBut.frame.origin.y+10, 30, 30);
        [_phoneView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"w10" ofType:@"png"]] forState:UIControlStateNormal];
        [_phoneView addTarget:self action:@selector(readPhoneNumFormPhone:) forControlEvents:UIControlEventTouchUpInside];
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
        [_RightBut addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_RightBut];
        
    }
    return self;
}

#pragma mark - 确认信息 确认信息之后视图从父视图移除
- (void)makeSure:(UIButton *)sender{
    if (_addRelDelegate && [_addRelDelegate respondsToSelector:@selector(addFamNumber:)]) {
        [_addRelDelegate addFamNumber:self];
    }
    [self removeFromSuperview];
}

#pragma mark - 修改联系人姓名
- (void)changeName:(UIButton *)sender{
    
    if (_addRelDelegate && [_addRelDelegate respondsToSelector:@selector(modFamNumber:)]) {
        [_addRelDelegate modFamNumber:self];
    }
    _relNameField.hidden = YES;
    _relNameLab.hidden = NO;
    _relNameLab.text = _relNameField.text;
}
- (void)lookBabyInfo:(UIButton *)sender{
    if (_addRelDelegate && [_addRelDelegate respondsToSelector:@selector(lookBabyInfo:)]) {
        [_addRelDelegate lookBabyInfo:self];
    }
}
#pragma mark - 从手机通讯录读取联系人信息
- (void)readPhoneNumFormPhone:(UIButton *)sender{
    if (_addRelDelegate &&[_addRelDelegate respondsToSelector:@selector(readIPhonefromMobile:)]) {
        [_addRelDelegate readIPhonefromMobile:self];
    }
}
#pragma mark - 增加旁系亲属
- (void)addNumber:(UIButton *)sender{
    if (_addRelDelegate && [_addRelDelegate respondsToSelector:@selector(addFamNumber:)]) {
        [_addRelDelegate addFamNumber:self];
    }
}
- (void)modeName:(UIButton *)sender{
    _modNameBut.hidden = NO;
    sender.hidden = YES;
    _relNameLab.hidden = YES;
    _relNameField.hidden = NO;
}
@end
