//
//  ActivityViewController.m
//  TYSociety
//
//  Created by szl on 16/8/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "ActivityViewController.h"
#import "ActivityModel.h"
#import "PreviewWebViewController.h"
#import "LoginViewController.h"
#import "NavigationController.h"

@interface ActivityViewController ()
{
    NSString *_currToken;
}
@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLable.text = @"活动";
    self.navigationController.navigationBar.translucent = NO;
    
    GlobalManager *manager = [GlobalManager shareInstance];
    _currToken = manager.detailInfo.token;
    
    [self createTableViewAndRequestAction:@"active" Param:nil Header:YES Foot:NO];
    self.silentAnimation = YES;
}

- (void)resetRequestParam
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:(_indexType == 1) ? @"queryMyActive" : @"queryActive"];
    [param setValue:_currToken ?: @"" forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.param = param;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    GlobalManager *manager = [GlobalManager shareInstance];
    if ([_currToken length] > 0 && [_currToken isEqualToString:manager.detailInfo.token]) {
        return;
    }
    _currToken = manager.detailInfo.token;
//    
//    if (self.isViewLoaded) {
//        [self beginRefresh];
//    }
}

#pragma mark - 网络请求结束
- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [NSMutableArray array];
        if (_indexType == 1) {
            id active = [ret_data valueForKey:@"myActive"];
            if (active && [active isKindOfClass:[NSArray class]]) {
                array = [ActivityModel arrayOfModelsFromDictionaries:active error:nil];
            }
        }
        else {
            id active = [ret_data valueForKey:@"active"];
            if (active && [active isKindOfClass:[NSArray class]]) {
                array = [ActivityModel arrayOfModelsFromDictionaries:active error:nil];
            }
        }
        self.dataSource = array;
        
        [self.tableView reloadData];
    }
    [self createTableFooterView];
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        if (self.tableView.tableHeaderView) {
            [self.tableView setTableHeaderView:nil];
        }
    }
    else{
        CGFloat margin = 100;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, margin + 96)];
        [headView setBackgroundColor:self.tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, margin, 65, 80)];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *homeBaseCellId = @"ActivityCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:homeBaseCellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:homeBaseCellId];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        //imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [imageView setTag:1];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.contentView addSubview:imageView];
        
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH * 200 / 375 - 24, SCREEN_WIDTH, 24)];
        [tipView setBackgroundColor:[UIColor blackColor]];
        [tipView setAlpha:0.4];
        [cell.contentView addSubview:tipView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, SCREEN_WIDTH * 200 / 375 - 24, SCREEN_WIDTH - 120, 24)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        [nameLabel setTag:2];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *cyLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frameRight, SCREEN_WIDTH * 200 / 375 - 24, 100, 24)];
        [cyLabel setBackgroundColor:[UIColor clearColor]];
        [cyLabel setTextColor:[UIColor whiteColor]];
        [cyLabel setFont:[UIFont systemFontOfSize:14]];
        [cyLabel setTextAlignment:NSTextAlignmentRight];
        [cyLabel setText:@"立即参与>"];
        [cell.contentView addSubview:cyLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ActivityModel *model = self.dataSource[indexPath.section];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    NSString *str = model.active_pic;
    if (![str hasPrefix:@"http"]) {
        str = [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
    }
    [imageView sd_setImageWithURL:[NSURL URLWithString:str]];
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    [nameLabel setText:[NSString stringWithFormat:@"已有%@人参与",model.user_nums]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
    if (detail) {
        ActivityModel *item = self.dataSource[indexPath.section];
        if (item.url.length == 0) {
            [self.view makeToast:@"精彩即将开始,敬请期待" duration:1.0 position:@"center"];
            return;
        }
        
        TimeRecordModel *model = [[TimeRecordModel alloc] init];
        PreviewWebViewController *preview = [[PreviewWebViewController alloc] init];
        preview.url = item.url;
        preview.recordItem = model;
        preview.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:preview animated:YES];
    }
    else{
        [self presentViewController:[[NavigationController alloc] initWithRootViewController:[LoginViewController new]] animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH * 200 / 375;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

@end
