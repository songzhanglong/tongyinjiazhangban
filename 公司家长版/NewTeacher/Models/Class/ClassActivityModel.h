//
//  ClassActivityModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface ClassActivityItem : JSONModel

@property (nonatomic,strong)NSString *path;       //图片路径
@property (nonatomic,strong)NSString *record_url; //音频路径
@property (nonatomic,strong)NSString *thumb;      //缩略图路径
@property (nonatomic,strong)NSString *photo_id;   //图片id
@property (nonatomic,strong)NSString *type;

@end

@interface ClassActivityModel : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *photos_num;
@property (nonatomic,strong)NSString *thumb;
@property (nonatomic,strong)NSString *up_time;
@property (nonatomic,strong)NSMutableArray *items;

@end
