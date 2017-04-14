//
//  ClassActivityNewCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/14.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassActivityNewCell.h"
#import "UIImage+Caption.h"
#import "MileageModel.h"
#import "NSString+Common.h"

@implementation ClassActivityNewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //image
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 66, 66)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 5.0;
        [_imageView setBackgroundColor:BACKGROUND_COLOR];
        [self.contentView addSubview:_imageView];
        
        _videoImg = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x + (_imageView.frame.size.width - 30) / 2, _imageView.frame.origin.y + (_imageView.frame.size.height - 30) / 2, 30, 30)];
        [_videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [_videoImg setBackgroundColor:[UIColor clearColor]];
        _videoImg.hidden = YES;
        [self.contentView addSubview:_videoImg];

        
        //num
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width-40, _imageView.frame.origin.y + _imageView.frame.size.height - 2 - 22+2, 40, 22)];
        [_numLabel setTextAlignment:NSTextAlignmentCenter];
        [_numLabel setBackgroundColor:[UIColor blackColor]];
        [_numLabel setTextColor:CreateColor(255,255,255)];
        [_numLabel setFont:[UIFont systemFontOfSize:17]];
        _numLabel.alpha=0.5;
        _numLabel.layer.cornerRadius=11;
        [_numLabel.layer setMasksToBounds:YES];
        _numLabel.hidden = YES;
        [self.contentView addSubview:_numLabel];
        
        CGFloat wei = [UIScreen mainScreen].bounds.size.width;
        CGFloat labWei = wei - _imageView.frame.origin.x - _imageView.frame.size.width - 30 - 20;
        //title
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + 10, _imageView.frame.origin.y + 3, labWei, 22)];
        [_titleLab setBackgroundColor:[UIColor clearColor]];
        [_titleLab setFont:[UIFont systemFontOfSize:18]];
        [_titleLab setTextColor:[UIColor colorWithRed:74.0 / 255 green:141.0 / 255 blue:201.0 / 255 alpha:1.0]];
        [self.contentView addSubview:_titleLab];
        
        //time
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(_titleLab.frame.origin.x, _titleLab.frame.origin.y + _titleLab.frame.size.height + 2, labWei, 18)];
        [_timeLab setFont:[UIFont systemFontOfSize:14]];
        [_timeLab setTextColor:CreateColor(147,146,142)];
        [_timeLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_timeLab];
        
        //tip
        _tipLabl = [[UILabel alloc] initWithFrame:CGRectMake(_titleLab.frame.origin.x, _imageView.frame.origin.y + _imageView.frame.size.height - 3 - 18, labWei, 18)];
        [_tipLabl setTextColor:CreateColor(147,146,142)];
        [_tipLabl setFont:[UIFont systemFontOfSize:14]];
        [_tipLabl setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_tipLabl];
    }
    return self;
}

- (void)resetClassActivityData:(id)object
{
    MileageThumbItem *model = (MileageThumbItem *)object;
    [_titleLab setText:model.name];
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:model.up_time.doubleValue];
    [_timeLab setText:[NSString stringWithFormat:@"%@ 更新",[NSString stringByDate:@"yyyy-MM-dd HH:mm:ss" Date:updateDate]]];

    NSString *fileName = [model.thumb lastPathComponent];
    BOOL mp4 = [[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"];
    NSString *url = [model.thumb hasPrefix:@"http"] ? model.thumb : [G_IMAGE_ADDRESS stringByAppendingString:model.thumb ?: @""];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (mp4)
    {
        _videoImg.hidden = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:url] atTime:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imageView setImage:image];
            });
        });
    }
    else
    {
        _videoImg.hidden = YES;
        [_imageView setImageWithURL:[NSURL URLWithString:url]];
    }
}

@end
