//
//  LastPhotoModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "LastPhotoModel.h"

@implementation LastPhotoFace

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation LastPhotoList

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation LastPhotoModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"ret_data.photo": @"photos",@"ret_data.face": @"face"}];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
