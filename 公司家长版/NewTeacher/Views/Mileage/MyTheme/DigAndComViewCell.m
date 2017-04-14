//
//  DigAndComViewCell.m
//  NewTeacher
//
//  Created by szl on 15/12/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DigAndComViewCell.h"
#import "ThemeBatchDetailModel.h"

@implementation DigAndComViewCell
{
    UIImageView *_digImg,*_comImg;
    UIView *_lineView;
    UILabel *_diggLab,*_comLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        self.contentView.backgroundColor = rgba(236, 236, 236, 1);
        UIView *backView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [backView setBackgroundColor:rgba(236, 236, 236, 1)];
        [backView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:backView];
        
        _digImg = [[UIImageView alloc] initWithFrame:CGRectMake(50, 10, 16, 16)];
        [_digImg setImage:CREATE_IMG(@"themeDigg")];
        [backView addSubview:_digImg];
        
        _diggLab = [[UILabel alloc] initWithFrame:CGRectMake(_digImg.frameRight + 10, 10, winSize.width - _digImg.frameRight - 20, 16)];
        [_diggLab setFont:[UIFont systemFontOfSize:12]];
        [_diggLab setNumberOfLines:0];
        [_diggLab setBackgroundColor:[UIColor clearColor]];
        [_diggLab setTextColor:CreateColor(83, 144, 172)];
        [backView addSubview:_diggLab];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(_digImg.frameX, backView.frameHeight - 25 - 10, winSize.width - _digImg.frameX, 0.5)];
        [_lineView setBackgroundColor:[UIColor lightGrayColor]];
        [_lineView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [backView addSubview:_lineView];
        
        _comImg = [[UIImageView alloc] initWithFrame:CGRectMake(_digImg.frameX, backView.frameHeight - 16 - 10, 16, 16)];
        [_comImg setImage:CREATE_IMG(@"themeComment")];
        [_comImg setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [backView addSubview:_comImg];
        
        _comLab = [[UILabel alloc] initWithFrame:CGRectMake(_comImg.frameRight + 10, backView.frameHeight - 16 - 10, winSize.width - _comImg.frameRight - 20, 16)];
        [_comLab setFont:[UIFont systemFontOfSize:12]];
        [_comLab setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_comLab setBackgroundColor:[UIColor clearColor]];
        [_comLab setTextColor:[UIColor lightGrayColor]];
        [backView addSubview:_comLab];
    }
    return self;
}

- (void)resetDig:(NSArray *)digs Count:(NSInteger)comCount Hei:(CGFloat)hei
{
    NSMutableArray *digArr = [NSMutableArray array];
    for (BatchDetailDiggItem *digg in digs) {
        [digArr addObject:digg.name];
    }
    if ([digArr count] > 0) {
        _digImg.hidden = NO;
        _diggLab.hidden = NO;
        NSString *strDig = [digArr componentsJoinedByString:@"、"];
        [_diggLab setText:strDig];
        [_diggLab setFrameHeight:hei];
    }
    else{
        _digImg.hidden = YES;
        _diggLab.hidden = YES;
    }
    
    [_comLab setText:[NSString stringWithFormat:@"所有%ld条评论",(long)comCount]];
    _comLab.hidden = (comCount == 0);
    _comImg.hidden = _comLab.hidden;
    
    _lineView.hidden = (_digImg.hidden || _comImg.hidden);
}

@end
