//
//  FamilyEditHeaderCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/17.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyEditHeaderCell.h"
#import "FamilyDetailModel.h"

@interface FamilyEditHeaderCell ()
{
    UILabel *_titleLabel;
}
@end

@implementation FamilyEditHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor clearColor]];
        CGFloat width = 301.5,xOri = (SCREEN_WIDTH - width) / 2;
        //top
        CGRect topRect = CGRectMake(xOri, 0, width, 60);
        UIImageView *topImg = [[UIImageView alloc] initWithFrame:topRect];
        [topImg setImage:CREATE_IMG(@"contact_cell_bg1")];
        [self.contentView addSubview:topImg];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, topImg.frameWidth - 20, 30)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        [topImg addSubview:_titleLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topImg.frameHeight - 0.5, topImg.frameWidth, 0.5)];
        [lineLabel setBackgroundColor:CreateColor(235, 235, 240)];
        [topImg addSubview:lineLabel];
        
    }
    return self;
}

- (void)resetFamilyEditHeaderData:(id)object
{
    FamilyDetailModel *item = (FamilyDetailModel *)object;
    [_titleLabel setText:item.title ?: @""];
}

@end
