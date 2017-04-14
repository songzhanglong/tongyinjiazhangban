//
//  MyCalendarView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyCalendarView.h"
#import "NSDate+Calendar.h"
#import "CalendarItem2.h"

@interface MyCalendarView ()<CalendarItemDelegate>

@end

@implementation MyCalendarView
{
    NSInteger _nFirstIndex;
    UIImageView *_topView,*_downView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectorForSwipeLeftGR:)];
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:left];
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectorForSwipeRightGR:)];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:right];
        
        CGFloat screenWei = [UIScreen mainScreen].bounds.size.width;
        
        _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWei, 36)];
        [_topView setBackgroundColor:[UIColor colorWithRed:235.0 / 255 green:73.0 / 255 blue:65.0 / 255 alpha:1.0]];
        [self addSubview:_topView];
        
        //label
        NSArray *array = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
        CGFloat wei = 45;
        CGFloat margin = (screenWei - wei * 7) / 8;
        for (NSInteger i = 0; i < 7; i++) {
            NSInteger col = i % 7;
            UILabel *weekLab = [[UILabel alloc] initWithFrame:CGRectMake(margin + (margin + wei) * col, 9, wei, 18)];
            [weekLab setFont:[UIFont systemFontOfSize:14]];
            [weekLab setTextAlignment:1];
            [weekLab setTextColor:[UIColor whiteColor]];
            [weekLab setBackgroundColor:[UIColor clearColor]];
            [weekLab setText:array[i]];
            [_topView addSubview:weekLab];
        }
    }
    return self;
}

- (void)setDateArr:(NSArray *)dateArr
{
    if (_dateArr == dateArr) {
        return;
    }
    
    _dateArr = dateArr;
    NSUInteger numDays = [_curDate numberOfDaysInMonth]; //当月的天数
    CGFloat numOfRows = ((numDays + _nFirstIndex - 1 - 1) / 7) + 1;
    NSInteger numOfCount = numOfRows * 7;    //向上取整
    for (NSInteger i = 0; i < numOfCount; i++) {
        
        CalendarItem2 *item = (CalendarItem2 *)[_downView viewWithTag:i+ 1];
        if (!item) {
            continue;
        }
        
        if ((i < _nFirstIndex - 1) || (i >= _nFirstIndex + numDays - 1)) {
            continue;
        }
        
        NSString *curYear = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)item.year,(long)item.month,(long)item.day];
        
        for (NSDictionary *dic in _dateArr)
        {
            NSString *dateStr = [dic valueForKey:@"date"];
            if ([dateStr isEqualToString:curYear]) {
                NSString *type = [dic valueForKey:@"type"];
                NSInteger idxType = [type integerValue];
                if (idxType == 0) {
                    //到勤
                    item.tipReason.hidden = YES;
                    [item.tipImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kq1" ofType:@"png"]]];
                }
                else if ((idxType == 1) || (idxType == 2))
                {
                    //1-病假,2-事假
                    NSString *tipStr = (idxType == 1) ? @"●病假" : @"●事假";
                    NSRange range = [tipStr rangeOfString:@"●"];
                    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:tipStr];
                    [attStr addAttribute:NSForegroundColorAttributeName value:_topView.backgroundColor range:range];
                    item.tipReason.hidden = NO;
                    item.tipReason.attributedText = attStr;
                    [item.tipImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kq2" ofType:@"png"]]];
                }
                else
                {
                    //未考勤
                    item.tipReason.hidden = YES;
                    [item.tipImage setImage:nil];
                }
                
                break;
            }
        }
        
    }
}

- (void)changeMonth:(id)sender
{
    switch ([sender tag] - 1) {
        case 0:
        {
            NSDate *preDate = [_curDate associateDayOfThePreviousMonth];
            _curDate = preDate;
            [self scrollToViewByLeft:NO Date:preDate];
        }
            break;
        case 1:
        {
            NSDate *nextDate = [_curDate associateDayOfTheFollowingMonth];
            _curDate = nextDate;
            [self scrollToViewByLeft:YES Date:nextDate];
        }
            break;
        default:
            break;
    }
}

- (UIImageView *)createSubViewByDate:(NSDate *)date
{
    NSDate *todayDate = [NSDate date];
    NSDate *firstDate = [date firstDayOfTheMonth];   //当月的第一天
    NSUInteger weekDay = [firstDate weekday];   //对应的星期,1开始
    NSDate *nextDate = nil;
    if (weekDay == 1) {
        nextDate = firstDate;
    }
    else
    {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = 1 - weekDay;
        nextDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:firstDate options:0];
    }
    
    _nFirstIndex = weekDay;
    NSUInteger numDays = [date numberOfDaysInMonth]; //当月的天数
    CGFloat screenWei = [UIScreen mainScreen].bounds.size.width;
    CGFloat wei = 45,hei = 42;
    CGFloat margin = (screenWei - wei * 7) / 8;
    
    CGFloat numOfRows = ((numDays + weekDay - 1 - 1) / 7) + 1;
    CGFloat downHei = numOfRows * hei + 5;
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _topView.frame.origin.y + _topView.frame.size.height, screenWei, downHei)];
    tmpView.userInteractionEnabled = YES;
    [self addSubview:tmpView];
    
    NSInteger numOfCount = numOfRows * 7;    //向上取整
    for (NSInteger i = 0; i < numOfCount; i++) {
        NSInteger row = i / 7;
        NSInteger col = i % 7;
        CGRect tmpRect = CGRectMake(margin + (margin + wei) * col, 5 + hei * row, wei, hei);
        CalendarItem2 *item = [[CalendarItem2 alloc] initWithFrame:tmpRect];
        [item setTag:i + 1];
        [item setDelegate:self];
        [item setItemDate:nextDate];
        //今天
        if ([nextDate sameDayWithDate:todayDate]) {
            item.backImage.hidden = NO;
        }
        else
        {
            item.backImage.hidden = YES;
        }
        
        if ([nextDate sameDayWithDate:_curDate]) {
            [item.layer setBorderColor:[UIColor redColor].CGColor];
        }
        else
        {
            [item.layer setBorderColor:[UIColor clearColor].CGColor];
        }
        
        if ((i < weekDay - 1) || (i >= weekDay + numDays - 1)) {
            item.gregorianLab.textColor = [UIColor darkGrayColor];
            item.tipImage.hidden = YES;
        }
        else
        {
            item.gregorianLab.textColor = [UIColor blackColor];
            if ((col == 0 || col == 6) || [nextDate compare:todayDate] == NSOrderedDescending) {
                item.tipImage.hidden = YES;
            }
            else
            {
                item.tipImage.hidden = NO;
                NSString *curYear = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)item.year,(long)item.month,(long)item.day];
                
                for (NSDictionary *dic in _dateArr) {
                    NSString *dateStr = [dic valueForKey:@"date"];
                    if ([dateStr isEqualToString:curYear]) {
                        NSString *type = [dic valueForKey:@"type"];
                        NSInteger idxType = [type integerValue];
                        if (idxType == 0) {
                            //到勤
                            item.tipReason.hidden = YES;
                            [item.tipImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kq1" ofType:@"png"]]];
                        }
                        else if ((idxType == 1) || (idxType == 2))
                        {
                            //1-病假,2-事假
                            NSString *tipStr = (idxType == 1) ? @"●病假" : @"●事假";
                            NSRange range = [tipStr rangeOfString:@"●"];
                            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:tipStr];
                            [attStr addAttribute:NSForegroundColorAttributeName value:_topView.backgroundColor range:range];
                            item.tipReason.hidden = NO;
                            item.tipReason.attributedText = attStr;
                            [item.tipImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kq2" ofType:@"png"]]];
                        }
                        else
                        {
                            //未考勤
                            item.tipReason.hidden = YES;
                            [item.tipImage setImage:nil];
                        }
                        
                        break;
                    }
                }
            }
        }
        
        [tmpView addSubview:item];
        nextDate = [nextDate followingDay];
    }
    
    return tmpView;
}

- (void)resetYMD
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateFormat:@"yyyy"];
    _year = [[formatter stringFromDate:_curDate] integerValue];
    [formatter setDateFormat:@"MM"];
    _month = [[formatter stringFromDate:_curDate] integerValue];
    [formatter setDateFormat:@"dd"];
    _day = [[formatter stringFromDate:_curDate] integerValue];
}

- (void)setCurDate:(NSDate *)curDate
{
    if ([_curDate isEqual:curDate]) {
        return;
    }
    
    _curDate = curDate;
    [self resetYMD];
    
    [_downView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _downView = [self createSubViewByDate:curDate];
    self.frame = CGRectMake(0, 0, _downView.frame.size.width, _downView.frame.size.height + _downView.frame.origin.y);
}

#pragma mark - privite
- (void)scrollToViewByLeft:(BOOL)left Date:(NSDate *)date
{
    [self resetYMD];
    UIImageView *imageView = [self createSubViewByDate:date];
    CGRect newRect = imageView.frame;
    CGFloat xOri = left ? (newRect.origin.x + newRect.size.width) : (newRect.origin.x - newRect.size.width);
    [imageView setFrame:CGRectMake(xOri, newRect.origin.y, newRect.size.width, newRect.size.height)];
    CGRect downRec = _downView.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [imageView setFrame:newRect];
        CGFloat selfXOri = left ? (downRec.origin.x - downRec.size.width) : (downRec.origin.x + downRec.size.width);
        [_downView setFrame:CGRectMake(selfXOri, downRec.origin.y, downRec.size.width, downRec.size.height)];
        [self setFrame:CGRectMake(0, 0, newRect.size.width, newRect.size.height + newRect.origin.y)];
    } completion:^(BOOL finished) {
        [_downView removeFromSuperview];
        _downView = imageView;
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeMonth:)]) {
            [_delegate changeMonth:self];
        }
    }];
}

- (void)changeToToday
{
    NSDate *today = [NSDate date];
    if ((today.year == _year) && (today.month == _month)) {
        return;
    }
    
    if ([today compare:_curDate] == NSOrderedAscending) {
        _curDate = today;
        [self scrollToViewByLeft:NO Date:today];
    }
    else
    {
        _curDate = today;
        [self scrollToViewByLeft:YES Date:today];
    }
    
}

#pragma mark - Class Extensions
- (void)selectorForSwipeLeftGR:(UISwipeGestureRecognizer *)swipeLeftGR
{
    NSDate *preDate = [_curDate associateDayOfTheFollowingMonth];
    _curDate = preDate;
    [self scrollToViewByLeft:YES Date:preDate];
}

- (void)selectorForSwipeRightGR:(UISwipeGestureRecognizer *)swipeRightGR
{
    NSDate *nextDate = [_curDate associateDayOfThePreviousMonth];
    _curDate = nextDate;
    [self scrollToViewByLeft:NO Date:nextDate];
}

#pragma mark - CalendarItemDelegate
- (void)clickCalendarItem:(CalendarItem2 *)item
{
    if (item.tag != _day + _nFirstIndex - 1) {
        if (item.month != _month) {
            return;
        }
        /*
         NSInteger index = item.tag % 7;
         if (index <= 1) {
         //周末
         return;
         }
         */
        CalendarItem2 *preItem = (CalendarItem2 *)[_downView viewWithTag:_day + _nFirstIndex - 1];
        [preItem.layer setBorderColor:[UIColor clearColor].CGColor];
        [item.layer setBorderColor:[UIColor redColor].CGColor];
        _day = item.day;
        _curDate = item.itemDate;
        if (_delegate && [_delegate respondsToSelector:@selector(changeDay:)]) {
            [_delegate changeDay:self];
        }
    }
}

@end
