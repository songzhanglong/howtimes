//
//  HomePageViewController.m
//  TYSociety
//
//  Created by szl on 16/6/28.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "HomePageViewController.h"
#import "HomeRecommond.h"
#import "PublicScrollView.h"
#import "UserInfoViewController.h"
#import "LoginViewController.h"
#import "CheckTemplateController.h"
#import "YWCMainViewController.h"
#import "HomePageUserController.h"
#import "MyPortfolioViewController.h"
#import "PreviewWebViewController.h"
#import "DJTOrderViewController.h"
#import "NavigationController.h"

@interface HomePageViewController ()<PublicScrollViewDelegate>

@property (nonatomic,strong)NSDictionary *curDic;

@end

@implementation HomePageViewController
{
    BOOL _hasLoaded;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserPorfile object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createRightBarButton];
    self.titleLable.text = @"好时光";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAd"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self createTableViewAndRequestAction:@"index" Param:param Header:YES Foot:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserPorfile:) name:UserPorfile object:nil];
    
    //初始数据
    [self dealWithInitTableDataSource];
    
    //尺寸
    [self getCraftRequest];
}

#pragma mark - 初始数据
- (void)dealWithInitTableDataSource
{
    //文件存储
    NSString *jsPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",NSStringFromClass([HomePageViewController class])]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:jsPath]) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:jsPath];
        self.curDic = dic;
        HomeRecommond *recommond = [[HomeRecommond alloc] initWithDictionary:dic error:nil];
        self.recommond = recommond;
        self.dataSource = recommond.tmplate_tag;
        [self createTableHeaderView];
    }
    else{
        NSString *resource = [[NSBundle mainBundle] pathForResource:NSStringFromClass([HomePageViewController class]) ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:resource];
        self.curDic = dic;
        HomeRecommond *recommond = [[HomeRecommond alloc] initWithDictionary:dic error:nil];
        self.recommond = recommond;
        self.dataSource = recommond.tmplate_tag;
        [self createTableHeaderView];
    }
    //保证数据最新
    [self startPullRefresh];
}

#pragma mark - UI
- (void)createRightBarButton
{
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 22, 47.0/3)];
    [rightBut setImage:CREATE_IMG(@"home_user") forState:UIControlStateNormal];
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(userInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
}

- (void)userInfoAction:(id)sender
{
    UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
    if (detail) {
        UserInfoViewController *userController = [[UserInfoViewController alloc] init];
        userController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userController animated:YES];
    }
    else{
        [self presentViewController:[[NavigationController alloc] initWithRootViewController:[LoginViewController new]] animated:YES completion:nil];
    }
}

- (void)createTableHeaderView{
    if ([_recommond.ad.ad_1 count] > 0) {
        if (self.tableView.tableHeaderView && [self.tableView.tableHeaderView isKindOfClass:[PublicScrollView class]]) {
            [(PublicScrollView *)self.tableView.tableHeaderView clearTimer];
        }
        
        NSMutableArray *array = [NSMutableArray array];
        PublicScrollView *public = [[PublicScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 400 / 750)];
        public.delegate = self;
        for (NSInteger i = 0;i < [_recommond.ad.ad_1 count];i++) {
            ADItem *item = [_recommond.ad.ad_1 objectAtIndex:i];
            [array addObject:item.picture];
        }
        [public setImagesArrayFromModel:array];
        [self.tableView setTableHeaderView:public];
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

#pragma mark - Appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
    if (detail) {
        if (detail.isDealer.integerValue == 1 || [detail.profiles count] > 0) {
            HomePageUserController *homeUser = [HomePageUserController new];
            homeUser.recommond = _recommond;
            [self.navigationController pushViewController:homeUser animated:NO];
        }
        return;
    }
    
    if (_hasLoaded) {
        PublicScrollView *scro = (PublicScrollView *)self.tableView.tableHeaderView;
        if (scro && [scro isKindOfClass:[PublicScrollView class]]) {
            [scro resetTimer];
        }
    }
    else{
        _hasLoaded = YES;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    PublicScrollView *scro = (PublicScrollView *)self.tableView.tableHeaderView;
    if (scro && [scro isKindOfClass:[PublicScrollView class]]) {
        [scro clearTimer];
    }
}

#pragma mark - UserPorfile
- (void)refreshUserPorfile:(NSNotification *)notifi
{
    if ([self.navigationController.viewControllers count] == 1) {
        UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
        if (detail) {
            if (detail.isDealer.integerValue == 0 && [detail.profiles count] > 0) {
                HomePageUserController *homeUser = [HomePageUserController new];
                homeUser.recommond = _recommond;
                [self.navigationController pushViewController:homeUser animated:NO];
            }
        }
    }
}

#pragma mark - PublicScrollViewDelegate
- (void)touchImageAtIndex:(NSInteger)index ScrollView:(PublicScrollView *)pubSro
{
    ADItem *item = _recommond.ad.ad_1[index];
    if ([item.param.is_login integerValue] == 1) {
        UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
        if (!detail) {
            [self presentViewController:[[NavigationController alloc] initWithRootViewController:[LoginViewController new]] animated:YES completion:nil];
            return;
        }
    }
    
    if (item.url.length > 0) {
        TimeRecordModel *record = [[TimeRecordModel alloc] init];
        record.grow_id = item.param.grow_id;
        record.user_id = item.param.user_id;
        record.batch_id = item.param.batch_id;
        record.is_double = item.param.is_double;
        PreviewWebViewController *preview = [[PreviewWebViewController alloc] init];
        preview.url = item.url;
        preview.recordItem = record;
        preview.isLandscape = ([item.param.is_double integerValue] == 1);
        preview.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:preview animated:YES];
        /*
        if ([item.param.is_double integerValue] == 1) {
            preview.isLandscape = YES;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:preview] animated:YES completion:nil];
        }
        else {
            preview.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:preview animated:YES];
        }
         */
    }
    else{
        [self.view makeToast:@"还没有配置地址哦" duration:1.0 position:@"center"];
    }
}

#pragma mark - Craft
- (void)getCraftRequest
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getCraft"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"template"];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf craftFinish:error Data:data];
    }];
}

- (void)craftFinish:(NSError *)error Data:(id)data
{
    if (error == nil) {
        id ret_data = [data valueForKey:@"ret_data"];
        NSMutableArray *page = [ret_data valueForKey:@"page_num"];
        if (page && [page isKindOfClass:[NSArray class]]) {
            [[GlobalManager shareInstance] setGzPages:page];
        }
        
        NSMutableArray *size = [ret_data valueForKey:@"size"];
        if (size && [size isKindOfClass:[NSArray class]]) {
            [[GlobalManager shareInstance] setSizeReferences:size];
        }
    }
}

#pragma mark - 网络请求结束
- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    if (error == nil) {
        NSDictionary *ret_data = [result valueForKey:@"ret_data"];
        if (![ret_data isKindOfClass:[NSDictionary class]] || [_curDic isEqualToDictionary:ret_data]) {
            return;
        }
        self.curDic = ret_data;
        //文件存储
        NSString *jsPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",NSStringFromClass([HomePageViewController class])]];
        HomeRecommond *recommond = [[HomeRecommond alloc] initWithDictionary:ret_data error:nil];
        self.recommond = recommond;
        self.dataSource = recommond.tmplate_tag;
        
        [self.tableView reloadData];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [ret_data writeToFile:jsPath atomically:NO];
        });
    }
    [self createTableHeaderView];
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
    static NSString *homeBaseCellId = @"homeBaseCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:homeBaseCellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:homeBaseCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        //imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        //[imageView setContentMode:UIViewContentModeScaleAspectFill];
        //[imageView setClipsToBounds:YES];
        [imageView setTag:1];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.contentView addSubview:imageView];
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    RecommondItem *item = self.dataSource[indexPath.section];
    NSString *str = item.picture;
    if (![str hasPrefix:@"http"]) {
        str = [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
    }
    [imageView sd_setImageWithURL:[NSURL URLWithString:str]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger tagCount = [_recommond.tags count];
    if (tagCount <= 0) {
        return;
    }
    
    RecommondItem *item = self.dataSource[indexPath.section];
    
    NSInteger curIdx = NSNotFound;
    //找索引
    for (NSInteger i = 0; i < tagCount; i++) {
        AdTags *adTag = _recommond.tags[i];
        if ([adTag.id integerValue] == item.tag_id.integerValue) {
            curIdx = i;
            if (adTag.status.integerValue == 0) {
                [self.navigationController.view makeToast:@"精彩即将开始,敬请期待" duration:1.0 position:@"center"];
                return;
            }
            break;
        }
    }
    
    if (curIdx == NSNotFound) {
        [self.navigationController.view makeToast:@"精彩即将开始,敬请期待" duration:1.0 position:@"center"];
        return;
    }
    
    YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
    mainVc.showFiltrate = YES;
    mainVc.titleLable.text = @"作品展示";
    for (NSInteger i = 0; i < tagCount; i++) {
        AdTags *adTag = _recommond.tags[i];
        if (adTag.status.integerValue == 0) {
            if (i < curIdx) {
                curIdx--;
            }
            continue;
        }
        YWCTitleVCModel *titleVcModel = [[YWCTitleVCModel alloc] init];
        titleVcModel.title = adTag.name;
        
        CheckTemplateController *checkTem = [[CheckTemplateController alloc] init];
        checkTem.tag_id = adTag.id;
        titleVcModel.viewController = checkTem;
        [mainVc.titleVcModelArray addObject:titleVcModel];
    }
    
    mainVc.initIdx = curIdx;
    mainVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mainVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH * 156 / 375;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

@end
