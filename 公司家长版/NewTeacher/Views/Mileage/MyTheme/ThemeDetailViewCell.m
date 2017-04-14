//
//  ThemeDetailViewCell.m
//  NewTeacher
//
//  Created by szl on 15/12/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ThemeDetailViewCell.h"
#import "ThemeBatchDetailModel.h"
#import "NSString+Common.h"

@implementation ThemeDetailViewCell
{
    UIImageView *_headImg;
    UILabel *_nameLab,*_timeLab,*_conLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        self.contentView.backgroundColor = rgba(236, 236, 236, 1);
        UIView *backView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [backView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        _backView = backView;
        [self.contentView addSubview:backView];
        
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 15;
        [backView addSubview:_headImg];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.frameRight + 10, _headImg.frameY, (winSize.width - _headImg.frameRight - 20) / 3, 16)];
        [_nameLab setTextColor:CreateColor(83, 144, 172)];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [_nameLab setFont:[UIFont systemFontOfSize:12]];
        [backView addSubview:_nameLab];
        
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameRight, _nameLab.frameY, (winSize.width - _headImg.frameRight - 20) / 3 * 2, _nameLab.frameHeight)];
        [_timeLab setTextAlignment:2];
        [_timeLab setBackgroundColor:_nameLab.backgroundColor];
        [_timeLab setFont:[UIFont systemFontOfSize:10]];
        [_timeLab setTextColor:[UIColor lightGrayColor]];
        [backView addSubview:_timeLab];
        
        _conLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom + 10, winSize.width - _nameLab.frameX - 10, 16)];
        [_conLab setTextColor:[UIColor blackColor]];
        [_conLab setBackgroundColor:[UIColor clearColor]];
        [_conLab setNumberOfLines:0];
        [_conLab setFont:_nameLab.font];
        [backView addSubview:_conLab];
    }
    return self;
}

- (void)resetReplyDetail:(id)object
{
    BatchDetailReplyItem *reply = (BatchDetailReplyItem *)object;
    NSString *lastUrl = reply.face;
    if (![lastUrl hasPrefix:@"http"]) {
        lastUrl = [G_IMAGE_ADDRESS stringByAppendingString:lastUrl ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:lastUrl] placeholderImage:CREATE_IMG(@"s21@2x")];
    [_nameLab setText:reply.name];
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:reply.dateline.doubleValue];
    [_timeLab setText:[NSString stringWithFormat:@"%@",[NSString stringByDate:@"yyyy年MM月dd日 HH:mm" Date:updateDate]]];
    [_conLab setText:reply.message];
    _conLab.frameHeight = reply.contentHei;
}

- (void)resetHead:(NSString *)url Name:(NSString *)name Time:(NSString *)time Con:(NSString *)content Hei:(CGFloat)hei
{
    NSString *lastUrl = url;
    if (![lastUrl hasPrefix:@"http"]) {
        lastUrl = [G_IMAGE_ADDRESS stringByAppendingString:lastUrl ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:lastUrl] placeholderImage:CREATE_IMG(@"s21@2x")];
    [_nameLab setText:name];
    [_timeLab setText:time];
    [_conLab setText:content];
    _conLab.frameHeight = hei;
}

@end
