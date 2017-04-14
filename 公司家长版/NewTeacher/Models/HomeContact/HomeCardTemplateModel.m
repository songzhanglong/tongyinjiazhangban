//
//  HomeCardTemplateModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "HomeCardTemplateModel.h"

@implementation HomeCardTemplateModel

- (void)calculateSizeBy:(UIFont *)font Wei:(CGFloat)maxWei
{
    //message
    CGSize lastSize = CGSizeZero;
    if (_card_title && [_card_title length] > 0) {
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_card_title boundingRectWithSize:CGSizeMake(maxWei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    _carSize = lastSize;
}

@end
