//
//  PhotoManagerModel.h
//  TYSociety
//
//  Created by szl on 16/7/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class PhotoManagerModel;

@protocol PhotoManagerUploadDelegate <NSObject>

@optional
- (void)photoManagerUpload:(PhotoManagerModel *)model Suc:(BOOL)suc;

@end

typedef enum{
    kPhotoUploadNone = 0,
    kPhotoUploadWait,       //等待上传
    kPhotoUploadCancel,     //取消
    kPhotoUploading,        //上传中
    kPhotoUploadFailed,     //失败
    kPhotoUploadSuc         //结束
}kPhotoUploadState;

@interface PhotoManagerModel : JSONModel

@property (nonatomic,strong)NSString *picture;          //视频封面
@property (nonatomic,strong)NSString *upload_time;      //上传时间
@property (nonatomic,strong)NSString *shooting_time;    //资源拍摄时间
@property (nonatomic,strong)NSString *file_size;        //资源大小
@property (nonatomic,strong)NSString *location;         //经纬度
@property (nonatomic,strong)NSString *md5;              //资源md5值
@property (nonatomic,strong)NSString *path;             //资源地址
@property (nonatomic,strong)NSString *upload_user;      //上传用户
@property (nonatomic,strong)NSString *file_type;        //资源类型 1图片，2视频 ，3语音，
@property (nonatomic,strong)NSString *file_client_path; //资源设备上的目录
@property (nonatomic,strong)NSString *device_no;        //设备号
@property (nonatomic,strong)NSString *location_name;    //地理位置
@property (nonatomic,strong)NSString *width;
@property (nonatomic,strong)NSString *height;
@property (nonatomic,strong)NSNumber<Ignore> *loadState;//0-未下载，1-已下载

@property (nonatomic,strong)ALAsset<Ignore> *asset;
@property (nonatomic,assign)kPhotoUploadState uploadState;      //1-上传成功，2-上传失败
@property (nonatomic,assign)id<PhotoManagerUploadDelegate> delegate;
@property (nonatomic,assign)CGFloat progress;
@property (nonatomic,strong)NSURLSessionTask<Ignore> *sessionTask;

- (void)beginUploadData;

- (void)clearUploadData;

@end
