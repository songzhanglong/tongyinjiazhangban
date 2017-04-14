//
//  ImageCropViewController.h
//  NewTeacher
//
//  Created by 张雪松 on 15/10/27.
//  Copyright © 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJImageCropper.h"
#import "DJTBaseViewController.h"

@class ImageCropViewController;

@protocol ImageCropDelegate <NSObject>

-(void)ImageCropVC:(ImageCropViewController*)ivc CroppedImage:(UIImage *)image;

@end


@interface ImageCropViewController : DJTBaseViewController
{
    UIImageView* previewV;
}

@property (nonatomic,strong)  BJImageCropper* cropView;
@property (nonatomic,strong)  UIImage* originImage;
@property (nonatomic,assign) id<ImageCropDelegate> delegate;

@end
