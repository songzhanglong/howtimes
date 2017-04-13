//
//  BatchDetailGalleryService.h
//  TYSociety
//
//  Created by szl on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckCoverCell.h"

#define GalleryCellId       @"GalleryCellId"
#define GalleryAddCellId    @"GalleryAddCellId"

@protocol BatchDetailGalleryServiceDelegate <NSObject>

@optional
- (void)didSelectGalleryAt:(NSIndexPath *)indexPath;
- (void)cancelCoverImg;
- (void)resetGalleryCoverAt:(NSInteger)idx;
- (void)addNewGallerySource;

@end

@interface BatchDetailGalleryService : NSObject<UICollectionViewDataSource,UICollectionViewDelegate,CheckCoverCellDelegate>

@property (nonatomic,strong)NSMutableArray *gallerys;
@property (nonatomic,strong)NSMutableArray *photos;
@property (nonatomic,assign)NSInteger coverIdx;
@property (nonatomic,assign)CGFloat minWei;
@property (nonatomic,assign)CGFloat minHei;
@property (nonatomic,assign)id<BatchDetailGalleryServiceDelegate> delegate;

@end
