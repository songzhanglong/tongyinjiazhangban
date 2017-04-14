//
//  NSDate+Common.m
//  NewTeacher
//
//  Created by soul on 15/3/17.
//  Copyright (c) 2015年 yanghaibo. All rights reserved.
//

#import "NSDate+Common.h"

@implementation NSDate (Common)
//数值转时间格式
+(NSString *) stringFormInterval:(NSString *)interval formater:(NSString *)formater

{
    NSDate*confromTimesp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[interval doubleValue]];
    NSString*confromTimespStr = [self stringFromDate:confromTimesp formater:@"yyyy-MM-dd HH:mm:ss"];
    
    return confromTimespStr;
    
}


//时间格式化为字符串 yyyy-MM-dd HH:mm:ss

+ (NSString *)stringFromDate:(NSDate *)date formater:(NSString *)formater{
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:formater];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    
    return destDateString;
    
}


//字符串格式时间转化为时间格式 yyyy-MM-dd HH:mm:ss

+ (NSDate *)dateFromString:(NSString *)date formater:(NSString *)formater{
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:formater];
    
    NSDate *destDateString = [dateFormatter dateFromString:date];
    
    return destDateString;
    
}

+(double)getTimeIntev:(id)date
{
    if ([date isKindOfClass:[NSString class]]) {
        return
        [[NSDate dateFromString:date formater:@"yyyy-MM-dd HH:mm:ss"] timeIntervalSince1970];
    }else if([date isKindOfClass:[NSDate class]]){
        return [date timeIntervalSince1970];
    }
    return 0.0;
}
@end
