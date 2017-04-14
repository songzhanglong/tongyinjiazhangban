//
//  ClassCircleModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassCircleModel.h"
#import "DJTGlobalDefineKit.h"

@implementation ReplyItem

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (NSAttributedString *)generalHTMLStr
{
    NSMutableAttributedString *str = nil;
    if (_reply_name && [_reply_name length] > 0) {
        NSString *tmpStr = [NSString stringWithFormat:@"%@回复%@:%@",_name,_reply_name,_replay_message];
        str = [[NSMutableAttributedString alloc] initWithString:tmpStr];
        NSRange range1 = [tmpStr rangeOfString:_name];
        NSRange range2 = [tmpStr rangeOfString:[NSString stringWithFormat:@"%@:",_reply_name]];
        [str addAttribute:NSForegroundColorAttributeName value:CreateColor(68, 138, 167) range:range1];
        [str addAttribute:NSForegroundColorAttributeName value:CreateColor(68, 138, 167) range:range2];
    }
    else
    {
        NSString *tmpStr = [NSString stringWithFormat:@"%@:%@",_name,_replay_message];
        str = [[NSMutableAttributedString alloc] initWithString:tmpStr];
        NSRange range = [tmpStr rangeOfString:[NSString stringWithFormat:@"%@:",_name]];
        [str addAttribute:NSForegroundColorAttributeName value:CreateColor(68, 138, 167) range:range];
    }
    
    return str;
}

- (NSString *)generalReplyString
{
    NSMutableString *result = [[NSMutableString alloc] init];
    if (_reply_name && [_reply_name length] > 0) {
        [result appendFormat:@"%@回复%@: ",_name,_reply_name];
    }
    else
    {
        [result appendFormat:@"%@: ",_name];
    }
    
    return [NSString stringWithFormat:@"%@%@",result,_replay_message];
}

- (NSString *)generalReplyString2
{
    NSMutableString *result = [[NSMutableString alloc] init];
    if (_reply_name && [_reply_name length] > 0) {
        [result appendFormat:@"回复%@: ",_reply_name];
    }
    
    return [NSString stringWithFormat:@"%@%@",result,_replay_message];
}

- (void)calculateItemRect:(CGFloat)wei Font:(UIFont *)font
{
    CGSize lastSize = CGSizeZero;
    NSString *str = [self generalReplyString2];
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [str boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    _itemSize = lastSize;
}

@end

@implementation DiggItem

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation ClassCircleModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (CGSize)calulateMsgSize:(NSString *)msg Font:(UIFont *)font MaxWei:(CGFloat)wei
{
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [msg boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return lastSize;
}

- (void)calculateGroupCircleRects
{
    CGFloat yOri = 10 + 40 + 10;
    CGFloat yOri2 = 8;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat margin = 10;
    //picture
    _tipRect = CGRectZero;
    if (!_picture_thumb || [_picture_thumb length] <= 0) {
        _imagesRect = CGRectZero;
        _imagesRect2 = CGRectZero;
    }
    else
    {
        //相册名存在，则为相册上传
        //if (_album_name && [_album_name length] > 0) {
            _tipRect = CGRectMake(margin, yOri, winSize.width - margin * 2, 18);
            yOri += 10 + _tipRect.size.height;
        //}
        
        //相册图片
        NSInteger count = [_picture_thumb componentsSeparatedByString:@"|"].count;
        CGFloat hei = 0,hei2 = 0;
        if (count > 3) {
            CGFloat wei = roundf((winSize.width - margin * 5) / 4);
            CGFloat wei2 = roundf((winSize.width - 78 - 5 * 5) / 4);
            hei = wei * 2 + margin;
            hei2 = wei2 * 2 + 5;
        }
        else if (count > 1)
        {
            CGFloat wei = roundf((winSize.width - margin * 4) / 3);
            CGFloat wei2 = roundf((winSize.width - 78 - 5 * 4) / 3);
            hei = wei;
            hei2 = wei2;
        }
        else
        {
            CGFloat wei = roundf((winSize.width - margin * 5) / 2) + margin;
            CGFloat wei2 = roundf((winSize.width - 78 - 5 * 5) / 2) + 5;
            hei = wei;
            hei2 = wei2;
        }
        
        _imagesRect = CGRectMake(0, yOri, winSize.width, hei);
        _imagesRect2 = CGRectMake(78, yOri2, winSize.width - 78, hei2);
        yOri += hei + 10;
        yOri2 += hei2;
    }
    
    //文本内容
    _contentRect = CGRectZero;
    _contentRect2 = CGRectZero;
    if (_message && [_message length] > 0) {
        CGSize lastSize = [self calulateMsgSize:_message Font:[UIFont systemFontOfSize:16] MaxWei:winSize.width - 20];
        _contentRect = CGRectMake(10, yOri, winSize.width - 20, lastSize.height);
        yOri += lastSize.height + 10;
        
        CGSize lastSize2 = [self calulateMsgSize:_message Font:[UIFont systemFontOfSize:16] MaxWei:winSize.width - 98 - 6]; //背景框往内缩进3个像素
        _contentRect2 = CGRectMake(88 + 3, yOri2 + 3, winSize.width - 98 - 6, lastSize2.height);
        yOri2 += lastSize2.height + 5 + 3;
    }
    
    _butYori2 = yOri2;
    
    //@对象
    _attentionRect = CGRectZero;
    if (_attention && _attention.count > 0) {
        NSMutableArray *attentions = [NSMutableArray array];
        for (NSDictionary *dic in _attention) {
            [attentions addObject:[NSString stringWithFormat:@"@%@",[dic.allValues firstObject]]];
        }
        NSString *strAtten = [attentions componentsJoinedByString:@" "];
        CGSize lastSize = [self calulateMsgSize:strAtten Font:[UIFont systemFontOfSize:16]  MaxWei:winSize.width - 20];
        _attentionRect = CGRectMake(10, yOri, winSize.width - 20, lastSize.height);
        yOri += lastSize.height + 10;
    }
    
    //按钮坐标Y值
    _butYori = yOri;
    
    yOri += 24 + 5;
    
    //点赞
    _diggRect = CGRectZero;
    if (_digg && _digg.count > 0) {
        CGFloat digImgHei = 30,digTipHei = 18;
        NSInteger numPerRow = (winSize.width - margin * 2 - margin - digTipHei) / (digImgHei + margin);
        NSInteger rows = (_digg.count - 1) / numPerRow + 1;
        CGFloat rowsHei = (5 + digImgHei) * rows;
        _diggRect = CGRectMake(margin, yOri, winSize.width - margin * 2, rowsHei);
        
        yOri += rowsHei;
    }
    
    //回复
    _replyBackRect = CGRectZero;
    _replyRects = [NSArray array];
    
    if (_reply && _reply.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        CGFloat replyYori = 5 + 20 + 5;
        NSInteger maxCount = 3;
        //最多截取10条数据
        for (NSInteger i = 0; i < _reply.count; i++) {
            if (i >= maxCount) {
                break;
            }
            
            ReplyItem *item = _reply[i];
            NSString *str = [item generalReplyString];
            CGSize strSize = [self calulateMsgSize:str Font:[UIFont systemFontOfSize:16]  MaxWei:winSize.width - 20];
            [array addObject:NSStringFromCGRect(CGRectMake(0, replyYori, winSize.width - 20, strSize.height))];
            replyYori += strSize.height + 5;
            
        }
        _replyRects = array;
        _replyBackRect = CGRectMake(10, yOri, winSize.width - 20, replyYori);
    }
    
    
}

@end
