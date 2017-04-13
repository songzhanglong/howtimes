//
//  CustomerView.h
//  TYSociety
//
//  Created by zhangxs on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PerInforModel.h"

@protocol CustomerViewDelegate <NSObject>

@optional
- (void)selectPhone:(PerInforModel *)model;

@end

@interface CustomerView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,assign)id<CustomerViewDelegate> delegate;

- (void)resetCustomerDatas:(NSMutableArray *)datas;
- (void)showInView:(UIView *)view;
- (void)hiddenInView;

@end
