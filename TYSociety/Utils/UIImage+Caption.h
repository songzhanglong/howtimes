//
//  UIImage+Caption.h
//  TYWorld
//
//  Created by songzhanglong on 14-8-6.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (Caption)

/**
 *	@brief	图片截取
 *
 *	@param 	size 	大小
 *
 *	@return	截图后的图片
 */
- (UIImage *)imageFromRect:(CGSize)size;

+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

+ (UIImage *)thumbnailPlaceHolderImageForVideo:(NSURL *)videoURL;

+ (AVAssetExportSession *)converVideoDimissionWithFilePath:(NSURL *)videoURL andOutputPath:(NSString *)outputPath withCompletion:(void (^)(NSError *error))completion To:(id)target Sel:(SEL)select;

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL;

@end
