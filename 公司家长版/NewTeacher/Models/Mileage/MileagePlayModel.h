//
//  MileagePlayModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface MileagePlayModel : JSONModel

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *num;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *max_num;
@property (nonatomic,strong)NSString *cover_img;
@property (nonatomic,strong)NSString *is_use;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *url;

@end