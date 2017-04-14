//
//  AdModel.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface AdModel : JSONModel

@property (nonatomic,strong) NSString *ad_id;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *digg;
@property (nonatomic,strong) NSString *digst;
@property (nonatomic,strong) NSString *end_time;
@property (nonatomic,strong) NSString *picture;
@property (nonatomic,strong) NSString *start_time;
@property (nonatomic,strong) NSString *url;

@end
