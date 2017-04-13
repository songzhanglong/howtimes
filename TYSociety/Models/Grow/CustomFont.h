//
//  CustomFont.h
//  TYSociety
//
//  Created by szl on 16/8/16.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@class CustomFont;
typedef void(^FontDownLoadBlock)(CustomFont *netFont,NSError *error, NSURL *filePath);

@interface CustomFont : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSNumber *status;
@property (nonatomic,strong)NSString *font_name;
@property (nonatomic,strong)NSString *download;
@property (nonatomic,strong)NSString *font_key;
@property (nonatomic,strong)NSString *show_font_img;
@property (nonatomic,strong)NSString *size;
@property (nonatomic,copy)FontDownLoadBlock downLoadBlock;
@property (nonatomic,strong)NSURLSessionTask<Ignore> *sessionTask;
@property (nonatomic,strong)NSNumber<Ignore> *uploadEnd;        //1-成功，2-失败

- (void)startDownLoadTTFFile;
- (BOOL)fileHasDownLoaded;

@end
