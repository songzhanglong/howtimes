//
//  UIImage+Caption.m
//  TYWorld
//
//  Created by songzhanglong on 14-8-6.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "UIImage+Caption.h"
#import "NSString+Common.h"
#import <objc/runtime.h>

@implementation UIImage (Caption)

/**
 *	@brief	图片截取
 *
 *	@param 	size 	大小
 *
 *	@return	截图后的图片
 */
- (UIImage *)imageFromRect:(CGSize)size
{
    CGSize imgSize = self.size;
    imgSize = CGSizeMake(imgSize.width * 2, imgSize.height * 2);    //高分辨率，宽，高各加一倍
    
    float xOri = 0.0,yOri = 0.0;
    float imgWidth = MIN(size.width, imgSize.width),imgHei = MIN(size.height, imgSize.height);;
    if (size.width < imgSize.width) {
        xOri = (imgSize.width - size.width) / 2;
    }
    
    if (size.height < imgSize.height) {
        yOri = (imgSize.height - size.height) / 2;
    }
    
    CGImageRef sourceImageRef = [self CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(xOri, yOri, imgWidth, imgHei));
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    NSString *fileUrl = [videoURL absoluteString];
    NSString *urlMd5 = [NSString md5:fileUrl];
    NSString *cachePath = [NSString getCachePath:@"videoThumb"];
    NSString *filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",urlMd5]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        UIImage *thumbImg = [UIImage imageWithContentsOfFile:filePath];
        return thumbImg;
    }
    
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    if (!asset) {
        return [UIImage imageNamed:@"videoPlace.png"];
    }
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : [UIImage imageNamed:@"videoPlace.png"];
    if (thumbnailImageRef) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imgData = UIImagePNGRepresentation(thumbnailImage);
            [imgData writeToFile:filePath atomically:NO];
        });
    }
    
    return thumbnailImage;
}

+ (UIImage *)thumbnailPlaceHolderImageForVideo:(NSURL *)videoURL
{
    NSString *fileUrl = [videoURL absoluteString];
    NSString *urlMd5 = [NSString md5:fileUrl];
    NSString *cachePath = [NSString getCachePath:@"videoThumb"];
    NSString *filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",urlMd5]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        UIImage *thumbImg = [UIImage imageWithContentsOfFile:filePath];
        return thumbImg;
    }
    else
    {
        return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"videoPlace" ofType:@"png"]];
    }
}

+ (AVAssetExportSession *)converVideoDimissionWithFilePath:(NSURL *)videoURL andOutputPath:(NSString *)outputPath withCompletion:(void (^)(NSError *error))completion To:(id)target Sel:(SEL)select
{
    //获取原视频
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];//素材的视频轨
        AVAssetTrack *audioAssertTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];//素材的音频轨
        AVMutableComposition *composition = [AVMutableComposition composition];//这是工程文件
        AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];//视频轨道
        [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];//在视频轨道插入一个时间段的视频
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];//音频轨道
        [audioCompositionTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:audioAssertTrack atTime:kCMTimeZero error:nil];//插入音频数据，否则没有声音
        //裁剪视频
        AVMutableVideoCompositionLayerInstruction *videoCompositionLayerIns = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
        [videoCompositionLayerIns setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];//得到视频素材（这个例子中只有一个视频）
        AVMutableVideoCompositionInstruction *videoCompositionIns = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        [videoCompositionIns setTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)];//得到视频轨道（这个例子中只有一个轨道）
        videoCompositionIns.layerInstructions = @[videoCompositionLayerIns];
        AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.instructions = @[videoCompositionIns];
        //BOOL library = [[[videoURL scheme] lowercaseString] isEqualToString:@"assets-library"];
        //CGFloat width = library ? videoAssetTrack.naturalSize.height : videoAssetTrack.naturalSize.width;
        //CGFloat height = library ? videoAssetTrack.naturalSize.width : videoAssetTrack.naturalSize.height;
        CGFloat width = videoAssetTrack.naturalSize.height;
        CGFloat height = videoAssetTrack.naturalSize.width;
        videoComposition.renderSize = CGSizeMake(width, height);//裁剪出对应的大小
        videoComposition.frameDuration = CMTimeMake(1, 30);
        NSTimer *timer = nil;
        if (target) {
            timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:target selector:select userInfo: nil repeats: YES];
            [[NSRunLoop mainRunLoop] addTimer: timer forMode: NSDefaultRunLoopMode];
            [timer fire];
        }
        
        //开始进行导出视频
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = [NSURL fileURLWithPath: outputPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.videoComposition = videoComposition;
        exportSession.shouldOptimizeForNetworkUse = YES;
        __weak typeof(timer)weakTimer = timer;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (exportSession.status == AVAssetExportSessionStatusFailed || exportSession.status == AVAssetExportSessionStatusCancelled) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakTimer invalidate];
                    if ((exportSession.status == AVAssetExportSessionStatusFailed) && completion) {
                        completion(exportSession.error);
                    }
                });
            }
            else if (exportSession.status == AVAssetExportSessionStatusCompleted){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakTimer invalidate];
                    if (completion) {
                        completion(exportSession.error);
                    }
                });
            }
        }];
        
        return exportSession;
    }
    else{
        completion([NSError errorWithDomain:@"视频压缩异常" code:100 userInfo:nil]);
        return nil;
    }
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL
{
    //setup video writer
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:inputURL options:nil];
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize videoSize = videoTrack.naturalSize;
    NSDictionary *videoWriterCompressionSettings =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1250000], AVVideoAverageBitRateKey, nil];
    
    NSDictionary *videoWriterSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey, [NSNumber numberWithFloat:videoSize.width], AVVideoWidthKey, [NSNumber numberWithFloat:videoSize.height], AVVideoHeightKey, nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoWriterSettings];
    videoWriterInput.expectsMediaDataInRealTime = YES;
    videoWriterInput.transform = videoTrack.preferredTransform;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    [videoWriter addInput:videoWriterInput];
    
    //setup video reader
    NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
    
    AVAssetReader *videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
    [videoReader addOutput:videoReaderOutput];
    
    //setup audio writer
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
    audioWriterInput.expectsMediaDataInRealTime = NO;
    [videoWriter addInput:audioWriterInput];
    
    //setup audio reader
    AVAssetTrack* audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVAssetReaderOutput *audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
    
    [audioReader addOutput:audioReaderOutput];
    
    [videoWriter startWriting];
    
    //start writing from video reader
    [videoReader startReading];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue1", NULL);
    [videoWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:
     ^{
         while ([videoWriterInput isReadyForMoreMediaData]) {
             CMSampleBufferRef sampleBuffer;
             if ([videoReader status] == AVAssetReaderStatusReading &&
                 (sampleBuffer = [videoReaderOutput copyNextSampleBuffer])) {
                 [videoWriterInput appendSampleBuffer:sampleBuffer];
                 CFRelease(sampleBuffer);
             }
             else {
                 [videoWriterInput markAsFinished];
                 if ([videoReader status] == AVAssetReaderStatusCompleted) {
                     //start writing from audio reader
                     [audioReader startReading];
                     [videoWriter startSessionAtSourceTime:kCMTimeZero];
                     dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue2", NULL);
                     [audioWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:^{
                        while (audioWriterInput.readyForMoreMediaData) {
                             CMSampleBufferRef sampleBuffer;
                             if ([audioReader status] == AVAssetReaderStatusReading &&
                                 (sampleBuffer = [audioReaderOutput copyNextSampleBuffer])) {
                                 [audioWriterInput appendSampleBuffer:sampleBuffer];
                                 CFRelease(sampleBuffer);
                             }
                             else {
                                 [audioWriterInput markAsFinished];
                                 if ([audioReader status] == AVAssetReaderStatusCompleted) {
                                     [videoWriter finishWritingWithCompletionHandler:^(){
                                         //[self sendMovieFileAtURL:outputURL];
                                         NSLog(@"finish");
                                     }];
                                 }
                             }
                         }
                     }
                    ];
                 }
             }
         }
     }
    ];
}

@end
