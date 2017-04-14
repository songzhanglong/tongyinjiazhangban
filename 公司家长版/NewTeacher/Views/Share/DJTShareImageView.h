//
//  DJTShareImageView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/7/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DJTShareImageViewDelegate <NSObject>

@optional
- (void)shareImageViewTo:(NSInteger)index;

@end

@interface DJTShareImageView : UIView

@property (nonatomic,assign)id<DJTShareImageViewDelegate> delegate;

- (void)showInView:(UIView *)view;

+ (BOOL)isCanShareToOtherPlatform;

@end
