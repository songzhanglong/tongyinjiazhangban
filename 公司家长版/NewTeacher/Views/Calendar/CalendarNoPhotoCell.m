//
//  CalendarNoPhotoCell.m
//  NewTeacher
//
//  Created by szl on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarNoPhotoCell.h"
#import "NSString+Common.h"

@implementation CalendarNoPhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(15.5, 0, 2, self.contentView.frameHeight)];
        [leftView setBackgroundColor:rgba(233, 233, 233, 1)];
        [leftView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:leftView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frameBottom - 1, self.contentView.frameWidth, 1)];
        [lineView setBackgroundColor:leftView.backgroundColor];
        [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [self.contentView addSubview:lineView];
        
        UIImageView *imgaeView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 33.5, 23, 23)];
        _leftImgView = imgaeView;
        [imgaeView setImage:CREATE_IMG(@"c_1")];
        [self.contentView addSubview:imgaeView];
        
        CGFloat xOri = imgaeView.frameRight + imgaeView.frameX * 2;
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(xOri, 22, winSize.width - xOri - 121 - 20, 20)];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [_nameLab setFont:[UIFont systemFontOfSize:17]];
        [self.contentView addSubview:_nameLab];
        
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom + 7, _nameLab.frameWidth, 18)];
        [_timeLab setFont:[UIFont systemFontOfSize:15]];
        [_timeLab setTextColor:[UIColor lightGrayColor]];
        [_timeLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_timeLab];
    }
    return self;
}

- (void)resetTimeCard:(TimeCardRecord *)record
{
    NSString *name = [NSString stringWithFormat:@"持卡人  %@",record.card_name];
    NSRange range = [name rangeOfString:record.card_name ?: @""];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:name];
    if (range.location != NSNotFound) {
        [attStr addAttribute:NSForegroundColorAttributeName value:CreateColor(117, 194, 242) range:range];
    }
    [_nameLab setAttributedText:attStr];
    
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:[record.check_time doubleValue]];
    NSString *dateStr = [NSString stringByDate:@"HH:mm:ss" Date:expirationDate];
    [_timeLab setText:[NSString stringWithFormat:@"考勤时间 %@",dateStr]];
}

@end
