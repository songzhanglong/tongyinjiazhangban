//
//  NotificationListViewController.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/10.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
/**
 *  通知下方显示文字判断规则
 通知有家长看了，文字提示:有X个家长查看了最新得院所通知
 通知有家长回复了，问题提示：XXX加载回复最新的消息
 3天内无回复,无查看，问题提示：最近通知时间：2014年12月12日
 园所从来没有发布过园所通知：暂无园所通知
 */
@interface NotificationListViewController : DJTTableViewController

@end
