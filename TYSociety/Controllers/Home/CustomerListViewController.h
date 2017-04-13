//
//  CustomerListViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/7/27.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"
#import "CustomerModel.h"

@interface CustomerListViewController : TableViewController

@property (nonatomic, assign) NSInteger numPerPage;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) CustomerModel *reloadItem;
@end
