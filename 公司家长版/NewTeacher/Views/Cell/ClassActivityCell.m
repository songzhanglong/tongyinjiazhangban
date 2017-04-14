//
//  ClassActivityCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/6.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassActivityCell.h"
#import "ClassActivityModel.h"
#import "UIImage+Caption.h"

@implementation ClassActivityCell
{
    UILabel *_titleLab,*_timeLab;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        
        //title
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, winSize.width - 20 - 44, 24)];
        [_titleLab setBackgroundColor:[UIColor clearColor]];
        [_titleLab setTextColor:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0]];
        [self.contentView addSubview:_titleLab];
        
        //time
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height - 10 - 18, (winSize.width - 30) / 2, 18)];
        _timeLab.translatesAutoresizingMaskIntoConstraints = NO;
        [_timeLab setTextColor:[UIColor lightGrayColor]];
        [_timeLab setBackgroundColor:[UIColor clearColor]];
        [_timeLab setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_timeLab];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_timeLab attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_timeLab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
        
        for (NSInteger i = 0; i < 5; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setBackgroundColor:[UIColor clearColor]];
            imageView.clipsToBounds = YES;
            imageView.layer.cornerRadius = 5.0;
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setTag:i + 1];
            [self.contentView addSubview:imageView];
            
            //video
            UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((imageView.frame.size.width - 30) / 2, (imageView.frame.size.height - 30) / 2, 30, 30)];
            [videoImg setImage:CREATE_IMG(@"mileageVideo")];
            [videoImg setTag:10];
            [videoImg setBackgroundColor:[UIColor clearColor]];
            videoImg.translatesAutoresizingMaskIntoConstraints = NO;
            [imageView addSubview:videoImg];
            
            [imageView addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0], nil]];
        }
    }
    
    return self;
}

@end
