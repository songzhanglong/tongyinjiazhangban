//
//  WeekListModel.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeekListModel : NSObject

@property (nonatomic,strong) NSString *term_name;   //学期名
@property (nonatomic,strong) NSString *week_index;  //周索引
@property (nonatomic,strong) NSString *week_name;   //周名称
@property (nonatomic,strong) NSString *home;        //家长是否编辑过,0-未编辑，1-已编辑

@end
