//
//  ThemeDetailViewController.h
//  NewTeacher
//
//  Created by szl on 15/12/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

typedef NS_ENUM (NSInteger, DetailFromType)
{
    DetailFromMy,           //我的
    DetailFromClass,        //班级
    DetailFromClassmates,   //同学
    DetailFromFound,        //发现
};
@class ThemeBatchModel;

@protocol ThemeDetailViewControllerDelegate <NSObject>

@optional
- (void)changeDiggAndComment;
- (void)deleteThisBatch;

@end

@interface ThemeDetailViewController : DJTTableViewController

@property (nonatomic,strong)ThemeBatchModel *themeBatch;
@property (nonatomic,assign)DetailFromType fromType;
@property (nonatomic,assign)id<ThemeDetailViewControllerDelegate> delegate;

@end
