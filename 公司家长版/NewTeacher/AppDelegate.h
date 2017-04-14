//
//  AppDelegate.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSTimer *time;
}

@property (strong, nonatomic) UIWindow *window;

#pragma mark - push 切换
/**
 *	@brief	退出到登录
 */
- (void)popToLoginViewController;

/**
 *	@brief	启动上传数据
 */
- (void)startUpload;

/**
 *	@brief	鉴权失败，退出登录
 */
- (void)failToLgoin;


#pragma mark - 选择登录用户索引
- (void)selectLoginChildIdx:(NSInteger)index;

#pragma mark - 孩子选择
- (void)popSelectedChildrenView;

@end

