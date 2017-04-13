//
//  NSString+Common.h
//  MZJD
//
//  Created by mac on 14-4-14.
//  Copyright (c) 2014年 DIGIT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Emoji_Count                 10000

@interface NSString (Common)

/**
 *	@brief	缓存目录下的文件夹路径，有则获取，无则创建
 *
 *	@param 	dir 	文件夹
 *
 *	@return	路径
 */
+ (NSString *)getCachePath:(NSString *)dir;

/**
 *	@brief	Document目录下的文件夹路径，有则获取，无则创建
 *
 *	@param 	dir 	文件夹
 *
 *	@return	路径
 */
+ (NSString *)getDocumentPath:(NSString *)dir;

/**
 *	@brief	日期转时间字符串
 *
 *	@param 	format 	时间格式
 *	@param 	date 	日期
 *
 *	@return	时间字符串
 */
+ (NSString *)stringByDate:(NSString *)format Date:(NSDate *)date;

/**
 *	@brief	字符串转日期
 *
 *	@param 	string 	字符串
 *
 *	@return	日期
 */
+ (NSDate *)convertStringToDate:(NSString *)string;

/**
 *	@brief	HmacSHA1加密
 *
 *	@param 	key 	密钥
 *	@param 	text 	待加密内容
 *
 *	@return	加密后内容
 */
+ (NSString *) hmacSha1:(NSString*)key text:(NSString*)text;

/**
 *	@brief	HmacSHA1加密
 *
 *	@param 	key 	密钥
 *	@param 	dic 	待加密内容
 *
 *	@return	加密后内容
 */
+ (NSString *) hmacSha1:(NSString*)key dic:(NSDictionary *)dic;

/**
 *	@brief	获取一个随机整数，范围在[from,to]
 *
 *	@param 	from 	最小值
 *	@param 	to 	最大值
 *
 *	@return	范围在[from,to]中的一个随机数
 */
+ (NSString *)getRandomNumber:(long long)from to:(long long)to;

/**
 *	@brief	md5加密
 *
 *	@param 	str 	待加密字符串
 *
 *	@return	加密后的字符串
 */
+ (NSString *)md5:(NSString *)str;

/**
 *	@brief	获取文件类型
 *
 *	@param 	urlStr 	网址
 *
 *	@return	文件后缀
 */
+ (NSString *)getImageType:(NSString *)urlStr;

/**
 *	@brief	切分字符串
 *
 *	@param 	str 	字符串
 *
 *	@return	数组
 */
+ (NSArray *)spliteStr:(NSString *)str;

/**
 *	@brief	获取字节数
 *
 *	@param 	_str 	字符串
 *
 *	@return	字节数
 */
+ (int)calc_charsetNum:(NSString *)_str;

/**
 *	@brief	计算时间
 *
 *	@param 	pubTime 	时间
 *
 *	@return	计算后的时间
 */
+ (NSString *)calculateTimeDistance:(NSString *)pubTime;

/**
 *	@brief	比较是否同一天
 *
 *	@param 	first 	当前日期
 *	@param 	other 	其他日期
 *
 *	@return	yes－同一天
 */
+ (BOOL)compareSameDay:(NSString *)first Other:(NSString *)other;

/**
 *	@brief	键盘表情输入判断
 *
 *	@param 	string 	表情
 *
 *	@return	yes－表情
 */
+ (BOOL)isContainsEmoji:(NSString *)string;

/**
 *	@brief	键盘表情输入判断
 *
 *	@param 	string 	文本内容
 *
 *	@return	－表情符号位置
 */
+ (NSInteger)containsEmoji:(NSString *)string;

/**
 *	@brief	判断是否输入的汉字数字字母组合
 *
 *	@param 	string 	文本内容
 *
 *	@return	yes－正常
 */
+(BOOL)isText:(NSString *)value;

#pragma mark - utf8
+ (NSString *)stringByUTF8:(NSString *)oriStr;

#pragma mark - des3
+ (NSString*)encrypt:(NSString*)plainText;
+ (NSString*)decrypt:(NSString*)encryptText;

#pragma mark - calculate
+ (CGSize)calculeteSizeBy:(NSString *)str Font:(UIFont *)font MaxWei:(CGFloat)wei;

#pragma mark - 图片
+ (NSString *)getPictureAddress:(NSString *)type width:(NSString *)width height:(NSString *)height original:(NSString *)original;

#pragma mark - MD5
//计算NSData的MD5值
+ (NSString *)getMD5WithData:(NSData *)data;

//计算字符串的MD5值，
+ (NSString *)getmd5WithString:(NSString *)string;

//计算大文件的MD5值
+ (NSString *)getFileMD5WithPath:(NSString *)path;

#pragma mark - UDID
+ (NSString *)getDeviceUDID;

+ (NSString *)dictToJsonStr:(NSDictionary *)dic;

#pragma mark - 字体
+ (UIFont *)customFontWithPath:(NSString *)path size:(CGFloat)size;

#pragma mark - 磁盘空间
+ (long long)freeSpace;

+ (float)getTotalDiskSpaceInBytes;

#pragma mark - today
+ (NSDate *)getToday;

@end
