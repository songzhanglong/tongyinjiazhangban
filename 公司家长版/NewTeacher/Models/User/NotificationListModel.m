//
//  NotificationListModel.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/8.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationListModel.h"
#import "DJTGlobalDefineKit.h"

@implementation NotificationListModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)calculateNotificationRect
{
    CGSize lastSize = CGSizeZero;
    if (_content && [_content length] > 0) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIFont *font = [UIFont systemFontOfSize:17];
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_content boundingRectWithSize:CGSizeMake(winSize.width - 32 - 40 - 10, CGFLOAT_MAX) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }

    _conSize = CGSizeMake(lastSize.width, MAX(lastSize.height, 20));
}

@end
