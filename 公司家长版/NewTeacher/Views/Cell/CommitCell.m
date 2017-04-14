//
//  CommitCell.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CommitCell.h"

@implementation CommitCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contantLabel=[[UILabel alloc]initWithFrame:CGRectMake(12, 5, 128, 61)];
        [_contantLabel setFont:[UIFont systemFontOfSize:14]];
        _contantLabel.numberOfLines=0;
        [_contantLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [self.contentView addSubview:_contantLabel];
        
        _bestBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_bestBtn setFrame:CGRectMake(185, 18, 33, 33)];
        [_bestBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_bestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_bestBtn setTitleColor:[UIColor colorWithRed:64/255.0 green:153/255.0 blue:252/255.0 alpha:1] forState:UIControlStateNormal];
        [_bestBtn setBackgroundImage:[UIImage imageNamed:@"icon10.png"] forState:UIControlStateSelected];
        _bestBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_bestBtn setTitle:@"优秀" forState:UIControlStateSelected];
        [_bestBtn setTitle:@"优秀" forState:UIControlStateNormal];
        [_bestBtn addTarget:self action:@selector(bestBtnClicke) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_bestBtn];
        
        _betterBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_betterBtn setFrame:CGRectMake(259, 18, 33, 33)];
        [_betterBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_betterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_betterBtn setTitleColor:[UIColor colorWithRed:64/255.0 green:153/255.0 blue:252/255.0 alpha:1] forState:UIControlStateNormal];
        [_betterBtn setBackgroundImage:[UIImage imageNamed:@"icon10.png"] forState:UIControlStateSelected];
        [_betterBtn setTitle:@"良好" forState:UIControlStateSelected];
        [_betterBtn setTitle:@"良好" forState:UIControlStateNormal];
        [_betterBtn addTarget:self action:@selector(betterBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_betterBtn];
    }
    return self;
}
-(void)bestBtnClicke
{
    _bestBtn.selected = YES;
    _betterBtn.selected= NO;
    if(_delegate)
    {
        [_delegate betterBtnClick:self];
    }
}
-(void)betterBtnClick
{
    _bestBtn.selected = NO;
    _betterBtn.selected= YES;
    if(_delegate)
    {
        [_delegate bestBtnClick:self];
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
