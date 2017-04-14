//
//  FamilyLeaveCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyLeaveCell.h"
#import "FamilyDetailModel.h"
#import "NSString+Common.h"

@interface FamilyLeaveCell ()
{
    UIImageView *_faceImgView;
    UILabel *_nameLabel;
    UIImageView *_hImgView;
    UILabel *_hLabel;
    UIButton *_delBtn;
    UIButton *_msgBtn;
    UILabel *_contLabel;
    ReplysItem *_currItem;
    UIImageView *_msgImgView;
}
@end
@implementation FamilyLeaveCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _faceImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 30, 30)];
        [[_faceImgView layer] setMasksToBounds:YES];
        [[_faceImgView layer] setCornerRadius:15];
        [self.contentView addSubview:_faceImgView];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(_faceImgView.frameRight + 5, 5, SCREEN_WIDTH - _faceImgView.frameRight - 20, self.contentView.frameHeight - 10)];
        [bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        bgView.layer.masksToBounds = YES;
        bgView.layer.cornerRadius = 2;
        [self.contentView addSubview:bgView];
        
        UIView *topBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bgView.frameWidth, 17)];
        [topBg setBackgroundColor:CreateColor(244, 244, 244)];
        [bgView addSubview:topBg];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 60, 17)];
        _nameLabel.backgroundColor = topBg.backgroundColor;
        [_nameLabel setFont:[UIFont systemFontOfSize:10]];
        [_nameLabel setTextColor:CreateColor(26, 147, 192)];
        [topBg addSubview:_nameLabel];
        
        _hImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLabel.frameRight + 10, 5, 7, 7)];
        [_hImgView setImage:CREATE_IMG(@"contact_history")];
        [topBg addSubview:_hImgView];
        
        _hLabel = [[UILabel alloc] initWithFrame:CGRectMake(_hImgView.frameRight + 5, 0, 100, 17)];
        [_hLabel setBackgroundColor:topBg.backgroundColor];
        [_hLabel setTextColor:[UIColor lightGrayColor]];
        [_hLabel setFont:[UIFont systemFontOfSize:8]];
        [topBg addSubview:_hLabel];
        
        _msgImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_message_h")];
        [_msgImgView setFrame:CGRectMake(0, 4 + 10, 7, 7)];
        
        _msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_msgBtn setFrame:CGRectMake(topBg.frameWidth - 45, -10, 40, 17+20)];
        [_msgBtn setTitleColor:CreateColor(17, 146, 183) forState:UIControlStateNormal];
        [_msgBtn setTitle:@"回复" forState:UIControlStateNormal];
        [_msgBtn.titleLabel setFont:[UIFont systemFontOfSize:8]];
        [_msgBtn addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
        [_msgBtn addSubview:_msgImgView];
        [topBg addSubview:_msgBtn];
        
        _contLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, topBg.frameBottom, bgView.frameWidth - 10, 28)];
        _contLabel.backgroundColor = bgView.backgroundColor;
        _contLabel.numberOfLines = 0;
        [_contLabel setFont:[UIFont systemFontOfSize:12]];
        [_contLabel setTextColor:[UIColor darkTextColor]];
        _contLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [bgView addSubview:_contLabel];
        
    }
    return self;
}

- (void)messageAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(replyOrDelMessage:)]) {
        [_delegate replyOrDelMessage:_currItem];
    }
}

- (void)resetFamilyLeaveData:(id)object
{
    ReplysItem *item = (ReplysItem *)object;
    _currItem = item;
    
    NSString *face = item.face_school;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_faceImgView setImageWithURL:[NSURL URLWithString:[face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    
    NSString *relation = @"";
    if ([item.relation length] > 0) {
        relation = item.relation;
    }else{
        relation = @"教师";
    }
    [_nameLabel setText:[NSString stringWithFormat:@"%@%@",item.create_user_name,relation]];
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:item.create_time.doubleValue];
    [_hLabel setText:[NSString calculateTimeDistance:[NSString stringByDate:@"yyyy-MM-dd  HH:mm:ss" Date:updateDate]]];
    
    if ([item.create_user_type length] > 0 && [item.create_user_type isEqualToString:@"1"]) {
        [_msgImgView setImage:CREATE_IMG(@"contact_delete_h")];
        [_msgBtn setTitle:@"删除" forState:UIControlStateNormal];
    }else {
        [_msgImgView setImage:CREATE_IMG(@"contact_message_h")];
        [_msgBtn setTitle:@"回复" forState:UIControlStateNormal];
    }
    
    if ([item.relate_user_name length] > 0) {
        NSString *str = [NSString stringWithFormat:@"回复%@:%@",item.relate_user_name,item.content];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
        NSRange range = [str rangeOfString:item.relate_user_name];
        [attr addAttribute:NSForegroundColorAttributeName value:CreateColor(26, 147, 192) range:range];
        [_contLabel setAttributedText:attr];
    }else {
        [_contLabel setAttributedText:[[NSAttributedString alloc] initWithString:item.content]];
    }
    [_contLabel setFrameHeight:item.class_contHei];
}

@end
