//
//  TimeCardViewCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "TimeCardViewCell.h"
#import "TimeCardModel.h"
#import "UIButton+WebCache.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"
#import "NSString+Common.h"

@implementation TimeCardViewCell
{
    UILabel *_cardNoLab,*_nameLab,*_timeLab;
    UIButton *_headImg;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        
        //home page
        UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 200)];
        [upView setBackgroundColor:CreateColor(220, 241, 244)];
        [self.contentView addSubview:upView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 293) / 2, 10, 293, 185)];
        [imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ka" ofType:@"png"]]];
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 5;
        [upView addSubview:imgView];
        
        _cardNoLab = [[UILabel alloc] initWithFrame:CGRectMake(10, imgView.frame.size.height - 10 - 20, imgView.frame.size.width - 20, 20)];
        [_cardNoLab setBackgroundColor:[UIColor clearColor]];
        [_cardNoLab setTextColor:[UIColor whiteColor]];
        [imgView addSubview:_cardNoLab];
        
        UIImageView *downView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, winSize.width, 64.5)];
        [downView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kuang1" ofType:@"png"]]];
        [downView setUserInteractionEnabled:YES];
        [self.contentView addSubview:downView];
        
        _headImg = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headImg setFrame:CGRectMake(10, 11, 42, 42)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 21;
        _headImg.layer.borderWidth = 0.5;
        _headImg.layer.borderColor = CreateColor(3, 209, 126).CGColor;
        [_headImg addTarget:self action:@selector(changeInfo:) forControlEvents:UIControlEventTouchUpInside];
        [downView addSubview:_headImg];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(62, 13, winSize.width - 62 * 3 - 10, 20)];
        [_nameLab setTextColor:[UIColor blackColor]];
        [downView addSubview:_nameLab];
        
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(62, 52 - 2 - 15 + 1, _nameLab.frame.size.width, 15)];
        [_timeLab setFont:[UIFont systemFontOfSize:13]];
        [_timeLab setTextColor:[UIColor lightGrayColor]];
        [downView addSubview:_timeLab];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(winSize.width - 62 * 2, 1, 62 * 2, 62)];
        [btn setTitle:@"解除绑定" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [btn setBackgroundColor:CreateColor(3, 209, 126)];
        [btn addTarget:self action:@selector(lossPressed:) forControlEvents:UIControlEventTouchUpInside];
        [downView addSubview:btn];
    }
    return self;
}

- (void)changeInfo:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(cancelBindAndChangeInfo:Tag:)]) {
        [_delegate cancelBindAndChangeInfo:self Tag:1];
    }
}

- (void)lossPressed:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(cancelBindAndChangeInfo:Tag:)]) {
        [_delegate cancelBindAndChangeInfo:self Tag:0];
    }
}

- (void)resetTimeCard:(id)dataSource
{
    TimeCardModel *timeCard = (TimeCardModel *)dataSource;
    [_cardNoLab setText:[NSString stringWithFormat:@"卡号：%@",timeCard.card_no]];
    NSString *str = timeCard.holder_face;
    if (![str hasPrefix:@"http"]) {
        str = [G_IMAGE_GROW_ADDRESS stringByAppendingString:str ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:str] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    [_nameLab setText:[NSString stringWithFormat:@"%@的%@",user.realname,timeCard.holder_rel]];
    
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:[timeCard.create_time doubleValue]];
    NSString *dateStr = [NSString stringByDate:@"yyyy/MM/dd" Date:expirationDate];
    [_timeLab setText:[NSString stringWithFormat:@"%@ 绑定",dateStr]];
}

@end
