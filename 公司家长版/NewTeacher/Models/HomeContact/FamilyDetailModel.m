//
//  FamilyDetailModel.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyDetailModel.h"

@implementation ReplysItem
+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)caculateClass_contHei
{
    if ([_content length] == 0) {
        _class_contHei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat wei = SCREEN_WIDTH - 75;
        NSString *str = _content;
        if ([_relate_user_name length] > 0) {
            str = [NSString stringWithFormat:@"回复%@:%@",_relate_user_name,_content];
        }
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [str boundingRectWithSize:CGSizeMake(wei, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        _class_contHei = MAX(28, lastSize.height + 10);
    }
}

@end

@implementation OptionsItem
+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)caculateClass_contHei
{
    if ([_content length] == 0) {
        _class_contHei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat wei = 280;
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_content boundingRectWithSize:CGSizeMake(wei, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        _class_contHei = MAX(30, lastSize.height + 10);
    }
    
    if ([_checked_option length] == 0) {
        _class_optionWei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:10];
        CGFloat Hei = 20;
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_checked_option boundingRectWithSize:CGSizeMake(MAXFLOAT, Hei) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        _class_optionWei = lastSize.width + 5;
    }
}

@end

@implementation FamilyDetailModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
