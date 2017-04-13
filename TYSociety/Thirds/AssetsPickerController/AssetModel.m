//
//  AssetModel.m
//  TYSociety
//
//  Created by szl on 16/7/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AssetModel.h"
#import <CoreLocation/CoreLocation.h>
#import "DataBaseOperation.h"

@implementation AssetModel

#pragma mark - ALAssetsLibrary
+ (dispatch_queue_t)defaultPatchQueue{
    static dispatch_once_t queuePred = 0;
    static dispatch_queue_t patchQueue = nil;
    dispatch_once(&queuePred, ^{
        patchQueue = dispatch_queue_create("com.quains.myQueue", 0);
    });
    return patchQueue;
}

+ (CLGeocoder *)defaultCLGeocoder
{
    static dispatch_once_t geoPred = 0;
    static CLGeocoder *geocoder = nil;
    dispatch_once(&geoPred, ^{
        geocoder = [[CLGeocoder alloc] init];
    });
    return geocoder;
}

- (id)initWithAsset:(ALAsset *)asset
{
    self = [super init];
    if (self) {
        self.asset = asset;
        
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        self.url = url.absoluteString;
        NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
        self.shooting_time = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] stringValue];
        self.isPhoto = [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto];
        
        CGSize size = asset.defaultRepresentation.dimensions;
        self.width = [[NSNumber numberWithFloat:size.width] stringValue];
        self.height = [[NSNumber numberWithFloat:size.height] stringValue];
    }
    return self;
}

- (BOOL)isEqual:(AssetModel *)object
{
    NSURL *url1 = [_asset valueForProperty:ALAssetPropertyAssetURL];
    NSURL *url2 = [object.asset valueForProperty:ALAssetPropertyAssetURL];
    return [url1 isEqual:url2];
}

- (void)assetForURLAndLocation
{
    if ((_path.length > 0) || _asset) {
        return;
    }
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[GlobalManager defaultAssetsLibrary] assetForURL:[NSURL URLWithString:_url] resultBlock:^(ALAsset *asset) {
            if (asset) {
                weakSelf.asset = asset;
                
                CLLocation *loc = [asset valueForProperty:ALAssetPropertyLocation];
                if (loc) {
                    weakSelf.latitude = [[NSNumber numberWithDouble:loc.coordinate.latitude] stringValue];
                    weakSelf.longitude = [[NSNumber numberWithDouble:loc.coordinate.longitude] stringValue];
                }
                @autoreleasepool {
                    CLGeocoder *geocoder = [AssetModel defaultCLGeocoder];
                    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                        if (error == nil) {
                            CLPlacemark *myMark = [placemarks firstObject];
                            weakSelf.location_name = myMark.name;
                        }
                    }];
                    
                }
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    });
}

- (void)reverseGeocodeLocationAddress
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CLLocation *loc = [weakSelf.asset valueForProperty:ALAssetPropertyLocation];
        if (loc) {
            weakSelf.latitude = [[NSNumber numberWithDouble:loc.coordinate.latitude] stringValue];
            weakSelf.longitude = [[NSNumber numberWithDouble:loc.coordinate.longitude] stringValue];
        }
        @autoreleasepool {
            CLGeocoder *geocoder = [AssetModel defaultCLGeocoder];
            [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                if (error == nil) {
                    CLPlacemark *myMark = [placemarks firstObject];
                    weakSelf.location_name = myMark.name;
                }
            }];
            
        }

    });
}

@end
