//
//  StudentModel.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BabyPhoto : NSObject

@property (nonatomic,retain)NSString *photo_id;     //图片唯一ID号
@property (nonatomic,retain)NSString *photo_thumb;  //图片的缩略图
@property (nonatomic,retain)NSString *photo_path;   //图片的高清图
@property (nonatomic,retain)NSString *photo_desc;   //
@property (nonatomic,retain)NSString *type;         //

@end

@interface BabyGrow : NSObject

@property (nonatomic,retain)NSString *id;          //每张成长档案唯一ID号
@property (nonatomic,retain)NSString *grow_index;   //
@property (nonatomic,retain)NSString *image_thumb;  //图片的缩略图
@property (nonatomic,retain)NSString *image_path;   //图片的高清图

@end

@interface BabyCard : NSObject

@property (nonatomic,retain)NSString *card_template_id;     //每张成长档案唯一ID号
@property (nonatomic,retain)NSString *school;       //完成状态（1：代表优秀；0代表良好）
@property (nonatomic,retain)NSString *home;         //完成状态（1：代表优秀；0代表良好）

@end

@interface BabyAttence : NSObject

@property (nonatomic,retain)NSString *date;         //日期
@property (nonatomic,retain)NSString *type;         //异常类型(1:病假；2:事假)
@property (nonatomic,retain)NSString *reason;       //异常原因

@end


@interface StudentModel : NSObject

@property (nonatomic,retain)NSMutableArray *photos;    //宝贝相册,DJTBabyPhoto
@property (nonatomic,retain)NSArray *grows;     //已制作成长档案列表,DJTBabyGrow
@property (nonatomic,retain)NSArray *cards;     //家园联系卡内容,DJTBabyCard
@property (nonatomic,retain)NSArray *attence;   //考勤异常数据,DJTBabyAttence
@property (nonatomic,retain)NSString *card_school_comment_type;     //教师评论类型（0:代表文字；1:代表录音）;
@property (nonatomic,retain)NSString *card_school_content;          //评论类容
@property (nonatomic,retain)NSString *card_home_comment_type;       //家长评论类型（0:代表文字；1:代表录音）
@property (nonatomic,retain)NSString *card_home_content;                            //评论类容

@end
