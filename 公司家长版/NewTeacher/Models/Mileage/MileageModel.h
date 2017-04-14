//
//  MileageModel.h
//  NewTeacher
//
//  Created by szl on 15/12/1.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol MileagePhotoItem
@end
@interface MileagePhotoItem : JSONModel

@property (nonatomic,strong)NSString *batch_id;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *is_teacher;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *thumb;
@property (nonatomic,strong)NSString *type;     //0-图片，1-视频
@property (nonatomic,strong)NSString *userid;

@end

@protocol MileageThumbItem
@end
@interface MileageThumbItem : JSONModel

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *up_time;
@property (nonatomic,strong)NSString *mileage_type;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *thumb;

@property (nonatomic,assign)CGFloat nameHei;

- (void)caculateNameHei;
@end

@interface MileageModel : JSONModel

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSNumber *mileage_type; //0（全部）  1（我的）  2（班级） 3（系统）
@property (nonatomic,strong)NSString *digst;
@property (nonatomic,strong)NSArray<MileagePhotoItem> *photo;
@property (nonatomic,strong)NSString *ctime;
@property (nonatomic,strong)NSString *etime;
@property (nonatomic,strong)NSString *update_time;

@property (nonatomic,assign)CGFloat nameHei;

- (void)caculateNameHei;

@end
