//
//  NSString+Common.m
//  MZJD
//
//  Created by mac on 14-4-14.
//  Copyright (c) 2014年 DIGIT. All rights reserved.
//

#import "NSString+Common.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSDate+Calendar.h"
#include <sys/sysctl.h>

#define gkey            @"abcdefghijklmntygoonbaby"
#define gIv             @"01234567"

@implementation NSString (Common)

/**
 *	@brief	缓存目录下的文件夹路径，有则获取，无则创建
 *
 *	@param 	dir 	文件夹
 *
 *	@return	路径
 */
+ (NSString *)getCachePath:(NSString *)dir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory =  [paths objectAtIndex:0];
    if (dir) {
        directory = [directory stringByAppendingPathComponent:dir];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return directory;
}

/**
 *	@brief	Document目录下的文件夹路径，有则获取，无则创建
 *
 *	@param 	dir 	文件夹
 *
 *	@return	路径
 */
+ (NSString *)getDocumentPath:(NSString *)dir
{
    NSString *directory =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (dir) {
        directory = [directory stringByAppendingPathComponent:dir];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return directory;
}

/**
 *	@brief	日期转时间字符串
 *
 *	@param 	format 	时间格式
 *	@param 	date 	日期
 *
 *	@return	时间字符串
 */
+ (NSString *)stringByDate:(NSString *)format Date:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *timeString = [formatter stringFromDate:date];
    
    [formatter release];
    return timeString;
}
/**
 *	@brief	字符串转日期
 *
 *	@param 	string 	字符串
 *
 *	@return	日期
 */
+ (NSDate *)convertStringToDate:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:string];
    [dateFormatter release];
    
    return date;
}

/**
 *	@brief	HmacSHA1加密
 *
 *	@param 	key 	密钥
 *	@param 	text 	待加密内容
 *
 *	@return	加密后内容
 */
+ (NSString *) hmacSha1:(NSString*)key text:(NSString*)text
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [HMAC release];
    return hash;
}

/**
 *	@brief	HmacSHA1加密
 *
 *	@param 	key 	密钥
 *	@param 	dic 	待加密内容
 *
 *	@return	加密后内容
 */
+ (NSString *) hmacSha1:(NSString*)key dic:(NSDictionary *)dic
{
    NSArray *keys = [dic allKeys];
    if ([keys count] <= 0) {
        return nil;
    }
    
    NSMutableArray *sortArr = [NSMutableArray arrayWithArray:keys];
    [sortArr sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *keyId in sortArr) {
        NSString *value = [dic valueForKey:keyId];
        if ([value isKindOfClass:[NSArray class]]) {
            NSUInteger count = [(NSArray *)value count];
            if (count <= 0) {
                value = @"[]";
            }
            else
            {
                NSMutableArray *tempArr = [NSMutableArray array];
                for (NSDictionary *tempDic in (NSArray *)value) {
                    NSMutableArray *tempSubArr = [NSMutableArray array];
                    NSArray *tempkeys = [tempDic allKeys];
                    for (NSString *tempKey in tempkeys) {
                        NSString *tempValue = [tempDic valueForKey:tempKey];
                        NSString *tempSubStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",tempKey,tempValue];
                        [tempSubArr addObject:tempSubStr];
                    }
                    NSString *str = [NSString stringWithFormat:@"{%@}",[tempSubArr componentsJoinedByString:@","]];
                    [tempArr addObject:str];
                }
                value = [NSString stringWithFormat:@"[%@]",[tempArr componentsJoinedByString:@","]];
            }
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            value = [(NSNumber *)value stringValue];
        }
        else if ([value isKindOfClass:[NSNull class]])
        {
            value = @"null";
        }
        NSString *str = [NSString stringWithFormat:@"%@=%@",keyId,value];
        [array addObject:str];
    }
    
    NSString *text = [array componentsJoinedByString:@"&"];
    NSString *lastStr = [NSString hmacSha1:key text:text];
    return lastStr;
}

/**
 *	@brief	获取一个随机整数，范围在[from,to]
 *
 *	@param 	from 	最小值
 *	@param 	to 	最大值
 *
 *	@return	范围在[from,to]中的一个随机数
 */
+ (NSString *)getRandomNumber:(long long)from to:(long long)to
{
    long long number = from + arc4random() % (to - from);
    return [NSString stringWithFormat:@"%lld",number];
}

/**
 *	@brief	md5加密
 *
 *	@param 	str 	待加密字符串
 *
 *	@return	加密后的字符串
 */
+ (NSString *)md5:(NSString *)str
{
    const char *charStr = [str UTF8String];
    if (charStr == NULL) {
        charStr = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(charStr, (CC_LONG)strlen(charStr), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

/**
 *	@brief	获取文件类型
 *
 *	@param 	urlStr 	网址
 *
 *	@return	文件后缀
 */
+ (NSString *)getImageType:(NSString *)urlStr
{
    NSString *imageType = @"jpg";
    //从url中获取图片类型
    NSMutableArray *arr = (NSMutableArray *)[urlStr componentsSeparatedByString:@"."];
    if (arr) {
        imageType = [arr objectAtIndex:arr.count - 1];
    }
    if ([[imageType lowercaseString] isEqualToString:@"png"])
    {
        imageType = @"png";
    }
    else if ([[imageType lowercaseString] isEqualToString:@"jpg"] || [[imageType lowercaseString] isEqualToString:@"jpeg"])
    {
        imageType = @"jpg";
    }
    else
    {
        imageType = nil;
    }
    return imageType;
}

/**
 *	@brief	切分字符串
 *
 *	@param 	str 	字符串
 *
 *	@return	数组
 */
+ (NSArray *)spliteStr:(NSString *)str
{
    NSArray *array = [str componentsSeparatedByString:@"[img"];
    NSMutableArray *lastArr = [NSMutableArray array];
    for (NSString *subStr in array) {
        if ([subStr isEqualToString:@"\n"] || [subStr isEqualToString:@""]) {
            continue;
        }
        subStr = [subStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        NSArray *secArr = [subStr componentsSeparatedByString:@"\"]"];
        for (NSString *secSub in secArr) {
            if ([secSub isEqualToString:@"\n"] || [secSub isEqualToString:@""]) {
                continue;
            }
            secSub = [secSub stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
            
            if ([secSub hasPrefix:@"+id"]) {
                NSRange range = [secSub rangeOfString:@"http"];
                NSString *imgStr = [secSub substringFromIndex:range.location];
                [lastArr addObject:imgStr];
            }
            else
            {
                [lastArr addObject:secSub];
            }
        }
    }
    
    return lastArr;
}

/**
 *	@brief	获取字节数
 *
 *	@param 	_str 	字符串
 *
 *	@return	字节数
 */
+ (int)calc_charsetNum:(NSString *)_str
{
    int strlength = 0;
    char *p = (char *)[_str cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0 ; i < [_str lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
    
}

/**
 *	@brief	计算时间
 *
 *	@param 	pubTime 	时间
 *
 *	@return	计算后的时间
 */
+ (NSString *)calculateTimeDistance:(NSString *)pubTime
{
    //时间
    NSString *time = [pubTime stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time = [time stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd HHmmss"];
    NSDate *date = [dateFormatter dateFromString:time];
    NSTimeInterval timeInterval = fabs([date timeIntervalSinceNow]);
    NSString *timeStr = nil;
    if (timeInterval < 60) {
        timeStr = [NSString stringWithFormat:@"%.0f秒前",timeInterval];
        //timeStr = @"1分钟前";
    }
    else
    {
        timeInterval = timeInterval / 60;
        if (timeInterval < 60) {
            timeStr = [NSString stringWithFormat:@"%.0f分钟前",timeInterval];
        }
        else
        {
            NSDateFormatter *indexDateFormatter = [[NSDateFormatter alloc] init];
            [indexDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *indexDate = [indexDateFormatter dateFromString:pubTime];
            [indexDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
            timeStr = [indexDateFormatter stringFromDate:indexDate];
            /*timeInterval = timeInterval / 60;
             if (timeInterval < 24) {
             timeStr = [NSString stringWithFormat:@"%.0f小时前",timeInterval];
             }
             else
             {
             timeInterval = timeInterval / 24;
             if (timeInterval < 30) {
             timeStr = [NSString stringWithFormat:@"%.0f天前",timeInterval];
             }
             else
             {
             timeInterval = timeInterval / 30;
             if (timeInterval < 12) {
             timeStr = [NSString stringWithFormat:@"%.0f月前",timeInterval];
             }
             else
             {
             timeInterval = timeInterval / 12;
             timeStr = [NSString stringWithFormat:@"%.0f年前",timeInterval];
             }
             //timeStr = pubTime;
             }
             }*/
        }
    }
    
    return timeStr;
}

/**
 *	@brief	比较是否同一天
 *
 *	@param 	first 	当前日期
 *	@param 	other 	其他日期
 *
 *	@return	yes－同一天
 */
+ (BOOL)compareSameDay:(NSString *)first Other:(NSString *)other
{
    //时间
    NSString *time = [first stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time = [time stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *time2 = [other stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    time2 = [time2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time2 = [time2 stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd HHmmss"];
    NSDate *date1 = [dateFormatter dateFromString:time];
    NSDate *date2 = [dateFormatter dateFromString:time2];
    return [date1 sameDayWithDate:date2];
}

/**
 *	@brief	键盘表情输入判断
 *
 *	@param 	string 	表情
 *
 *	@return	yes－表情
 */
+ (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
             //判断是否匹配特殊字符
             NSString *regex = @"^[a-zA-Z0-9_\u4e00-\u9fa5]+$";
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
             BOOL isValid = [predicate evaluateWithObject:substring];
             isEomji=!isValid;
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    return isEomji;
}


/**
 *	@brief	键盘表情输入判断
 *
 *	@param 	string 	表情
 *
 *	@return	yes－表情
 */
+ (int ) containsEmoji:(NSString *)string {
    __block int  eomji = -1;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     
                     eomji=(int)(substringRange.location*10000+substringRange.length);
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             }
             
             //判断是否匹配特殊字符
             NSString *regex = @"^[a-zA-Z0-9_\u4e00-\u9fa5]+$";
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
             BOOL isValid = [predicate evaluateWithObject:substring];
             if (!isValid) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             }
             
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 eomji=(int)(substringRange.location*10000+substringRange.length);
             }
         }
     }];
    return eomji;
}

#pragma mark - utf8
+ (NSString *)stringByUTF8:(NSString *)oriStr
{
    if (oriStr.length == 0) {
        return @"";
    }
    
    NSString *value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)oriStr,NULL,CFSTR("!'();:@&=+$,/?%#[]~"),kCFStringEncodingUTF8));
    return value;
}

// 加密方法
+ (NSString*)encrypt:(NSString*)plainText
{
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [gkey UTF8String];
    const void *vinitVec = (const void *) [gIv UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    
    NSString *result = [myData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return result;
}

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText{
    NSData *encryptData = [GTMBase64 decodeString:encryptText];
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [gkey UTF8String];
    const void *vinitVec = (const void *) [gIv UTF8String];
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSString *result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                      length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding] autorelease];
    return result;
}

#pragma mark - calculate
+ (CGSize)calculeteSizeBy:(NSString *)str Font:(UIFont *)font MaxWei:(CGFloat)wei
{
    CGSize lastSize = CGSizeZero;
    if ([str length] > 0) {
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [str boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    return lastSize;
}

#pragma mark - 图片
/*
 缩略图脚本已经调整完成，现在已经部署到测试环境，当等比缩放只取一个只的时候，请将另一个值定义为0，
 比如：275x  = 275_0
 x440=0_440
 http://static.goonbaby.com/original/group1/M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831.jpg 原图
 
 http://static.goonbaby.com/thumbnail/group1/M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_275_440.jpg 默认缩略图
 
 http://static.goonbaby.com/thumbnail/group1/M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=2_100_0.jpg 等比缩放
 
 http://static.goonbaby.com/thumbnail/group1/M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=2_0_440.jpg 等比缩放
 
 http://static.goonbaby.com/thumbnail/group1/M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=2_275_440.jpg 等比缩放
 
 http://static.goonbaby.com/thumbnail/group1/M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=1_0_440.jpg 等比缩放带白边
 
 http://static.goonbaby.com/thumbnail/group1/M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=1_275_0.jpg 等比缩放带白边
 
 http://static.goonbaby.com/thumbnail/group1/M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=1_275_440.jpg 等比缩放带白边
 */
+ (NSString *)getPictureAddress:(NSString *)type width:(NSString *)width height:(NSString *)height original:(NSString *)original
{
    if (original.length <= 0) {
        return original;
    }
    
    NSString *extension = [original pathExtension];
    NSString *preStr = [original stringByDeletingPathExtension];
    if ([preStr hasPrefix:@"http:/"] && ![preStr hasPrefix:@"http://"]) {
        preStr = [preStr stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
    }
    preStr = [preStr stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"];
    return [NSString stringWithFormat:@"%@_type=%@_%@_%@.%@",preStr,type,width,height,extension];
}

+ (NSString *)resetOriginalStr:(NSString *)original
{
    if (original.length <= 0) {
        return original;
    }
    
    NSString *extension = [original pathExtension];
    NSString *preStr = [original stringByDeletingPathExtension];
    if ([preStr hasPrefix:@"http:/"] && ![preStr hasPrefix:@"http://"]) {
        preStr = [preStr stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
    }
    preStr = [preStr stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"original"];
    NSRange range = [preStr rangeOfString:@"_type"];
    preStr = [preStr substringToIndex:range.location];
    return [preStr stringByAppendingString:[@"." stringByAppendingString:extension]];
}

#pragma mark - 设备型号
+ (NSString *)getCurrentDeviceModel
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

+ (NSString *)dictToJsonStr:(NSDictionary *)dic
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in dic.allKeys) {
        NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\"",key,[dic valueForKey:key]];
        [array addObject:str];
    }
    
    return [NSString stringWithFormat:@"{%@}",[array componentsJoinedByString:@","]];
}

#pragma mark - 字体
+ (UIFont *)customFontWithPath:(NSString *)path size:(CGFloat)size
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return [UIFont systemFontOfSize:size];
    }
    
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    return font;
}

@end
