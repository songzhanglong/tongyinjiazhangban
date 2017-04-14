//
//  CreatePlayMileageView.m
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "CreatePlayMileageView.h"

@implementation CreatePlayMileageView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setContView:frame];
    }
    return self;
}

- (void)setContView:(CGRect)frame
{
    UIView *_contView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [_contView setBackgroundColor:[UIColor whiteColor]];
    [_contView.layer setMasksToBounds:YES];
    [_contView.layer setCornerRadius:3];
    [_contView setUserInteractionEnabled:YES];
    [self addSubview:_contView];
    
    UIView *_themeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contView.frame.size.width, (_contView.frame.size.height - 40 - 1) / 2)];
    [_themeView setBackgroundColor:[UIColor clearColor]];
    [_themeView setUserInteractionEnabled:YES];
    [_contView addSubview:_themeView];
    
    UIImageView *_themeImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"create_theme")];
    [_themeImgView setFrame:CGRectMake(20, 21, 16, 16)];
    [_themeView addSubview:_themeImgView];
    
    UILabel *_themeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_themeImgView.frameRight + 5, 20, _themeView.frameWidth - _themeImgView.frameRight - 10 - 30, 18)];
    [_themeNameLabel setBackgroundColor:[UIColor clearColor]];
    [_themeNameLabel setText:@"按主题创建"];
    [_themeNameLabel setTextColor:CreateColor(79, 166, 0)];
    [_themeNameLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_themeView addSubview:_themeNameLabel];
    
    UIImageView *_arrowImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"mileage_arrow")];
    [_arrowImgView setFrame:CGRectMake(_themeView.frameWidth - 30, 21.5, 15, 15)];
    [_themeView addSubview:_arrowImgView];
    
    UILabel *_themeContLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _themeNameLabel.frameBottom + 10, _themeView.frameWidth - 40, 50)];
    [_themeContLabel setBackgroundColor:[UIColor clearColor]];
    [_themeContLabel setText:@"你可以在所选的主题中，挑选数张照片、小视频制作成电子播放文件并分享。该类文件在制作成长档案时，可作素材备用。"];
    [_themeContLabel setFont:[UIFont systemFontOfSize:10]];
    [_themeContLabel setTextColor:[UIColor lightGrayColor]];
    [_themeContLabel setNumberOfLines:3];
    [_themeView addSubview:_themeContLabel];
    
    UITapGestureRecognizer *_themeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(themeGesture:)];
    [_themeView addGestureRecognizer:_themeGesture];
    
    UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, _themeView.frameBottom, _contView.frame.size.width - 40, 1)];
    [lineImgView setImage:CREATE_IMG(@"mileage_line")];
    [_contView addSubview:lineImgView];
    
    UIView *_timeView = [[UIView alloc] initWithFrame:CGRectMake(0, lineImgView.frameBottom, _contView.frame.size.width, (_contView.frame.size.height - 40 - 1) / 2)];
    [_timeView setBackgroundColor:[UIColor clearColor]];
    [_timeView setUserInteractionEnabled:YES];
    [_contView addSubview:_timeView];
    
    UIImageView *_timeImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"create_time")];
    [_timeImgView setFrame:CGRectMake(20, 21, 16, 16)];
    [_timeView addSubview:_timeImgView];
    
    UILabel *_timeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_timeImgView.frameRight + 5, 20, _timeView.frameWidth - _timeImgView.frameRight - 10 - 30, 18)];
    [_timeNameLabel setBackgroundColor:[UIColor clearColor]];
    [_timeNameLabel setText:@"按时间创建"];
    [_timeNameLabel setTextColor:CreateColor(43, 145, 182)];
    [_timeNameLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_timeView addSubview:_timeNameLabel];
    
    UIImageView *_arrowImgView1 = [[UIImageView alloc] initWithImage:CREATE_IMG(@"mileage_arrow")];
    [_arrowImgView1 setFrame:CGRectMake(_timeView.frameWidth - 30, 21.5, 15, 15)];
    [_timeView addSubview:_arrowImgView1];
    
    UILabel *_timeContLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _timeNameLabel.frameBottom + 10, _timeView.frameWidth - 40, 50)];
    [_timeContLabel setBackgroundColor:[UIColor clearColor]];
    [_timeContLabel setText:@"你可以选择图片、小视频、自定义制作电子播放文件并分享。该类文件支持添加多个主题内容，但不能作为成长档案素材。"];
    [_timeContLabel setFont:[UIFont systemFontOfSize:10]];
    [_timeContLabel setTextColor:[UIColor lightGrayColor]];
    [_timeContLabel setNumberOfLines:3];
    [_timeView addSubview:_timeContLabel];
    
    UITapGestureRecognizer *_timeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeGesture:)];
    [_timeView addGestureRecognizer:_timeGesture];
    
    UIView *_cencelView = [[UIView alloc] initWithFrame:CGRectMake(0, _contView.frame.size.height - 40, _contView.frame.size.width, 40)];
    [_cencelView setBackgroundColor:CreateColor(238, 91, 38)];
    [_cencelView setUserInteractionEnabled:YES];
    [_contView addSubview:_cencelView];
    
    UIImageView *_cencelImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"mileage_cencel")];
    [_cencelImgView setFrame:CGRectMake((_cencelView.frameWidth - 25) / 2, (_cencelView.frameHeight - 25) / 2, 25, 25)];
    [_cencelView addSubview:_cencelImgView];
    
    UITapGestureRecognizer *_cencelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cencelGesture:)];
    [_cencelView addGestureRecognizer:_cencelGesture];
}

-(void)themeGesture:(id)sender
{
    [self cencelGesture:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(selectCreateIndex:)]) {
        [_delegate selectCreateIndex:1];
    }
}

-(void)timeGesture:(id)sender
{
    [self cencelGesture:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(selectCreateIndex:)]) {
        [_delegate selectCreateIndex:2];
    }
}

-(void)cencelGesture:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(cancelToView:)]) {
        [_delegate cancelToView:self];
    }
}

@end
