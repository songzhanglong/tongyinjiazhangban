//
//  NotificationListModel.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/8.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface NotificationListModel : JSONModel

@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *sender;
@property (nonatomic,strong) NSString *face;
@property (nonatomic,strong) NSString *teacher_name;
@property (nonatomic,strong) NSString *message_id;
@property (nonatomic,strong) NSString *ctime;
@property (nonatomic,assign) CGSize conSize;

- (void)calculateNotificationRect;

@end
