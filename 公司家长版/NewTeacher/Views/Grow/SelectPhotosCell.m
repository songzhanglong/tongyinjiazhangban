//
//  SelectPhotosCell.m
//  NewTeacher
//
//  Created by szl on 16/2/22.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import "SelectPhotosCell.h"
#import "GrowAlbumListItem.h"
#import "UIImage+Caption.h"

@implementation SelectPhotosCell
{
    UIImageView *_videoImg;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //content
        _contentImg = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [_contentImg setContentMode:UIViewContentModeScaleAspectFill];
        [_contentImg setClipsToBounds:YES];
        [_contentImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_contentImg setBackgroundColor:BACKGROUND_COLOR];
        [self.contentView addSubview:_contentImg];
        
        //video
        _videoImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [_videoImg setBackgroundColor:[UIColor clearColor]];
        _videoImg.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_videoImg];
        [self.contentView addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:_videoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],[NSLayoutConstraint constraintWithItem:_videoImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0], nil]];
        [_videoImg addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:_videoImg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30],[NSLayoutConstraint constraintWithItem:_videoImg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30], nil]];
        
        //label
        _fromLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 14)];
        [_fromLab setTextAlignment:NSTextAlignmentCenter];
        [_fromLab setFont:[UIFont systemFontOfSize:10]];
        [_fromLab setTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:_fromLab];
        
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setFrame:CGRectMake(self.contentView.frame.size.width - 27, 0, 27, 27)];
        [_checkBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [_checkBtn setImage:CREATE_IMG(@"grow_photo_check1") forState:UIControlStateNormal];
        [_checkBtn setImage:CREATE_IMG(@"grow_photo_check") forState:UIControlStateSelected];
        [_checkBtn addTarget:self action:@selector(checkButton:) forControlEvents:UIControlEventTouchUpInside];
        [_checkBtn setHidden:YES];
        [self.contentView addSubview:_checkBtn];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"checkBig2"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(self.contentView.frame.size.width - 20 - 2, 2, 20, 20)];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [button setHidden:YES];
        _selBut = button;
        [self.contentView addSubview:button];
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frameWidth, self.contentView.frameHeight)];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        [_bgView setAlpha:0.5];
        _bgView.hidden = YES;
        [self.contentView addSubview:_bgView];
        [self.contentView bringSubviewToFront:_checkBtn];
    }
    
    return self;
}

- (void)checkButton:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^{
        _checkBtn.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        _checkBtn.transform = CGAffineTransformIdentity;
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(checkItemToController:)]) {
        [_delegate checkItemToController:self];
    }
}

- (void)pressButton:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(preShowBigView:)]) {
        [_delegate preShowBigView:self];
    }
}

- (void)resetDataSource:(id)data
{
    GrowAlbumListItem *item = (GrowAlbumListItem *)data;
    NSString *str = item.thumb ?: item.path;
    if (![str hasPrefix:@"http"]) {
        str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (item.type.integerValue != 0){
        _videoImg.hidden = NO;
        NSString *imageName = (item.type.integerValue == 1) ? @"mileageVideo" : @"mileage_h5";
        [_videoImg setImage:CREATE_IMG(imageName)];
        
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
        _videoImg.hidden = YES;
        [_contentImg setImageWithURL:[NSURL URLWithString:str]];
    }
    
    //from
    if (!_fromLab.hidden) {
        [_fromLab setText:(item.is_teacher.integerValue == 1) ? @"班级" : @"宝宝"];
        [_fromLab setBackgroundColor:(item.is_teacher.integerValue == 1) ? rgba(25, 161, 86, 1) : rgba(24, 84, 144, 1)];
    }
}

- (UIImageView *)hdImg{
    if (!_hdImg) {
        _hdImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 27)];
        [_hdImg setBackgroundColor:[UIColor clearColor]];
        [_hdImg setImage:CREATE_IMG(@"HDTip")];
        [self.contentView addSubview:_hdImg];
    }
    return _hdImg;
}

@end
