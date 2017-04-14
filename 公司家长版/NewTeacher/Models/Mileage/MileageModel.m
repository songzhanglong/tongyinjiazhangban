//
//  MileageModel.m
//  NewTeacher
//
//  Created by szl on 15/12/1.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageModel.h"

@implementation MileagePhotoItem

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation MileageThumbItem

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)caculateNameHei
{
    if ([_name length] == 0) {
        _nameHei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat wei = (winSize.width - 30) / 3 - 10;
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_name boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        _nameHei = MIN(40, lastSize.height);
    }
}

@end

@implementation MileageModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)caculateNameHei
{
    if ([_name length] == 0) {
        _nameHei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat wei = (winSize.width - 30) / 3 - 10;
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_name boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        _nameHei = MIN(36, lastSize.height);
    }
}

@end
