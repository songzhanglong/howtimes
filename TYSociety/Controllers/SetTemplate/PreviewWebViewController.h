//
//  PreviewWebViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/8/5.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"
#import "TimeRecordModel.h"
#import "CustomerModel.h"

@protocol PreviewWebViewControllerDelegate <NSObject>

@optional
- (void)reloadToCustomerList:(CustomerModel *)item Idx:(NSInteger)idx;

@end
@interface PreviewWebViewController : BaseViewController

@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)TimeRecordModel *recordItem;
@property (nonatomic,strong)NSMutableArray *customers;
@property (nonatomic,assign)BOOL isLandscape;
@property (nonatomic,assign)BOOL hasLoaded;
@property (nonatomic,assign)id<PreviewWebViewControllerDelegate> delegate;

- (void)resetSelfToRequest;

@end
