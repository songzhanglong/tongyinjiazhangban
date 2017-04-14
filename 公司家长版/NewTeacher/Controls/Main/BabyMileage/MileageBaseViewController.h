//
//  MileageBaseViewController.h
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "SelectChannelView.h"

typedef NS_ENUM (NSInteger, MileageThemeType)
{
    MileageThemeNormal = 0,
    MileageThemeAdd,           //添加
    MileageThemeEdit,          //编辑
    MileageThemeDelete,        //删除
    MileageThemeSee,           //只能查看
};

@interface MileageBaseViewController : DJTTableViewController
{
    SelectChannelView *_channelView;
}

@property (nonatomic ,strong) UIViewController *currentVC;
@property (nonatomic,assign)NSInteger initIdx;
@property (nonatomic ,strong) NSArray *subControls;

- (id)initWithControls:(NSArray *)subControls Titles:(NSArray *)titles Frame:(CGRect)frame;

- (void)changeControlToIndex:(NSInteger)index;

@end
