//
//  ClockViewCell.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/24.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "ClockViewCell.h"

@implementation ClockViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIColor *color = [UIColor colorWithRed:104.0 / 255 green:52.0 / 255 blue:83.0 / 255 alpha:1.0];
        self.backgroundColor = color;
        self.contentView.clipsToBounds = YES;
        self.contentView.backgroundColor = color;
        
        _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 120, 24)];
        [_tipLab setTextColor:[UIColor colorWithRed:225.0 / 255 green:131.0 / 255 blue:119.0 / 255 alpha:1.0]];
        [_tipLab setText:@"考勤信息获取中..."];
        [_tipLab setFont:[UIFont systemFontOfSize:20]];
        [_tipLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_tipLab];
        
        //image
        _midImage = [[UIImageView alloc] initWithFrame:CGRectMake(135, 17, 30, 30)];
        [_midImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s12_2@2x" ofType:@"png"]]];
        [self.contentView addSubview:_midImage];
        
        UIImageView *_imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 10 - 54, 14, 54, 37)];
        [_imageView1 setImage:[UIImage imageNamed:@"s4.png"]];
        [self.contentView addSubview:_imageView1];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
