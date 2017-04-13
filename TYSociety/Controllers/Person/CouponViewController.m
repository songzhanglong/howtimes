//
//  CouponViewController.m
//  TYSociety
//
//  Created by szl on 16/7/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CouponViewController.h"
#import "CouponItemModel.h"
#import "CouponTableViewCell.h"
#import "ActivityViewController.h"

@interface CouponViewController ()

@end

@implementation CouponViewController
{
    CGFloat _imgWei,_imgHei;
    NSInteger _pageIdx,_pageCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.silentAnimation = YES;
    [self.view setBackgroundColor:rgba(236, 235, 243, 1)];
    //688 134
    _imgWei = 344,_imgHei = 67;
    _pageCount = 30;
    [self createTableViewAndRequestAction:@"coupon" Param:nil Header:YES Foot:YES];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"couponCellId"];
    [self.tableView registerClass:[CouponTableViewCell class] forCellReuseIdentifier:@"couponCellId2"];
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        if (self.tableView.tableHeaderView) {
            [self.tableView setTableHeaderView:nil];
        }
    }
    else{
        CGFloat margin = (SCREEN_HEIGHT - 64 - 44 - 155) / 2;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, margin + 155)];
        [headView setUserInteractionEnabled:YES];
        [headView setBackgroundColor:self.tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, margin, 65, 80)];
        imgView.image = CREATE_IMG(@"order_default");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 5, SCREEN_WIDTH - 80, 20)];
        [label setTextAlignment:1];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"无优惠信息"];
        [headView addSubview:label];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, label.frameBottom + 5, SCREEN_WIDTH - 80, 20)];
        [tipLabel setTextAlignment:1];
        [tipLabel setFont:[UIFont systemFontOfSize:10]];
        [tipLabel setTextColor:CreateColor(86, 86, 86)];
        [tipLabel setText:@"去活动页面看看吧~"];
        [headView addSubview:tipLabel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((SCREEN_WIDTH - 80) / 2, tipLabel.frameBottom + 5, 80, 20)];
        [btn setTitle:@"去看看" forState:UIControlStateNormal];
        [btn setTitleColor:CreateColor(86, 86, 86) forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5];
        [btn.layer setBorderWidth:1];
        [btn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [headView addSubview:btn];
        
        [self.tableView setTableHeaderView:headView];
    }
}

- (void)buttonPressed:(id)sender
{
    ActivityViewController *activity = [[ActivityViewController alloc] init];
    activity.showBack = YES;
    [self.navigationController pushViewController:activity animated:YES];
}

#pragma mark - 接口配置
- (void)resetRequestParam
{
    UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
    NSMutableDictionary *param = [[GlobalManager shareInstance] requestinitParamsWith:@"queryUserCoupon"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"page_size"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page_num"];
    [param setObject:detail.token forKey:@"token"];
    [param setObject:_status.stringValue forKey:@"status"];
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
    _pageIdx = 1;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    if ([self.dataSource count] > 0) {
        _pageIdx++;
    }
    [super startPullRefresh2];
}

- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSInteger pages = [[ret_data valueForKey:@"page_count"] integerValue];
        if (pages <= _pageIdx) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        NSArray *dataList = [ret_data valueForKey:@"data"];
        self.dataSource = [CouponItemModel arrayOfModelsFromDictionaries:dataList error:nil];
        
        [self.tableView reloadData];
    }
    [self createTableFooterView];
}

- (void)requestFinish2:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSInteger pages = [[ret_data valueForKey:@"page_count"] integerValue];
        if (pages <= _pageIdx) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else{
            [self finishRefresh];
        }
        
        NSArray *dataList = [ret_data valueForKey:@"data"];
        NSMutableArray *array = [CouponItemModel arrayOfModelsFromDictionaries:dataList error:nil];
        if (self.dataSource) {
            [self.dataSource addObjectsFromArray:array];
        }
        else{
            self.dataSource = array;
        }
        
        [self.tableView reloadData];
    }
    else{
        [self finishRefresh];
    }
    [self createTableFooterView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *couponCellId = ([_status integerValue] == 2) ? @"couponCellId2" : @"couponCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:couponCellId forIndexPath:indexPath];
    if ([_status integerValue] == 2) {
        //
        CouponItemModel *model = [self.dataSource objectAtIndex:indexPath.section];
        [(CouponTableViewCell *)cell resetCouponDatas:model];
    }else {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - _imgWei) / 2, 0, _imgWei, _imgHei)];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setClipsToBounds:YES];
            [imageView setTag:1];
            [imageView setImage:CREATE_IMG(@"couponH")];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            [cell.contentView addSubview:imageView];
        }
        
        CouponItemModel *model = [self.dataSource objectAtIndex:indexPath.section];
        NSString *url = model.coupon_url;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        [imageView sd_setImageWithURL:[NSURL URLWithString:url]placeholderImage:CREATE_IMG(@"couponH")];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_status integerValue] == 2) ? 255 : _imgHei;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

@end
