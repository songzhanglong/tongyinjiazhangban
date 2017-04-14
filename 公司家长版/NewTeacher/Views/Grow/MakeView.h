//
//  MakeView.h
//  NewTeacher
//
//  Created by szl on 16/2/23.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectPhotosModel.h"

@class MakeView;

@protocol MakeViewDelegate <NSObject>

@optional
- (void)touchMakeView:(MakeView *)makeView;
- (void)hasChangeState:(MakeView *)makeView;

@end
#pragma mark - 自定义拖拽视图

@interface MakeView : UIView

@property (nonatomic,readonly)UIImageView *curImg;
@property (nonatomic,assign)id<MakeViewDelegate> delegate;
@property (nonatomic,strong)SelectPhotosModel *photoModel;
@property (nonatomic,strong)NSArray *photosArray;
@property (nonatomic,assign)CGFloat nRotation;
@property (nonatomic,assign)CGFloat fRate;

/**
 *	@brief	视图重设
 *
 *	@param 	image 	图片内容
 */
- (void)resetImageView:(UIImage *)image;

- (void)beginScale:(CGFloat)scale;

@end
