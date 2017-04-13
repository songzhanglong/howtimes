//
//  AddressBookViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"
#import "HomeRecommond.h"
#import "CustomerModel.h"

@interface AddressBookViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *product_id;
@property (nonatomic, strong) BatchCustomers *batchCustomers;
@property (nonatomic, assign) BOOL goBack;

@end
