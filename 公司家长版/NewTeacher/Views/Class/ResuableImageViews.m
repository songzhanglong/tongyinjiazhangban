//
//  ResuableImageViews.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ResuableImageViews.h"
#import "DJTGlobalDefineKit.h"
#import "UIImage+Caption.h"
#import "DJTGlobalManager.h"

@implementation ResuableImageViews

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _nMaxCount = 5;
        
        for (NSInteger i = 0; i < _nMaxCount; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [imageView setTag:i + 1];
            [imageView setUserInteractionEnabled:YES];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 3.0;
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setClipsToBounds:YES];
            [imageView setBackgroundColor:BACKGROUND_COLOR];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageItemClicked:)]];
            [self addSubview:imageView];
            
            //video
            UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            [videoImg setImage:CREATE_IMG(@"mileageVideo")];
            videoImg.hidden = YES;
            [videoImg setTag:100];
            [imageView addSubview:videoImg];
        }
        _morePicture=[[UIButton alloc] initWithFrame:CGRectZero];
        [_morePicture setTitle:@"查看更多" forState:UIControlStateNormal];
        [_morePicture setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _morePicture.titleLabel.font=[UIFont systemFontOfSize:15];
        [_morePicture.layer setCornerRadius:3];
        [_morePicture.layer setMasksToBounds:YES];
        [_morePicture setBackgroundColor:[UIColor blackColor]];
        [_morePicture setHidden:YES];
        [_morePicture addTarget:self action:@selector(morePicture:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_morePicture];
    }
    return self;
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    [self buildViews];
    
}

#pragma mark 设置展示的图片
- (void)buildViews
{
    NSInteger imageCount = [_images count];
    CGFloat margin = (_changeMargin > 0) ? _changeMargin : 10;
    BOOL bigMp4 = (_type.integerValue != 0);
    for (NSInteger i = 0; i < _nMaxCount; i++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:i + 1];
        if (i < imageCount) {
            imageView.hidden = NO;
            CGFloat wei = 0;
            CGRect rect = CGRectZero;
            if (imageCount > 3) {
                wei = (self.bounds.size.width - margin * 3 - 20) / 4;
                if (i == 0) {
                    rect = CGRectMake(10, 0, wei * 2 + margin, wei * 2 + margin);
                }
                else
                {
                    NSInteger row = (i - 1) / 2;
                    NSInteger col = (i - 1) % 2;
                    CGFloat yOri = (wei + margin) * row;
                    CGFloat xOri = margin * 2 + wei * 2 + 10 + (wei + margin) * col;
                    rect = CGRectMake(xOri, yOri, wei, wei);
                }
            }
            else if (imageCount > 1)
            {
                wei = (self.bounds.size.width - margin * 2 - 20) / 3;
                rect = CGRectMake(10 + (wei + margin) * i, 0, wei, wei);
            }
            else if (imageCount == 1)
            {
                wei = (self.bounds.size.width - margin * 3 - 20) / 2 + margin;
                rect = CGRectMake(10, 0, wei, wei);
            }
            
            NSString *url = _images[i];
            if (![url hasPrefix:@"http"]) {
                url = [[G_IMAGE_ADDRESS stringByAppendingString:url ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [imageView setFrame:rect];
            
            UIImageView *video = (UIImageView *)[imageView viewWithTag:100];
            [imageView setImage:nil];
            NSURL *nsurl = [NSURL URLWithString:url];
            if (bigMp4)
            {
                video.hidden = NO;
                [video setCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)];
                BOOL mp4 = [[[[url lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
                if (mp4) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = [UIImage thumbnailImageForVideo:nsurl atTime:1];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imageView setImage:image];
                        });
                    });
                }
                else
                {
                    [imageView setImageWithURL:nsurl];
                }
            }
            else
            {
                video.hidden = YES;
                [imageView setImageWithURL:nsurl];
            }
        }
        else
        {
            imageView.hidden = YES;
        }
    }
}

- (void)imageItemClicked:(UITapGestureRecognizer *)tap
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickedImageWithIndex:)]) {
        [_delegate clickedImageWithIndex:tap.view.tag - 1];
    }
}

-(void)morePicture:(id)sender
{
    if (_delegate &&[_delegate respondsToSelector:@selector(clickedMorePicture)]) {
        [_delegate clickedMorePicture];
    }
}

@end
