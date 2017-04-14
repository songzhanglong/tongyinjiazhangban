//
//  ClassCircleModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol ReplyItem

@end
@interface ReplyItem : JSONModel

@property (nonatomic,strong)NSString *replay_message;   //回复内容
@property (nonatomic,strong)NSString *reply_name;   //回复人
@property (nonatomic,strong)NSString *send_name;    //发送人
@property (nonatomic,strong)NSString *tid;          //班级动态id
@property (nonatomic,strong)NSString *face;         //发送人头像
@property (nonatomic,strong)NSString *is_teacher;   //0-家长，1-老师
@property (nonatomic,strong)NSString *name;         //跟send_name一样，该字段重复
@property (nonatomic,strong)NSString *reply_id;     //回复人id
@property (nonatomic,strong)NSString *reply_is_teacher; //回复人是否老师
@property (nonatomic,strong)NSString *send_id;      //发送方id
@property (nonatomic,strong)NSString *pid;
@property (nonatomic,strong)NSString *dateline;     //时间
@property (nonatomic,assign)CGSize itemSize;

- (void)calculateItemRect:(CGFloat)wei Font:(UIFont *)font;

- (NSAttributedString *)generalHTMLStr;

- (NSString *)generalReplyString;

- (NSString *)generalReplyString2;

@end

@protocol DiggItem

@end
@interface DiggItem : JSONModel

@property (nonatomic,strong)NSString *face;         //点赞人头像
@property (nonatomic,strong)NSString *is_teacher;   //点赞人是否老师
@property (nonatomic,strong)NSString *name;         //点赞人姓名
@property (nonatomic,strong)NSString *userid;       //点赞人id

@end

@interface ClassCircleModel : JSONModel

@property (nonatomic,strong)NSString *album_name;   //相册名
@property (nonatomic,strong)NSString *albums_id;    //相册id
@property (nonatomic,strong)NSArray *attention;     //[{"member_name":"张三"},{"member_name":"李四"}]，提醒哪些人关注
@property (nonatomic,strong)NSString *author;       //该动态发布作者
@property (nonatomic,strong)NSString *authorid;     //该动态发布人id
@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *class_name;
@property (nonatomic,strong)NSString *dateline;     //时间
@property (nonatomic,strong)NSMutableArray<DiggItem> *digg;          //点赞,DiggItem
@property (nonatomic,strong)NSString *digest;
@property (nonatomic,strong)NSNumber *digg_count;   //点赞数量
@property (nonatomic,strong)NSString *displayorder;
@property (nonatomic,strong)NSString *face;         //头像地址
@property (nonatomic,strong)NSString *grade_id;
@property (nonatomic,strong)NSString *grade_name;
@property (nonatomic,strong)NSNumber *have_digg;    //0-未点赞
@property (nonatomic,strong)NSString *is_teacher;   //1-老师
@property (nonatomic,strong)NSString *lastpost;     //最后一次评论时间
@property (nonatomic,strong)NSString *lastposter;   //最后一次评论人员
@property (nonatomic,strong)NSString *message;      //文本内容
@property (nonatomic,strong)NSString *name;         //姓名
@property (nonatomic,strong)NSString *picture;      //以｜分隔
@property (nonatomic,strong)NSString *picture_thumb;//以｜分隔
@property (nonatomic,strong)NSNumber *replies;      //评论数量
@property (nonatomic,strong)NSString *school_id;
@property (nonatomic,strong)NSString *subject;
@property (nonatomic,strong)NSString *tag;
@property (nonatomic,strong)NSString *tid;          //动态编号
@property (nonatomic,strong)NSString *type;         //0－图片，1-视频
@property (nonatomic,strong)NSString *views;        //
@property (nonatomic,strong)NSMutableArray<ReplyItem> *reply;  //ReplyItem
@property (nonatomic,assign) BOOL isNotUpload;

#pragma mark - 计算坐标
@property (nonatomic,assign,readonly)CGRect tipRect;
@property (nonatomic,assign,readonly)CGRect imagesRect;
@property (nonatomic,assign,readonly)CGRect contentRect;
@property (nonatomic,assign,readonly)CGRect attentionRect;
@property (nonatomic,assign,readonly)CGFloat butYori;
@property (nonatomic,assign,readonly)CGRect diggRect;
@property (nonatomic,strong)NSArray *replyRects;
@property (nonatomic,assign,readonly)CGRect replyBackRect;

@property (nonatomic,assign,readonly)CGRect imagesRect2;
@property (nonatomic,assign,readonly)CGRect contentRect2;
@property (nonatomic,assign,readonly)CGFloat butYori2;

- (void)calculateGroupCircleRects;

@end
