//
//  GrowAlbumListItem.h
//  NewTeacher
//
//  Created by szl on 16/1/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface GrowAlbumListItem : JSONModel

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *batch_id;
@property (nonatomic,strong)NSNumber *create_d;
@property (nonatomic,strong)NSNumber *create_m;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSNumber *create_y;
@property (nonatomic,strong)NSNumber *digg;
@property (nonatomic,strong)NSString *digst;
@property (nonatomic,strong)NSNumber *mileage_type;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *photo_id;
@property (nonatomic,strong)NSNumber *replies;
@property (nonatomic,strong)NSString *thumb;
@property (nonatomic,strong)NSNumber *type;
@property (nonatomic,strong)NSString *useid;
@property (nonatomic,strong)NSNumber *is_teacher;
@property (nonatomic,strong)NSNumber *width;
@property (nonatomic,strong)NSNumber *height;

@end
