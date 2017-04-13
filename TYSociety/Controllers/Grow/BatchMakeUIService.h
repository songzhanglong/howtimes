//
//  BatchMakeUIService.h
//  TYSociety
//
//  Created by szl on 16/7/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FastMakeCell.h"
#import "PhotoManagerModel.h"

#define FastMakeHeader          @"fastMakeHeader"
#define FastMakeCellID          @"fastMakeCell"

@interface BatchMakeUIService : NSObject<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)NSMutableArray *checkArr;
@property (nonatomic,strong)NSMutableArray *gallerys;
@property (nonatomic,assign)id<FastMakeCellDelegate> delegate;

@end
