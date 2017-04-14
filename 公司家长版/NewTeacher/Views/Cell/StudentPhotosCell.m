//
//  StudentPhotosCell.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StudentPhotosCell.h"

@implementation StudentPhotosCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //bb_kuang@2x.png
        UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [backView setBackgroundColor:[UIColor clearColor]];
        [backView setImage:[UIImage imageNamed:@"bb_kuang.png"]];
        [self.contentView addSubview:backView];
        
        _studentPhotos = [[UIImageView alloc]initWithFrame:CGRectMake(backView.frame.origin.x + (backView.frame.size.width - 72) / 2, backView.frame.origin.x + (backView.frame.size.width - 72) / 2, 72, 72)];
        _studentPhotos.contentMode = UIViewContentModeScaleAspectFill;
        _studentPhotos.clipsToBounds = YES;
        //[_studentPhotos.layer setMasksToBounds:YES];
        //[_studentPhotos.layer setCornerRadius:5];
        [self.contentView addSubview:_studentPhotos];
        [self.contentView sendSubviewToBack:_studentPhotos];
        
        _videoImg = [[UIImageView alloc] initWithFrame:CGRectMake(backView.frame.origin.x + (backView.frame.size.width - 30) / 2, backView.frame.origin.x + (backView.frame.size.width - 30) / 2, 30, 30)];
        [_videoImg setImage:CREATE_IMG(@"mileageVideo")];
        _videoImg.hidden = YES;
        [self.contentView addSubview:_videoImg];
        
        _studentPhotosCount = [[UILabel alloc]initWithFrame:CGRectMake(_studentPhotos.frame.size.width - 2 - 40 + _studentPhotos.frame.origin.x, _studentPhotos.frame.origin.y + _studentPhotos.frame.size.height - 2 - 20, 40, 20)];
        _studentPhotosCount.textColor = [UIColor whiteColor];
        _studentPhotosCount.textAlignment = NSTextAlignmentCenter;
        _studentPhotosCount.backgroundColor = [UIColor orangeColor];
        [_studentPhotosCount.layer setMasksToBounds:YES];
        [_studentPhotosCount.layer setCornerRadius:10];
        [self.contentView addSubview:_studentPhotosCount];
        
        _studentName = [[UILabel alloc]initWithFrame:CGRectMake(backView.frame.origin.x, backView.frame.origin.y + backView.frame.size.height, backView.frame.size.width, 20)];
        [_studentName setTextAlignment:1];
        [self.contentView addSubview:_studentName];
    }
    return self;
}

@end
