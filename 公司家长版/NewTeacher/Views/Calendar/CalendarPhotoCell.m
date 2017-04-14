//
//  CalendarPhotoCell.m
//  NewTeacher
//
//  Created by szl on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarPhotoCell.h"

@implementation CalendarPhotoCell
{
    UIImageView *_headImg;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [_leftImgView setFrameY:_leftImgView.frameY + 13];
        [_nameLab setFrameY:_nameLab.frameY + 13];
        [_timeLab setFrameY:_timeLab.frameY + 13];
        
        UIImageView *imgaeView = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLab.frameRight + 10, 11.5, 121, 93)];
        [imgaeView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kuang2" ofType:@"png"]]];
        [self.contentView addSubview:imgaeView];
        
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(imgaeView.frameX + 2, imgaeView.frameY, imgaeView.frameWidth - 4, imgaeView.frameHeight - 4)];
        _headImg.clipsToBounds = YES;
        [_headImg setContentMode:UIViewContentModeScaleAspectFill];
        [_headImg setBackgroundColor:BACKGROUND_COLOR];
        [self.contentView addSubview:_headImg];
    }
    return self;
}

- (void)resetTimeCard:(TimeCardRecord *)record
{
    [super resetTimeCard:record];
    
    NSString *str = record.check_face;
    if (![str hasPrefix:@"http"]) {
        str = [G_IMAGE_GROW_ADDRESS stringByAppendingString:str ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:str]];
}

@end
