//
//  NotificationCommentModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/2/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol NotificationMsg

@end
//消息详情
@interface NotificationMsg : JSONModel

@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *message_id;
@property (nonatomic,strong)NSString *ctime;

@end

@protocol NotificationReader

@end
//已看过用户
@interface NotificationReader : JSONModel

@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *real_name;
@property (nonatomic,strong)NSString *receiver_type;    //0-家长,1-老师
@property (nonatomic,strong)NSString *receiver;

@end

@protocol NotificationUnReader

@end
//已看过用户
@interface NotificationUnReader : JSONModel

@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *real_name;
@property (nonatomic,strong)NSString *receiver_type;    //0-家长,1-老师
@property (nonatomic,strong)NSString *receiver;

@end

@protocol NotificationCommentItem

@end
//评论
@interface NotificationCommentItem : JSONModel

@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *reply_name;
@property (nonatomic,strong)NSString *reply_id;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *author_name;
@property (nonatomic,strong)NSString *message_id;
@property (nonatomic,strong)NSString *author_id;
@property (nonatomic,strong)NSString *is_teacher;   //发送人是家长还是教师   家长0  教师1  园长2

@property (nonatomic,strong)NSString *lastText;
@property (nonatomic,assign)CGSize conSize;

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font;

@end

@interface NotificationCommentModel : JSONModel

@property (nonatomic,strong)NotificationMsg *message;
@property (nonatomic,strong)NSArray<NotificationReader> *reader;
@property (nonatomic,strong)NSArray<NotificationUnReader> *unreader;
@property (nonatomic,strong)NSArray<NotificationCommentItem> *comment;

@end

@interface ObjectModel : NSObject

@property (nonatomic,strong)NSString *content;
@property (nonatomic,assign)CGSize contentSize;
@property (nonatomic,strong)NSArray *parents;
@property (nonatomic,assign)BOOL isAllShow;
@property (nonatomic,assign)BOOL showAll;

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font;

@end
