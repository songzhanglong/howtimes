//
//  CustomFont.m
//  TYSociety
//
//  Created by szl on 16/8/16.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CustomFont.h"

@implementation CustomFont

- (void)dealloc
{
    [self clearRequest];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)clearRequest
{
    if (_sessionTask && (_sessionTask.state == NSURLSessionTaskStateRunning)) {
        [_sessionTask cancel];
    }
    self.sessionTask = nil;
}

- (void)startDownLoadTTFFile
{
    if (_download.length == 0) {
        return;
    }
    if (_sessionTask) {
        [self clearRequest];
    }
    NSString *url = [G_IMAGE_ADDRESS stringByAppendingString:_download];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient downloadFileWithProgress:url Name:[_font_key stringByAppendingString:@".ttf"] complateBlcok:^(NSError *error, NSURL *filePath) {
        weakSelf.sessionTask = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.downLoadBlock) {
                weakSelf.downLoadBlock(weakSelf,error,filePath);
            }
        });
    } progressBlock:^(NSProgress *progress) {
        
    }];
}

- (BOOL)fileHasDownLoaded
{
    if (_download.length == 0) {
        return NO;
    }
    
    NSString *filePath = [APPDocumentsDirectory stringByAppendingPathComponent:[_font_key stringByAppendingString:@".ttf"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

@end
