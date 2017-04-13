//
//  DJTGlobalManager.m
//  TY
//
//  Created by songzhanglong on 14-5-21.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "GlobalManager.h"
#import "GlobalDefineKit.h"
#import "NSString+Common.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DataBaseOperation.h"
#import "CTAssetsPickerController.h"
#import "AssetModel.h"
#import "UIImage+YTZEqualImage.h"
#import "MyTimeRecord.h"
#import "CustomerModel.h"

@implementation GlobalManager
{
    BOOL _shouldReloadImgAssets;
}

- (void)dealloc
{
    [self removeAssetsLibraryChangedNotification];
}

+ (GlobalManager *)shareInstance
{
    static GlobalManager *globalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalManager = [[GlobalManager alloc] init];
    });
    
    return globalManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)clearRequest
{
    if (_sessionTask && (_sessionTask.state == NSURLSessionTaskStateRunning)) {
        [_sessionTask cancel];
        _requestCount = 0;
    }
    self.sessionTask = nil;
}

/**
 *	@brief	查找视图的某个父类
 *
 *	@param 	view 	视图
 *	@param 	father 	类别
 *
 *	@return	查找结果
 */
+ (id)findViewFrom:(UIView *)view To:(Class)father
{
    if (!view) {
        return nil;
    }
    
    if ([view.nextResponder isKindOfClass:father])
    {
        return view.nextResponder;
    }
    return [GlobalManager findViewFrom:(UIView *)view.nextResponder To:father];
}

#pragma mark - notification
- (void)enterForegroundNotification:(NSNotification *)notifi
{
    if (!_detailInfo) {
        _shouldReloadImgAssets = NO;
        return;
    }
    if (_shouldReloadImgAssets) {
        _shouldReloadImgAssets = NO;
        DataBaseOperation *operation = [DataBaseOperation shareInstance];
        NSString *maxShootTime = [operation selectMaxShootingTime] ?: @"0";
        [self loadNewImgAssets:[NSDate dateWithTimeIntervalSince1970:maxShootTime.doubleValue]];
    }
}

#pragma mark - 初始化请求参数通用部分
/**
 *	@brief	初始化请求参数通用部分
 *
 *	@param 	ckey 	标记请求
 *
 *	@return	NSMutableDictionary
 */
- (NSMutableDictionary *)requestinitParamsWith:(NSString *)ckey
{
    NSString *nonce = [NSString getRandomNumber:100000 to:1000000];
    NSString *timestamp = [NSString getRandomNumber:1000000000 to:10000000000];    //系统时间
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:ckey,@"ckey",nonce,@"nonce",timestamp,@"timestamp",@"1.0",@"version",app_Version,@"v",[NSString getDeviceUDID],@"device_no",nil];

    return dic;
}

/**
 *	@brief	查找视图的某个父类
 *
 *	@param 	view 	视图
 *	@param 	father 	类别
 *
 *	@return	查找结果
 */
+ (id)viewController:(UIView *)view Class:(Class)father
{
    if (!view) {
        return nil;
    }
    
    if ([view.nextResponder isKindOfClass:father])
    {
        return view.nextResponder;
    }
    return [GlobalManager viewController:(UIView *)view.nextResponder Class:father];
}

#pragma mark - 同步相册
- (void)syncAlbumManagerInfo
{
    [self clearRequest];
    
    NSMutableDictionary *param = [self requestinitParamsWith:@"getFileData"];
    [param setObject:_detailInfo.token forKey:@"token"];
    NSString *device_no = [NSString getDeviceUDID];
    [param setObject:device_no forKey:@"device_no"];
    NSString *ctime = [[DataBaseOperation shareInstance] selectCtimeBy:_detailInfo.user.id];
    if (ctime) {
        [param setObject:ctime forKey:@"upload_time"];
    }
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"file"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf syncFinish:error Data:data];
        });
    }];
}

- (void)syncFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    if (error) {
        if (_requestCount < 3 && _detailInfo) {
            _requestCount++;
            [self performSelector:@selector(syncAlbumManagerInfo) withObject:nil afterDelay:5];
        }
    }
    else{
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [PhotoManagerModel arrayOfModelsFromDictionaries:ret_data error:nil];
        if ([array count] > 0) {
            [[DataBaseOperation shareInstance] updateOrReplaceModels:array By:_detailInfo.user.id];
        }
    }
}

#pragma mark - 相册管理
+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
        [library groupForURL:nil resultBlock:^(ALAssetsGroup *group) {
            
        } failureBlock:^(NSError *error) {
            
        }];
    });
    return library;
}

#pragma mark - 我的作品
- (void)requestMyProfiles
{
    if (_detailInfo.isDealer.integerValue == 1) {
        return;
    }
    
    NSMutableDictionary *param = [self requestinitParamsWith:@"getGrowAlbum"];
    [param setObject:_detailInfo.token ?: @"" forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"growAlbum"];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf getMyProfilesFinish:error Data:data];
    }];
}

- (void)getMyProfilesFinish:(NSError *)error Data:(id)result
{
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [NSMutableArray array];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            for (id subDic in ret_data) {
                NSError *error = nil;
                MyTimeRecord *model = [[MyTimeRecord alloc] initWithDictionary:subDic error:&error];
                if (error) {
                    NSLog(@"%@",error.description);
                    continue;
                }
                NSMutableArray *tempArr = [NSMutableArray array];
                for (NSString *sizeName in [model.tag_name componentsSeparatedByString:@","]) {
                    TagNameSize *item = [[TagNameSize alloc]init];
                    item.name = sizeName;
                    [item calculateTagnameRect];
                    [tempArr addObject:item];
                }
                model.nameSizeArray = tempArr;
                [model calculateTagNameRect];
                [array addObject:model];
            }
        }
        if (_detailInfo.profiles && [_detailInfo.profiles isEqualToArray:array]) {
            return;
        }
        _detailInfo.profiles = array;
        [[NSNotificationCenter defaultCenter] postNotificationName:UserPorfile object:nil];
    }
}

#pragma mark - 相册变化监听
- (void)addAssetsLibraryChangedNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectAssetLibrary:) name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)removeAssetsLibraryChangedNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)changeSelectAssetLibrary:(NSNotification *)notifi
{
    _shouldReloadImgAssets = YES;
}

#pragma mark - 相册加载
- (void)loadNewImgAssets:(NSDate *)date
{
    if (!_isReloadImgAssets) {
        _isReloadImgAssets = YES;
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            __block NSMutableSet *set = [[DataBaseOperation shareInstance] checkAllUrlsByDeviceID];
            NSInteger curCount = [set count];
            __block __block NSInteger numofAssets = 0;
            NSMutableArray *tmpArr = [NSMutableArray array];
            ALAssetsGroupEnumerationResultsBlock assetsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if (asset)
                {
                    NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
                    NSString *url = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
                    if ([set containsObject:url]) {
                        [set removeObject:url];
                    }
                    else if (![assetType isEqualToString:ALAssetTypeUnknown]) {
                        AssetModel *model = [[AssetModel alloc] initWithAsset:asset];
                        [tmpArr addObject:model];
                    }
                }
                else
                {
                    *stop = YES;
                    [[DataBaseOperation shareInstance] updateAllAssets:tmpArr];
                    [[DataBaseOperation shareInstance] deleteAllLoacalNoneData:set];
                    weakSelf.isReloadImgAssets = NO;
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group)
                {
                    [group setAssetsFilter:[ALAssetsFilter allAssets]];
                    numofAssets = group.numberOfAssets;
                    if (numofAssets != curCount){
                        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetsBlock];
                    }
                    else{
                        weakSelf.isReloadImgAssets = NO;
                    }
                }
            };
            
            ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
                weakSelf.isReloadImgAssets = NO;
            };
            // Enumerate Camera roll first
            [[GlobalManager defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:resultsBlock failureBlock:failureBlock];
        });
    }
}

@end
