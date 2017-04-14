
//
//  RelativeView.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "RelativeView.h"

@implementation RelativeView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        _relativeHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 50, 50)];
        _relativeHeaderView.layer.cornerRadius = 25;
        _relativeHeaderView.layer.masksToBounds  = YES;
        [self addSubview:_relativeHeaderView];
        
        _relativeNameLab =[[UILabel alloc]initWithFrame:CGRectMake(_relativeHeaderView.frame.origin.x+_relativeHeaderView.frame.size.width + 20, _relativeHeaderView.frame.origin.y, 50, 40)];
        _relativeNameLab.font = [UIFont systemFontOfSize:18];
        _relativeNameLab.textColor = [UIColor blackColor];
        _relativeNameLab.textAlignment = 1;
        _relativeNameLab.text = @"爷爷";
        [self addSubview:_relativeNameLab];
        
        _updateBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _updateBut.frame = CGRectMake(0, _relativeHeaderView.frame.origin.y+_relativeHeaderView.frame.size.height +10, width, 60);
        [_updateBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _updateBut.backgroundColor = [UIColor darkGrayColor];
        [_updateBut setTitle:@"给他看看宝宝最新动态" forState:UIControlStateNormal];
        [_updateBut addTarget:self action:@selector(babyActivity) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_updateBut];
        
        _phoneView = [UIButton buttonWithType:UIButtonTypeCustom];
        _phoneView.frame =CGRectMake(10, _updateBut.frame.size.height+_updateBut.frame.origin.y+10, 30, 30);
        [_phoneView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"w10-1" ofType:@"png"]] forState:UIControlStateNormal];
        [_phoneView addTarget:self action:@selector(readPhoneNumFormPhone) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_phoneView];
        
        _phoneNumberLab = [[UILabel alloc]initWithFrame:CGRectMake(_phoneView.frame.size.width+_phoneView.frame.origin.x - 10, _phoneView.frame.origin.y-5, 150, 40)];
        _phoneNumberLab.textColor = [UIColor colorWithRed:34.0/255.0 green:112.0/255.0 blue:246.0/255.0 alpha:1];
        _phoneNumberLab.textAlignment = 1;
        _phoneNumberLab.font = [UIFont systemFontOfSize:12];
        if (!_model.mobile) {
            _phoneNumberLab.text = @"暂无联系方式";
        }else{
            _phoneNumberLab.text = _model.mobile;
        }
        [self addSubview:_phoneNumberLab];
        
        _changePhoneBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _changePhoneBut.frame = CGRectMake(self.bounds.size.width-100, _phoneNumberLab.frame.origin.y , 100, 40);
        [_changePhoneBut setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_changePhoneBut setTitle:@"号码不对?" forState:UIControlStateNormal];
        [_changePhoneBut addTarget:self action:@selector(changePhoneNunber) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changePhoneBut];

        _callPoneBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _callPoneBut.frame = CGRectMake(_phoneNumberLab.frame.origin.x, _phoneNumberLab.frame.origin.y+_phoneNumberLab.frame.size.height - 10, 150, 20);
        [_callPoneBut setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _callPoneBut.titleLabel.font = [UIFont systemFontOfSize:12];
        [_callPoneBut setTitle:@"给他打电话吧～" forState:UIControlStateNormal];
        [_callPoneBut addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_callPoneBut];
        
        _deleteBut = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-15,-10, 30, 30)];
        [_deleteBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"closed2" ofType:@"png"]]];
        _deleteBut.layer.cornerRadius =20;
        _deleteBut.layer.masksToBounds =YES;
        [self addSubview:_deleteBut];
        
    }
    return self;
}

- (void)babyActivity{
    if (_relDelegate && [_relDelegate respondsToSelector:@selector(babyActivity:)]) {
        [_relDelegate babyActivity:self];
    }
}

- (void)changePhoneNunber{
    if (_relDelegate && [_relDelegate respondsToSelector:@selector(changePhoneNumber:)]) {
        [_relDelegate changePhoneNumber:self];
    }
}

- (void)callPhone{
    if (_relDelegate &&[_relDelegate respondsToSelector:@selector(callPhone:)]) {
        [_relDelegate callPhone:self];
    }
}

- (void)readPhoneNumFormPhone{
    if (_relDelegate &&[_relDelegate respondsToSelector:@selector(readPhoneNumFromPhone:)]) {
        [_relDelegate readPhoneNumFromPhone:self];
    }
}
@end
