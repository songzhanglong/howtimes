//
//  CheckTemplateController.m
//  TYSociety
//
//  Created by szl on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CheckTemplateController.h"
#import "TimeRecordModel.h"
#import "TimeRecordCell.h"
#import "PageViewController.h"
#import "TimeRecordInfo.h"
#import "HomePageUserController.h"
#import "PreviewWebViewController.h"
#import "SizeReferenceViewController.h"

@interface CheckTemplateController ()<TimeRecordCellDelegate>
{
    TimeRecordModel *_selectItem;
}
@end

@implementation CheckTemplateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"作品展示";
    [self createRightBarButton];
    _numPerPage = 30;
    
    self.view.backgroundColor = PortfolioColor;
    [self createTableViewAndRequestAction:@"index" Param:nil Header:YES Foot:YES];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.silentAnimation = YES;
}

- (void)createTableHeaderView{
    if ([self.dataSource count] > 0) {
        if (self.tableView.tableHeaderView) {
            [self.tableView setTableHeaderView:nil];
        }
    }
    else{
        
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

- (void)createRightBarButton
{
    UIButton * backBtn = [[self.navigationItem.leftBarButtonItems lastObject] customView];
    
    UIFont *font = [UIFont systemFontOfSize:12.5];
    NSString *tipStr = @"尺寸参考";
    CGSize size = [NSString calculeteSizeBy:tipStr Font:font MaxWei:SCREEN_WIDTH];
    [backBtn setFrameWidth:size.width];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(6.5, 0, 6.5, size.width - 10)];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, size.width, size.height)];
    [rightBut setTitle:tipStr forState:UIControlStateNormal];
    [rightBut setTitleColor:rgba(239, 237, 243, 1) forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(referenceSize:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut.titleLabel setFont:font];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
}

#pragma mark - actions
- (void)referenceSize:(id)sender
{
    
}

#pragma mark - 接口配置
- (void)resetRequestParam
{
    NSMutableDictionary *param = [[GlobalManager shareInstance] requestinitParamsWith:@"queryGrowByTag"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_numPerPage] forKey:@"page_size"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageNo] forKey:@"page_num"];
    [param setObject:_tag_id forKey:@"tag_id"];
    [param setObject:_size_id ?: @"" forKey:@"craft_size"];
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
        self.dataSource = [TimeRecordModel arrayOfModelsFromDictionaries:dataList error:nil];
        
        [self.tableView reloadData];
    }
    [self createTableHeaderView];
}

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
        NSMutableArray *array = [TimeRecordModel arrayOfModelsFromDictionaries:dataList error:nil];
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
    [self createTableHeaderView];
}

#pragma mark - TimeRecordCellDelegate
- (void)selectTimeRecord:(id)record At:(UITableViewCell *)cell
{    
    TimeRecordModel *item = (TimeRecordModel *)record;
    _selectItem = item;
    
    PreviewWebViewController *preview = [[PreviewWebViewController alloc] init];
    preview.url = [G_PLAYER_ADDRESS stringByAppendingString:[NSString stringWithFormat:@"book/b%@.htm",item.grow_id]];
    preview.recordItem = item;
    preview.customers = _customers;
    
    preview.isLandscape = ([item.is_double integerValue] == 1);
    preview.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:preview animated:YES];
    /*
    if ([item.is_double integerValue] == 1) {
        preview.isLandscape = YES;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:preview] animated:YES completion:nil];
    }
    else {
        preview.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:preview animated:YES];
    }
     */
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataSource count] == 0) {
        return 0;
    }
    
    NSInteger rows = ([self.dataSource count] - 1) / 2 + 1; //每行3个
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *recordCellId = @"timeRecordCellId";
    TimeRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:recordCellId];
    if (cell == nil) {
        cell = [[TimeRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recordCellId];
        [cell setDelegate:self];
    }

    NSMutableArray *lastAr = [NSMutableArray array];
    NSInteger preIdx = indexPath.row * 2;
    NSInteger count = MIN(2, [self.dataSource count] - preIdx);
    for (NSInteger i = preIdx; i < count + preIdx; i++) {
        [lastAr addObject:self.dataSource[i]];
    }
    [cell resetTimeRecords:lastAr];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CGFloat xOri = 30,margin = 20,itemWei = (SCREEN_WIDTH - xOri * 2 - margin * 2) / 3,itemHei = itemWei * 4 / 3;
    //return 30 + itemHei + 8;
    CGFloat itemHei = 75 * 4 / 3 * SCREEN_WIDTH / 375;
    return 15 * SCREEN_WIDTH / 375 + itemHei + 8;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
