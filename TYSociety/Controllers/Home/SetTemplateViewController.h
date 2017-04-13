//
//  SetTemplateViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/7/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"
#import "XWDragCellCollectionView.h"
#import "HomeRecommond.h"

@interface SetTemplateViewController : TableViewController<XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate>

@property (nonatomic, strong) NSString *batch_id;
@property (nonatomic, strong) NSString *grow_id;
@property (nonatomic, strong) NSMutableArray *customers;
@property (nonatomic, assign) NSInteger statue_set; // 0-创建 1-个人修改 2-批次修改
@property (nonatomic, assign) BOOL isBack;

@end
