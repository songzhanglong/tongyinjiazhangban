//
//  MyMsgModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/2/26.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyMsgModel.h"
#import "DJTGlobalDefineKit.h"

@implementation MyMsgModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font
{
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [_eachData boundingRectWithSize:CGSizeMake(maxWei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    _conSize = lastSize;
}

@end
