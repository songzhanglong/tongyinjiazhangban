//
//  CalendarItem2.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarItem2.h"

@implementation CalendarItem2

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        
        //back
        _backImage = [[UIImageView alloc] init];
        [_backImage setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_backImage setBackgroundColor:[UIColor clearColor]];
        [_backImage.layer setMasksToBounds:YES];
        _backImage.layer.borderWidth = 3;
        _backImage.layer.borderColor = [UIColor colorWithRed:235.0 / 255 green:234.0 / 255 blue:234.0 / 255 alpha:1.0].CGColor;
        [_backImage setHidden:YES];
        [self addSubview:_backImage];
        
        //
        _tipImage = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 39) / 2, -2, 39, 37)];
        [_tipImage setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_tipImage];
        
        //公历
        _gregorianLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 7.5, frame.size.width, 20)];
        [_gregorianLab setTextColor:[UIColor blackColor]];
        [_gregorianLab setTextAlignment:1];
        [_gregorianLab setFont:[UIFont systemFontOfSize:17]];
        [_gregorianLab setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_gregorianLab];
        
        //活动名称
        _tipReason = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, frame.size.width, frame.size.height - 30)];
        [_tipReason setTextAlignment:1];
        [_tipReason setFont:[UIFont systemFontOfSize:10]];
        [_tipReason setBackgroundColor:[UIColor clearColor]];
        _tipReason.hidden = YES;//默认隐藏
        [self addSubview:_tipReason];
    }
    return self;
}

- (void)setItemDate:(NSDate *)itemDate
{
    if ([_itemDate isEqual:itemDate]) {
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateFormat:@"yyyy"];
    _year = [[formatter stringFromDate:itemDate] integerValue];
    [formatter setDateFormat:@"MM"];
    _month = [[formatter stringFromDate:itemDate] integerValue];
    [formatter setDateFormat:@"dd"];
    _day = [[formatter stringFromDate:itemDate] integerValue];
    
    _itemDate = itemDate;
    [_gregorianLab setText:[NSString stringWithFormat:@"%ld",(long)_day]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickCalendarItem:)]) {
        [_delegate clickCalendarItem:self];
    }
}

@end
