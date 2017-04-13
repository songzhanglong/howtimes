//
//  SyncViewController.m
//  TYSociety
//
//  Created by szl on 16/7/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SyncViewController.h"
#import "SyncCollectionCell.h"
#import "SyncCheckModel.h"
#import "Masonry.h"
#import "HorizontalButton.h"
#import "TimeRecordInfo.h"
#import "CustomerListViewController.h"
#import "YWCMainViewController.h"

@interface SyncViewController ()

@end

@implementation SyncViewController
{
    NSMutableArray *_checkArr;
    CGSize _headerSize;
    HorizontalButton *_checkBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"同步";
    _checkArr = [NSMutableArray array];
    _headerSize = CGSizeZero;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    NSInteger numPerRow = 4,itemMargin = 8 ,itemWidth = (SCREEN_WIDTH - itemMargin * (numPerRow + 3)) / numPerRow;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth + 20);
    layout.minimumLineSpacing = itemMargin;
    layout.minimumInteritemSpacing = itemMargin;
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"querySyncConsumer"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    [param setObject:_recordTemplate.id forKey:@"c_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [self createCollectionViewLayout:layout Action:@"consumer" Param:param Header:YES Foot:NO];
    [self.collectionView registerClass:[SyncCollectionCell class] forCellWithReuseIdentifier:@"SyncCollectionCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"syncCellId"];
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, itemMargin * 2, 44, itemMargin * 2)];
    [self.collectionView setBackgroundColor:rgba(239, 239, 244, 1)];
    self.silentAnimation = YES;
}

#pragma mark - actions
- (void)backToPreControl:(id)sender
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSInteger count = [viewControllers count];
    
    [self.navigationController popToViewController:viewControllers[count - 3] animated:YES];
}

- (void)selectAllItems:(id)sender
{
    _checkBtn.selected = !_checkBtn.selected;
    [_checkArr removeAllObjects];
    if (_checkBtn.selected) {
        for (NSInteger i = 0; i < [self.dataSource count]; i++) {
            SyncCheckModel *sync = [self.dataSource objectAtIndex:i];
            if (sync.is_change.integerValue == 0) {
                [_checkArr addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            
        }
    }
    [self.collectionView reloadData];
}

- (void)hasCheckFinish:(id)sender
{
    if ([_checkArr count] == 0) {
        [self.view makeToast:@"请先选择需要同步的用户" duration:1.0 position:@"center"];
        return;
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self beginSyncRequest];
}

- (BOOL)canSelectedCheckBtn
{
    NSInteger count = 0;
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        SyncCheckModel *sync = [self.dataSource objectAtIndex:i];
        if (sync.is_change.integerValue == 0) {
            count++;
        }
    }
    
    return ([_checkArr count] == count);
}

#pragma mark - 开始同步
- (void)beginSyncRequest
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"syncProduction"];
    [param setObject:_recordTemplate.batch_id forKey:@"batch_id"];
    [param setObject:_recordTemplate.id forKey:@"c_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (NSIndexPath *indexPath in _checkArr) {
        SyncCheckModel *sync = [self.dataSource objectAtIndex:indexPath.item];
        [tmpArr addObject:sync.user_id];
    }
    NSString *sync_user_ids = [tmpArr componentsJoinedByString:@","];
    [param setObject:sync_user_ids forKey:@"sync_user_ids"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"production"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf syncFinished:error Data:data];
        });
    }];
}

- (void)syncFinished:(NSError *)error Data:(id)result
{
    [self.view hideToastActivity];
    self.sessionTask = nil;
    self.view.userInteractionEnabled = YES;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self.navigationController.view makeToast:@"成功同步" duration:1.0 position:@"center"];
        
        for (id controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[YWCMainViewController class]]) {
                NSArray * arr = ((YWCMainViewController *)controller).childViewControllers;
                for (int i = 0; i < 2; i++) {
                    CustomerListViewController *list = [arr objectAtIndex:i];
                    if (list.isViewLoaded) {
                        [list startPullRefresh];
                    }
                }
                
                break;
            }
        }
        
        [self backToPreControl:nil];
    }
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
    [super requestFinish:error Data:result];
    
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        self.dataSource = [SyncCheckModel arrayOfModelsFromDictionaries:ret_data error:nil];
        if ([self.dataSource count] > 0) {
            _headerSize = CGSizeZero;
            self.collectionView.mj_header = nil;
            [self.view addSubview:self.bottomView];
            [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view.mas_bottom);
                make.width.equalTo(self.view.mas_width);
                make.height.equalTo(@(44));
                make.centerX.equalTo(self.view.mas_centerX);
            }];
        }
        else{
            _headerSize = CGSizeMake(SCREEN_WIDTH, 100 + 56 + 10 + 18);
        }
    }
    else{
        _headerSize = CGSizeMake(SCREEN_WIDTH, 100 + 56 + 10 + 18);
    }
    [self.collectionView reloadData];
}

#pragma mark - CollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *syncCellId = @"SyncCollectionCell";
    
    SyncCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:syncCellId forIndexPath:indexPath];

    SyncCheckModel *sync = [self.dataSource objectAtIndex:indexPath.item];
    NSString *head_img = sync.head_img;
    if (![head_img hasPrefix:@"http"]) {
        head_img = [G_IMAGE_ADDRESS stringByAppendingString:head_img ?: @""];
    }
    [cell.contentImg sd_setImageWithURL:[NSURL URLWithString:head_img] placeholderImage:CREATE_IMG(@"logo")];
    [cell.nameLab setText:sync.name];
    
    if (sync.is_change.integerValue == 0) {
        cell.checkBtn.enabled = YES;
        cell.checkBtn.selected = [_checkArr containsObject:indexPath];
    }
    else{
        cell.checkBtn.enabled = NO;
        cell.checkBtn.selected = NO;
    }
    
    return cell;
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SyncCheckModel *sync = [self.dataSource objectAtIndex:indexPath.item];
    if (sync.is_change.integerValue == 1) {
        return;
    }
    
    SyncCollectionCell *cell = (SyncCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([_checkArr containsObject:indexPath]) {
        [_checkArr removeObject:indexPath];
        cell.checkBtn.selected = NO;
        _checkBtn.selected = NO;
    }
    else{
        [_checkArr addObject:indexPath];
        cell.checkBtn.selected = YES;
        _checkBtn.selected = [self canSelectedCheckBtn];
    }
}

#pragma mark - 头视图
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return _headerSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"syncCellId" forIndexPath:indexPath];
    
    UIImageView *tipImg = (UIImageView *)[view viewWithTag:1];
    if (!tipImg) {
        tipImg = [[UIImageView alloc] init];
        [tipImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [tipImg setTag:1];
        tipImg.image = CREATE_IMG(@"order_default");
        [view addSubview:tipImg];
        [tipImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(65));
            make.height.equalTo(@(80));
            make.centerX.equalTo(view.mas_centerX);
            make.bottom.equalTo(view.mas_bottom).with.offset(-40);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:1];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"还没有数据吗？下拉刷新试试"];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view.mas_centerX);;
            make.width.equalTo(@(200));
            make.height.equalTo(@(18));
            make.top.equalTo(tipImg.mas_bottom).with.offset(10);
        }];
    }
    
    return view;
}

#pragma mark - lazy load
- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView setBackgroundColor:[UIColor whiteColor]];
        [_bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        _checkBtn = [HorizontalButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_checkBtn setBackgroundColor:_bottomView.backgroundColor];
        [_checkBtn setImgSize:CGSizeMake(16, 16)];
        [_checkBtn setTextSize:CGSizeMake(40, 20)];
        [_checkBtn setTitleColor:rgba(0, 0, 0, 1) forState:UIControlStateNormal];
        [_checkBtn setImage:CREATE_IMG(@"syncNor") forState:UIControlStateNormal];
        [_checkBtn setImage:CREATE_IMG(@"syncSel") forState:UIControlStateSelected];
        [_checkBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_checkBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_checkBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_checkBtn addTarget:self action:@selector(selectAllItems:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_checkBtn];
        [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(20));
            make.width.equalTo(@(56));
            make.left.equalTo(@(10));
            make.centerY.equalTo(_bottomView.mas_centerY);
        }];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sureBtn setBackgroundColor:BASELINE_COLOR];
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureBtn setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [sureBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [sureBtn addTarget:self action:@selector(hasCheckFinish:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:sureBtn];
        [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(0));
            make.right.equalTo(_bottomView.mas_right);
            make.height.equalTo(_bottomView.mas_height);
            make.width.equalTo(sureBtn.mas_height).with.multipliedBy(2);
        }];
    }
    return _bottomView;
}

@end
