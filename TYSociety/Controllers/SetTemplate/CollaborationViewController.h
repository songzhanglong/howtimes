//
//  CollaborationViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/7/12.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@interface CollaborationViewController : TableViewController

@property (nonatomic, strong) NSString *batch_id;
@property (nonatomic, strong) NSString *grow_id;
@property (nonatomic, strong) NSString *template_id;
@property (nonatomic, strong) NSMutableArray *customers;
@property (nonatomic, assign) BOOL is_double;

@end
