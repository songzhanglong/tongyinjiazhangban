//
//  EditFamilyModel.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EditFamilyModel.h"

@implementation Options

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation EditFamilyModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)caculateClass_commentHei
{
    if ([_comment length] == 0) {
        _class_commentHei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat wei = 290;
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_comment boundingRectWithSize:CGSizeMake(wei, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        _class_commentHei = MAX(20, lastSize.height + 10);
    }
    
}
@end
