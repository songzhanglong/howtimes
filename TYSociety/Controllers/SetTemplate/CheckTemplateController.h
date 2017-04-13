//
//  CheckTemplateController.h
//  TYSociety
//
//  Created by szl on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@interface CheckTemplateController : TableViewController

@property (nonatomic, strong) NSString *tag_id;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger numPerPage;
@property (nonatomic, strong) NSString *batch_id;
@property (nonatomic, strong) NSString *size_id;
@property (nonatomic, strong) NSMutableArray *customers;

@end
