//
//  DJTHttpClient.h
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface HttpClient : NSObject

#pragma mark - 单任务请求

+ (NSURLSessionTask *)asynchronousNormalRequest:(NSString *)url parameters:(NSDictionary *)parameters complateBlcok:(void (^)(NSError *error,id data))complateBlock;


/**
 *	@brief	json序列数据提交到http服务器
 *
 *	@param 	url 	链接地址
 *	@param 	parameters 	传输参数
 *
 *	@return	AFHTTPRequestOperation，供调用方获取，以便可以手动取消网络请求
 */
+ (NSURLSessionTask *)asynchronousRequest:(NSString *)url parameters:(NSDictionary *)parameters complateBlcok:(void (^)(NSError *error,id data))complateBlock;


#pragma mark - 单个文件上传,下载
+ (NSURLSessionTask *)downloadFileWithProgress:(NSString *)url complateBlcok:(void (^)(NSError *error,NSURL *filePath))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock;

+ (NSURLSessionTask *)downloadFileWithProgress:(NSString *)url Name:(NSString *)name complateBlcok:(void (^)(NSError *error,NSURL *filePath))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock;

+ (NSURLSessionTask *)uploadFile:(NSString *)url filePath:(NSString *)path parameters:(NSDictionary *)parameter complateBlcok:(void (^)(NSError *error,id data))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock;

#pragma mark - 多任务请求
+ (NSOperationQueue *)uploadMutiImages:(NSArray*)images url:(NSArray *)urls parameters:(NSDictionary *)parameter singleFinishBlock:(void (^)(NSInteger index, id responseObject, NSError *error))singleFinishBlock completion:(void (^)(NSArray *result))completionBlock;

@end
