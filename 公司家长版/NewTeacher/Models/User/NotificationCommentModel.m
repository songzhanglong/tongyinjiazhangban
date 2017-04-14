//
//  NotificationCommentModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/2/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationCommentModel.h"
#import "DJTGlobalDefineKit.h"

@implementation NotificationMsg

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation NotificationReader

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation NotificationUnReader

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation NotificationCommentItem

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (NSString *)generalReplyString
{
    NSMutableString *result = [[NSMutableString alloc] init];
    if (_reply_name && [_reply_name length] > 0) {
        [result appendFormat:@"%@回复%@: ",_author_name,_reply_name];
    }
    else
    {
        [result appendFormat:@"%@: ",_author_name];
    }
    
    return [NSString stringWithFormat:@"%@%@",result,_content];
}

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font
{
    if (!_lastText) {
        self.lastText = [self generalReplyString];
    }
    
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [_lastText boundingRectWithSize:CGSizeMake(maxWei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    _conSize = lastSize;
}

@end

@implementation NotificationCommentModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation ObjectModel

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font
{
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [_content boundingRectWithSize:CGSizeMake(maxWei, 3000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    _contentSize = lastSize;
}

@end
