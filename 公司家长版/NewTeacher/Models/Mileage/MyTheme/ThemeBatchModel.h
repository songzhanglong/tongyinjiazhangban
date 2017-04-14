//
//  ThemeBatchModel.h
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol ThemeBatchItem

@end
@interface ThemeBatchItem : JSONModel

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *batch_id;
@property (nonatomic,strong)NSString *comments_num;
@property (nonatomic,strong)NSString *create_d;
@property (nonatomic,strong)NSString *create_m;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *create_y;
@property (nonatomic,strong)NSString *creater;
@property (nonatomic,strong)NSString *deleted;
@property (nonatomic,strong)NSString *exif;
@property (nonatomic,assign)CGFloat height;
@property (nonatomic,strong)NSString *hits;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *is_cover;
@property (nonatomic,strong)NSString *message;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *parent_photo_id;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *record_url;
@property (nonatomic,strong)NSString *tags;
@property (nonatomic,strong)NSString *thumb;
@property (nonatomic,strong)NSString *type;     //0－图片，1-视频
@property (nonatomic,strong)NSString *upload_from;
@property (nonatomic,strong)NSString *use_student_ids;
@property (nonatomic,strong)NSString *userid;
@property (nonatomic,strong)NSString *width;

@end

@interface ThemeBatchModel : JSONModel

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *batch_id;
@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *create_term;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,assign)BOOL deleted;
@property (nonatomic,strong)NSNumber *digg;
@property (nonatomic,strong)NSString *digst;    //描述
@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSNumber *have_digg;    //0-未点赞
@property (nonatomic,strong)NSString *is_teacher;
@property (nonatomic,strong)NSString *mid;
@property (nonatomic,strong)NSString *mileage_type;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSArray<ThemeBatchItem> *photos;
@property (nonatomic,strong)NSNumber *replies;
@property (nonatomic,strong)NSString *userid;
@property (nonatomic,strong)NSString *visual_type;
@property (nonatomic,strong)NSString *relation;

@property (nonatomic,assign)CGFloat contentHei;

@end
