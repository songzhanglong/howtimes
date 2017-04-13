//
//  MyPortfolioViewController.m
//  TYSociety
//
//  Created by szl on 16/7/18.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyPortfolioViewController.h"
#import "MyTimeRecord.h"
#import "MyTimeRecordCell.h"
#import "TimeRecordInfo.h"
#import "HomePageViewController.h"
#import "PreviewWebViewController.h"
#import "BatchMakeViewController.h"
#import "SetTemplateViewController.h"
#import "CustomerModel.h"
#import "YWCMainViewController.h"
#import "CheckTemplateController.h"
#import "HomePageViewController.h"
#import "MyTableBarViewController.h"

@interface MyPortfolioViewController ()<TimeRecordCellDelegate,BatchMakeViewControllerDelegate>

@end

@implementation MyPortfolioViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserPorfile object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = PortfolioColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo:) name:UserPorfile object:nil];
    [self createInitDataView];
}

- (void)createInitDataView
{
    NSMutableDictionary *param = [[GlobalManager shareInstance] requestinitParamsWith:@"getGrowAlbum"];
    [param setObject:[GlobalManager shareInstance].detailInfo.token ?: @"" forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self createTableViewAndRequestAction:@"growAlbum" Param:param Header:YES Foot:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    NSArray *array = [GlobalManager shareInstance].detailInfo.profiles;
    if (array && [array count] > 0) {
        self.dataSource = array;
    }
    else{
        self.silentAnimation = YES;
    }
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        if (self.tableView.tableHeaderView) {
            [self.tableView setTableHeaderView:nil];
        }
    }
    else{
        CGFloat margin = 50;
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
        [label setText:@"您还没有作品哦"];
        [headView addSubview:label];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, label.frameBottom + 5, SCREEN_WIDTH - 80, 20)];
        [tipLabel setTextAlignment:1];
        [tipLabel setFont:[UIFont systemFontOfSize:10]];
        [tipLabel setTextColor:CreateColor(86, 86, 86)];
        [tipLabel setText:@"赶快去制作一本吧~"];
        [headView addSubview:tipLabel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((SCREEN_WIDTH - 80) / 2, tipLabel.frameBottom + 5, 80, 20)];
        [btn setTitle:@"去看看" forState:UIControlStateNormal];
        [btn setTitleColor:CreateColor(86, 86, 86) forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:3];
        [btn.layer setBorderWidth:1];
        [btn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [headView addSubview:btn];
        
        [self.tableView setTableHeaderView:headView];
    }
}

- (void)buttonPressed:(id)sender
{
    if (!_recommond) {
        HomePageViewController *homePage = (HomePageViewController *)[[(UINavigationController *)[[(MyTableBarViewController *)[APPWindow rootViewController] viewControllers] firstObject] viewControllers] firstObject];
        self.recommond = homePage.recommond;
    }
    
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

#pragma mark - notice
- (void)refreshUserInfo:(NSNotification *)notifi
{
    NSArray *array = [GlobalManager shareInstance].detailInfo.profiles;
    self.dataSource = array;
    [self.tableView reloadData];
}

#pragma mark - 接口配置
- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [NSMutableArray array];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            for (id subDic in ret_data) {
                NSError *error = nil;
                MyTimeRecord *model = [[MyTimeRecord alloc] initWithDictionary:subDic error:&error];
                if (error) {
                    NSLog(@"%@",error.description);
                    continue;
                }
                NSMutableArray *tempArr = [NSMutableArray array];
                for (NSString *sizeName in [model.tag_name componentsSeparatedByString:@","]) {
                    TagNameSize *item = [[TagNameSize alloc]init];
                    item.name = sizeName;
                    [item calculateTagnameRect];
                    [tempArr addObject:item];
                }
                model.nameSizeArray = tempArr;
                [model calculateTagNameRect];
                [array addObject:model];
            }
        }
//        self.dataSource = array;
//        [self.tableView reloadData];
        
        [GlobalManager shareInstance].detailInfo.profiles = array;
        [[NSNotificationCenter defaultCenter] postNotificationName:UserPorfile object:nil];
    }

    [self createTableFooterView];
}

#pragma mark - BatchMakeViewControllerDelegate
- (void)batchMakePublishFinish
{
    if (_timeRecord.is_public.integerValue == 0) {
        self.timeRecord.is_public = [NSNumber numberWithInt:1];
    }
}

#pragma mark - TimeRecordCellDelegate
- (void)selectTimeRecord:(id)record At:(UITableViewCell *)cell
{
    MyTimeRecord *timeRecord = (MyTimeRecord *)record;
    self.timeRecord = timeRecord;
    
    UINavigationController *nav = (UINavigationController *)[(UITabBarController *)[APPWindow rootViewController] selectedViewController];
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
    if ((detailInfo.isDealer.integerValue == 0) && (timeRecord.is_public.integerValue != 2) && ([timeRecord.is_print integerValue] == 0)) {
        //个人且未发布，直接进入编辑页面，因为此时看不到东西
        BatchMakeViewController *batch = [BatchMakeViewController new];
        batch.batch_id = timeRecord.batch_id;
        batch.user_id = timeRecord.user_id;
        batch.delegate = self;
        batch.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:batch animated:YES];
        return;
    }
    
    TimeRecordModel *item = [[TimeRecordModel alloc] init];
    item.grow_id = timeRecord.grow_id;
    item.user_id = timeRecord.user_id;
    item.batch_id = timeRecord.batch_id;
    item.is_double = timeRecord.is_double;
    item.is_print = timeRecord.is_print;
    item.finish_num = [NSNumber numberWithInteger:[timeRecord.finish_num integerValue]];
    item.detail_num = [NSNumber numberWithInteger:[timeRecord.nums integerValue]];
    
    PreviewWebViewController *preview = [[PreviewWebViewController alloc] init];
    preview.url = [G_PLAYER_ADDRESS stringByAppendingString:[NSString stringWithFormat:@"book/b%@.htm",timeRecord.grow_id]];
    preview.recordItem = item;
    preview.isLandscape = ([item.is_double integerValue] == 1);
    preview.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:preview animated:YES];
    /*
    if ([item.is_double integerValue] == 1) {
        preview.isLandscape = YES;
        [nav presentViewController:[[UINavigationController alloc] initWithRootViewController:preview] animated:YES completion:nil];
    }
    else {
        preview.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:preview animated:YES];
    }
     */
}

- (void)setTemplateTimeRecord:(id)record At:(UITableViewCell *)cell
{
    MyTimeRecord *timeRecord = (MyTimeRecord *)record;
    self.timeRecord = timeRecord;
    
    UserInfo *info = [GlobalManager shareInstance].detailInfo.user;
    CustomerModel *item = [[CustomerModel alloc] init];
    item.batch_id = timeRecord.batch_id;
    item.finish_num = timeRecord.finish_num;
    item.name = info.name;
    item.nums = [timeRecord.nums stringValue];
    item.phone = info.phone;
    item.template_id = timeRecord.template_id;
    item.template_name = timeRecord.template_name;
    item.user_id = info.id;
    item.grow_id = timeRecord.grow_id;
    
    SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
    setController.batch_id = timeRecord.batch_id;
    setController.grow_id = timeRecord.grow_id;
    setController.customers = (NSMutableArray *)@[item];
    setController.statue_set = 1;
    setController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setController animated:YES];
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
    static NSString *myRecordCellId = @"myTimeRecordCellId";
    MyTimeRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:myRecordCellId];
    if (cell == nil) {
        cell = [[MyTimeRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myRecordCellId];
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
    //CGFloat xOri = 15,margin = 15,itemWei = (SCREEN_WIDTH - xOri * 2 - margin * 2) / 3,itemHei = itemWei * 4 / 3;
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
