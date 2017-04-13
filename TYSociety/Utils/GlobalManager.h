//
//  DJTGlobalManager.h
//  TY
//
//  Created by songzhanglong on 14-5-21.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpClient.h"
#import "UserDetailInfo.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class BatchCustomers;

@interface GlobalManager : NSObject
//用户信息
@property (nonatomic,strong)UserDetailInfo *detailInfo;
//同步操作
@property (nonatomic,strong)NSURLSessionTask *sessionTask;
@property (nonatomic,assign)NSInteger requestCount;         //同步次数，不超过3次

@property (nonatomic,strong)NSArray *decorationArr;

//查询相册
@property (nonatomic,strong)NSMutableArray *gzPages;
@property (nonatomic,strong)NSMutableArray *sizeReferences;
@property (nonatomic,strong)NSMutableArray *systemConfig;
@property (nonatomic,assign)BOOL isWebAlipay;
@property (nonatomic,assign)BOOL isReloadImgAssets;

@property (nonatomic,assign)AFNetworkReachabilityStatus networkReachabilityStatus;    //网络状态

+ (GlobalManager *)shareInstance;

/**
 *	@brief	查找视图的某个父类
 *
 *	@param 	view 	视图
 *	@param 	father 	类别
 *
 *	@return	查找结果
 */
+ (id)findViewFrom:(UIView *)view To:(Class)father;

#pragma mark - 初始化请求参数通用部分
/**
 *	@brief	初始化请求参数通用部分
 *
 *	@param 	ckey 	标记请求
 *
 *	@return	NSMutableDictionary
 */
- (NSMutableDictionary *)requestinitParamsWith:(NSString *)ckey;

#pragma mark - 同步相册
- (void)syncAlbumManagerInfo;

#pragma mark - 相册管理
+ (ALAssetsLibrary *)defaultAssetsLibrary;

#pragma mark - 相册变化监听
- (void)addAssetsLibraryChangedNotification;
- (void)removeAssetsLibraryChangedNotification;

#pragma mark - 我的作品
- (void)requestMyProfiles;

#pragma mark - 相册加载
- (void)loadNewImgAssets:(NSDate *)date;

@end
