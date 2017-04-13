//
//  DataBaseOperation.h
//  TY
//
//  Created by songzhanglong on 14-6-12.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "PhotoManagerModel.h"
@class RecordTemplate;

typedef enum
{
    kTableMyMsg = 0,    //我的消息
    kTableAlbumManager  //相册管理
}kTableType;

@interface DataBaseOperation : NSObject

@property (nonatomic,readonly)FMDatabaseQueue *databaseQueue;
@property (nonatomic,strong)NSString *databaseName;

+ (DataBaseOperation *)shareInstance;

#pragma mark - 数据库的打开与关闭
/**
 *	@brief	打开数据库
 *
 *	@param 	filePath 	数据库路径
 */
- (void)openDataBase:(NSString *)filePath;

/**
 *	@brief	关闭数据库
 */
- (void)close;

/**
 *	@brief	释放队列
 */
- (void)releaseDatabaseQueue;

#pragma mark - 建表
/**
 *	@brief	创建表
 *
 *	@param 	type 	表类型
 */
- (void)createTableByType:(kTableType)type;

#pragma mark - 相册管理
//还差一个监听相册变化的处理
//查询所有本地相册中内容
- (NSMutableArray *)selectAllAblumsBy:(NSString *)userId;
- (NSMutableArray *)selectNetAndLocalAlbum:(NSString *)userId;
//删除一个本地图片
- (void)deleteOneLocalData:(NSString *)url;

//从接口同步增量数据
- (void)updateOrReplaceModels:(NSArray *)photoArr By:(NSString *)userId;
//用于本地上传成功后及时更新数据库
- (void)updateOrReplaceModel:(PhotoManagerModel *)photoManager;
//删除某条具体数据
- (void)deleteDataBy:(PhotoManagerModel *)photoManager;
//查询某个图片详细上传信息
- (PhotoManagerModel *)selectPathBy:(NSString *)local;
//本地相册库同步
- (void)updateAllAssets:(NSArray *)assets;
//查询本地相册最新时间
- (NSString *)selectMaxShootingTime;

//查询所有url
- (NSMutableSet *)checkAllUrlsByDeviceID;

//删除所有本地已删除的数据
- (void)deleteAllLoacalNoneData:(NSMutableSet *)set;

#pragma mark - 时间戳
- (NSString *)selectCtimeBy:(NSString *)userId;

#pragma mark - 模版待提交数据
- (void)resetTemplateInfo:(NSString *)templateStr;
- (NSMutableArray *)checkTemplateInfo:(NSString *)templateStr;

@end
