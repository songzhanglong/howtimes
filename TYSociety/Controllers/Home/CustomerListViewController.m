//
//  CustomerListViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/27.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CustomerListViewController.h"
#import "KxMenu.h"
#import "AddressBookViewController.h"
#import "SetTemplateViewController.h"
#import "BatchMakeViewController.h"
#import "EditAddressView.h"
#import "PaymentTableViewCell.h"
#import "HorizontalButton.h"
#import "BeMadeTableViewCell.h"
#import "CustomerTableViewCell.h"
#import "GrowAlertView.h"
#import "VerticalButton.h"
#import "YWCMainViewController.h"
#import "YWCTopScrollView.h"
#import "PreviewWebViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "HomePageUserController.h"
#import "AddressModel.h"

@interface CustomerListViewController () <EditAddressViewDelegate,PaymentTableViewCellDelegate,BeMadeTableViewCellDelegate,CustomerTableViewCellDelegate,GrowAlertViewDelegate,PreviewWebViewControllerDelegate>
{
    NSInteger _indexSection;
    NSIndexPath *_indexPath;
    NSMutableArray *_selectArray;
    UILabel *_priceLabel;
    double _totalPrice;
    HorizontalButton *_allHoriBut;
}
@end
@implementation CustomerListViewController

- (void)dealloc
{
    if (_status == 2) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ALIPAY_SUCCESS object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    _numPerPage = 30;
    _selectArray = [NSMutableArray array];
    _totalPrice = 0.00;
    
    self.view.backgroundColor = CreateColor(245, 245, 245);
    
    [self createTableViewAndRequestAction:@"consumer" Param:nil Header:YES Foot:YES];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[BeMadeTableViewCell class] forCellReuseIdentifier:@"BeMadeCellId"];
    [self.tableView registerClass:[PaymentTableViewCell class] forCellReuseIdentifier:@"PaymentCellId"];
    [self.tableView registerClass:[CustomerTableViewCell class] forCellReuseIdentifier:@"CustomerCellId"];
    [self.tableView setBackgroundColor:CreateColor(245, 245, 245)];
    self.silentAnimation = YES;
    
    if (_status == 2) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAlipayFinish:) name:ALIPAY_SUCCESS object:nil];
    }
}

- (void)backToPreControl:(id)sender
{
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[HomePageUserController class]]) {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
            return;
        }
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)createTableHeaderView{
    if ([self.dataSource count] > 0) {
        [self.tableView setTableHeaderView:nil];
    }
    else{
        
        //CGFloat margin = (SCREEN_HEIGHT - 64 - 96) / 2;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100 + 96)];
        [headView setBackgroundColor:self.tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, 100, 65, 80)];
        imgView.image = CREATE_IMG(@"order_default");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 10, SCREEN_WIDTH - 80, 30)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"还没有数据吗？下拉刷新试试"];
        [headView addSubview:label];
        
        [self.tableView setTableHeaderView:headView];
    }
}

- (void)submitAction:(UIButton *)sender
{
    NSMutableArray *indexArray = [NSMutableArray array];
    for (NSArray *array in self.dataSource) {
        for (CustomerModel *item in array) {
            if (item.isSelected) {
                [indexArray addObject:item.grow_id];
            }
        }
    }
    
    if ([indexArray count] == 0) {
        [self.view makeToast:@"请选择要提交打印的档案" duration:1.0 position:@"center"];
        return;
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"consumerCreateOrder"];
    [param setValue:[indexArray componentsJoinedByString:@","] forKey:@"grow_ids"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"consumer"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf submitFinish:error Data:data];
    }];
}

- (void)createBottomView
{
    UIView *bottomView = (UIView *)[self.view viewWithTag:107];
    if (bottomView) {
        [bottomView removeFromSuperview];
    }
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 45 - 44, SCREEN_WIDTH, 45)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [bottomView setTag:107];
    [bottomView setUserInteractionEnabled:YES];
    [self.view addSubview:bottomView];
    
    HorizontalButton *horiBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
    _allHoriBut = horiBut;
    [horiBut setFrame:CGRectMake(18, 10, 50, 25)];
    horiBut.textSize = CGSizeMake(40, 18);
    horiBut.imgSize = CGSizeMake(15, 15);
    [horiBut setTitle:@"全选" forState:UIControlStateNormal];
    [horiBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    horiBut.titleLabel.font = [UIFont systemFontOfSize:14];
    horiBut.titleLabel.textAlignment = NSTextAlignmentCenter;
    [horiBut setImage:CREATE_IMG(@"cust_check") forState:UIControlStateNormal];
    [horiBut setImage:CREATE_IMG(@"cust_checked") forState:UIControlStateSelected];
    [horiBut addTarget:self action:@selector(selectAllAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:horiBut];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(horiBut.frameRight + 10, horiBut.frameY, 45, 25)];
    [tipLabel setBackgroundColor:[UIColor clearColor]];
    [tipLabel setText:@"合计："];
    [tipLabel setTextColor:CreateColor(100, 100, 100)];
    [tipLabel setFont:[UIFont systemFontOfSize:14]];
    [bottomView addSubview:tipLabel];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipLabel.frameRight - 10, tipLabel.frameY, 80, 25)];
    _priceLabel = priceLabel;
    [_priceLabel setText:@"￥0.00"];
    [priceLabel setBackgroundColor:[UIColor clearColor]];
    [priceLabel setTextColor:CreateColor(131, 84, 251)];
    [priceLabel setFont:[UIFont systemFontOfSize:14]];
    [bottomView addSubview:priceLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100 - 40 - 45, priceLabel.frameY + 18, 45, 15)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"不含运费"];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:10]];
    [bottomView addSubview:label];
    
    VerticalButton *backButton = [VerticalButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(SCREEN_WIDTH - 100 - 40, 5, 30, 40)];
    backButton.imgSize = CGSizeMake(18, 18);
    backButton.textSize = CGSizeMake(30, 20);
    backButton.margin = 2;
    [backButton setImage:CREATE_IMG(@"cust_back") forState:UIControlStateNormal];
    [backButton setTitle:@"撤销" forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [backButton setTitleColor:CreateColor(131, 84, 251) forState:UIControlStateNormal];
    [backButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [backButton addTarget:self action:@selector(undoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:backButton];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(SCREEN_WIDTH - 100, 0, 100, 45)];
    [button setTitle:@"付款" forState:UIControlStateNormal];
    [button setBackgroundColor:CreateColor(153, 125, 251)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [button addTarget:self action:@selector(playPriceAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button];
}

- (void)undoPressed:(id)sender
{
    NSMutableArray *indexArray = [NSMutableArray array];
    for (NSArray *array in self.dataSource) {
        for (CustomerModel *item in array) {
            if (item.isSelected) {
                [indexArray addObject:item];
            }
        }
    }
    
    if ([indexArray count] == 0) {
        [self.view makeToast:@"请选择撤销的档案" duration:1.0 position:@"center"];
        return;
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"cancelOrder"];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (CustomerModel *info in indexArray) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:info.grow_id ?: @"" forKey:@"grow_id"];
        [dic setValue:info.sys_order_num ?: @"" forKey:@"order_id"];
        NSString *jsonString = [self dictToJsonStr:dic];
        [tempArray addObject:jsonString];
    }
    [param setValue:[NSString stringWithFormat:@"[%@]",[tempArray componentsJoinedByString:@","]] forKey:@"data"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"consumer"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf undoPrintFinish:error Data:data];
    }];
}

- (void)selectAllAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _totalPrice = 0.00;
    for (NSArray *index in self.dataSource) {
        for (CustomerModel *item in index) {
            item.isSelected = sender.selected;
            if (item.isSelected) {
                _totalPrice += [item.sale_price doubleValue] * item.print_num;
            }
        }
    }
    [_priceLabel setText:[NSString stringWithFormat:@"￥%0.2lf",_totalPrice]];
    
    [self.tableView reloadData];
}

- (NSString *)dictToJsonStr:(NSDictionary *)dic
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in dic.allKeys) {
        NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\"",key,[dic valueForKey:key]];
        [array addObject:str];
    }
    
    return [NSString stringWithFormat:@"{%@}",[array componentsJoinedByString:@","]];
}

- (void)playPriceAction:(id)sender
{
    //order request
    NSMutableArray *indexArray = [NSMutableArray array];
    for (NSArray *array in self.dataSource) {
        for (CustomerModel *item in array) {
            if (item.isSelected) {
                [indexArray addObject:item];
            }
        }
    }
    
    if ([indexArray count] == 0) {
        [self.view makeToast:@"请选择最终打印的档案" duration:1.0 position:@"center"];
        return;
    }
    
    for (CustomerModel *item in indexArray) {
        if ([item.address length] == 0) {
            [self.view makeToast:@"请输入收货地址" duration:1.0 position:@"center"];
            return;
        }
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"consumerCreatePrint"];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (CustomerModel *info in indexArray) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:info.grow_id forKey:@"grow_id"];
        [dic setValue:info.sys_order_num forKey:@"order_id"];
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)info.print_num] forKey:@"num"];
        NSString *jsonString = [self dictToJsonStr:dic];
        [tempArray addObject:jsonString];
    }
    [param setValue:[NSString stringWithFormat:@"[%@]",[tempArray componentsJoinedByString:@","]] forKey:@"data"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"consumer"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf printFinish:error Data:data];
    }];
}

#pragma mark - 接口配置
- (void)resetRequestParam
{
    NSMutableDictionary *param = [[GlobalManager shareInstance] requestinitParamsWith:@"queryComsumerOrder"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_numPerPage] forKey:@"page_size"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageNo] forKey:@"page_num"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_status] forKey:@"status"];
    [param setObject:[GlobalManager shareInstance].detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)startPullRefresh
{
    if ([self.tableView.mj_footer isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
        return;
    }
    _pageNo = 1;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    if ([self.dataSource count] > 0) {
        _pageNo++;
    }
    [super startPullRefresh2];
}

- (void)addCustomer:(id)secder
{
    NSArray *array = [self.dataSource objectAtIndex:_indexSection];
    for (CustomerModel *item in array) {
        item.name = item.user_name;
    }
    CustomerModel *info = array.firstObject;
    
    BatchCustomers *model = [[BatchCustomers alloc] init];
    model.batch_id = info.batch_id;
    model.is_create_grow = [NSNumber numberWithInteger:1];
    model.grow_name = info.grow_name;
    model.consumers = (NSMutableArray <CustomerModel>*)array;
    AddressBookViewController *addressBook = [[AddressBookViewController alloc] init];
    addressBook.batchCustomers = model;
    [self.navigationController pushViewController:addressBook animated:YES];
}

- (void)setTemplate:(id)sender
{
    NSArray *array = [self.dataSource objectAtIndex:_indexSection];
    CustomerModel *info = array.firstObject;
    
    SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
    setController.batch_id = info.batch_id;
    setController.grow_id = info.grow_id;
    setController.customers = (NSMutableArray *)array;
    setController.statue_set = 2;
    [self.navigationController pushViewController:setController animated:YES];
}

- (void)setAddress:(UIButton *)sender
{
    [self getAddressRequest:YES];
}

- (void)setAllAddress:(UIButton *)sender
{
    _indexSection = [sender tag] - 1;
    [self getAddressRequest:YES];
}
- (void)renameAction:(id)sender
{
    NSArray *array = [self.dataSource objectAtIndex:_indexSection];
    CustomerModel *item = array[0];
    GrowAlertView *alertView = [[GrowAlertView alloc] initWithFrame:self.view.window.bounds];
    alertView.delegate = self;
    [alertView setDefaultTheme:item.grow_name ?: @""];
    [self.view.window addSubview:alertView];
}

#pragma mark GrowAlertView delegate
- (void)closeGrowAlertView
{
    for (id subview in self.view.window.subviews) {
        if ([subview isKindOfClass:[GrowAlertView class]]) {
            [subview removeFromSuperview];
        }
    }
}
- (void)submitThemeToGrowAlertView:(GrowAlertView *)alert Theme:(NSString *)theme
{
    if ([theme length] <= 0) {
        [self.view makeToast:@"您还没有输入批次名哦" duration:1.0 position:@"center"];
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSArray *array = [self.dataSource objectAtIndex:_indexSection];
    CustomerModel *info = array.firstObject;
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"templateSet"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"updateGrowAlbumName"];
    [param setObject:info.batch_id forKey:@"batch_id"];
    [param setObject:theme forKey:@"grow_name"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view.window makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateGrowNameFinish:error Data:data GrowName:theme];
        });
    }];
}

#pragma mark GrowAlertView delegate
- (void)closeEditAddressView
{
    for (id subview in self.view.window.subviews) {
        if ([subview isKindOfClass:[EditAddressView class]]) {
            [subview removeFromSuperview];
        }
    }
}

- (void)submitAddress:(EditAddressView *)alert Address:(CustomerModel *)item
{
    if (alert.isSetAll) {
        NSArray *array = [self.dataSource objectAtIndex:_indexSection];
        for (CustomerModel *info in array) {
            info.address_id = item.address_id;
            info.address = item.address;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:_indexSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else {
        NSArray *array = [self.dataSource objectAtIndex:_indexPath.section];
        CustomerModel *info = array[_indexPath.row];
        info.address_id = item.address_id;
        info.address = item.address;
        [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)addActions:(UIButton *)sender
{
    _indexSection = [sender tag] - 1;
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"添加客户"
                     image:CREATE_IMG(@"ku_add")
                    target:self
                    action:@selector(addCustomer:)],
      [KxMenuItem menuItem:@"设置模板"
                     image:CREATE_IMG(@"ku_edit")
                    target:self
                    action:@selector(setTemplate:)],
      [KxMenuItem menuItem:@"重命名"
                     image:CREATE_IMG(@"ku_rename")
                    target:self
                    action:@selector(renameAction:)],
      [KxMenuItem menuItem:@"设置收货地址"
                     image:CREATE_IMG(@"ku_local")
                    target:self
                    action:@selector(setAddress:)]
      ];
    CGRect rect = [[sender superview] convertRect:sender.frame toView:self.view];
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
                 menuItems:menuItems];
}

- (void)getAddressRequest:(BOOL)is_all
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"address"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAddress"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getAddressFinish:error Data:data SetAll:is_all];
        });
    }];
}

- (void)setIndexActions:(NSIndexPath *)indexPath Index:(NSInteger)idx
{
    NSArray *array = [self.dataSource objectAtIndex:indexPath.section];
    CustomerModel *info = array[indexPath.row];
    switch (idx) {
        case 0:
        {
            BatchMakeViewController *batch = [BatchMakeViewController new];
            batch.hidesBottomBarWhenPushed = YES;
            batch.batch_id = info.batch_id;
            batch.user_id = info.user_id;
            [self.navigationController pushViewController:batch animated:YES];
        }
            break;
        case 1:
        {
            //地址
            _indexPath = indexPath;
            
            [self getAddressRequest:NO];
        }
            break;
        case 2:
        {
            //设置
            SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
            setController.batch_id = info.batch_id;
            setController.grow_id = info.grow_id;
            setController.customers = (NSMutableArray *)@[info];
            setController.statue_set = 1;
            [self.navigationController pushViewController:setController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

/*********************************************************************/
#pragma mark 
#pragma mark request end

//刷新、获取数据
- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSInteger pages = [[ret_data valueForKey:@"page_count"] integerValue];
        if (pages <= _pageNo) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        NSArray *dataList = [ret_data valueForKey:@"data"];
        NSArray *array = [CustomerModel arrayOfModelsFromDictionaries:dataList error:nil];
        NSMutableArray *lastArr = [NSMutableArray array];
        NSString *firstLetter = @"";
        for (CustomerModel *item in array) {
            item.print_num = 1;
            if ([item.batch_id length] == 0) {
                continue;
            }
            
            if (_reloadItem) {
                if ([item.batch_id isEqualToString:_reloadItem.batch_id] && [item.user_id isEqualToString:_reloadItem.user_id]) {
                    item.isSelected = YES;
                    _reloadItem = nil;
                }
            }
            
            if (![firstLetter isEqualToString:item.batch_id]) {
                firstLetter = item.batch_id;
                NSMutableArray *tmpArr = [NSMutableArray arrayWithObject:item];
                [lastArr addObject:tmpArr];
            }
            else{
                NSMutableArray *sufArr = [lastArr lastObject];
                [sufArr addObject:item];
            }
        }
        
        if ([lastArr count] > 0 && (_status == 2 || _status == 1)) {
            [self.tableView setAutoresizingMask:UIViewAutoresizingNone];
            [self.tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 45 - 44)];
            if (_status == 1) {
                UIButton *button = (UIButton *)[self.view viewWithTag:106];
                if (!button) {
                    button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 45 - 44, SCREEN_WIDTH, 45)];
                    [button setTitle:@"提交订单" forState:UIControlStateNormal];
                    [button setTag:106];
                    [button setBackgroundColor:CreateColor(153, 125, 251)];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
                    [button addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:button];
                }
            }else {
                [self createBottomView];
            }
        }
        
        _totalPrice = 0.00;
        for (NSArray *index in lastArr) {
            for (CustomerModel *info in index) {
                if (info.isSelected) {
                    _totalPrice += [info.sale_price doubleValue];
                }
            }
        }
        [_priceLabel setText:[NSString stringWithFormat:@"￥%0.2lf",_totalPrice]];
        
        self.dataSource = lastArr;
        [self.tableView reloadData];
    }
    [self createTableHeaderView];
}

//加载更多
- (void)requestFinish2:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSInteger pages = [[ret_data valueForKey:@"page_count"] integerValue];
        if (pages <= _pageNo) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else{
            [self finishRefresh];
        }
        
        NSArray *dataList = [ret_data valueForKey:@"data"];
        NSMutableArray *array = [CustomerModel arrayOfModelsFromDictionaries:dataList error:nil];
        
        NSMutableArray *lastArr = [NSMutableArray array];
        NSString *firstLetter = @"";
        for (CustomerModel *item in array) {
            item.print_num = 1;
            if ([item.batch_id length] == 0) {
                continue;
            }
            if (![firstLetter isEqualToString:item.batch_id]) {
                firstLetter = item.batch_id;
                NSMutableArray *tmpArr = [NSMutableArray arrayWithObject:item];
                [lastArr addObject:tmpArr];
            }
            else{
                NSMutableArray *sufArr = [lastArr lastObject];
                [sufArr addObject:item];
            }
        }
        
        if (self.dataSource) {
            [self.dataSource addObjectsFromArray:lastArr];
        }
        else{
            self.dataSource = lastArr;
        }
        
        [self.tableView reloadData];
    }
    else{
        [self finishRefresh];
    }
    [self createTableHeaderView];
}

//获取地址
- (void)getAddressFinish:(NSError *)error Data:(id)result SetAll:(BOOL)is_all
{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [AddressModel arrayOfModelsFromDictionaries:ret_data error:nil];
        NSArray *tempArray = [self.dataSource objectAtIndex:_indexPath.section];
        EditAddressView *editAddressView = [[EditAddressView alloc] initWithFrame:self.view.window.bounds];
        editAddressView.delegate = self;
        editAddressView.isSetAll = is_all;
        editAddressView.dataSource = array;
        editAddressView.customer = is_all ? [[self.dataSource objectAtIndex:_indexSection] objectAtIndex:0] : tempArray[_indexPath.row];
        [editAddressView setFramToSelf];
        [self.view.window addSubview:editAddressView];
    }
}

//updateGrowName
- (void)updateGrowNameFinish:(NSError *)error Data:(id)result GrowName:(NSString *)name
{
    [self.view.window hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }else {
        NSArray *array = [self.dataSource objectAtIndex:_indexSection];
        CustomerModel *info = array.firstObject;
        info.grow_name = name;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:_indexSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//create order
- (void)submitFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (error) {
        [self.view.window makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self relodCurrView:2];
    }
}

//submit print
- (void)printFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (error) {
        [self.view.window makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [data valueForKey:@"ret_data"];
        NSString *orderSpec = [ret_data valueForKey:@"prestr"];
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderSpec, [ret_data valueForKey:@"sign"], @"RSA"];
        //将签名成功字符串格式化为订单字符串,请严格按照该格式
        if ([orderString length] > 0) {
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:@"society" callback:^(NSDictionary *resultDic) {
                if ([[resultDic objectForKey:@"resultStatus"] integerValue] == 9000) {
                    [self refreshAlipayFinish:nil];
                }
            }];
        }else {
            [self.view makeToast:@"订单信息获取失败！" duration:1.0 position:@"center"];
        }
    }
}

//undo print
- (void)undoPrintFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (error) {
        [self.view.window makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        //back
        [self relodCurrView:1];
        
    }
}

- (void)relodCurrView:(NSInteger)idx
{
    NSMutableArray *datas = [NSMutableArray array];
    for (NSArray *array in self.dataSource) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (CustomerModel *item in array) {
            if (!item.isSelected) {
                [tempArr addObject:item];
            }
        }
        
        if ([tempArr count] > 0) {
            [datas addObject:tempArr];
        }
    }
    if (_status == 2) {
        _totalPrice = 0.00;
        [_priceLabel setText:[NSString stringWithFormat:@"￥%0.2lf",_totalPrice]];
    }
    self.dataSource = datas;
    [self.tableView reloadData];
    
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[YWCMainViewController class]]) {
            NSArray * arr = ((YWCMainViewController *)controller).childViewControllers;
            CustomerListViewController *list = [arr objectAtIndex:idx];
            if (idx == 2) {
                list.reloadItem = _reloadItem;
            }
            if (list.isViewLoaded) {
                [list beginRefresh];
            }
            YWCTopScrollView *topScro = ((YWCMainViewController *)controller).topScrollView;
            [topScro selectIndexToController:idx];
            break;
        }
    }
    
    if (idx == 1 || idx == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RefreshCustomer object:nil];
    }
}

- (void)checkAction:(UIButton *)sender
{
    NSArray *array = [self.dataSource objectAtIndex:[sender tag] - 10];
    BOOL isFind = NO;
    
    if (_status == 1) {
        for (CustomerModel *info in array) {
            if ([info.finish_num integerValue] != [info.nums integerValue] || [info.finish_num integerValue] == 0 || [info.nums integerValue] == 0) {
                isFind = YES;
                break;
            }
            else {
                info.isSelected = !sender.selected;
            }
        }
        
        if (isFind) {
            [self.view makeToast:@"您还有档案没有制作完哦" duration:1.0 position:@"center"];
            return;
        }
    }
    
    sender.selected = !sender.selected;
    
    if (_status == 2) {
        for (CustomerModel *info in array) {
            if (info.isSelected != sender.selected) {
                info.isSelected = sender.selected;
                if (sender.selected) {
                    _totalPrice += [info.sale_price doubleValue] * info.print_num;
                }else {
                    _totalPrice -= [info.sale_price doubleValue] * info.print_num;
                }
            }
        }
        [_priceLabel setText:[NSString stringWithFormat:@"￥%0.2lf",_totalPrice]];
        
        BOOL is_all = NO;
        for (NSArray *arr in self.dataSource) {
            if (is_all) {
                break;
            }
            for (CustomerModel *info in arr) {
                if (!info.isSelected) {
                    is_all = YES;
                    break;
                }
            }
        }
        
        _allHoriBut.selected  = !is_all;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[sender tag] - 10] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Alipay delegate
- (void)refreshAlipayFinish:(id)sender
{
    [self relodCurrView:3];
}
#pragma mark - CustomerTableViewCell delegate
- (void)editActionsToSelf:(CustomerTableViewCell *)cell Index:(NSInteger)idx
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self setIndexActions:indexPath Index:idx];
}

- (void)orderInfo:(CustomerModel *)item
{
    PreviewWebViewController *order = [[PreviewWebViewController alloc] init];
    order.url = [NSString stringWithFormat:@"http://mall.goonbaby.com/moblie/times/print?user_id=%@&order_id=%@&type=orderDetail", [GlobalManager shareInstance].detailInfo.user.id, item.sys_order_num];
    order.recordItem = [TimeRecordModel new];
    [self.navigationController pushViewController:order animated:YES];
}

#pragma mark - PaymentTableViewCell delegate
- (void)editAddressToController:(PaymentTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    _indexPath = indexPath;
    
    [self getAddressRequest:NO];
}

- (void)isReloadSectionToController:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BOOL is_all = NO;
    for (NSArray *arr in self.dataSource) {
        if (is_all) {
            break;
        }
        
        for (CustomerModel *info in arr) {
            if (!info.isSelected) {
                is_all = YES;
                break;
            }
        }
    }
    
    if (_status == 2) {
        CustomerModel *info = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if (info.isSelected) {
            _totalPrice += ([info.sale_price doubleValue] * info.print_num);
        }else {
            _totalPrice -= ([info.sale_price doubleValue]  * info.print_num);
        }
        [_priceLabel setText:[NSString stringWithFormat:@"￥%.2lf",_totalPrice]];
        _allHoriBut.selected  = !is_all;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadPriceToController:(PaymentTableViewCell *)cell IsAdd:(BOOL)is_add
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CustomerModel *info = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (is_add) {
        _totalPrice += [info.sale_price doubleValue];
    }else {
        _totalPrice -= [info.sale_price doubleValue];
    }
    [_priceLabel setText:[NSString stringWithFormat:@"￥%0.2lf",_totalPrice]];
}

#pragma mark - PreviewWebViewController delegate
- (void)reloadToCustomerList:(CustomerModel *)item Idx:(NSInteger)idx
{
    _reloadItem = item;
    [self relodCurrView:idx];
}

#pragma mark - BeMadeTableViewCell delegate
- (void)editActionsToController:(BeMadeTableViewCell *)cell Index:(NSInteger)idx
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self setIndexActions:indexPath Index:idx];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSource objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *recordCellId =  (_status == 2) ? @"PaymentCellId" : ((_status == 1) ? @"BeMadeCellId" : @"CustomerCellId");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recordCellId];
    CustomerModel *info = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (_status == 1) {
        [(BeMadeTableViewCell *)cell setDelegate:self];
        [(BeMadeTableViewCell *)cell resetDataSource:info];
    }
    else if (_status == 2) {
        [(PaymentTableViewCell *)cell setDelegate:self];
        [(PaymentTableViewCell *)cell resetDataSource:info];
    }else {
        [(CustomerTableViewCell *)cell setDelegate:self];
        [(CustomerTableViewCell *)cell resetDataSource:info CurrState:_status];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomerModel *info = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([info.is_public integerValue] == 2 || ([info.is_print integerValue] == 1)) {
        TimeRecordModel *item = [[TimeRecordModel alloc] init];
        item.grow_id = info.grow_id;
        item.user_id = info.user_id;
        item.batch_id = info.batch_id;
        item.is_double = info.is_double;
        item.is_print = info.is_print;
        item.finish_num = [NSNumber numberWithInteger:[info.finish_num integerValue]];
        item.detail_num = [NSNumber numberWithInteger:[info.nums integerValue]];
        item.sys_order_num = info.sys_order_num;
        PreviewWebViewController *preview = [[PreviewWebViewController alloc] init];
        preview.url = [G_PLAYER_ADDRESS stringByAppendingString:[NSString stringWithFormat:@"book/b%@.htm",info.grow_id]];
        preview.recordItem = item;
        preview.delegate = self;
        preview.isLandscape = ([item.is_double integerValue] == 1);
        preview.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:preview animated:YES];
        /*
        if ([item.is_double integerValue] == 1) {
            preview.isLandscape = YES;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:preview] animated:YES completion:nil];
        }
        else {
            [self.navigationController pushViewController:preview animated:YES];
        }
         */
    }
    else {
        //制作
        BatchMakeViewController *batch = [BatchMakeViewController new];
        batch.batch_id = info.batch_id;
        batch.user_id = info.user_id;
        [self.navigationController pushViewController:batch animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *array = [self.dataSource objectAtIndex:section];
    CustomerModel *item = array.firstObject;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [headerView setBackgroundColor:(_status == 2) ? [UIColor whiteColor] : CreateColor(245, 245, 245)];
    [headerView setUserInteractionEnabled:YES];
    
    BOOL isfind_nar = NO;
    for (CustomerModel *info in [self.dataSource objectAtIndex:section]) {
        if (!info.isSelected) {
            isfind_nar = YES;
            break;
        }
    }
    
    CGFloat delt = 0;
    if (_status == 2 || _status == 1) {
        UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkBtn setFrame:CGRectMake(7.5, 0, 30, 30)];
        [checkBtn setImage:CREATE_IMG(@"cust_check") forState:UIControlStateNormal];
        [checkBtn setImage:CREATE_IMG(@"cust_checked") forState:UIControlStateSelected];
        checkBtn.selected = !isfind_nar;
        [checkBtn setImageEdgeInsets:UIEdgeInsetsMake(12.5, 7.5, 2.5, 7.5)];
        [checkBtn setTag:10 + section];
        [checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:checkBtn];
        delt = 25;
    }
    else {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"customer_beach")];
        [imgView setFrame:CGRectMake(15, 12.5, 15, 15)];
        [headerView addSubview:imgView];
        delt = 20;
    }
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + delt, 10, 150, 20)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setText:item.grow_name ?: @""];
    [nameLabel setFont:[UIFont systemFontOfSize:14]];
    [nameLabel setTextColor:CreateColor(100, 100, 100)];
    [headerView addSubview:nameLabel];
    
    if (_status < 2) {
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [addBtn setFrame:CGRectMake(SCREEN_WIDTH - 40, 0, 30, 30)];
        [addBtn setTitle:@"+" forState:UIControlStateNormal];
        [addBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, 5, 0, 5)];
        [addBtn setTitleColor:CreateColor(131, 84, 251) forState:UIControlStateNormal];
        [addBtn setTag:section + 1];
        [addBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
        [addBtn addTarget:self action:@selector(addActions:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:addBtn];
    }else if (_status == 2) {
        HorizontalButton *setAdressBtn = [HorizontalButton buttonWithType:UIButtonTypeSystem];
        setAdressBtn.imgSize = CGSizeMake(14, 14);
        setAdressBtn.textSize = CGSizeMake(86, 20);
        [setAdressBtn setFrame:CGRectMake(SCREEN_WIDTH - 110, 10, 100, 20)];
        [setAdressBtn setTitle:@"设置收货地址" forState:UIControlStateNormal];
        [setAdressBtn setImage:CREATE_IMG(@"cust_local") forState:UIControlStateNormal];
        [setAdressBtn setTitleColor:CreateColor(100, 100, 100) forState:UIControlStateNormal];
        [setAdressBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [setAdressBtn setTag:section + 1];
        [setAdressBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [setAdressBtn addTarget:self action:@selector(setAllAddress:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:setAdressBtn];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

@end
