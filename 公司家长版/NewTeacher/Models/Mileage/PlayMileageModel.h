//
//  PlayMileageModel.h
//  NewTeacher
//
//  Created by 张雪松 on 15/12/10.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface PlayMileageModel : JSONModel

@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *have_pic;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *up_time;
@property (nonatomic,strong)NSString *update_time;
@property (nonatomic,strong)NSString *url;

@end
