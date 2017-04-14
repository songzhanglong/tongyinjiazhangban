//
//  ChannelModel.m
//  NewTeacher
//
//  Created by szl on 16/5/13.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "ChannelModel.h"

@implementation PowerOpen

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (BOOL)isEqual:(id)object
{
    PowerOpen *other = (PowerOpen *)object;
    return  [_id isEqualToString:other.id] &&
            [_open_time isEqualToString:other.open_time] &&
            [_name isEqualToString:other.name] &&
            [_is_valid isEqualToNumber:other.is_valid];
}

@end

@implementation ChannelModel

@end
