//
//  BatchDetailMatterService.h
//  TYSociety
//
//  Created by szl on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecorateModel.h"

#define MatterCellId   @"MatterCellId"

@protocol BatchDetailMatterServiceDelegate <NSObject>

@optional
- (void)didSelectItem:(NSIndexPath *)indexPath Img:(UIImage *)img Deco:(DecorateModel *)deco;

@end

@interface BatchDetailMatterService : NSObject<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,assign)NSInteger nCurIdx;
@property (nonatomic,assign)id<BatchDetailMatterServiceDelegate> delegate;

@end
