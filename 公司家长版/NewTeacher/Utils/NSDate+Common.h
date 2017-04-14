//
//  NSDate+Common.h
//  NewTeacher
//
//  Created by soul on 15/3/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Common)

/*
 * 数值转时间格式
 * interval 毫秒  formater 格式
 */
+(NSString *) stringFormInterval:(NSString *)interval formater:(NSString *)formater;
/*
 * 时间格式化为字符串
 * date 日期  formater 格式
 */
+ (NSString *)stringFromDate:(NSDate *)date formater:(NSString *)formater;

/*
 *字符串格式时间转化为时间格式
 * date 日期  formater 格式
 */
+ (NSDate *)dateFromString:(NSString *)date formater:(NSString *)formater;

/*
 *时间转换为毫秒
 * date 日期
 */
+(double)getTimeIntev:(id)date;
@end
