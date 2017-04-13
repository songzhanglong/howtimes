//
//  SelectTempalteViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SelectTempalteViewController.h"
#import "HorizontalButton.h"
#import "TemplateModel.h"
#import "SetTemplateViewController.h"

@interface SelectTempalteViewController ()
{
    NSMutableArray *_recordDatasArray;
}
@end
@implementation SelectTempalteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"选择模板";
    self.navigationController.navigationBar.translucent = NO;
    
    _recordDatasArray = [NSMutableArray array];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    //CGFloat itemWei = (SCREEN_WIDTH - 10 - 15 - 2 * 5) / 3,itemHei = 150;
    //layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 15);
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getOtherTemplate"];
    [param setValue:[_datasDictory valueForKey:@"copy_batch_id"] forKey:@"batch_id"];
    [param setValue:[_datasDictory valueForKey:@"template_id"] forKey:@"template_id"];
    [param setValue:[_datasDictory valueForKey:@"copy_user_id"] forKey:@"user_id"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self createCollectionViewLayout:layout Action:@"templateSet" Param:param Header:NO Foot:NO];
    [self.collectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SelectTemplate"];
    
    [self createBottomView];
    
    if ([self.dataSource count] == 0) {
        self.silentAnimation = YES;
    }
}

#pragma mark - 网络请求结束
- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [NSMutableArray array];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            array = [TemplateModel arrayOfModelsFromDictionaries:ret_data error:nil];
        }
        self.dataSource = array;
        
        [self.collectionView reloadData];
        
        if ([self.dataSource count] == 0) {
            [self createTableFooterView];
        }
    }
}

- (void)createBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 50, SCREEN_WIDTH, 50)];
    [bottomView setBackgroundColor:CreateColor(243, 243, 243)];
    [self.view addSubview:bottomView];
    
    UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.frameWidth, 7)];
    [marginView setBackgroundColor:self.collectionView.backgroundColor];
    [bottomView addSubview:marginView];
    
    HorizontalButton *horiBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
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
    
    UIButton *nextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextStep setFrame:CGRectMake(bottomView.frameWidth - 10 - 104, 7.5, 104, 35)];
    nextStep.layer.masksToBounds = YES;
    nextStep.layer.cornerRadius = 5;
    [nextStep setBackgroundColor:CreateColor(153, 125, 251)];
    [nextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextStep setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [nextStep setTitle:@"保存" forState:UIControlStateNormal];
    [nextStep.titleLabel setFont:horiBut.titleLabel.font];
    [nextStep addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:nextStep];
}

- (void)selectAllAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if ([_recordDatasArray count] > 0) {
        [_recordDatasArray removeAllObjects];
    }
    if (btn.selected) {
        
        [_recordDatasArray addObjectsFromArray:self.dataSource];
    }
    
    [self.collectionView reloadData];
}

- (void)saveAction:(id)sender
{
    if ([_recordDatasArray count] == 0) {
        [self.view makeToast:@"请选择要添加的模板" duration:1.0 position:@"center"];
        return;
    }
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[SetTemplateViewController class]]) {
            //[controller addTemplateSource:_recordDatasArray Theme:_theme_name];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectAction:(id)sender
{
    
}

- (void)createTableFooterView
{
    UIView *footView = [self.view viewWithTag:1];
    if (footView) {
        [footView removeFromSuperview];
    }
    footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    [footView setTag:1];
    [footView setBackgroundColor:self.collectionView.backgroundColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, (footView.frameHeight - 80 - 40) / 2, 65, 80)];
    imgView.image = CREATE_IMG(@"order_default");
    [footView addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 10, SCREEN_WIDTH - 80, 30)];
    [label setTextAlignment:1];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:CreateColor(86, 86, 86)];
    [label setText:@"您还没有获取到数据，下拉刷新试试吧"];
    [footView addSubview:label];
    
    [self.view addSubview:footView];
}

- (void)editPressed:(id)sender
{
    
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateModel *item = [self.dataSource objectAtIndex:indexPath.item];
    CGFloat itemHei = [item.image_height floatValue];
    CGFloat scale = ((self.collectionView.frameWidth - 10 - 15 - 5 * 2) / 3 - 5) / [item.image_width floatValue];
    itemHei = 5 + itemHei * scale;
    CGFloat itemWei = (self.collectionView.frameWidth - 10 - 15 - 5 * 2) / 3;
    
    return CGSizeMake(itemWei, itemHei);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectTemplate" forIndexPath:indexPath];
    
    UIImageView *_imgView = (UIImageView *)[cell.contentView viewWithTag:2];
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, cell.contentView.frameWidth - 5, cell.contentView.frameHeight - 5)];
        [_imgView setTag:2];
        //_imgView.contentMode = UIViewContentModeScaleAspectFill;
        //_imgView.clipsToBounds = YES;
        [_imgView setBackgroundColor:CreateColor(240, 239, 244)];
        [cell.contentView addSubview:_imgView];
    }
    TemplateModel *model = [self.dataSource objectAtIndex:indexPath.item];
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
    
    if ([_recordDatasArray containsObject:model]) {
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
    TemplateModel *model = [self.dataSource objectAtIndex:indexPath.item];
    if ([_recordDatasArray containsObject:model]) {
        _checkBtton.selected = NO;
        [_recordDatasArray removeObject:model];
    }else{
        _checkBtton.selected = YES;
        [_recordDatasArray addObject:model];
    }

}

- (void)selectItemAction:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    UICollectionViewCell *cell = [GlobalManager findViewFrom:btn To:[UICollectionViewCell class]];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    TemplateModel *model = [self.dataSource objectAtIndex:indexPath.item];
    if ([_recordDatasArray containsObject:model]) {
        btn.selected = NO;
        [_recordDatasArray removeObject:model];
    }else{
        btn.selected = YES;
        [_recordDatasArray addObject:model];
    }
}

@end
