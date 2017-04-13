//
//  MyWorkViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/6/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyWorkViewController.h"
#import "HorizontalButton.h"

@interface MyWorkViewController ()
{
    NSInteger _nums;
    NSMutableArray *_recordIndexPathArray;
}
@end
@implementation MyWorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"我的作品";
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    [self createRightBarButton];
    //_names = @[@"@我的",@"收到的评论",@"收到的赞",@"通知"];
    //_imgs = @[@"msg_my",@"msg_comments",@"msg_praise",@"msg_noti"];
    _recordIndexPathArray = [NSMutableArray array];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    CGFloat itemWei = (SCREEN_WIDTH - 10 * 4) / 3,itemHei = 164;
    CGFloat margin = 10;
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    
    [self createCollectionViewLayout:layout Action:nil Param:nil Header:YES Foot:NO];
    [self.collectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyWorkCell"];
    
    _nums = 10;
    if (_nums == 0) {
        [self createTableFooterView];
    }
    
    [self createBottomView];
}

- (void)createBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.frameBottom, SCREEN_WIDTH, 50)];
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
    [nextStep setTitle:@"购买" forState:UIControlStateNormal];
    [nextStep.titleLabel setFont:horiBut.titleLabel.font];
    [nextStep addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:nextStep];
}

- (void)selectAllAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
}

- (void)buyAction:(id)sender
{
    
}

- (void)createRightBarButton
{
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 40, 30)];
    [rightBut setTitle:@"选择" forState:UIControlStateNormal];
    [rightBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    [self.navigationItem setRightBarButtonItems:@[rightItem] animated:YES];
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
    [label setText:@"无作品信息"];
    [footView addSubview:label];
    
    [self.view addSubview:footView];
}

- (void)editPressed:(id)sender
{
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _nums;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyWorkCell" forIndexPath:indexPath];
    
    UIImageView *_imgView = (UIImageView *)[cell.contentView viewWithTag:2];
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, cell.contentView.frame.size.width - 5, 131)];
        [_imgView setTag:2];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.backgroundColor = BASELINE_COLOR;
        [cell.contentView addSubview:_imgView];
    }
    [_imgView setBackgroundColor:CreateColor(247, 246, 254)];
    
    UIView *editView = (UIView *)[cell.contentView viewWithTag:3];
    if (!editView) {
        editView = [[UIView alloc] initWithFrame:CGRectMake(_imgView.frameX, _imgView.frameBottom, _imgView.frameWidth, 23)];
        [editView setBackgroundColor:CreateColor(180, 160, 255)];
        [editView setUserInteractionEnabled:YES];
        [cell addSubview:editView];
        
        for (int i = 0; i < 2; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(_imgView.frameWidth / 2 * i, 0, _imgView.frameWidth / 2, 20)];
            [btn setImage:CREATE_IMG((i == 0) ? @"work_edit" : @"work_delete") forState:UIControlStateNormal];
            [btn setImageEdgeInsets:UIEdgeInsetsMake((editView.frameHeight - 58.0 / 3) / 2, (editView.frameWidth / 2 - 58.0 / 3) / 2, (editView.frameHeight - 58.0 / 3) / 2, (editView.frameWidth / 2 - 58.0 / 3) / 2)];
            [btn setTag:i + 1];
            [btn addTarget:self action:@selector(editPressed:) forControlEvents:UIControlEventTouchUpInside];
            [editView addSubview:btn];
        }
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameWidth / 2, 0, 0.5, 23)];
        [lineLabel setBackgroundColor:[UIColor whiteColor]];
        [editView addSubview:lineLabel];
    }
    
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
    if ([_recordIndexPathArray containsObject:indexPath]) {
        _checkBtton.selected = YES;
    }else{
        _checkBtton.selected = NO;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)selectItemAction:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
}

@end
