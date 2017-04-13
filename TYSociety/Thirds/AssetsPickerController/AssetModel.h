//
//  AssetModel.h
//  TYSociety
//
//  Created by szl on 16/7/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetModel : NSObject

@property (nonatomic,strong)ALAsset *asset;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *shooting_time;    //资源拍摄时间
@property (nonatomic,strong)NSString *location_name;    //地理位置
@property (nonatomic,strong)NSString *latitude;         //经度
@property (nonatomic,strong)NSString *longitude;        //纬度
@property (nonatomic,assign)BOOL isPhoto;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *width;
@property (nonatomic,strong)NSString *height;

- (id)initWithAsset:(ALAsset *)asset;
- (void)reverseGeocodeLocationAddress;


@end
