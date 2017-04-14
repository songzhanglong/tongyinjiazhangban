//
//  LatestPhotoCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "LatestPhotoCell.h"
#import "UIImage+Caption.h"
#import "LastPhotoModel.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"
#import "DJTGlobalManager.h"

@implementation LatestPhotoCell
{
    UIImageView *_headImg;
    UILabel *_nameLab,*_timeLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *backView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        backView.clipsToBounds = YES;
        [backView setBackgroundColor:[UIColor colorWithRed:215.0 / 255 green:79.0 / 255 blue:57.0 / 255 alpha:1.0]];
        [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:backView];
        
        CGSize winSize = [UIScreen mainScreen].bounds.size;

        //head
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 15;
        [backView addSubview:_headImg];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 120, 20)];
        [_nameLab setTextColor:[UIColor whiteColor]];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [backView addSubview:_nameLab];
        
        //time
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(winSize.width - 10 - 150, 11, 150, 18)];
        [_timeLab setFont:[UIFont systemFontOfSize:14]];
        [_timeLab setBackgroundColor:[UIColor clearColor]];
        [_timeLab setTextColor:[UIColor whiteColor]];
        _timeLab.alpha = 0.5;
        [_timeLab setTextAlignment:2];
        [backView addSubview:_timeLab];
        
        CGFloat margin = 2.0;
        CGFloat imgWei = roundf((winSize.width - margin * 5) / 4);
        for (NSInteger i = 0; i < 4; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(margin + (margin + imgWei) * i, 40, imgWei, imgWei)];
            [imageView setClipsToBounds:YES];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setTag:i + 1];
            [imageView setBackgroundColor:BACKGROUND_COLOR];
            [backView addSubview:imageView];
            
            
            UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((imgWei - 30) / 2, (imgWei - 30) / 2, 30, 30)];
            [videoImg setImage:CREATE_IMG(@"mileageVideo")];
            [videoImg setBackgroundColor:[UIColor clearColor]];
            [videoImg setTag:100];
            videoImg.hidden = YES;
            [imageView addSubview:videoImg];
        }
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    LastPhotoModel *model = (LastPhotoModel *)object;
    NSString *face = model.face.face;
    if (face && (![face hasPrefix:@"http"])) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:face ?: @""] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    [_nameLab setText:model.face.name];
    NSInteger count = model.photos.count;
    if (count > 0) {
        LastPhotoList *first = [model.photos objectAtIndex:0];
        [_timeLab setText:[NSString calculateTimeDistance:first.create_time]];
    }
    else
    {
        [_timeLab setText:@""];
    }
    
    for (NSInteger i = 0; i < 4; i++) {
        UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:i + 1];
        if (i >= count) {
            [imageView setHidden:YES];
        }
        else
        {
            [imageView setHidden:NO];
            
            LastPhotoList *first = [model.photos objectAtIndex:i];
            
            NSString *fileName = [first.path lastPathComponent];
            BOOL mp4 = [[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"];
            
            NSString *url = mp4 ? first.path : first.thumb;
            if (url && (![url hasPrefix:@"http"])) {
                url = [[G_IMAGE_ADDRESS stringByAppendingString:url ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            UIImageView *videoImg = (UIImageView *)[imageView viewWithTag:100];
            if (mp4)
            {
                videoImg.hidden = NO;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:url ?: @""] atTime:1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imageView setImage:image];
                    });
                });
            }
            else
            {
                videoImg.hidden = YES;
                [imageView setImageWithURL:[NSURL URLWithString:url ?: @""]];
            }
        }
    }
}

@end
