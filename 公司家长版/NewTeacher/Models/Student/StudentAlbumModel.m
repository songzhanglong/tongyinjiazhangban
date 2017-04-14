//
//  StudentAlbumModel.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "StudentAlbumModel.h"

@implementation StudentItem
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation StudentAlbumModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
