//
//  ClassActivityModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassActivityModel.h"

@implementation ClassActivityItem
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation ClassActivityModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
