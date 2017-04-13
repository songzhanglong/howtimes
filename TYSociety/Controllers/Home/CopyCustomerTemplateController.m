//
//  CopyCustomerTemplateController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/27.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CopyCustomerTemplateController.h"
#import "CustomerModel.h"
#import "PerInforModel.h"
#import "BatchMakeViewController.h"
#import "YWCMainViewController.h"
#import "CustomerListViewController.h"
#import "PreviewWebViewController.h"
#import "SetTemplateViewController.h"

@implementation CopyCustomerTemplateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showBack = YES;
    self.titleLable.text = _batch_id ? [NSString stringWithFormat:@"请选择一位客户制作"] : @"请选择一位客户模板";
    self.navigationController.navigationBar.translucent = NO;
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = (SCREEN_WIDTH - 55 * 5 - 10 * 2) / 4;
    layout.minimumInteritemSpacing = (SCREEN_WIDTH - 55 * 5 - 10 * 2) / 4;
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    [self createCollectionViewLayout:layout Action:nil Param:nil Header:NO Foot:NO];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CopyCustomer"];
    
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CopyCustomer" forIndexPath:indexPath];
    
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
    
    CustomerModel *item = [self.dataSource objectAtIndex:indexPath.item];
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
    
    if (_batch_id && !_isNeedSet) {
        BatchMakeViewController *batch = [BatchMakeViewController new];
        batch.hidesBottomBarWhenPushed = YES;
        batch.batch_id = _batch_id;
        batch.user_id = item.user_id;
        [self.navigationController pushViewController:batch animated:YES];
    }else {
        GlobalManager *manager = [GlobalManager shareInstance];
        if (manager.networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
            [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            return;
        }
        [self.view setUserInteractionEnabled:NO];
        [self.view makeToastActivity];
        
        __weak typeof(self)weakSelf = self;
        
        NSMutableDictionary *param = [manager requestinitParamsWith:@"addAlbumToBatch"];
        [param setValue:_isNeedSet ? _grow_id :item.grow_id forKey:@"copy_grow_id"];
        NSMutableArray *tempArray = [NSMutableArray array];
        for (PerInforModel *item in _userList) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:item.name forKey:@"name"];
            [dic setValue:item.phone forKey:@"phone"];
            [tempArray addObject:dic];
        }
        [param setObject:tempArray forKey:@"userlist"];
        [param setValue:manager.detailInfo.token forKey:@"token"];
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
        [param setObject:text forKey:@"signature"];
        NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"templateSet"];
        self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
            [weakSelf submitFinish:error Data:data];
        }];
    }
}

- (void)submitFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (error) {
        [self.view.window makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:RefreshCustomer object:nil];
        
        if (_isNeedSet) {
            SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
            setController.batch_id = _batch_id;
            setController.grow_id = _grow_id;
            setController.customers = _userList;
            [self.navigationController pushViewController:setController animated:YES];
        }
        else {
            for (id controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[YWCMainViewController class]]) {
                    for (CustomerListViewController *list in ((YWCMainViewController *)controller).childViewControllers) {
                        if (list.isViewLoaded) {
                            [list beginRefresh];
                        }
                    }
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }
    }
}

@end
