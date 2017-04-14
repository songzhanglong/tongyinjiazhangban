//
//  SelectedPhotosCell.m
//  NewTeacher
//
//  Created by szl on 16/2/22.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import "SelectedPhotosCell.h"
#import "GrowAlbumListItem.h"
#import "UIImage+Caption.h"
#import "SelectPhotosModel.h"

@implementation SelectedPhotosCell
{
    UIImageView *_videoImg;
    UIImageView *_delImg;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //content
        _contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, self.contentView.bounds.size.width - 8, self.contentView.bounds.size.height - 8)];
        [_contentImg setContentMode:UIViewContentModeScaleAspectFill];
        [_contentImg setClipsToBounds:YES];
        _contentImg.layer.masksToBounds = YES;
        _contentImg.layer.borderColor = [UIColor whiteColor].CGColor;
        _contentImg.layer.borderWidth = 1;
        _contentImg.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentImg setBackgroundColor:BACKGROUND_COLOR];
        [self.contentView addSubview:_contentImg];
        [self.contentView addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:_contentImg attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:8],[NSLayoutConstraint constraintWithItem:_contentImg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8],[NSLayoutConstraint constraintWithItem:_contentImg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:-8],[NSLayoutConstraint constraintWithItem:_contentImg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1 constant:-8], nil]];
        
        //video
        _videoImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [_videoImg setBackgroundColor:[UIColor clearColor]];
        _videoImg.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentImg addSubview:_videoImg];
        [_contentImg addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:_videoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_contentImg attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],[NSLayoutConstraint constraintWithItem:_videoImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_contentImg attribute:NSLayoutAttributeCenterY multiplier:1 constant:0], nil]];
        [_videoImg addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:_videoImg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30],[NSLayoutConstraint constraintWithItem:_videoImg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30], nil]];
        
        //del
        _delImg = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 15, 15)];
        [_delImg setImage:CREATE_IMG(@"grow_del@2x")];
        [self.contentView addSubview:_delImg];
        
        _fmImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_contentImg.frameWidth - 25.5, 0, 25.5, 19.5)];
        [_fmImgView setImage:CREATE_IMG(@"grow_fm")];
        [_contentImg addSubview:_fmImgView];
    }
    
    return self;
}

- (void)resetDataSource:(id)data
{
    if ([data isKindOfClass:[SelectPhotosModel class]]) {
        SelectPhotosModel *phtotModel = (SelectPhotosModel *)data;
        _videoImg.hidden = (phtotModel.type == 0);
        _delImg.hidden = YES;
        if (!_videoImg.hidden) {
            NSString *imageName = (phtotModel.type == 1) ? @"mileageVideo" : @"mileage_h5";
            [_videoImg setImage:CREATE_IMG(imageName)];
        }
        if (phtotModel.thumb.length > 0) {
            NSString *url = phtotModel.thumb;
            if (![url hasPrefix:@"http"]) {
                url = [[G_IMAGE_ADDRESS stringByAppendingString:url ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [_contentImg setImageWithURL:[NSURL URLWithString:url]];
        }
        else if (phtotModel.thumbImg != nil){
            [_contentImg setImage:phtotModel.thumbImg];
        }
        else if (phtotModel.imageFileStr.length > 0) {
            [_contentImg setImage:[UIImage imageWithContentsOfFile:phtotModel.imageFileStr]];
        }
        else if (phtotModel.imgStr.length > 0){
            NSString *url = phtotModel.imgStr;
            if (![url hasPrefix:@"http"]) {
                url = [[G_IMAGE_ADDRESS stringByAppendingString:url ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [_contentImg setImageWithURL:[NSURL URLWithString:url]];
        }
        else if (phtotModel.videoFileStr.length > 0){
            NSURL *url = [NSURL fileURLWithPath:phtotModel.videoFileStr];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage thumbnailImageForVideo:url atTime:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_contentImg setImage:image];
                });
            });
        }
        else if (phtotModel.videoStr.length > 0)
        {
            NSString *url = phtotModel.videoStr;
            if (![url hasPrefix:@"http"]) {
                url = [[G_IMAGE_ADDRESS stringByAppendingString:url ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:url] atTime:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_contentImg setImage:image];
                });
            });
        }
        else{
            [_contentImg setImage:nil];
        }
    }
    else
    {
        GrowAlbumListItem *item = (GrowAlbumListItem *)data;
        _videoImg.hidden = !(item.type.integerValue != 0);
        _fmImgView.hidden = YES;
        NSString *str = item.thumb ?: item.path;
        if (![str hasPrefix:@"http"]) {
            str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        if (!_videoImg.hidden){
            BOOL mp4 = [[[[str lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
            if (mp4) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:str] atTime:1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_contentImg setImage:image];
                    });
                });
            }
            else
            {
                [_contentImg setImageWithURL:[NSURL URLWithString:str]];
            }
        }
        else
        {
            [_contentImg setImageWithURL:[NSURL URLWithString:str]];
        }
    }
}

- (UIImageView *)hdImg{
    if (!_hdImg) {
        _hdImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 12, 20)];
        [_hdImg setBackgroundColor:[UIColor clearColor]];
        [_hdImg setImage:CREATE_IMG(@"HDTip")];
        [self.contentView addSubview:_hdImg];
    }
    return _hdImg;
}

@end
