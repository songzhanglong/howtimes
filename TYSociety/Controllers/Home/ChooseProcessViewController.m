//
//  ChooseProcessViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "ChooseProcessViewController.h"
#import "PublicScrollView.h"
#import "SelectPickViewCell.h"
#import "YWCMainViewController.h"
#import "CheckTemplateController.h"
#import "HomePageUserController.h"
#import "AddressBookViewController.h"

@interface ChooseProcessViewController ()<PublicScrollViewDelegate,SelectPickViewCellDelegate>
{
    NSMutableDictionary *_dataDictory;
    NSMutableDictionary *_selectDictory;
}

@end
@implementation ChooseProcessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"工艺选择";
    self.navigationController.navigationBar.translucent = NO;

    _dataDictory = [NSMutableDictionary dictionary];
    _selectDictory = [NSMutableDictionary dictionary];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self createTableHeaderView];
    [self createTableFooterView];
    [self getCraftRequest];
}

- (void)backToPreControl:(id)sender
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)createTableHeaderView{
    PublicScrollView *public = [[PublicScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 336 / 751)];
    public.delegate = self;
    [public setImagesArrayFromModel:@[@"/original/group1/M0E/00/E9/c-eohVdzabiIQ7HRAAVlTJ9k7VcAABXgwJ0sGkABWVk088.png"]];
    [self.tableView setTableHeaderView:public];
}

- (void)createTableFooterView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frameWidth, 40 + 22)];
    [footView setBackgroundColor:[UIColor whiteColor]];
    [footView setUserInteractionEnabled:YES];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(15, 22, footView.frameWidth - 30, 40)];
    [button setBackgroundColor:CreateColor(153, 125, 251)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [button addTarget:self action:@selector(comfigAction:) forControlEvents:UIControlEventTouchUpInside];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:5];
    [footView addSubview:button];
    [self.tableView setTableFooterView:footView];
}

- (void)comfigAction:(id)sender
{
    NSArray *array = [_selectDictory allValues];
    if ([array count] != 4) {
        [self.view makeToast:@"工艺选择没有选择全" duration:1.0 position:@"center"];
        return;
    }
    
    AddressBookViewController *addressBook = [[AddressBookViewController alloc] init];
    [self.navigationController pushViewController:addressBook animated:YES];
/*
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"chooseCraft"];
    [param setValue:_batch_id forKey:@"batch_id"];
    [param setValue:@"2" forKey:@"user_type"];
    
    NSDictionary *dic1 = [_selectDictory valueForKey:@"select_1"];
    [param setValue:[dic1 valueForKey:@"id"] forKey:@"size"];
    NSDictionary *dic2 = [_selectDictory valueForKey:@"select_2"];
    [param setValue:[dic2 valueForKey:@"id"] forKey:@"bookbinding"];
    NSDictionary *dic3 = [_selectDictory valueForKey:@"select_3"];
    [param setValue:[dic3 valueForKey:@"id"] forKey:@"type"];
    NSDictionary *dic4 = [_selectDictory valueForKey:@"select_4"];
    [param setValue:[dic4 valueForKey:@"id"] forKey:@"paper"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"template"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf submitFinish:error Data:data];
    }];
 */
}

/*
- (void)submitFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (error) {
        [self.view.window makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [[GlobalManager shareInstance] requestIndexConsumer];
        
        NSInteger tagCount = [_recommond.tags count];
        if (tagCount <= 0) {
            return;
        }
        
        YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
        mainVc.showFiltrate = YES;
        mainVc.titleLable.text = @"作品展示";
        for (NSInteger i = 0; i < tagCount; i++) {
            AdTags *adTag = _recommond.tags[i];
            
            YWCTitleVCModel *titleVcModel = [[YWCTitleVCModel alloc] init];
            titleVcModel.title = adTag.name;
            
            CheckTemplateController *checkTem = [[CheckTemplateController alloc] init];
            checkTem.batch_id = _batch_id;
            checkTem.tag_id = adTag.id;
            NSDictionary *dic = [_selectDictory valueForKey:@"select_1"];
            checkTem.size_id = [dic valueForKey:@"id"];
            checkTem.customers = self.dataSource;
            titleVcModel.viewController = checkTem;
            [mainVc.titleVcModelArray addObject:titleVcModel];
        }
        mainVc.initIdx = 0;
        mainVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mainVc animated:YES];
    }
}
*/

#pragma mark 规格信息
- (void)getCraftRequest
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getCraft"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"template"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf craftFinish:error Data:data];
    }];
}

- (void)craftFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (error) {
        [self.view.window makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [data valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSDictionary class]]) {
            _dataDictory = ret_data;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - SelectPickViewCellDelegate
- (void)pickChangeContent:(SelectPickViewCell *)cell Item:(NSMutableDictionary *)dictory
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [_selectDictory setValue:dictory forKey:[NSString stringWithFormat:@"select_%ld",(long)indexPath.section + 1]];
    if (indexPath.section == 2) {
        NSString *select_id = [dictory valueForKey:@"id"];
        NSMutableArray *tempArr = [NSMutableArray array];
        NSMutableArray *dataArr = [_dataDictory valueForKey:@"paper"];
        for (NSDictionary *dic in dataArr) {
            if ([[dic valueForKey:@"condition"] integerValue] == [select_id integerValue]) {
                [tempArr addObject:dic];
            }
        }
        SelectPickViewCell *to_cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        [to_cell restPickerDatas:tempArr];
    }
}

- (void)pickContentToTableHeiht:(SelectPickViewCell *)cell KeyboardHeight:(CGFloat)height
{
    CGRect cellRect = [self.view convertRect:cell.frame fromView:self.tableView];
    if (cellRect.size.width == 0) {
        return;
    }
    
    CGFloat diffence = (self.view.frame.size.height - cellRect.origin.y - cellRect.size.height) - height;
    if (diffence < 0) {
        
        CGRect tabRect = self.tableView.frame;
        [UIView animateWithDuration:0.1 animations:^{
            [self.tableView setFrame:CGRectMake(tabRect.origin.x, diffence, tabRect.size.width, tabRect.size.height)];
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *registerCell = @"CraftCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:registerCell];
    if (cell == nil) {

        cell = [[SelectPickViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:registerCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [(SelectPickViewCell *)cell setDelegate:self];
        
//        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 40)];
//        [backView setBackgroundColor:rgba(231, 225, 252, 1)];
//        [backView.layer setMasksToBounds:YES];
//        [backView.layer setCornerRadius:5];
//        [cell.contentView addSubview:backView];
//
//        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 70, 40)];
//        [nameLabel setBackgroundColor:[UIColor clearColor]];
//        [nameLabel setFont:[UIFont systemFontOfSize:14]];
//        [nameLabel setTextColor:CreateColor(100, 100, 100)];
//        [nameLabel setTag:1];
//        [cell.contentView addSubview:nameLabel];
//        
//        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frameRight + 15, 0, backView.frameWidth - nameLabel.frameRight - 15, backView.frameHeight)];
//        [detailLabel setBackgroundColor:[UIColor clearColor]];
//        [detailLabel setFont:[UIFont systemFontOfSize:14]];
//        [detailLabel setTextColor:[UIColor lightGrayColor]];
//        [detailLabel setTag:2];
//        [cell.contentView addSubview:detailLabel];
    }
    //UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    //UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:2];
    NSString *tip = @"";
    NSMutableArray *array = [NSMutableArray array];
    switch (indexPath.section) {
        case 0:
        {
            tip = @"产品规格：";
            NSMutableArray *tempArr = [_dataDictory valueForKey:@"size"];
            if (tempArr && [tempArr isKindOfClass:[NSMutableArray class]]) {
                array = tempArr;
            }
        }
            break;
        case 1:
        {
            tip = @"封装规格：";
            NSMutableArray *tempArr = [_dataDictory valueForKey:@"bookbinding"];
            if (tempArr && [tempArr isKindOfClass:[NSMutableArray class]]) {
                array = tempArr;
            }
        }
            break;
        case 2:
        {
            tip = @"封面类型：";
            NSMutableArray *tempArr = [_dataDictory valueForKey:@"type"];
            if (tempArr && [tempArr isKindOfClass:[NSMutableArray class]]) {
                array = tempArr;
            }
        }
            break;
        case 3:
        {
            tip = @"纸张类型：";
            NSMutableArray *tempArr = [_dataDictory valueForKey:@"paper"];
            if (tempArr && [tempArr isKindOfClass:[NSMutableArray class]]) {
                array = tempArr;
            }
        }
            break;

        default:
            break;
    }
    
    SelectPickViewCell *pickerCell = (SelectPickViewCell *)cell;
    pickerCell.tipLabel.text = tip;
    [pickerCell restPickerDatas:array];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

@end
