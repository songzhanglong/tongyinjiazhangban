//
//  ThemeBatchModel.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ThemeBatchModel.h"

@implementation ThemeBatchItem

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation ThemeBatchModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (BOOL)isEqual:(ThemeBatchModel *)object{
    return [_batch_id isEqualToString:object.batch_id];
}

@end
