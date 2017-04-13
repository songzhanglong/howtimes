//
//  SyncViewController.h
//  TYSociety
//
//  Created by szl on 16/7/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@class RecordTemplate;
@interface SyncViewController : TableViewController

@property (nonatomic,strong)RecordTemplate *recordTemplate;
@property (nonatomic,strong)UIView *bottomView;

@end
