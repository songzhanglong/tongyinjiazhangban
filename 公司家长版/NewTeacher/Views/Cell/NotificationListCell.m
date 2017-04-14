//
//  NotificationListCell.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/8.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationListCell.h"
#import "NotificationListModel.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"
#import "DJTGlobalManager.h"

@implementation NotificationListCell
{
    UILabel *_nameLab,*_timeLab,*_conLab;
    UIImageView *_headImg,*_bottom;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizesSubviews=YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        double interval = 0.5;
        _bottom = [[UIImageView alloc] initWithFrame:CGRectMake(16.5, self.contentView.frame.size.height - interval, winSize.width - 16.5, interval)];
        [_bottom setBackgroundColor:[UIColor lightGrayColor]];
        //[_bottom setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [self.contentView addSubview:_bottom];
        
        
        //left line
        UIImageView *leftLine = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, .5, self.contentView.frame.size.height)];
        [leftLine setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [leftLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:leftLine];
        
        //clock
        UIImageView *clockImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 16, 16, 16)];
        [clockImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"time@2x" ofType:@"png"]]];
        [self.contentView addSubview:clockImg];
        
        //time
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(32, 14, 200, 20)];
        [_timeLab setFont:[UIFont systemFontOfSize:17]];
        [_timeLab setTextColor:[UIColor orangeColor]];
        [self.contentView addSubview:_timeLab];
        
        //head
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(32, 48, 40, 40)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 20;
        [self.contentView addSubview:_headImg];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(32 + 40 + 5, 48, 200, 20)];
        [_nameLab setTextColor:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0]];
        [_nameLab setFont:[UIFont systemFontOfSize:17]];
        [self.contentView addSubview:_nameLab];
        
        //conte
        _conLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frame.origin.x, _nameLab.frame.origin.y + _nameLab.frame.size.height, winSize.width - 5 - _nameLab.frame.origin.x, 10)];
        [_conLab setNumberOfLines:3];
        [_conLab setFont:[UIFont systemFontOfSize:17]];
        [self.contentView addSubview:_conLab];
    }
    return self;
}

- (void)resetNotifiCationSource:(id)object
{
    NotificationListModel *listModel = (NotificationListModel *)object;
    [_nameLab setText:listModel.teacher_name];
    [_timeLab setText:[NSString calculateTimeDistance:listModel.ctime]];
    
    NSString *url = listModel.face;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    
    CGRect rect = _conLab.frame;
    [_conLab setFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, MIN(listModel.conSize.height, 61))];
    [_conLab setText:listModel.content];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    [_bottom setFrame:CGRectMake(16.5, MIN(listModel.conSize.height, 61) + 48 + 20 + 16 - 0.5, winSize.width - 16.5, 0.5)];
}

@end
