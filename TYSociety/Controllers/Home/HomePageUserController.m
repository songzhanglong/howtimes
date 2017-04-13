//
//  HomePageUserController.m
//  TYSociety
//
//  Created by szl on 16/7/18.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "HomePageUserController.h"
#import "HomeRecommond.h"
#import "PublicScrollView.h"
#import "VerticalButton.h"
#import "UIButton+WebCache.h"
#import "HomePortfolioViewController.h"
#import "StoryViewController.h"
#import "RecommendViewController.h"
#import "YWCMainViewController.h"
#import "CreateCustomerViewController.h"
#import "DJTOrderViewController.h"
#import "CheckTemplateController.h"
#import "PreviewWebViewController.h"

@interface HomePageUserController ()<PublicScrollViewDelegate,YWCMainViewControllerDelegate>

@end

@implementation HomePageUserController
{
    CGPoint _prePoint,_offPoint;
    BOOL _shouleReset,_hasLoaded;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USER_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ScrollToTop object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"我的书柜";
    [[[self.navigationItem.leftBarButtonItems lastObject] customView] setHidden:YES];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollviewToTop:) name:ScrollToTop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginOut:) name:USER_LOGOUT object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    [self createTableHeaderView];
}

- (void)createTableHeaderView{
    if (self.tableView.tableHeaderView) {
        return;
    }
    
    UIView *headView = [[UIView alloc] init];
    CGFloat hei = 0;
    //ad_1
    if ([_recommond.ad.ad_1 count] > 0) {
        PublicScrollView *public = [[PublicScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 400 / 750)];
        public.delegate = self;
        [public setTag:101];
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = 0;i < [_recommond.ad.ad_1 count];i++) {
            ADItem *item = [_recommond.ad.ad_1 objectAtIndex:i];
            [array addObject:item.picture];
        }
        [public setImagesArrayFromModel:array];
        [headView addSubview:public];
        
        hei += public.frameHeight;
    }
    
    //标签
    if ([_recommond.tags count]) {
        CGFloat scrollHei = 160;
        UIScrollView *middleScro = [[UIScrollView alloc] initWithFrame:CGRectMake(0, hei, SCREEN_WIDTH, scrollHei)];
        [middleScro setBackgroundColor:rgba(249, 249, 251, 1)];
        middleScro.showsHorizontalScrollIndicator = NO;
        middleScro.pagingEnabled = YES;
        
        //tags
        NSInteger numPerPage = 10,allTagsCount = [_recommond.tags count];
        CGFloat margin = 5,textHei = 15,itemWei = 45,itemHei = 65,yOri = (scrollHei - itemHei * 2) / 4,xOri = (SCREEN_WIDTH - itemWei * numPerPage / 2) / (numPerPage / 2 + 1);
        for (NSInteger i = 0; i < allTagsCount; i++) {
            AdTags *adt = [_recommond.tags objectAtIndex:i];
            NSInteger page = i / numPerPage;
            NSInteger min = i % numPerPage;
            NSInteger row = min / (numPerPage / 2);
            NSInteger col = min % (numPerPage / 2);
            CGRect rect = CGRectMake(xOri + (itemWei + xOri) * col + page * SCREEN_WIDTH, yOri + (itemHei + yOri * 2) * row, itemWei, itemHei);
            VerticalButton *button = [VerticalButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:rect];
            [button setTag:10 + i];
            button.imgSize = CGSizeMake(itemWei, itemWei);
            button.textSize = CGSizeMake(itemWei, textHei);
            button.margin = margin;
            NSString *path = adt.logo;
            if (![path hasPrefix:@"http"]) {
                path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
            }
            [button sd_setImageWithURL:[NSURL URLWithString:path] forState:UIControlStateNormal];
            [button setTitle:adt.name forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [button setTitleColor:rgba(97, 97, 97, 1) forState:UIControlStateNormal];
            [button setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
            [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [button addTarget:self action:@selector(checkLabel:) forControlEvents:UIControlEventTouchUpInside];
            [middleScro addSubview:button];
        }
        
        NSInteger page = ((allTagsCount - 1) / numPerPage + 1);
        [middleScro setContentSize:CGSizeMake(SCREEN_WIDTH * page, scrollHei)];
        [headView addSubview:middleScro];
        
        hei += scrollHei;
    }
    
    //ad_2
    NSInteger ad2Count = [_recommond.ad.ad_2 count];
    if (ad2Count > 0) {
        PublicScrollView *public = [[PublicScrollView alloc] initWithFrame:CGRectMake(0, hei, SCREEN_WIDTH, SCREEN_WIDTH * 184 / 750)];
        public.delegate = self;
        [public setTag:102];
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = 0;i < ad2Count;i++) {
            ADItem *item = [_recommond.ad.ad_2 objectAtIndex:i];
            [array addObject:item.picture];
        }
        [public setImagesArrayFromModel:array];
        [headView addSubview:public];
        
        hei += public.frameHeight;
    }
    
    [headView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, hei)];
    [self.tableView setTableHeaderView:headView];
}

#pragma mark - publicscrollview timer
- (void)publicTimerSet:(BOOL)reset
{
    PublicScrollView *scro1 = [self.tableView.tableHeaderView viewWithTag:101];
    PublicScrollView *scro2 = [self.tableView.tableHeaderView viewWithTag:102];
    if (scro1 && [scro1 isKindOfClass:[PublicScrollView class]]) {
        if (reset) {
            [scro1 resetTimer];
        }
        else{
            [scro1 clearTimer];
        }
    }
    if (scro2 && [scro2 isKindOfClass:[PublicScrollView class]]) {
        if (reset) {
            [scro2 resetTimer];
        }
        else{
            [scro2 clearTimer];
        }
    }
}

#pragma mark - notice
- (void)userLoginOut:(NSNotification *)notifi
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_hasLoaded) {
        [self publicTimerSet:YES];
    }
    else{
        _hasLoaded = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_shouleReset) {
        _shouleReset = NO;
        [self.tableView setContentOffset:_offPoint animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self publicTimerSet:NO];
    
    _offPoint = self.tableView.contentOffset;
    _shouleReset = YES;
}

#pragma mark - actions
- (void)checkLabel:(id)sender
{
    NSInteger index = [sender tag] - 10;
    AdTags *curTag = _recommond.tags[index];
    if (curTag.status.integerValue == 0) {
        [self.navigationController.view makeToast:@"精彩即将开始,敬请期待" duration:1.0 position:@"center"];
        return;
    }
    
    NSMutableArray *customers = [NSMutableArray array];
    for (id controller in [self childViewControllers]) {
        if ([controller isKindOfClass:[YWCMainViewController class]]) {
            CreateCustomerViewController *customer = (CreateCustomerViewController *)((YWCTitleVCModel *)(((YWCMainViewController *)controller).titleVcModelArray[0])).viewController;
            customers = customer.dataSource;
            
            break;
        }
    }
    YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
    mainVc.showFiltrate = YES;
    mainVc.titleLable.text = @"作品展示";
    NSInteger tagCount = [_recommond.tags count];
    NSInteger idx = index;
    for (NSInteger i = 0; i < tagCount; i++) {
        AdTags *adTag = _recommond.tags[i];
        if (adTag.status.integerValue == 0) {
            if (i < index) {
                idx--;
            }
            continue;
        }
        YWCTitleVCModel *titleVcModel = [[YWCTitleVCModel alloc] init];
        titleVcModel.title = adTag.name;
        
        CheckTemplateController *checkTem = [[CheckTemplateController alloc] init];
        checkTem.tag_id = adTag.id;
        checkTem.customers = customers;
        titleVcModel.viewController = checkTem;
        [mainVc.titleVcModelArray addObject:titleVcModel];
    }
    mainVc.initIdx = idx;
    mainVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mainVc animated:YES];
}

#pragma mark - 手势控制
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        _prePoint = [panGestureRecognizer locationInView:self.view];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [panGestureRecognizer locationInView:self.view];
        //偏移距离
        CGFloat diff = point.y - _prePoint.y;
        CGFloat tableHei = self.tableView.tableHeaderView.frameHeight;
        
        //到底，判断内容
        YWCMainViewController *main = [[self childViewControllers] lastObject];
        YWCTitleVCModel *model = [main.titleVcModelArray objectAtIndex:main.topScrollView.selectedIndex];
        TableViewController *viewController = (TableViewController *)model.viewController;
        CGFloat bottomOffsetY = viewController.tableView.contentSize.height - viewController.tableView.frameHeight;
        CGPoint subOffset = viewController.tableView.contentOffset,curOffset = self.tableView.contentOffset;
        if (diff > 0) {
            subOffset.y -= diff;
            //下拉
            if (subOffset.y > 0) {
                [viewController.tableView setContentOffset:subOffset animated:NO];
            }
            else{
                [viewController.tableView setContentOffset:CGPointMake(subOffset.x, 0) animated:NO];
                [self.tableView setContentOffset:CGPointMake(curOffset.x, curOffset.y + subOffset.y) animated:NO];
            }
        }
        else{
            //首先tableview拉到底
            curOffset.y -= diff;
            if (curOffset.y <= tableHei) {
                [self.tableView setContentOffset:curOffset animated:NO];
            }
            else{
                subOffset.y += curOffset.y - tableHei;
                //上拉
                if (subOffset.y > bottomOffsetY ) {
                    [viewController.tableView setContentOffset:CGPointMake(subOffset.x, bottomOffsetY) animated:NO];
                    [self.tableView setContentOffset:CGPointMake(curOffset.x, tableHei + subOffset.y - bottomOffsetY) animated:NO];
                }
                else{
                    [viewController.tableView setContentOffset:subOffset animated:NO];
                    [self.tableView setContentOffset:CGPointMake(curOffset.x, tableHei) animated:NO];
                }
            }
        }
        
        _prePoint = point;
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint offset = self.tableView.contentOffset;
        if (offset.y < 0) {
            offset.y = 0;
        }
        else if (offset.y > self.tableView.tableHeaderView.frameHeight)
        {
            offset.y = self.tableView.tableHeaderView.frameHeight;
        }
        [self.tableView setContentOffset:offset animated:YES];
    }
}

#pragma mark - PublicScrollViewDelegate
- (void)touchImageAtIndex:(NSInteger)index ScrollView:(PublicScrollView *)pubSro
{
    NSInteger tagIdx = pubSro.tag - 101;
    ADItem *item = (tagIdx == 0) ? _recommond.ad.ad_1[index] : _recommond.ad.ad_2[index];
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

#pragma mark - NSNotification
- (void)scrollviewToTop:(NSNotification *)notifi
{
    if (self.tableView.contentOffset.y == 0) {
        return;
    }
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    //[self.tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.frameWidth, self.tableView.frameHeight) animated:YES];
    YWCMainViewController *main = [[self childViewControllers] lastObject];
    for (YWCTitleVCModel *model in main.titleVcModelArray) {
        if ([model.viewController isKindOfClass:[TableViewController class]]) {
            TableViewController *tab = (TableViewController *)model.viewController;
            tab.tableView.scrollEnabled = NO;
            tab.collectionView.scrollEnabled = NO;
        }
    }
    self.tableView.scrollEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat maxY = self.tableView.tableHeaderView.frameHeight;
    if (scrollView.contentOffset.y > maxY) {
        [self.tableView setContentOffset:CGPointMake(0, maxY) animated:NO];
    }
}

#pragma mark -  滚动停止时，触发该函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetSubScrollviewsEnable];
}

#pragma mark -  触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self resetSubScrollviewsEnable];
    }
}

- (void)resetSubScrollviewsEnable
{
    CGFloat hei = (NSInteger)self.tableView.tableHeaderView.frameHeight;
    BOOL scrollEnable = (self.tableView.contentOffset.y >= hei);
    YWCMainViewController *main = [[self childViewControllers] lastObject];
    for (YWCTitleVCModel *model in main.titleVcModelArray) {
        if ([model.viewController isKindOfClass:[TableViewController class]] && ![model.viewController isKindOfClass:[StoryViewController class]]) {
            TableViewController *tab = (TableViewController *)model.viewController;
            tab.tableView.scrollEnabled = scrollEnable;
            tab.collectionView.scrollEnabled = scrollEnable;
        }
    }
    self.tableView.scrollEnabled = (main.topScrollView.selectedIndex == 1) || (main.topScrollView.selectedIndex != 1 && !scrollEnable);
}

#pragma mark - YWCMainViewControllerDelegate
- (void)changeSelectedIndex:(NSInteger)index
{
    [self resetSubScrollviewsEnable];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *timeCellId = @"timeCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:timeCellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
        mainVc.delegate = self;
        GlobalManager *manager = [GlobalManager shareInstance];
        BOOL isDealer = (manager.detailInfo.isDealer.integerValue == 1);
        if (isDealer) {
            CreateCustomerViewController *customer = [CreateCustomerViewController new];
            customer.recommond = _recommond;
            YWCTitleVCModel *titleCustomer = [[YWCTitleVCModel alloc] init];
            titleCustomer.title = @"客户";
            titleCustomer.viewController = customer;
            
            [mainVc.titleVcModelArray addObject:titleCustomer];
        }
        else{
            HomePortfolioViewController *myPortfolio = [HomePortfolioViewController new];
            myPortfolio.recommond = _recommond;
            YWCTitleVCModel *titlePortfolio = [[YWCTitleVCModel alloc] init];
            titlePortfolio.title = @"我的作品";
            titlePortfolio.viewController = myPortfolio;
            [mainVc.titleVcModelArray addObject:titlePortfolio];
        }
        
        StoryViewController *story = [StoryViewController new];
        YWCTitleVCModel *titleStory = [[YWCTitleVCModel alloc] init];
        titleStory.title = @"故事";
        titleStory.viewController = story;
        
        RecommendViewController *recomment = [RecommendViewController new];
        recomment.tags = _recommond.tags;
        recomment.dataSource = _recommond.tmplate_tag;
        YWCTitleVCModel *titleRecommend = [[YWCTitleVCModel alloc] init];
        titleRecommend.title = @"更多推荐";
        titleRecommend.viewController = recomment;
        
        [mainVc.titleVcModelArray addObject:titleStory],
        [mainVc.titleVcModelArray addObject:titleRecommend];
        [self addChildViewController:mainVc];
        
        CGSize tmpSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 49 - 64);
        mainVc.bottomSize = tmpSize;
        [mainVc.view setFrame:CGRectMake(0, 0, tmpSize.width, tmpSize.height)];
        [mainVc.view setTag:1];
        [cell.contentView addSubview:mainVc.view];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT - 49 - 64;
}

@end
