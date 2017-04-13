//
//  PhotoManagerModel.m
//  TYSociety
//
//  Created by szl on 16/7/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "PhotoManagerModel.h"
#import "HttpClient.h"
#import "DataBaseOperation.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Caption.h"

@implementation PhotoManagerModel

- (id)init
{
    self = [super init];
    if (self) {
        _uploadState = kPhotoUploadNone;
    }
    
    return self;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)dealloc
{
    [self clearUploadData];
}

- (void)clearUploadData
{
    if (_sessionTask && (_sessionTask.state == NSURLSessionTaskStateRunning)) {
        [_sessionTask cancel];
    }
    self.sessionTask = nil;
    _uploadState = kPhotoUploadNone;
}

- (void)beginUploadData
{
    if (_sessionTask) {
        return;
    }
    
    if (_path.length > 0) {
        [self uploadEnd:YES];
        return;
    }
    
    _uploadState = kPhotoUploading;
    //相册获取asset
    __weak typeof(self)weakSelf = self;
    if (!_asset) {
        //获取相册
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[GlobalManager defaultAssetsLibrary] assetForURL:[NSURL URLWithString:weakSelf.file_client_path] resultBlock:^(ALAsset *asset) {
                if (asset) {
                    weakSelf.asset = asset;
                    [weakSelf getAsset];
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf uploadEnd:NO];
                    });
                }
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf uploadEnd:NO];
                });
            }];
        });
    }
    else{
        //相册已有
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf getAsset];
        });
        
    }
}

//获取相册数据管理相,异步处理
- (void)getAsset
{
    NSString *timeStr = [NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSString getToday]];
    if (_file_type.integerValue == 1) {
        //图片
        NSString *path = [timeStr stringByAppendingString:@".jpg"];
        path = [APPTmpDirectory stringByAppendingPathComponent:path];
        @autoreleasepool {
            UIImage *image = [UIImage imageWithCGImage:_asset.defaultRepresentation.fullResolutionImage scale:_asset.defaultRepresentation.scale orientation:(UIImageOrientation)_asset.defaultRepresentation.orientation];
            image = [image fixOrientation];
            NSData *data = UIImageJPEGRepresentation(image, 0.8);
            [data writeToFile:path atomically:NO];
        }
        [self startUploadPath:path];
    }
    else{
        __weak typeof(self)weakSelf = self;
        ALAssetRepresentation *representation = [_asset defaultRepresentation];
        BOOL isMP4 = [representation.url.resourceSpecifier hasSuffix:@"mp4"];
        if (isMP4) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf uploadEnd:NO];
                [APPWindow makeToast:@"非常抱歉，暂时不支持这种视频文件" duration:1.0 position:@"center"];
            });
            return;
        }
        //100M以上的文件
        if ([representation size] > 1024 * 1024 * 100) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf uploadEnd:NO];
                [APPWindow makeToast:@"非常抱歉，暂时不支持超过100M的视频文件" duration:1.0 position:@"center"];
            });
            return;
        }
        
        NSString *videoPath = [timeStr stringByAppendingString:@".mp4"];
        videoPath = [APPTmpDirectory stringByAppendingPathComponent:videoPath];
        
        //压缩后上传
        [UIImage converVideoDimissionWithFilePath:[_asset valueForProperty:ALAssetPropertyAssetURL] andOutputPath:videoPath withCompletion:^(NSError *error) {
            if (error) {
                [weakSelf uploadEnd:NO];
                [APPWindow makeToast:@"非常抱歉，该视频处理异常，暂无法上传" duration:1.0 position:@"center"];
            }
            else{
                [weakSelf startUploadPath:videoPath];
            }
        } To:nil Sel:nil];
    }
}

//上传结果
- (void)uploadEnd:(BOOL)suc
{
    _sessionTask = nil;
    _uploadState = suc ? kPhotoUploadSuc : kPhotoUploadFailed;
    if (_delegate && [_delegate respondsToSelector:@selector(photoManagerUpload:Suc:)]) {
        [_delegate photoManagerUpload:self Suc:suc];
    }
}

- (void)startUploadPath:(NSString *)filePath
{
    NSMutableDictionary *file_info = [NSMutableDictionary dictionary];
    NSString *tmpShootTime = [[_shooting_time componentsSeparatedByString:@"."] firstObject];
    [file_info setObject:tmpShootTime forKey:@"shooting_time"];
    NSString *md5 = [NSString getFileMD5WithPath:filePath];
    _md5 = md5;
    [file_info setObject:md5 forKey:@"md5"];
    [file_info setObject:[NSString getDeviceUDID] forKey:@"device_no"];
    [file_info setObject:_file_client_path forKey:@"file_client_path"];
    [file_info setObject:_file_type forKey:@"type"];
    [file_info setObject:_width forKey:@"width"];
    [file_info setObject:_height forKey:@"height"];
    if (_location.length > 0) {
        [file_info setObject:_location forKey:@"location"];
    }
    else{
        [file_info setObject:@"" forKey:@"location"];
    }
    if (_location_name > 0) {
        [file_info setObject:_location_name forKey:@"location_name"];
    }
    else{
        [file_info setObject:@"" forKey:@"location_name"];
    }
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
    NSDictionary *lstDic = @{@"token":detailInfo.token,@"file_info":file_info};
    NSData *json = [NSJSONSerialization dataWithJSONObject:lstDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    lstJson = [NSString encrypt:lstJson];
    NSString *gbkStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)lstJson,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient uploadFile:url filePath:filePath parameters:nil complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [weakSelf uploadEnd:NO];
            }
            else{
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *retJson = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                id retData = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                if ([retData isKindOfClass:[NSArray class]]) {
                    retData = [retData firstObject];
                }
                NSString *ret_code = [retData valueForKey:@"ret_code"];
                if ((ret_code.length > 0) && [ret_code isEqualToString:@"0000"]) {
                    NSString *path = [retData valueForKey:@"path"];
                    NSString *picture = [retData valueForKey:@"picture"];
                    weakSelf.path = path;
                    weakSelf.picture = picture;
                    [[DataBaseOperation shareInstance] updateOrReplaceModel:weakSelf];
                    [weakSelf uploadEnd:YES];
                }
                else{
                    [weakSelf uploadEnd:NO];
                }
            }
        });
    } progressBlock:^(NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progress = progress.fractionCompleted;
        });
    }];
}

@end
