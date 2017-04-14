//
//  WeatherModel.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "WeatherModel.h"

@implementation PMModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)setPM25Value
{
    if ([_PM25 length] > 0) {
        CGFloat pm = (CGFloat)[_PM25 floatValue];
        if (pm > 0 && pm <= 75.0) {
            _pm25Str = @"无";
        }else if (pm > 75.0 && pm <= 115.0) {
            _pm25Str = @"轻微";
        }else if (pm > 115.0) {
            _pm25Str = @"严重";
        }
    }else {
        _pm25Str = @"";
    }
    
    if ([_HCHO length] > 0) {
        CGFloat pm = (CGFloat)[_HCHO floatValue];
        if (pm > 0 && pm <= 60.0) {
            _hchoStr = @"无";
        }else if (pm > 60.0 && pm <= 100.0) {
            _hchoStr = @"轻微";
        }else if (pm > 100.0) {
            _hchoStr = @"严重";
        }
    }else {
        _hchoStr = @"";
    }
}

@end

@implementation WeatherModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)calculeteConSize
{
    _descSize = CGSizeZero;
    _contSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
    _descSize = [_aqi_desc boundingRectWithSize:CGSizeMake(1000, 15) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    _contSize = [_tip boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    _descSize.width = MAX(25, _descSize.width + 5);
    _contSize.height = MAX(20, _contSize.height + 10);
}

@end
