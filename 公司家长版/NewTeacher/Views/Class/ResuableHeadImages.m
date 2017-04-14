//
//  ResuableHeadImages.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ResuableHeadImages.h"
#import "ClassCircleModel.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"

@implementation ResuableHeadImages

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        imageViews = [[NSMutableArray alloc] init];
        //tip
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 18, 18)];
        [tipImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s31@2x" ofType:@"png"]]];
        [self addSubview:tipImg];
    }
    
    return self;
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    [self removeAllImageViews];
    [self buildViews];
    
}

- (void)removeAllImageViews
{
    for (UIView *iv in imageViews) {
        [iv removeFromSuperview];
    }
    [imageViews removeAllObjects];
}

- (void)createImageView:(NSString *)url Tag:(NSInteger)tag Rect:(CGRect)rect PlaceHolder:(NSString *)holdName
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setTag:tag];
    //[imageView setUserInteractionEnabled:YES];
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [imageView setImage:nil];
    [imageView setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:holdName]];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = rect.size.width / 2;
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageItemClicked:)]];
    [self addSubview:imageView];
    [imageViews addObject:imageView];
}

- (void)imageItemClicked:(UITapGestureRecognizer *)tap
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickedImageWithIndex:)]) {
        [_delegate clickedImageWithIndex:tap.view.tag - 1];
    }
}

#pragma mark 设置展示的图片
- (void)buildViews
{
    NSInteger imageCount = [self.images count];
    if (imageCount == 0) {
        return;
    }
    
    CGFloat margin = 10;
    CGFloat digImgHei = 30,digTipHei = 18;
    NSInteger numPerRow = ([UIScreen mainScreen].bounds.size.width - 20 - margin - digTipHei) / (digImgHei + margin);
    
    for (NSInteger i = 0; i < imageCount; i++) {
        NSInteger row = i / numPerRow;
        NSInteger col = i % numPerRow;
        
        CGRect rect = CGRectMake(margin + 18 + (digImgHei + margin) * col, row * (digImgHei + 5), digImgHei, digImgHei);;
        DiggItem *item = self.images[i];
        [self createImageView:item.face Tag:i + 101 Rect:rect PlaceHolder:@"s21.png"];
        
    }
}

@end
