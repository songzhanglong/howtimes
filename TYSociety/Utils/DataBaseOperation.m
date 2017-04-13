//
//  DataBaseOperation.m
//  TY
//
//  Created by songzhanglong on 14-6-12.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DataBaseOperation.h"
#import "AssetModel.h"
#import "TimeRecordInfo.h"

#pragma mark - 相册同步表格
#define Album_TableName         @"albumManager"     //相册管理表名

#define Album_Location          @"location"         //经纬度
#define Album_Location_name     @"location_name"    //经度位置
#define Album_UploadTime        @"upload_time"      //上传时间
#define Album_ShootTime         @"shooting_time"    //拍照时间
#define Album_FileSize          @"file_size"        //资源大小
#define Album_Md5               @"md5"              //md5码
#define Album_Path              @"path"             //资源地址
#define Album_Picture           @"picture"          //视频封面
#define Album_UploadUser        @"upload_user"      //用户id
#define Album_FileType          @"file_type"        //资源类型 1图片，2视频 ，3语音
#define Album_FileClientPath    @"file_client_path" //资源设备上的目录
#define Album_DeviceNo          @"device_no"        //设备id
#define Album_LoadState         @"loadState"        //0-未上传(本地)，1-已上传（服务器）
#define Album_Width             @"width"            //
#define Album_Height            @"height"           //

#pragma mark - 时间戳
#define CTime_TableName         @"myCTime"
#define Album_CTime             @"albumCTime"       //相册管理时间戳

@implementation DataBaseOperation

- (void)dealloc
{
    [self releaseDatabaseQueue];
}



#pragma mark - 数据库的打开与关闭
+ (DataBaseOperation *)shareInstance
{
    static DataBaseOperation *databaseOperation = nil;
    static dispatch_once_t onceTokenDatabase;
    dispatch_once(&onceTokenDatabase, ^{
        databaseOperation = [[DataBaseOperation alloc] init];
    });
    
    return databaseOperation;
}

/**
 *	@brief	打开数据库
 *
 *	@param 	filePath 	数据库路径
 */
- (void)openDataBase:(NSString *)filePath
{
    if (_databaseQueue) {
        [self releaseDatabaseQueue];
    }
    
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [_databaseQueue close];
    self.databaseName = [filePath lastPathComponent];
}

/**
 *	@brief	关闭数据库
 */
- (void)close
{
    if (_databaseQueue) {
        [_databaseQueue close];
    }
    _databaseQueue = nil;
}

/**
 *	@brief	释放队列
 */
- (void)releaseDatabaseQueue
{
    if (_databaseQueue) {
        [_databaseQueue close];
    }
    _databaseQueue = nil;
}

#pragma mark - 建表
/**
 *	@brief	创建表
 *
 *	@param 	type 	表类型
 */
- (void)createTableByType:(kTableType)type
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            switch (type) {
                case kTableMyMsg:
                {
                    /*
                    NSString *dele = @"drop table msgMyTable1;";
                    [db executeStatements:dele];
                    
                    NSString *msgMy = [NSString stringWithFormat:@"create table if not exists %@(%@ INTEGER PRIMARY KEY AUTOINCREMENT,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null);",MSG_MY_TABLE,MSG_PRIMARYKEY,MSG_MY_DATE,MSG_MY_EACHDATA,MSG_MY_FLAG,MSG_MY_MDFLAG,MSG_MY_SENDER,MSG_MY_ID,MSG_MY_URL];   //我的消息
                    NSString *mileageTable = [NSString stringWithFormat:@"create table if not exists %@(%@ INTEGER PRIMARY KEY AUTOINCREMENT,%@ text not null,%@ text not null,%@ text not null);",MILEAGE_TABLE,MILEAGE_ID,MILEAGE_USERID,MILEAGE_ALBUM_ID,MILEAGE_PHOTO_IDS];   //里程
                    [db executeStatements:msgMy];
                    [db executeStatements:mileageTable];
                     */
                }
                    break;
                case kTableAlbumManager:
                {
                    NSString *createAlbumTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@ text not null,%@ text,%@ text not null,%@ text not null,%@ text,%@ text,%@ text not null,%@ text not null,%@ text,%@ text,%@ text not null,%@ text,%@ INTEGER,%@ text,%@ text,PRIMARY KEY (%@,%@));",Album_TableName,Album_UploadUser,Album_Md5,Album_DeviceNo,Album_FileClientPath,Album_Path,Album_Picture,Album_FileSize,Album_FileType,Album_Location,Album_Location_name,Album_ShootTime,Album_UploadTime,Album_LoadState,Album_Width,Album_Height,Album_ShootTime,Album_FileClientPath];
                    [db executeStatements:createAlbumTableSql];
                    
                    NSString *createCTimeSql = [NSString stringWithFormat:@"create table if not exists %@(%@ text not null);",CTime_TableName,Album_CTime];
                    [db executeStatements:createCTimeSql];
                    
//                    NSString *dropTable = [NSString stringWithFormat:@"drop table %@",NSStringFromClass([TimeRecordInfo class])];
//                    [db executeStatements:dropTable];
                    
                    NSString *createTemplate = [RecordTemplate templateCreateTable];
                    [db executeStatements:createTemplate];
                }
                    break;
                default:
                    break;
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

#pragma mark - 相册管理
//查询所有本地相册中内容
- (NSMutableArray *)selectAllAblumsBy:(NSString *)userId
{
    NSMutableArray *array = [NSMutableArray array];
    __weak typeof(array) weakArr = array;
    
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *selectStr = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@ from %@ where %@ = '%@' order by %@ desc",Album_FileClientPath,Album_Location_name,Album_ShootTime,Album_FileType,Album_Path,Album_Width,Album_Height,Album_TableName,Album_DeviceNo,[NSString getDeviceUDID],Album_ShootTime];
            FMResultSet *result = [db executeQuery:selectStr];
            while ([result next]) {
                NSString *file_client_path  =   [result stringForColumnIndex:0];
                NSString *location_name     =   [result stringForColumnIndex:1];
                NSString *shooting_time     =   [result stringForColumnIndex:2];
                NSString *fileType          =   [result stringForColumnIndex:3];
                NSString *path              =   [result stringForColumnIndex:4];
                NSString *width             =   [result stringForColumnIndex:5];
                NSString *height            =   [result stringForColumnIndex:6];
                
                BOOL shouldAdd = NO;
                if (path.length > 0) {
                    shouldAdd = YES;
                }
                else{
                    NSString *md5Str = [NSString md5:file_client_path];
                    NSString *lastPath = [[NSString getCachePath:@"thumbnail"] stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if (![fileManager fileExistsAtPath:lastPath]){
//                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                            [[DataBaseOperation shareInstance] deleteOneLocalData:file_client_path];
//                        });
                    }
                    else{
                        shouldAdd = YES;
                    }
                }
                
                if (shouldAdd) {
                    AssetModel *assModel = [[AssetModel alloc] init];
                    assModel.url = file_client_path;
                    assModel.location_name = location_name;
                    assModel.shooting_time = shooting_time;
                    assModel.isPhoto = (fileType.integerValue == 1);
                    assModel.path = path;
                    assModel.width = width;
                    assModel.height = height;
                    [weakArr addObject:assModel];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return array;
}

- (NSMutableArray *)selectNetAndLocalAlbum:(NSString *)userId
{
    NSMutableArray *array = [NSMutableArray array];
    __weak typeof(array) weakArr = array;
    
    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *selectStr = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@ from %@ where %@ = '%@' order by %@ desc",Album_UploadUser,Album_Md5,Album_DeviceNo,Album_FileClientPath,Album_Path,Album_Picture,Album_FileSize,Album_FileType,Album_Location,Album_Location_name,Album_ShootTime,Album_UploadTime,Album_LoadState,Album_Width,Album_Height,Album_TableName,Album_UploadUser,userId,Album_ShootTime];
            FMResultSet *result = [db executeQuery:selectStr];
            while ([result next]) {
                NSString *upload_user       =   [result stringForColumnIndex:0];
                NSString *md5               =   [result stringForColumnIndex:1];
                NSString *device_no         =   [result stringForColumnIndex:2];
                NSString *file_client_path  =   [result stringForColumnIndex:3];
                NSString *path              =   [result stringForColumnIndex:4];
                NSString *picture           =   [result stringForColumnIndex:5];
                NSString *file_size         =   [result stringForColumnIndex:6];
                NSString *file_type         =   [result stringForColumnIndex:7];
                NSString *location          =   [result stringForColumnIndex:8];
                NSString *location_name     =   [result stringForColumnIndex:9];
                NSString *shooting_time     =   [result stringForColumnIndex:10];
                NSString *upload_time       =   [result stringForColumnIndex:11];
                NSInteger loadState         =   [result intForColumnIndex:12];
                NSString *width             =   [result stringForColumnIndex:13];
                NSString *height            =   [result stringForColumnIndex:14];
                
                BOOL shouldAdd = NO;
                if (path.length > 0) {
                    shouldAdd = YES;
                }
                else{
                    NSString *md5Str = [NSString md5:file_client_path];
                    NSString *lastPath = [[NSString getCachePath:@"thumbnail"] stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if (![fileManager fileExistsAtPath:lastPath]){
//                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                            [[DataBaseOperation shareInstance] deleteOneLocalData:file_client_path];
//                        });
                    }
                    else{
                        shouldAdd = YES;
                    }
                }
                
                if (shouldAdd) {
                    PhotoManagerModel *photoModel = [[PhotoManagerModel alloc] init];
                    photoModel.upload_user = upload_user;
                    photoModel.md5 = md5;
                    photoModel.device_no = device_no;
                    photoModel.file_client_path = file_client_path;
                    photoModel.path = path;
                    photoModel.picture = picture;
                    photoModel.file_size = file_size;
                    photoModel.file_type = file_type;
                    photoModel.location = location;
                    photoModel.location_name = location_name;
                    photoModel.shooting_time = shooting_time;
                    photoModel.upload_time = upload_time;
                    photoModel.loadState = @(loadState);
                    photoModel.width = width;
                    photoModel.height = height;
                    [weakArr addObject:photoModel];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return array;
}

//删除一个本地图片
- (void)deleteOneLocalData:(NSString *)url
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *deleteStr = [NSString stringWithFormat:@"delete from %@ where %@ = '%@' and %@ = '0'",Album_TableName,Album_FileClientPath,url,Album_LoadState];
            [db executeStatements:deleteStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

//从接口同步增量数据
- (void)updateOrReplaceModels:(NSArray *)photoArr By:(NSString *)userId
{
    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            for (PhotoManagerModel *photoManager in photoArr) {
                NSString *insertStr = [NSString stringWithFormat:@"insert or replace into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','1','%@','%@')",Album_TableName,Album_UploadUser,Album_Md5,Album_DeviceNo,Album_FileClientPath,Album_Path,Album_Picture,Album_FileSize,Album_FileType,Album_Location,Album_Location_name,Album_ShootTime,Album_UploadTime,Album_LoadState,Album_Width,Album_Height,photoManager.upload_user,photoManager.md5,photoManager.device_no,photoManager.file_client_path,photoManager.path,photoManager.picture ?: @"",photoManager.file_size,photoManager.file_type,photoManager.location ?: @"",photoManager.location_name ?: @"",photoManager.shooting_time,photoManager.upload_time ?: @"",photoManager.width,photoManager.height];
                [db executeStatements:insertStr];
            }
            NSString *updateTime = [NSString stringWithFormat:@"insert or replace into %@(%@) values ('%@')",CTime_TableName,Album_CTime,userId];
            [db executeStatements:updateTime];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

//本地相册库同步
- (void)updateAllAssets:(NSArray *)assets
{
    if (assets.count == 0) {
        return;
    }
    [self createNewFile:assets];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
    
        [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @try {
                NSString *uuid = [NSString getDeviceUDID];
                for (AssetModel *asset in assets) {
                    BOOL isPhoto = [[asset.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto];
                    NSString *fileSize = @"0";
                    NSString *insertStr = [NSString stringWithFormat:@"insert or replace into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@','0','%@','%@')",Album_TableName,Album_UploadUser,Album_DeviceNo,Album_FileClientPath,Album_FileSize,Album_FileType,Album_ShootTime,Album_LoadState,Album_Width,Album_Height,detailInfo.user.id,uuid,asset.url,fileSize,isPhoto ? @"1" : @"2",asset.shooting_time,asset.width,asset.height];
                    [db executeStatements:insertStr];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {

            }
        }];
    });
}

//用于本地上传成功后及时更新数据库
- (void)updateOrReplaceModel:(PhotoManagerModel *)photoManager
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *insertStr = [NSString stringWithFormat:@"insert or replace into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",Album_TableName,Album_UploadUser,Album_Md5,Album_DeviceNo,Album_FileClientPath,Album_Path,Album_Picture,Album_FileSize,Album_FileType,Album_Location,Album_Location_name,Album_ShootTime,Album_UploadTime,Album_LoadState,Album_Width,Album_Height,photoManager.upload_user,photoManager.md5,photoManager.device_no,photoManager.file_client_path,photoManager.path,photoManager.picture ?: @"",photoManager.file_size,photoManager.file_type,photoManager.location ?: @"",photoManager.location_name ?: @"",photoManager.shooting_time,photoManager.upload_time ?: @"",photoManager.loadState.stringValue,photoManager.width,photoManager.height];
            [db executeStatements:insertStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

//删除某条具体数据
- (void)deleteDataBy:(PhotoManagerModel *)photoManager
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *deleteStr = [NSString stringWithFormat:@"delete from %@ where %@ = '%@' and %@ = '%@'",Album_TableName,Album_FileClientPath,photoManager.file_client_path,Album_ShootTime,photoManager.shooting_time];
            [db executeStatements:deleteStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

//查询某个图片详细上传信息
- (PhotoManagerModel *)selectPathBy:(NSString *)local
{
    __block PhotoManagerModel *_lstPhoto = nil;
    
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *selectStr = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@ from %@ where %@ like '%%%@%%' and %@ = '1'",Album_UploadUser,Album_Md5,Album_DeviceNo,Album_FileClientPath,Album_Path,Album_Picture,Album_FileSize,Album_FileType,Album_Location,Album_Location_name,Album_ShootTime,Album_UploadTime,Album_LoadState,Album_Width,Album_Height,Album_TableName,Album_FileClientPath,local,Album_LoadState];
            FMResultSet *result = [db executeQuery:selectStr];
            while ([result next]) {
                NSString *upload_user       =   [result stringForColumnIndex:0];
                NSString *md5               =   [result stringForColumnIndex:1];
                NSString *device_no         =   [result stringForColumnIndex:2];
                NSString *file_client_path  =   [result stringForColumnIndex:3];
                NSString *path =                [result stringForColumnIndex:4];
                NSString *picture           =   [result stringForColumnIndex:5];
                NSString *file_size         =   [result stringForColumnIndex:6];
                NSString *file_type         =   [result stringForColumnIndex:7];
                NSString *location          =   [result stringForColumnIndex:8];
                NSString *location_name     =   [result stringForColumnIndex:9];
                NSString *shooting_time     =   [result stringForColumnIndex:10];
                NSString *upload_time       =   [result stringForColumnIndex:11];
                NSInteger loadState         =   [result intForColumnIndex:12];
                NSString *width             =   [result stringForColumnIndex:13];
                NSString *height            =   [result stringForColumnIndex:14];
                
                PhotoManagerModel *photoModel = [[PhotoManagerModel alloc] init];
                photoModel.upload_user = upload_user;
                photoModel.md5 = md5;
                photoModel.device_no = device_no;
                photoModel.file_client_path = file_client_path;
                photoModel.path = path;
                photoModel.picture = picture;
                photoModel.file_size = file_size;
                photoModel.file_type = file_type;
                photoModel.location = location;
                photoModel.location_name = location_name;
                photoModel.shooting_time = shooting_time;
                photoModel.upload_time = upload_time;
                photoModel.loadState = @(loadState);
                photoModel.width = width;
                photoModel.height = height;
                
                _lstPhoto = photoModel;
                
                break;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return _lstPhoto;
}

//查询本地相册最新时间
- (NSString *)selectMaxShootingTime
{
    __block NSString *str = nil;
    
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *selectStr = [NSString stringWithFormat:@"select max(%@) from %@ where %@ = '%@'",Album_ShootTime,Album_TableName,Album_DeviceNo,[NSString getDeviceUDID]];
            FMResultSet *result = [db executeQuery:selectStr];
            while ([result next]) {
                str = [result stringForColumnIndex:0];
                break;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return str;
}

//查询所有url
- (NSMutableSet *)checkAllUrlsByDeviceID
{
    NSMutableSet *set = [NSMutableSet set];
    __weak typeof(set) weakSet = set;
    
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *selectStr = [NSString stringWithFormat:@"select %@ from %@ where %@ = '%@'",Album_FileClientPath,Album_TableName,Album_DeviceNo,[NSString getDeviceUDID]];
            FMResultSet *result = [db executeQuery:selectStr];
            while ([result next]) {
                NSString *path = [result stringForColumnIndex:0];
                [weakSet addObject:path];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return set;
}

//删除所有本地已删除的数据
- (void)deleteAllLoacalNoneData:(NSMutableSet *)set
{
    if ([set count] == 0) {
        return;
    }
    [self deleteFileBy:set];
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            for (NSString *url in set) {
                NSString *deleteStr = [NSString stringWithFormat:@"delete from %@ where %@ = '%@' and %@ = '0'",Album_TableName,Album_FileClientPath,url,Album_LoadState];
                [db executeStatements:deleteStr];
                
                NSString *md5Str = [NSString md5:url];
                NSString *lastPath = [[NSString getCachePath:@"thumbnail"] stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:lastPath]){
                    [fileManager removeItemAtPath:lastPath error:nil];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

#pragma mark - 文件管理
- (void)createNewFile:(NSArray *)array
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *catchPath = [NSString getCachePath:@"thumbnail"];
        for (AssetModel *asset in array) {
            NSString *md5Str = [NSString md5:asset.url];
            NSString *lastPath = [catchPath stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
            
            if (![fileManager fileExistsAtPath:lastPath]) {
                @autoreleasepool {
                    NSData *fileDate = UIImagePNGRepresentation([UIImage imageWithCGImage:asset.asset.thumbnail]);
                    [fileDate writeToFile:lastPath atomically:NO];
                }
            }
        }
    });
}

- (void)deleteFileBy:(NSMutableSet *)set
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *catchPath = [NSString getCachePath:@"thumbnail"];
        for (NSString *url in set) {
            NSString *md5Str = [NSString md5:url];
            NSString *lastPath = [catchPath stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
            
            if ([fileManager fileExistsAtPath:lastPath]) {
                [fileManager removeItemAtPath:lastPath error:nil];
            }
        }
    });
}

#pragma mark - 时间戳
- (void)updateCTime:(NSString *)time
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *deleteTime = [NSString stringWithFormat:@"delete from %@",CTime_TableName];
            [db executeStatements:deleteTime];
            NSString *updateTime = [NSString stringWithFormat:@"insert into %@(%@) values (%@)",CTime_TableName,Album_CTime,time];
            [db executeStatements:updateTime];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

- (NSString *)selectCtimeBy:(NSString *)userId
{
    __block NSString *str = nil;
    
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *selectStr = [NSString stringWithFormat:@"select %@ from %@",Album_CTime,CTime_TableName];
            FMResultSet *result = [db executeQuery:selectStr];
            while ([result next]) {
                str = [result stringForColumnIndex:0];
                break;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return str;
}

#pragma mark - 模版待提交数据
//删除，更新，插入
- (void)resetTemplateInfo:(NSString *)templateStr;
{
    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            [db executeStatements:templateStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

- (NSMutableArray *)checkTemplateInfo:(NSString *)templateStr
{
    NSMutableArray *array = [NSMutableArray array];
    __weak typeof(array) weakArr = array;
    
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            FMResultSet *result = [db executeQuery:templateStr];
            while ([result next]) {
                NSString *record_Grow_ID    =   [result stringForColumnIndex:0];
                NSString *record_ID         =   [result stringForColumnIndex:1];
                NSString *base_Param        =   [result stringForColumnIndex:2];
                NSString *record_Imgpath    =   [result stringForColumnIndex:3];
                NSString *record_Gallery    =   [result stringForColumnIndex:4];
                NSString *record_Txtinput   =   [result stringForColumnIndex:5];
                NSString *record_Imgdeco    =   [result stringForColumnIndex:6];
                NSString *record_Decotxt    =   [result stringForColumnIndex:7];
                
                [weakArr addObject:@[record_Grow_ID,record_ID,base_Param,record_Imgpath,record_Gallery,record_Txtinput,record_Imgdeco,record_Decotxt]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return array;
}

@end
