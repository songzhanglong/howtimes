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
#import "GTMBase64.h"
#import "SFHFKeychainUtils.h"
#include <sys/param.h>
#include <sys/mount.h>

#define gkey            @"abcdefghijklmntysdk_album"
#define gIv             @"01234567"
#define FileHashDefaultChunkSizeForReadingData 1024*8 // 8K

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
+ (NSString *)stringByDate:(NSString *)format Date:(NSDate *)date;
{
    NSDate *currentTime = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:format];
    NSString *timeString = [formatter stringFromDate:currentTime];
    
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
        NSString *newsubStr = [subStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        NSArray *secArr = [newsubStr componentsSeparatedByString:@"\"]"];
        for (NSString *secSub in secArr) {
            if ([secSub isEqualToString:@"\n"] || [secSub isEqualToString:@""]) {
                continue;
            }
            NSString *newsecSub = [secSub stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
            
            if ([newsecSub hasPrefix:@"+id"]) {
                NSRange range = [newsecSub rangeOfString:@"http"];
                NSString *imgStr = [newsecSub substringFromIndex:range.location];
                [lastArr addObject:imgStr];
            }
            else
            {
                [lastArr addObject:newsecSub];
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
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *date1 = [dateFormatter dateFromString:time];
    NSDate *date2 = [dateFormatter dateFromString:time2];
    
    return ([date1 compare:date2] == NSOrderedSame);
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
+ (NSInteger)containsEmoji:(NSString *)string {
    __block NSInteger eomji = -1;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const NSInteger uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     eomji = (substringRange.location * Emoji_Count + substringRange.length);
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                eomji = (substringRange.location * Emoji_Count + substringRange.length);
             }
             
             //判断是否匹配特殊字符
             NSString *regex = @"^[a-zA-Z0-9_\u4e00-\u9fa5]+$";
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
             BOOL isValid = [predicate evaluateWithObject:substring];
             if (!isValid) {
                 eomji = (substringRange.location * Emoji_Count + substringRange.length);
             }
             
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 eomji = (substringRange.location * Emoji_Count + substringRange.length);
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 eomji = (substringRange.location * Emoji_Count + substringRange.length);
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 eomji = (substringRange.location * Emoji_Count + substringRange.length);
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 eomji = (substringRange.location * Emoji_Count + substringRange.length);
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 eomji = (substringRange.location * Emoji_Count + substringRange.length);
             }
         }
     }];
    return eomji;
}

/**
 *	@brief	判断是否输入的汉字数字字母组合
 *
 *	@param 	string 	文本内容
 *
 *	@return	yes－正常
 */
+(BOOL)isText:(NSString *)value
{
    //判断是否匹配特殊字符
    NSString *regex = @"^[a-zA-Z0-9\u4e00-\u9fa5]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:value];
    return isValid;
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
    
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                      length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
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
 /M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831.jpg 原图
 /M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_275_440.jpg 默认缩略图
 /M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=2_100_0.jpg 等比缩放
 /M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=2_0_440.jpg 等比缩放
 /M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=2_275_440.jpg 等比缩放
 /M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=1_0_440.jpg 等比缩放带白边
 /M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=1_275_0.jpg 等比缩放带白边
 /M00/00/03/CoQtrVZ4q0WAdmbPAAb1VxMy5DQ831_type=1_275_440.jpg 等比缩放带白边
 */
+ (NSString *)getPictureAddress:(NSString *)type width:(NSString *)width height:(NSString *)height original:(NSString *)original
{
    if (original.length <= 0) {
        return original;
    }
    
    NSString *extension = [original pathExtension];
    NSString *preStr = [original stringByDeletingPathExtension];
    if ([preStr rangeOfString:@"thumbnail"].location != NSNotFound) {
        NSMutableArray *tmpArr = [NSMutableArray array];
        NSString *tmpStr = [preStr copy];
        NSRange tmpRange = [tmpStr rangeOfString:@"_"];
        while (tmpRange.location != NSNotFound) {
            [tmpArr addObject:NSStringFromRange(tmpRange)];
            tmpStr = [tmpStr stringByReplacingCharactersInRange:tmpRange withString:@" "];
            tmpRange = [tmpStr rangeOfString:@"_"];
        }
        
        if ([tmpArr count] >= 2) {
            NSString *preTwo = [tmpArr objectAtIndex:tmpArr.count - 2];
            NSRange range = NSRangeFromString(preTwo);
            preStr = [preStr substringToIndex:range.location];
        }
        else{
            return original;
        }
    }
    
    if ([preStr hasPrefix:@"http:/"] && ![preStr hasPrefix:@"http://"]) {
        preStr = [preStr stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
    }
    preStr = [preStr stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"];
    return [NSString stringWithFormat:@"%@_type=%@_%@_%@.%@",preStr,type,width,height,extension];
}

#pragma mark - MD5
//计算NSData的MD5值
+ (NSString *)getMD5WithData:(NSData *)data
{
    const char* original_str = (const char *)[data bytes];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (CC_LONG)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i = 0; i < CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x",digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    
    return [outPutStr lowercaseString];
}

//计算字符串的MD5值，
+ (NSString *)getmd5WithString:(NSString *)string
{
    const char* original_str = [string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (CC_LONG)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i = 0; i < CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x", digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    return [outPutStr lowercaseString];
}

//计算大文件的MD5值
+ (NSString *)getFileMD5WithPath:(NSString *)path
{
    return (__bridge NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path,FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    
    CC_MD5_CTX hashObject;
    bool hasMoreData = true;
    bool didSucceed;
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1)break;
        if (readBytesCount == 0) {
            hasMoreData =false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 *sizeof(digest) + 1];
    for (size_t i =0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i),3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

#pragma mark - UDID
+ (NSString *)getDeviceUDID
{
    //uuid+keychain几乎是唯一的方法，但不完美，，用户reset手机，数据就没了。系统升级没问题
    NSString *SERVICE_NAME = @"com.digit.TYSociety";    //最好用程序的bundle id
    NSString * str =  [SFHFKeychainUtils getPasswordForUsername:@"UUID" andServiceName:SERVICE_NAME error:nil];  // 从keychain获取数据
    if ([str length] <= 0)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        str = [userDefault objectForKey:SERVICE_NAME];
        if (str.length <= 0) {
            str  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];  // 保存UUID作为手机唯一标识符
            [userDefault setObject:str forKey:SERVICE_NAME];
        }
        [SFHFKeychainUtils storeUsername:@"UUID" andPassword:str forServiceName:SERVICE_NAME updateExisting:1 error:nil];  // 往keychain添加数据
    }
    return str;
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

#pragma mark - 磁盘空间
+ (long long)freeSpace
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)buf.f_bsize * buf.f_bfree;
    }
    
    return freespace;
}

+ (float)getTotalDiskSpaceInBytes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[paths lastObject] cStringUsingEncoding:NSUTF8StringEncoding], &tStats);
    float totalSpace = (float)(tStats.f_blocks * tStats.f_bsize);
    return totalSpace;
}

#pragma mark - today
+ (NSDate *)getToday
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    return localeDate;
}

@end
