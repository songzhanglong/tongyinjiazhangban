//
//  DJTShareView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/7/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DJTShareViewDelegate <NSObject>

@optional
- (void)shareViewTo:(NSInteger)index;

@end

@interface DJTShareView : UIView

@property (nonatomic,assign)id<DJTShareViewDelegate> delegate;

- (void)showInView:(UIView *)view;

+ (BOOL)isCanShareToOtherPlatform;

@end
