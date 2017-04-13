//
//  BatchMakeViewController.h
//  TYSociety
//
//  Created by szl on 16/7/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@class TimeRecordInfo;

@protocol BatchMakeViewControllerDelegate <NSObject>

@optional
- (void)batchMakePublishFinish;

@end

@interface BatchMakeViewController : TableViewController

@property (nonatomic,strong)TimeRecordInfo *recordInfo;
@property (nonatomic,strong)NSString *batch_id;
@property (nonatomic,strong)NSString *user_id;
@property (nonatomic,assign)id<BatchMakeViewControllerDelegate> delegate;

@end
