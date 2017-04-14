//
//  StudentCheckCell.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StudentCheckCell.h"

@implementation StudentCheckCell
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        _faceImageView=[[UIImageView alloc]initWithFrame:CGRectMake(21, 2, 62, 62)];
        [_faceImageView.layer setMasksToBounds:YES];
        [_faceImageView.layer setCornerRadius:30];
        [self.contentView addSubview:_faceImageView];
        
        _coverImage=[[UIImageView alloc]initWithFrame:_faceImageView.frame];
        [_coverImage setImage:[UIImage imageNamed:@"tu2.png"]];
        [self.contentView addSubview:_coverImage];
        
        _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(6, 70, 95, 21)];
        _nameLabel.text=@"夏小造";
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_nameLabel];
        
        _sickLabel=[[UILabel alloc]initWithFrame:CGRectMake(0 , 22, 62, 21)];
        [_sickLabel setText:@"病假"];
        [_sickLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
        [_sickLabel setTextColor:[UIColor whiteColor]];
        [_sickLabel setTextAlignment:NSTextAlignmentCenter];
        [_coverImage addSubview:_sickLabel];
    }
    return self;
}
@end
