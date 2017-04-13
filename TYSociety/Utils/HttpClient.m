//
//  DJTHttpClient.m
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "HttpClient.h"
#import "NSString+Common.h"
#import "HAMURLSessionWrapperOperation.h"

@implementation HttpClient

#pragma mark - 单任务请求
+ (NSURLSessionDataTask *)asynchronousNormalRequest:(NSString *)url parameters:(NSDictionary *)parameters complateBlcok:(void (^)(NSError *error,id data))complateBlock;
{
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    serializer.timeoutInterval = 15;
    NSError *error;
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:url parameters:parameters error:&error];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json", nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = response;
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        complateBlock(error,responseObject);
    }];
    [dataTask resume];
    return dataTask;
}

/**
 *	@brief	json序列数据提交到http服务器
 *
 *	@param 	url 	链接地址
 *	@param 	parameters 	传输参数
 *
 *	@return	AFHTTPRequestOperation，供调用方获取，以便可以手动取消网络请求
 */
+ (NSURLSessionDataTask *)asynchronousRequest:(NSString *)url parameters:(NSDictionary *)parameters complateBlcok:(void (^)(NSError *error,id data))complateBlock;
{
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    serializer.timeoutInterval = 15;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *json = [NSString encrypt:jsonStr];

    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    [request setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json", nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = response;
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString *retJson = [NSString decrypt:str];
            if (retJson == nil) {
                complateBlock([[NSError alloc] initWithDomain:NET_WORK_TIP code:0 userInfo:nil],nil);
            }
            else{
                id result = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                //此处针对新开发的接口，做签名认证等一系列处理
                NSString *str1 = [result valueForKey:@"ret_code"];
                if ([str1 isEqualToString:@"0000"]) {
                    complateBlock(nil,result);
                }
                else{
                    NSString *msg =  [result valueForKey:@"ret_msg"];
                    if (![msg isKindOfClass:[NSString class]] && msg.length == 0) {
                        msg = NET_WORK_TIP;
                    }
                    complateBlock([[NSError alloc] initWithDomain:msg code:0 userInfo:nil],result);
                }
            }
            
        }
        else{
            complateBlock([[NSError alloc] initWithDomain:NET_WORK_TIP code:0 userInfo:nil],responseObject);
        }
    }];
    [dataTask resume];
    return dataTask;
}

#pragma mark - 单个文件上传,下载
+ (NSURLSessionTask *)downloadFileWithProgress:(NSString *)url complateBlcok:(void (^)(NSError *error,NSURL *filePath))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock
{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progressBlock(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        complateBlock(error,filePath);
    }];
    [downloadTask resume];
    
    return downloadTask;
}

+ (NSURLSessionTask *)downloadFileWithProgress:(NSString *)url Name:(NSString *)name complateBlcok:(void (^)(NSError *error,NSURL *filePath))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock
{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progressBlock(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:name];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        complateBlock(error,filePath);
    }];
    [downloadTask resume];
    
    return downloadTask;
}

+ (NSURLSessionTask *)uploadFile:(NSString *)url filePath:(NSString *)path parameters:(NSDictionary *)parameter complateBlcok:(void (^)(NSError *error,id data))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock
{
    // 构造 NSURLRequest
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" error:nil];
    } error:nil];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"audio/mpeg",@"text/plain",@"application/zip",@"audio/x-aac",@"application/json",@"text/xml",@"image/png",@"image/jpg",@"image/jpeg",@"image/gif", nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = response;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        complateBlock(error,responseObject);
    }];
    [uploadTask resume];
    
    return uploadTask;
}

#pragma mark - 多任务请求
+ (NSURLSessionUploadTask*)uploadTaskWithImage:(NSString *)file url:(NSString *)url completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionBlock {
    // 构造 NSURLRequest
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:file] name:@"file" error:nil];
        //[formData appendPartWithFileData:imageData name:@"file" fileName:@"someFileName" mimeType:@"multipart/form-data"];
    } error:nil];
    
    // 可在此处配置验证信息
    
    // 将 NSURLRequest 与 completionBlock 包装为 NSURLSessionUploadTask
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"audio/mpeg",@"text/plain",@"application/zip",@"audio/x-aac",@"application/json",@"text/xml",@"image/png",@"image/jpg",@"image/jpeg",@"image/gif", nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = response;
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
    } completionHandler:completionBlock];
    return uploadTask;
}

+ (NSOperationQueue *)uploadMutiImages:(NSArray *)images url:(NSArray *)urls  parameters:(NSDictionary *)parameter singleFinishBlock:(void (^)(NSInteger index, id responseObject, NSError *error))singleFinishBlock completion:(void (^)(NSArray *result))completionBlock
{
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < images.count; i++) {
        [result addObject:[NSNull null]];
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 5;
    
    __block dispatch_group_t group = dispatch_group_create();
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            completionBlock(result);
        });
    }];
    
    NSMutableArray *operations = [NSMutableArray array];
    for (NSInteger i = 0; i < images.count; i++) {
        NSURLSessionUploadTask *uploadTask = [HttpClient uploadTaskWithImage:images[i] url:urls[i] completion:^(NSURLResponse *response, id responseObject, NSError *error) {
            dispatch_group_async(group, dispatch_get_main_queue(), ^{
                if (error) {
                    
                }
                else{
                    @synchronized (result) {
                        result[i] = responseObject;
                    }
                }
                singleFinishBlock(i,responseObject,error);
                
                dispatch_group_leave(group);
            });
        }];
        
        HAMURLSessionWrapperOperation *uploadOperation = [HAMURLSessionWrapperOperation operationWithURLSessionTask:uploadTask];
        dispatch_group_enter(group);
        [completionOperation addDependency:uploadOperation];
        [operations addObject:uploadOperation];
        //[queue addOperation:uploadOperation];
    }
    NSArray *lstArr = [operations arrayByAddingObject:completionOperation];
    [queue addOperations:lstArr waitUntilFinished:NO];
    
    return queue;
}

@end
