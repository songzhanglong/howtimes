//
//  CopyCustomerTemplateController.h
//  TYSociety
//
//  Created by zhangxs on 16/7/27.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@interface CopyCustomerTemplateController : TableViewController

@property (nonatomic, strong) NSMutableArray *userList;
@property (nonatomic, strong) NSString *batch_id;
@property (nonatomic, strong) NSString *grow_id;
@property (nonatomic, assign) NSInteger templates;
@property (nonatomic, assign) BOOL isNeedSet;

@end
