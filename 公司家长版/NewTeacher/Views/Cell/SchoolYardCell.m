//
//  SchoolYardCell.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/20.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SchoolYardCell.h"

@implementation SchoolYardCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _faceImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        [self.contentView addSubview:_faceImageView];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_faceImageView.frame.origin.x, _faceImageView.frame.size.height + 5 , _faceImageView.frame.size.width, 20)];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        _nameLabel.textAlignment = 1;
        _nameLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}
@end
