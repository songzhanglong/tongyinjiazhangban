//
//  GrowNewCell.m
//  NewTeacher
//
//  Created by szl on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowNewCell.h"
#import "GrowTermModel.h"

@implementation GrowNewCell
{
    UIImageView *_coverImg;
    UILabel *_titleLab,*_nameLab,*_numLab,*_tipLabel;
    UIButton *_printBut;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //back
        _backView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, self.contentView.bounds.size.height)];
        [_backView setBackgroundColor:[UIColor whiteColor]];
        [_backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        _backView.layer.cornerRadius = 2;
        _backView.layer.masksToBounds = YES;
        [self.contentView addSubview:_backView];
        
        //img
        _coverImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 65, 85)];
        [_coverImg setContentMode:UIViewContentModeScaleAspectFill];
        _coverImg.clipsToBounds = YES;
        [_coverImg setBackgroundColor:BACKGROUND_COLOR];
        [_backView addSubview:_coverImg];
        
        //title
        CGFloat wei = _backView.frameWidth - _coverImg.frameRight - 30;
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(_coverImg.frameRight + 15, _coverImg.frameY, wei, 18)];
        [_titleLab setFont:[UIFont systemFontOfSize:14]];
        [_titleLab setTextColor:[UIColor blackColor]];
        [_backView addSubview:_titleLab];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_titleLab.frameX, (_coverImg.frameHeight - 20 - _titleLab.frameHeight - 2 - 32) / 2 + _titleLab.frameBottom, wei, 16)];
        [_nameLab setTextColor:[UIColor darkGrayColor]];
        [_nameLab setFont:[UIFont systemFontOfSize:12]];
        [_backView addSubview:_nameLab];
        
        //number
        _numLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom + 2, wei, _nameLab.frameHeight)];
        [_numLab setTextColor:_nameLab.textColor];
        [_numLab setFont:_nameLab.font];
        [_backView addSubview:_numLab];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, -2, 10, 10)];
        [_tipLabel setBackgroundColor:CreateColor(236, 184, 7)];
        [_tipLabel setTextColor:[UIColor whiteColor]];
        [_tipLabel setFont:[UIFont boldSystemFontOfSize:8]];
        [_tipLabel setText:@"!"];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        [_tipLabel.layer setMasksToBounds:YES];
        [_tipLabel.layer setCornerRadius:5];
        [_tipLabel.layer setBorderWidth:1];
        [_tipLabel.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        _printBut = button;
        [button setFrame:CGRectMake(_backView.frameWidth - 70, _coverImg.frameBottom - 20, 60, 20)];
        [button setImage:CREATE_IMG(@"growPrint") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(beginToPrint:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:_tipLabel];
        [_backView addSubview:button];
    }
    return self;
}

- (void)beginToPrint:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(startToPrint:)]) {
        [_delegate startToPrint:self];
    }
}

- (void)resetDataSource:(id)dataSource
{
    GrowTermModel *termModel = (GrowTermModel *)dataSource;
    
    NSString *url = termModel.cover_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_coverImg setImageWithURL:[NSURL URLWithString:url]];

    [_titleLab setText:termModel.term];
    [_nameLab setText:[NSString stringWithFormat:@"模板名称:%@",termModel.templist_name ?: @""]];
    
    NSString *titleStr = [NSString stringWithFormat:@"完成数/总页数:%@/%@",termModel.finish_num,termModel.total_num];
    [_numLab setText:titleStr];
    
    _tipLabel.hidden = (termModel.print_flag.integerValue == 1);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [_backView setBackgroundColor:CreateColor(226, 226, 231)];
    }
    else{
        [_backView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [_backView setBackgroundColor:CreateColor(226, 226, 231)];
    }
    else{
        [_backView setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
