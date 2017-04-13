//
//  CollaborationViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/12.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CollaborationViewController.h"
#import "HorizontalButton.h"
#import "BatchMakeViewController.h"
#import "PerInforModel.h"
#import "CopyCustomerTemplateController.h"
#import "CustomerModel.h"
#import "CoopModel.h"
#import "SetTemplateViewController.h"

@interface CollaborationViewController ()
{
    NSMutableArray *_recordDatasArray;
    HorizontalButton *_horiButton;
}
@end

@implementation CollaborationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"协作";
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = CreateColor(235, 233, 247);
    _recordDatasArray = [NSMutableArray array];
    
    NSMutableDictionary *param = [[GlobalManager shareInstance] requestinitParamsWith:@"getCoopTemplate"];
    [param setObject:_batch_id forKey:@"batch_id"];
    [param setObject:_template_id forKey:@"template_id"];
    if ([_customers count] == 1) {
        CustomerModel *item = _customers.firstObject;
        [param setObject:item.user_id forKey:@"user_id"];
    }
    [param setObject:[GlobalManager shareInstance].detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 15);
    [self createCollectionViewLayout:layout Action:@"cooperation" Param:param Header:YES Foot:NO];
    [self.collectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    self.collectionView.backgroundColor = CreateColor(235, 233, 247);
    [self.collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collaborationCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collheadCell"];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.silentAnimation = YES;
}

- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];

    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [NSMutableArray array];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            array = [CoopModel arrayOfModelsFromDictionaries:ret_data error:nil];
        }
        self.dataSource = array;
        [self.collectionView reloadData];
        if ([self.dataSource count] > 0) {
            self.collectionView.mj_header = nil;
            [self createBottomView];
        }
    }
    
    [self createTableFooterView];
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        UIView *footView = [self.view viewWithTag:13];
        if (footView) {
            [footView removeFromSuperview];
        }
    }
    else {
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        [footView setTag:13];
        [footView setUserInteractionEnabled:YES];
        [footView setBackgroundColor:self.collectionView.backgroundColor];
        [self.collectionView addSubview:footView];
        
        CGFloat margin = (footView.frameHeight - 120) / 2;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, margin, 65, 80)];
        imgView.image = CREATE_IMG(@"order_default");
        [footView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 10, SCREEN_WIDTH - 80, 30)];
        [label setTextAlignment:1];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"您还没有获取到数据，下拉刷新试试吧"];
        [footView addSubview:label];
    }
}

- (void)backToPreControl:(id)sender
{
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[SetTemplateViewController class]]) {
            [(SetTemplateViewController *)controller setStatue_set:2];
            [(SetTemplateViewController *)controller setIsBack:YES];
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 50, SCREEN_WIDTH, 50)];
    [bottomView setBackgroundColor:CreateColor(243, 243, 243)];
    [self.view addSubview:bottomView];
    
    UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.frameWidth, 7)];
    [marginView setBackgroundColor:CreateColor(243, 243, 243)];
    [bottomView addSubview:marginView];
    
    HorizontalButton *horiBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
    _horiButton = horiBut;
    [horiBut setFrame:CGRectMake(18, 12 + marginView.frameBottom, 50, 20)];
    horiBut.textSize = CGSizeMake(40, 18);
    horiBut.imgSize = CGSizeMake(43.0 / 3, 43.0 / 3);
    [horiBut setTitle:@"全选" forState:UIControlStateNormal];
    [horiBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    horiBut.titleLabel.font = [UIFont systemFontOfSize:14];
    horiBut.titleLabel.textAlignment = NSTextAlignmentCenter;
    [horiBut setImage:CREATE_IMG(@"work_all_dis_check") forState:UIControlStateNormal];
    [horiBut setImage:CREATE_IMG(@"work_all_sel_check") forState:UIControlStateSelected];
    [horiBut addTarget:self action:@selector(selectAllAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:horiBut];
    
    UIButton *skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipBtn setFrame:CGRectMake(bottomView.frameWidth - 10 - 125, 12, 60, 26)];
    skipBtn.layer.masksToBounds = YES;
    skipBtn.layer.cornerRadius = 13;
    skipBtn.layer.borderWidth = 1;
    skipBtn.layer.borderColor = [CreateColor(166, 143, 250) CGColor];
    [skipBtn setBackgroundColor:[UIColor clearColor]];
    [skipBtn setTitleColor:CreateColor(166, 143, 250) forState:UIControlStateNormal];
    [skipBtn setTag:1];
    [skipBtn setTitle:@"跳 过" forState:UIControlStateNormal];
    [skipBtn.titleLabel setFont:horiBut.titleLabel.font];
    [skipBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:skipBtn];
    
    UIButton *nextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextStep setFrame:CGRectMake(bottomView.frameWidth - 10 - 60, 12, 60, 26)];
    nextStep.layer.masksToBounds = YES;
    nextStep.layer.cornerRadius = 13;
    [nextStep setBackgroundColor:CreateColor(153, 125, 251)];
    [nextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextStep setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [nextStep setTag:2];
    [nextStep setTitle:@"确 认" forState:UIControlStateNormal];
    [nextStep.titleLabel setFont:horiBut.titleLabel.font];
    [nextStep addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:nextStep];
}

- (void)nextAction
{
    if ([_customers count] == 0) {
        [self.navigationController.view makeToast:@"您还没有添加要制作档案的客户哦" duration:1.0 position:@"center"];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        return;
    }else {
        if ([_customers count] == 1) {
            CustomerModel *item = _customers[0];
            BatchMakeViewController *batch = [BatchMakeViewController new];
            batch.hidesBottomBarWhenPushed = YES;
            batch.batch_id = _batch_id;
            batch.user_id = item.user_id;
            [self.navigationController pushViewController:batch animated:YES];
        }
        else {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (PerInforModel *item in _customers) {
                CustomerModel *customer = [[CustomerModel alloc] init];
                customer.name = item.name;
                customer.phone = item.phone;
                customer.user_id = item.user_id;
                [tempArray addObject:customer];
            }
            CopyCustomerTemplateController *copyController = [[CopyCustomerTemplateController alloc] init];
            copyController.batch_id = _batch_id;
            copyController.dataSource = tempArray;
            copyController.templates = [self.dataSource count];
            [self.navigationController pushViewController:copyController animated:YES];
        }
    }
}

- (void)buttonAction:(UIButton *)sender
{
    switch (sender.tag - 1) {
        case 0:
        {
            [self nextAction];
        }
            break;
        case 1:
        {
            //发起协作
            if ([_recordDatasArray count] == 0) {
                [self.view makeToast:@"您还没有选择要协作的模板" duration:1.0 position:@"center"];
                return;
            }
            if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
                [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
                return;
            }
            
            NSMutableArray *indexArray = [NSMutableArray array];
            for (NSIndexPath *indexPath in _recordDatasArray) {
                CoopModel *model = self.dataSource[indexPath.item];
                [indexArray addObject:model.c_id];
            }
            [self.view setUserInteractionEnabled:NO];
            [self.view makeToastActivity];
            GlobalManager *manager = [GlobalManager shareInstance];
            __weak typeof(self)weakSelf = self;
            NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"cooperation"];
            NSMutableDictionary *param = [manager requestinitParamsWith:@"sendCoop"];
            [param setObject:_batch_id forKey:@"batch_id"];
            [param setObject:_template_id forKey:@"template_id"];
            [param setObject:[indexArray componentsJoinedByString:@","] forKey:@"c_ids"];
            [param setObject:@"1" forKey:@"syncType"];
            [param setObject:manager.detailInfo.token forKey:@"token"];
            NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
            [param setObject:text forKey:@"signature"];
            self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf sendCoopFinish:error Data:data];
                });
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 请求结束
- (void)sendCoopFinish:(NSError *)error Data:(id)result
{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self nextAction];
    }
}
- (void)selectAllAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if ([_recordDatasArray count] > 0) {
        [_recordDatasArray removeAllObjects];
    }
    if (btn.selected) {
        for (int i = 0; i < [self.dataSource count]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [_recordDatasArray addObject:indexPath];
        }
    }
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger num = _is_double ? 2 : 3;
    CoopModel *item = [self.dataSource objectAtIndex:indexPath.item];
    CGFloat itemHei = [item.image_height floatValue];
    CGFloat scale = ((SCREEN_WIDTH - 10 - 15 - (num - 1) * 5) / num - 5) / [item.image_width floatValue];
    itemHei = 5 + itemHei * scale;
    CGFloat itemWei = (SCREEN_WIDTH - 10 - 15 - (num - 1) * 5) / num;
    
    return CGSizeMake(itemWei, itemHei);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collaborationCell" forIndexPath:indexPath];
    
    UIImageView *_imgView = (UIImageView *)[cell.contentView viewWithTag:2];
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, cell.contentView.frameWidth - 5, cell.contentView.frameHeight - 5)];
        [_imgView setTag:2];
        //_imgView.contentMode = UIViewContentModeScaleAspectFill;
        //_imgView.clipsToBounds = YES;
        [_imgView setBackgroundColor:CreateColor(240, 239, 244)];
        [cell.contentView addSubview:_imgView];
    }
    CoopModel *model = [self.dataSource objectAtIndex:indexPath.item];
    NSString *url = model.image_thumb_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_imgView sd_setImageWithURL:[NSURL URLWithString:url]];
    
    UIButton *_checkBtton = (UIButton *)[cell.contentView viewWithTag:1];
    if (!_checkBtton) {
        _checkBtton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkBtton.frame = CGRectMake(0, 0, 70.0 / 3, 23);
        [_checkBtton setImage:CREATE_IMG(@"work_dis_check") forState:UIControlStateNormal];
        [_checkBtton setImage:CREATE_IMG(@"work_sel_check") forState:UIControlStateSelected];
        [_checkBtton setTag:1];
        [_checkBtton addTarget:self action:@selector(selectItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_checkBtton];
    }
    
    if ([_recordDatasArray containsObject:indexPath]) {
        _checkBtton.selected = YES;
    }else{
        _checkBtton.selected = NO;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIButton *_checkBtton = (UIButton *)[cell.contentView viewWithTag:1];
    if ([_recordDatasArray containsObject:indexPath]) {
        _checkBtton.selected = NO;
        [_recordDatasArray removeObject:indexPath];
    }else{
        _checkBtton.selected = YES;
        [_recordDatasArray addObject:indexPath];
    }
    
    _horiButton.selected = ([_recordDatasArray count] == [self.dataSource count]);
}

#pragma mark - 头视图
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    
    return ([self.dataSource count] > 0) ? CGSizeMake(SCREEN_WIDTH, 40) : CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collheadCell" forIndexPath:indexPath];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *label = (UILabel *)[view viewWithTag:1];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frameWidth, 40)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTag:1];
            [label setTextColor:CreateColor(100, 100, 100)];
            [label setFont:[UIFont systemFontOfSize:14]];
            [view addSubview:label];
        }
        [label setText:@"您的客户将参与以下模板制作"];
        
        return view;
    }
    
    return nil;
}


- (void)selectItemAction:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    UICollectionViewCell *cell = [GlobalManager findViewFrom:btn To:[UICollectionViewCell class]];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    if ([_recordDatasArray containsObject:indexPath]) {
        btn.selected = NO;
        [_recordDatasArray removeObject:indexPath];
    }else{
        btn.selected = YES;
        [_recordDatasArray addObject:indexPath];
    }
    _horiButton.selected = ([_recordDatasArray count] == [self.dataSource count]);
}

@end
