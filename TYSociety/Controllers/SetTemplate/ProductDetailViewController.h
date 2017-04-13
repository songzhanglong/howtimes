//
//  ProductDetailViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/8/6.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"
#import "TimeRecordModel.h"

@interface ProductDetailViewController : BaseViewController

@property (nonatomic,strong)TimeRecordModel *recordItem;
@property (nonatomic,strong)NSMutableArray *customers;

@end
