//
//  FamilNumberModel.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FamilNumberModel : NSObject

@property (nonatomic,strong) NSString *baby_id;     //baby_id
@property (nonatomic,strong) NSString *create_time; //添加时间
@property (nonatomic,strong) NSString *face;        //头像
@property (nonatomic,strong) NSString *mobile;      //手机
@property (nonatomic,strong) NSString *name;        //姓名
@property (nonatomic,strong) NSString *id;          //唯一标志

@end
