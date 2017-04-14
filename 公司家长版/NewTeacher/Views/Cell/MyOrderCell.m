//
//  MyOrderCell.m
//  NewTeacher
//
//  Created by szl on 16/4/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "MyOrderCell.h"
#import "NSString+Common.h"

@implementation MyOrderCell
{
    UIView *_contentView,*_barView;
    UILabel *_numLab,*_stateLab,*_nameLab,*_conLab,*_timeLab;
    UIImageView *_imageView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //内容视图
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, self.contentView.bounds.size.height)];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 2;
        _contentView.clipsToBounds = YES;
        [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_contentView];
        
        //bar
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentView.frameWidth, 29)];
        [barView setBackgroundColor:CreateColor(224, 224, 227)];
        _barView = barView;
        [_contentView addSubview:barView];
        
        //订单号
        _numLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 6.5, barView.frameWidth - 20 - 90 - 10, 16)];
        [_numLab setFont:[UIFont systemFontOfSize:12]];
        [_numLab setTextColor:CreateColor(102, 102, 102)];
        [_numLab setBackgroundColor:barView.backgroundColor];
        [_contentView addSubview:_numLab];
        
        //状态
        _stateLab = [[UILabel alloc] initWithFrame:CGRectMake(_numLab.frameRight + 10, _numLab.frameY, 90, _numLab.frameHeight)];
        [_stateLab setFont:_numLab.font];
        [_stateLab setTextColor:CreateColor(246, 94, 70)];
        [_stateLab setTextAlignment:NSTextAlignmentRight];
        [_stateLab setBackgroundColor:barView.backgroundColor];
        [_contentView addSubview:_stateLab];
        
        //image
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_numLab.frameX, barView.frameBottom + 10, 44, 58)];
        _imageView.clipsToBounds = YES;
        [_imageView setBackgroundColor:BACKGROUND_COLOR];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_contentView addSubview:_imageView];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.frameRight + 10, _imageView.frameY, barView.frameWidth - _imageView.frameRight - 20, 18)];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [_nameLab setTextColor:CreateColor(51, 51, 51)];
        [_nameLab setNumberOfLines:2];
        [_contentView addSubview:_nameLab];
        
        //content
        _conLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom + 11, 100, 18)];
        [_conLab setFont:_nameLab.font];
        [_conLab setTextColor:CreateColor(11, 149, 221)];
        [_contentView addSubview:_conLab];
        
        //time
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _imageView.frameBottom - 14, _nameLab.frameWidth, 14)];
        [_timeLab setFont:[UIFont systemFontOfSize:10]];
        [_timeLab setTextAlignment:NSTextAlignmentRight];
        [_timeLab setTextColor:CreateColor(186, 185, 185)];
        [_contentView addSubview:_timeLab];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [_contentView setBackgroundColor:CreateColor(226, 226, 231)];
    }
    else{
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        [_barView setBackgroundColor:CreateColor(224, 224, 227)];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [_contentView setBackgroundColor:CreateColor(226, 226, 231)];
    }
    else{
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        [_barView setBackgroundColor:CreateColor(224, 224, 227)];
    }
}

- (void)resetDataSource:(MyOrderList *)order
{
    NSString *cover_url = order.cover_url;
    if (![cover_url hasPrefix:@"http"]) {
        cover_url = [G_IMAGE_ADDRESS stringByAppendingString:cover_url ?: @""];
    }
    [_imageView setImageWithURL:[NSURL URLWithString:cover_url]];
    [_numLab setText:[NSString stringWithFormat:@"订单号：%@",order.order_no]];
    [_stateLab setText:order.status_name];
    [_nameLab setText:order.product_name];
    [_conLab setText:order.product_type_name];
    if (order.create_time.length <= 0) {
        [_timeLab setText:@""];
    }
    else{
        NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:order.create_time.doubleValue];
        [_timeLab setText:[NSString stringWithFormat:@"下单时间：%@",[NSString stringByDate:@"yyyy-MM-dd HH:mm" Date:updateDate]]];
    }
    
}

@end
