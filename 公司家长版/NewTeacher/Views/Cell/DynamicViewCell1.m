//
//  DynamicViewCell1.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/4/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DynamicViewCell1.h"
#import "ClassCircleModel.h"
#import "UIImage+Caption.h"
#import "NSString+Common.h"
#import "ResuableImageViews.h"
#import "NSDate+Calendar.h"

@interface DynamicViewCell1 ()<ColleagueImageViewDelegate>

@end

@implementation DynamicViewCell1

{
    UILabel *_dayLab,*_monLab,*_contentLab;
    
    ResuableImageViews *_resumeImageView;
    UIView *_titleBack;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        //前置层
        UIView *backView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        backView.opaque = YES;
        [self.contentView addSubview:backView];
        
        //day
        _dayLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 48, 28)];
        [_dayLab setFont:[UIFont boldSystemFontOfSize:24]];
        [_dayLab setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:_dayLab];
        
        //month
        _monLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 5 + 7, 45, 21)];
        //[_monLab setFont:[UIFont systemFontOfSize:17]];
        [_monLab setTextColor:[UIColor darkGrayColor]];
        [self.contentView addSubview:_monLab];
        
        //imageViews
        _resumeImageView = [[ResuableImageViews alloc] initWithFrame:CGRectZero];
        _resumeImageView.changeMargin = 5;
        _resumeImageView.delegate = self;
        [backView addSubview:_resumeImageView];
        
        _titleBack = [[UIView alloc] initWithFrame:CGRectZero];
        [_titleBack setBackgroundColor:[UIColor colorWithRed:243.0 / 255.0 green:243.0 / 255.0 blue:245.0 / 255.0 alpha:1.0]];
        [backView addSubview:_titleBack];
        
        //content
        _contentLab = [[UILabel alloc] initWithFrame:CGRectZero];
        [_contentLab setNumberOfLines:0];
        [_contentLab setTextColor:[UIColor blackColor]];
        [_contentLab setFont:[UIFont systemFontOfSize:16]];
        [backView addSubview:_contentLab];
        
    }
    
    return self;
}

- (void)resetClassGroupData:(id)object
{
    ClassCircleModel *model = (ClassCircleModel *)object;
    //时间
    NSString *time = [model.dateline stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time = [time stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd HHmmss"];
    NSDate *date = [dateFormatter dateFromString:time];
    BOOL sameDay = [date sameDayWithDate:[NSDate date]];
    if (!_firstIdx) {
        _monLab.hidden = YES;
        _dayLab.hidden = YES;
    }
    else
    {
        _dayLab.hidden = NO;
        if (sameDay) {
            _monLab.hidden = YES;
            [_dayLab setText:@"今天"];
        }
        else
        {
            _monLab.hidden = NO;
            [_dayLab setText:[NSString stringWithFormat:@"%02ld",(long)date.day]];
            [_monLab setText:[NSString stringWithFormat:@"%ld月",(long)date.month]];
        }
    }
    
    NSArray *images = [model.picture_thumb componentsSeparatedByString:@"|"];
    //图片
    if (model.imagesRect2.size.height > 0) {
        [_resumeImageView.morePicture setHidden:YES];
        [_resumeImageView setFrame:model.imagesRect2];
        [_resumeImageView setType:model.type];
        [_resumeImageView setImages:images];
        [_resumeImageView setHidden:NO];
    }
    else
    {
        [_resumeImageView setHidden:YES];
    }
    
    //内容
    if (model.contentRect2.size.height > 0) {
        [_contentLab setFrame:model.contentRect2];
        [_contentLab setText:model.message];
        [_contentLab setHidden:NO];
        
        [_titleBack setFrame:CGRectMake(model.contentRect2.origin.x - 3, model.contentRect2.origin.y - 3, model.contentRect2.size.width + 6, model.contentRect2.size.height + 6)];
        [_titleBack setHidden:(model.imagesRect2.size.height > 0)];
    }
    else
    {
        [_contentLab setHidden:YES];
        [_titleBack setHidden:YES];
    }
    
}

#pragma mark - ColleagueImageViewDelegate
- (void)clickedImageWithIndex:(NSInteger)index
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectImgView:At:)]) {
        [_delegate selectImgView:self At:index];
    }
}

- (void)clickedMorePicture
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectImgView:At:)]) {
        [_delegate selectImgView:self At:0];
    }
}

@end
