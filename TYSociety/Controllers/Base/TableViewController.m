//
//  DJTTableViewVC.m
//  TY
//
//  Created by songzhanglong on 14-5-28.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "TableViewController.h"
#import "ShapeLoadingView.h"
#import "Masonry.h"

@interface TableViewController ()

@property (nonatomic,strong)UIView *loadingView;

@end

@implementation TableViewController

#pragma mark - Animation
- (void)dealloc
{
    [self stopAnimation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_silentAnimation) {
        //此处请求参数必须正常设置
        _silentAnimation = NO;
        [self startAnimation];
        [self startPullRefresh];
    }
}

#pragma mark - Animation
- (void)startAnimation
{
    if (_loadingView) {
        return;
    }
    [self.view addSubview:self.loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(100));
        make.height.equalTo(@(120));
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
}

- (void)stopAnimation
{
    if (_loadingView) {
        ShapeLoadingView *shapeView = [_loadingView viewWithTag:1];
        [shapeView stopAnimating];
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

#pragma mark - UITableView && UICollectionView
/**
 *	@brief	创建表和网络请求
 *
 *	@param 	action 	接口动作类型
 *	@param 	param 	接口参数
 *	@param 	header 	下拉
 *	@param 	foot 	上拉
 */
- (void)createTableViewAndRequestAction:(NSString *)action Param:(NSDictionary *)param Header:(BOOL)header Foot:(BOOL)foot
{
    self.param = param;
    self.action = action;
    
    //data source
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = self.view.backgroundColor;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:footView];
    [self.view addSubview:_tableView];
    
    if (header) {
        _tableView.mj_header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(startPullRefresh)];
    }
    if (foot) {
        _tableView.mj_footer = [MJChiBaoZiFooter2 footerWithRefreshingTarget:self refreshingAction:@selector(startPullRefresh2)];
    }
}

- (void)createCollectionViewLayout:(UICollectionViewLayout *)layout Action:(NSString *)action Param:(NSDictionary *)param Header:(BOOL)header Foot:(BOOL)foot
{
    self.param = param;
    self.action = action;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = self.view.backgroundColor;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_collectionView];
    
    if (header) {
        _collectionView.mj_header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(startPullRefresh)];
    }
    if (foot) {
        _collectionView.mj_footer = [MJChiBaoZiFooter2 footerWithRefreshingTarget:self refreshingAction:@selector(startPullRefresh2)];
    }
}

#pragma mark - 下拉，上拉刷新
- (BOOL)isHeaderRefreshing{
    if (_tableView && (_tableView.mj_header.isRefreshing || _tableView.mj_footer.isRefreshing)) {
        return YES;
    }
    else if (_collectionView && (_collectionView.mj_header.isRefreshing || _collectionView.mj_footer.isRefreshing)){
        return YES;
    }
    
    return NO;
}

/**
 *	@brief	开始刷新
 */
- (void)beginRefresh
{
    if (_tableView.mj_header) {
        [_tableView.mj_header beginRefreshing];
    }
    else if (_collectionView.mj_header) {
        [_collectionView.mj_header beginRefreshing];
    }
}

/**
 *	@brief	结束下拉刷新
 */
- (void)finishRefresh
{
    if (_tableView.mj_header.isRefreshing) {
        [_tableView.mj_header endRefreshing];
    }
    
    if (_tableView.mj_footer.isRefreshing) {
        [_tableView.mj_footer endRefreshing];
    }
    
    if (_collectionView.mj_header.isRefreshing) {
        [_collectionView.mj_header endRefreshing];
    }
    
    if (_collectionView.mj_footer.isRefreshing) {
        [_collectionView.mj_footer endRefreshing];
    }
}

- (BOOL)isRefreshing
{
    return _tableView.mj_header.isRefreshing || _tableView.mj_footer.isRefreshing || _collectionView.mj_header.isRefreshing || _collectionView.mj_footer.isRefreshing;
}

/**
 *	@brief	重置请求参数，子类覆盖
 */
- (void)resetRequestParam
{
    
}

- (BOOL)canBeginToRequest{
    //重置请求参数
    [self resetRequestParam];
    
    if (!_action || !_param) {
        [self finishRefresh];
        return NO;
    }
    
    return YES;
}

/**
 *	@brief	开始刷新
 */
- (void)startPullRefresh
{
    if (![self canBeginToRequest]) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:_action];
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:_param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf requestFinish:error Data:data];
        });
    }];
}

- (void)startPullRefresh2
{
    if (_tableView && _tableView.mj_header.isRefreshing) {
        [_tableView.mj_footer endRefreshing];
        return;
    }
    else if (_collectionView && _collectionView.mj_header.isRefreshing){
        [_collectionView.mj_footer endRefreshing];
        return;
    }
    
    if (![self canBeginToRequest]) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:_action];
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:_param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf requestFinish2:error Data:data];
        });
    }];
}

#pragma mark - 网络请求结束
/**
 *	@brief	数据请求结果
 *
 *	@param 	success 	yes－成功
 *	@param 	result 	服务器返回数据
 */
- (void)requestFinish:(NSError *)error Data:(id)result
{
    [self stopAnimation];
    [self.view setUserInteractionEnabled:YES];
    self.sessionTask = nil;
    [self finishRefresh];
    
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    
}

- (void)requestFinish2:(NSError *)error Data:(id)result
{
    [self stopAnimation];
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.sessionTask = nil;
    [self finishRefresh];
    
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return nil;
}

#pragma mark - lazy loading
- (UIView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] init];
        [_loadingView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_loadingView setBackgroundColor:self.view.backgroundColor];
        
        ShapeLoadingView *shapeView = [[ShapeLoadingView alloc] initWithFrame:CGRectMake(0, 0, 100, 120) title:@"加载中..."];
        [shapeView setTag:1];
        shapeView.backgroundColor = _loadingView.backgroundColor;
        [shapeView startAnimating];
        [_loadingView addSubview:shapeView];
    }
    return _loadingView;
}

@end
