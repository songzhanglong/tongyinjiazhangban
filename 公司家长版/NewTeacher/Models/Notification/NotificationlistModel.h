//
//  NotificationlistModel.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationlistModel : NSObject
@property (nonatomic,retain) NSString *content;
@property (nonatomic,retain) NSString *ctime;
@property (nonatomic,retain) NSString *message_id;
@property (nonatomic,retain) NSString *receivers;
@property (nonatomic,retain) NSString *title;
@end
