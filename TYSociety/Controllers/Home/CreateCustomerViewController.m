//
//  CreateCustomerViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CreateCustomerViewController.h"
#import "AddressBookViewController.h"
#import "CustomerModel.h"
#import "CustomerListViewController.h"
#import "YWCTitleVCModel.h"
#import "YWCMainViewController.h"
#import "BatchMakeViewController.h"
#import "TimeRecordInfo.h"
#import "ChooseProcessViewController.h"
#import "PerInforModel.h"
#import "CheckTemplateController.h"
#import "GrowAlertView.h"
#import "HomePageViewController.h"
#import "SetTemplateViewController.h"
#import "HorizontalButton.h"
#import "PreviewWebViewController.h"
#import "Masonry.h"

@interface CreateCustomerViewController () <GrowAlertViewDelegate,PreviewWebViewControllerDelegate>

@property (nonatomic,strong)BatchCustomers *batchCustom;
@property (nonatomic,strong)UIView *headView;
@property (nonatomic,strong)UIView *nullTipView;
@property (nonatomic,strong)UIView *failTipView;

@end

@implementation CreateCustomerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RefreshCustomer object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChangeCustomPublic object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = (SCREEN_WIDTH - 55 * 5 - 10 * 2) / 4;
    layout.minimumInteritemSpacing = (SCREEN_WIDTH - 55 * 5 - 10 * 2) / 4;
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);

    [self createCollectionViewLayout:layout Action:nil Param:nil Header:NO Foot:NO];
    [self.collectionView setFrame:CGRectMake(0, 35, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 35 - 44 - 49)];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Customer"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CustomerHaeder"];
    [self.collectionView setAlwaysBounceVertical:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:RefreshCustomer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCustomPublicState:) name:ChangeCustomPublic object:nil];
    
    [self startAnimation];
    [self requestMyCustomers];
}

#pragma mark - notice
- (void)changeCustomPublicState:(NSNotification *)notifi
{
    NSDictionary *dic = [notifi object];
    NSString *batch_id = [dic valueForKey:@"batch_id"],*user_id = [dic valueForKey:@"user_id"];
    for (CustomerModel *item in self.dataSource) {
        if ([item.batch_id isEqualToString:batch_id] && [item.user_id isEqualToString:user_id]) {
            item.is_public = @"2";
            break;
        }
    }
}

- (void)refreshData:(NSNotification *)notifi
{
    [self requestMyCustomers];
}

#pragma mark PreviewWebViewController delegate
- (void)reloadToCustomerList:(CustomerModel *)item Idx:(NSInteger)idx
{
    [self pushCustomerList:idx CustomerItem:item];
}

#pragma mark - 我的客户
- (void)requestMyCustomers
{
    if (self.sessionTask) {
        return;
    }
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"queryIndexConsumer"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"consumer"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf requestMyCustomersFinish:error Data:data];
        });
    }];
}

- (void)requestMyCustomersFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [self stopAnimation];
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        self.batchCustom = [[BatchCustomers alloc] initWithDictionary:ret_data error:nil];
        self.dataSource = self.batchCustom.consumers;
        if ([self.dataSource count] > 0) {
            //头部
            if (!_headView) {
                [self.view addSubview:self.headView];
            }
            //没有客户提示
            if (_nullTipView) {
                [_nullTipView removeFromSuperview];
                _nullTipView = nil;
            }
        }
        else{
            //头部
            if (_headView) {
                [_headView removeFromSuperview];
                _headView = nil;
            }
            //没有客户提示
            if (!_nullTipView) {
                [self.view addSubview:self.nullTipView];
            }
        }
        //失败
        if (_failTipView) {
            [_failTipView removeFromSuperview];
            _failTipView = nil;
        }
    }
    else{
        self.batchCustom = nil;
        self.dataSource = nil;
        //头部
        if (_headView) {
            [_headView removeFromSuperview];
            _headView = nil;
        }
        //没有客户提示
        if (_nullTipView) {
            [_nullTipView removeFromSuperview];
            _nullTipView = nil;
        }
        //失败
        if (!_failTipView) {
            [self.view addSubview:self.failTipView];
            [self.failTipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view.mas_centerX);
                make.centerY.equalTo(self.view.mas_centerY);
                make.width.equalTo(@(65));
                make.height.equalTo(@(100));
            }];
        }
    }
    [self.collectionView reloadData];
}

#pragma mark - Actions
- (void)createNewUsers:(id)sender
{
    YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
    mainVc.showFiltrate = YES;
    mainVc.titleLable.text = @"作品展示";
    NSInteger tagCount = [_recommond.tags count];
    for (NSInteger i = 0; i < tagCount; i++) {
        AdTags *adTag = _recommond.tags[i];
        if (adTag.status.integerValue == 0) {
            continue;
        }
        YWCTitleVCModel *titleVcModel = [[YWCTitleVCModel alloc] init];
        titleVcModel.title = adTag.name;
        
        CheckTemplateController *checkTem = [[CheckTemplateController alloc] init];
        checkTem.tag_id = adTag.id;
        titleVcModel.viewController = checkTem;
        [mainVc.titleVcModelArray addObject:titleVcModel];
    }
    mainVc.initIdx = 0;
    mainVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mainVc animated:YES];
}

- (void)buttonAction:(UIButton *)sender
{
    //客户列表
    [self pushCustomerList:0 CustomerItem:nil];
}

- (void)pushCustomerList:(NSInteger)idx CustomerItem:(CustomerModel *)item
{
    NSArray *titles = @[@"全部",@"待制作",@"待付款",@"打印中",@"待收货"];
    YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
    mainVc.titleLable.text = @"客户列表";
    mainVc.rightItemType = YES;
    for (int i = 0; i < [titles count]; i++) {
        CustomerListViewController *customerList = [CustomerListViewController new];
        customerList.status = i;
        if (item && i == idx) {
            customerList.reloadItem = item;
        }
        YWCTitleVCModel *titleCustomer = [[YWCTitleVCModel alloc] init];
        titleCustomer.title = titles[i];
        titleCustomer.viewController = customerList;
        [mainVc.titleVcModelArray addObject:titleCustomer];
    }
    mainVc.initIdx = idx;
    mainVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mainVc animated:YES];
}

- (void)addCustomerAction:(UIButton *)sender
{
    switch ([sender tag] - 2) {
        case 0:
        {
            SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
            setController.batch_id = _batchCustom.batch_id;
            setController.grow_id = _batchCustom.grow_id;
            setController.customers = self.dataSource;
            setController.statue_set = (_batchCustom.is_create_grow.integerValue == 1) ? 2 : 0;
            setController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:setController animated:YES];
        }
            break;
        case 1:
        {
            AddressBookViewController *addressBook = [[AddressBookViewController alloc] init];
            addressBook.batchCustomers = _batchCustom;
            addressBook.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addressBook animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)editBeachName:(id)sender
{
    GrowAlertView *alertView = [[GrowAlertView alloc] initWithFrame:self.view.window.bounds];
    alertView.delegate = self;
    [alertView setDefaultTheme:_batchCustom.grow_name];
    [self.view.window addSubview:alertView];
}

- (void)tryAgainRequest:(id)sender
{
    [_failTipView removeFromSuperview];
    _failTipView = nil;
    [self startAnimation];
    [self requestMyCustomers];
}

#pragma mark - lazy load
- (UIView *)headView
{
    if (!_headView) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        _headView = headView;
        [headView setBackgroundColor:CreateColor(241, 241, 242)];
        [headView setUserInteractionEnabled:YES];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(SCREEN_WIDTH - 15 - 90, 5, 87, 25)];
        [btn setBackgroundColor:CreateColor(153, 124, 251)];
        [btn setTitle:@" 更多客户" forState:UIControlStateNormal];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:2];
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:btn];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"customer_list")];
        CGFloat imgHeight = 13;
        [imgView setFrame:CGRectMake(5, (btn.frameHeight - imgHeight) / 2, 13, imgHeight)];
        [btn addSubview:imgView];
    }
    return _headView;
}

- (UIView *)nullTipView
{
    if (!_nullTipView) {
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160 + 50)];
        _nullTipView = footView;
        [footView setUserInteractionEnabled:YES];
        [footView setBackgroundColor:self.collectionView.backgroundColor];
        
        CGFloat margin = 50;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, margin, 65, 80)];
        imgView.image = CREATE_IMG(@"order_default");
        [footView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 5, SCREEN_WIDTH - 80, 20)];
        [label setTextAlignment:1];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"您还没有导入客户哦"];
        [footView addSubview:label];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, label.frameBottom + 5, SCREEN_WIDTH - 80, 20)];
        [tipLabel setTextAlignment:1];
        [tipLabel setFont:[UIFont systemFontOfSize:10]];
        [tipLabel setTextColor:CreateColor(86, 86, 86)];
        [tipLabel setText:@"赶快去制作一本导入客户吧~"];
        [footView addSubview:tipLabel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((SCREEN_WIDTH - 80) / 2, tipLabel.frameBottom + 5, 80, 20)];
        [btn setTitle:@"去看看" forState:UIControlStateNormal];
        [btn setTitleColor:CreateColor(86, 86, 86) forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [btn addTarget:self action:@selector(createNewUsers:) forControlEvents:UIControlEventTouchUpInside];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:3];
        [btn.layer setBorderWidth:1];
        [btn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [footView addSubview:btn];
    }
    return _nullTipView;
}

- (UIView *)failTipView
{
    if (!_failTipView) {
        _failTipView = [[UIView alloc] init];
        [_failTipView setBackgroundColor:self.view.backgroundColor];
        [_failTipView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imgView setImage:CREATE_IMG(@"order_default")];
        [_failTipView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.top.equalTo(@(0));
            make.width.equalTo(_failTipView.mas_width);
            make.height.equalTo(imgView.mas_width).with.multipliedBy(80.0 / 65);
        }];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitle:@"再试一次" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button setTitleColor:CreateColor(86, 86, 86) forState:UIControlStateNormal];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:5];
        [button.layer setBorderWidth:1];
        [button.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [button addTarget:self action:@selector(tryAgainRequest:) forControlEvents:UIControlEventTouchUpInside];
        [_failTipView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_failTipView.mas_centerX);
            make.top.equalTo(imgView.mas_bottom);
            make.width.equalTo(imgView.mas_width);
            make.height.equalTo(@(20));
        }];
    }
    return _failTipView;
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
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"templateSet"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"updateGrowAlbumName"];
    [param setObject:_batchCustom.batch_id forKey:@"batch_id"];
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

- (void)updateGrowNameFinish:(NSError *)error Data:(id)result GrowName:(NSString *)name
{
    [self.view.window hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }else {
        _batchCustom.grow_name = name;
        [self.collectionView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ScrollToTop object:nil];
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
        scrollView.scrollEnabled = NO;
    }
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(55, 75);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Customer" forIndexPath:indexPath];
    CustomerModel *item = [self.dataSource objectAtIndex:indexPath.item];
    UIImageView *_imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frameWidth, cell.contentView.frameHeight - 20)];
        [_imgView setTag:1];
        [_imgView.layer setMasksToBounds:YES];
        [_imgView.layer setCornerRadius:cell.contentView.frameWidth / 2];
        [[_imgView layer] setBorderWidth:1.0];
        [[_imgView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [cell.contentView addSubview:_imgView];
    }
    [_imgView setImage:CREATE_IMG(@"loginLogo")];
    
    UIView *view = (UIView *)[_imgView viewWithTag:20];
    if (!view) {
        view = [[UIView alloc] init];
        view.tag = 20;
        view.backgroundColor = [UIColor orangeColor];
        view.alpha = 0.3;
        [_imgView addSubview:view];
    }
    CGFloat progress = ([item.nums integerValue] == 0) ? 0 : ([item.finish_num floatValue] / [item.nums floatValue]);
    [view setFrame:CGRectMake(0, _imgView.frameHeight * (1 - progress), _imgView.frameWidth, _imgView.frameHeight * progress)];
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _imgView.frameBottom, _imgView.frameWidth, 20)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:CreateColor(100, 100, 100)];
        [nameLabel setFont:[UIFont systemFontOfSize:12]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setTag:2];
        [cell.contentView addSubview:nameLabel];
    }
    [nameLabel setText:item.name ?: @""];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomerModel *item = [self.dataSource objectAtIndex:indexPath.item];
    BOOL is_create_grow = ([_batchCustom.is_create_grow integerValue] != 0);
    if (is_create_grow) {
        if ([item.is_public integerValue] == 2 || [item.is_print integerValue] == 1) {
            TimeRecordModel *timeRecord = [[TimeRecordModel alloc] init];
            timeRecord.grow_id = item.grow_id;
            timeRecord.user_id = item.user_id;
            timeRecord.batch_id = item.batch_id;
            timeRecord.is_double = item.is_double;
            timeRecord.is_print = item.is_print;
            timeRecord.finish_num = [NSNumber numberWithInteger:[item.finish_num integerValue]];
            timeRecord.detail_num = [NSNumber numberWithInteger:[item.nums integerValue]];
            
            UINavigationController *nav = (UINavigationController *)[(UITabBarController *)[APPWindow rootViewController] selectedViewController];
            PreviewWebViewController *preview = [[PreviewWebViewController alloc] init];
            preview.url = [G_PLAYER_ADDRESS stringByAppendingString:[NSString stringWithFormat:@"book/b%@.htm",timeRecord.grow_id]];
            preview.recordItem = timeRecord;
            preview.delegate = self;
            preview.isLandscape = ([item.is_double integerValue] == 1);
            preview.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:preview animated:YES];
        }
        else {
            //制作
            BatchMakeViewController *batch = [BatchMakeViewController new];
            batch.batch_id = item.batch_id;
            batch.user_id = item.user_id;
            batch.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:batch animated:YES];
        }
    }else {
        //设置模板
        SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
        setController.batch_id = _batchCustom.batch_id;
        setController.grow_id = _batchCustom.grow_id;
        setController.customers = (NSMutableArray *)@[item];
        setController.statue_set = (_batchCustom.is_create_grow.integerValue == 1) ? 1 : 0;
        setController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setController animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if ([self.dataSource count] == 0) {
        return CGSizeMake(0, 0);
    }
    return CGSizeMake(SCREEN_WIDTH, 30);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CustomerHaeder" forIndexPath:indexPath];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view setUserInteractionEnabled:YES];
    
    HorizontalButton *btn = (HorizontalButton *)[view viewWithTag:1];
    if (!btn) {
        btn = [HorizontalButton buttonWithType:UIButtonTypeCustom];
        btn.imgSize = CGSizeMake(15, 15);
        btn.textSize = CGSizeMake(105, 30);
        [btn setFrame:CGRectMake(10, 0, 120, 30)];
        [btn addTarget:self action:@selector(editBeachName:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:CREATE_IMG(@"customer_beach") forState:UIControlStateNormal];
        [btn setTitleColor:CreateColor(100, 100, 100) forState:UIControlStateNormal];
        [btn.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn setTag:1];
        [view addSubview:btn];
    }
    [btn setTitle:_batchCustom.grow_name ?: @"" forState:UIControlStateNormal];
    
    UIButton *setBtn = (UIButton *)[view viewWithTag:2];
    if (!setBtn) {
        setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [setBtn setFrame:CGRectMake(view.frameWidth - 20 - 15 - 5 - 65, 5, 60, 20)];
        [setBtn.layer setMasksToBounds:YES];
        [setBtn.layer setCornerRadius:3];
        [setBtn.layer setBorderWidth:1];
        [setBtn.layer setBorderColor:BASELINE_COLOR.CGColor];
        [setBtn setTag:2];
        [setBtn setTitle:@"设置模板" forState:UIControlStateNormal];
        [setBtn setTitleColor:BASELINE_COLOR forState:UIControlStateNormal];
        [setBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [setBtn addTarget:self action:@selector(addCustomerAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:setBtn];
    }
    
    UIButton *addCustomer = (UIButton *)[view viewWithTag:3];
    if (!addCustomer) {
        addCustomer = [UIButton buttonWithType:UIButtonTypeCustom];
        [addCustomer setBackgroundColor:view.backgroundColor];
        [addCustomer setTag:3];
        [addCustomer setFrame:CGRectMake(view.frameWidth - 20 - 15 - 5, 0, 30, 30)];
        [addCustomer setImage:CREATE_IMG(@"customer_new_phone") forState:UIControlStateNormal];
        [addCustomer setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [addCustomer addTarget:self action:@selector(addCustomerAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:addCustomer];
    }
    return view;
}

@end
