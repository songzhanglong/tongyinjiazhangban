//
//  DynamicDetailCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DynamicDetailCell.h"
#import "ClassCircleModel.h"
#import "DJTGlobalManager.h"

@interface DynamicDetailCell()

@end

@implementation DynamicDetailCell
{
    UIImageView *_headImg;
    UILabel *_nameLab;
    UILabel *_contentLab;
    UIButton *_delBut;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        
        //head
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        _headImg.clipsToBounds = YES;
        _headImg.contentMode = UIViewContentModeScaleAspectFill;
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 15;
        [self.contentView addSubview:_headImg];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, winSize.width - 100, 20)];
        [_nameLab setTextColor:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0]];
        [_nameLab setFont:[UIFont systemFontOfSize:16]];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_nameLab];
        
        //content
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, winSize.width - 60, 10)];
        [_contentLab setNumberOfLines:0];
        [_contentLab setFont:[UIFont systemFontOfSize:16]];
        [_contentLab setTextColor:CreateColor(91, 89, 89)];
        [_contentLab setBackgroundColor:[UIColor clearColor]];
        _contentLab.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_contentLab];
        
        //del
        _delBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delBut setFrame:CGRectMake(winSize.width - 40 - 10, 10, 40, 20)];
        [_delBut setBackgroundColor:[UIColor clearColor]];
        [_delBut setTitleColor:_nameLab.textColor forState:UIControlStateNormal];
        [_delBut setTitle:@"删除" forState:UIControlStateNormal];
        [_delBut.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_delBut addTarget:self action:@selector(delReply:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_delBut];
        
    }
    
    return self;
}

- (void)delReply:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(beginDelete:)]) {
        [_delegate beginDelete:self];
    }
}

- (void)resetDynamicDetailData:(id)object
{
    ReplyItem *item = (ReplyItem *)object;
    NSString *url = item.face;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    
    [_nameLab setText:item.name];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    _delBut.hidden = (![manager.userInfo.userid isEqualToString:item.send_id]);
    
    CGRect conRec = _contentLab.frame;
    [_contentLab setFrame:CGRectMake(conRec.origin.x, conRec.origin.y, conRec.size.width, item.itemSize.height)];
    NSString *gene = [item generalReplyString2];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:gene];
    if (item.reply_name && [item.reply_name length] > 0) {
        NSRange range = [gene rangeOfString:item.reply_name];
        [attr addAttribute:NSForegroundColorAttributeName value:CreateColor(68, 138, 167) range:range];
    }
    [_contentLab setAttributedText:attr];
}

@end
