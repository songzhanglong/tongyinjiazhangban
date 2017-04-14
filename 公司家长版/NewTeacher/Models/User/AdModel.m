//
//  AdModel.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "AdModel.h"

@implementation AdModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (BOOL)isEqual:(AdModel *)object
{
    return [_picture isEqualToString:object.picture];
}

@end
