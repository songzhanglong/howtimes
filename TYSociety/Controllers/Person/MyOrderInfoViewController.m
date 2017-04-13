//
//  MyOrderInfoViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/6/29.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyOrderInfoViewController.h"

@interface MyOrderInfoViewController ()
{
    UIView *_headView;
}

@end

@implementation MyOrderInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"我的订单";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:rgba(236, 235, 243, 1)];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:YES Foot:NO];
    
    if (_nums == 0) {
        [self createTableFooterView];
    }
}

- (void)createTableFooterView
{
    if (_nums > 0) {
        [self.tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.tableView.frameHeight - 104)];
        [footView setBackgroundColor:self.tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, (footView.frameHeight - 80 - 40) / 2, 65, 80)];
        imgView.image = CREATE_IMG(@"order_default");
        [footView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 10, SCREEN_WIDTH - 80, 30)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"您还没有相关的订单"];
        [footView addSubview:label];
        
        [self.tableView setTableFooterView:footView];
    }
}

#pragma mark - actions
- (void)deleteOrder:(id)sender
{
    UITableViewCell *cell = [GlobalManager findViewFrom:sender To:[UITableViewCell class]];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    _nums--;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _nums;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *leftIdentifierBase = @"OrderInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:leftIdentifierBase];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftIdentifierBase];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        UILabel *tipLabl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 40)];
        [tipLabl setBackgroundColor:[UIColor clearColor]];
        [tipLabl setTextAlignment:NSTextAlignmentRight];
        [tipLabl setText:@"交易关闭"];
        [tipLabl setTextColor:[UIColor redColor]];
        [tipLabl setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:tipLabl];
        
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, tipLabl.frameBottom, SCREEN_WIDTH, 85)];
        [middleView setBackgroundColor:CreateColor(245, 245, 245)];
        [cell.contentView addSubview:middleView];
        //imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 7 + tipLabl.frameBottom, 70, 70)];
        [imageView setTag:1];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.contentView addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frameRight + 10, imageView.frameY, SCREEN_WIDTH - 20 - 80, 20)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:@"至宝贝"];
        [titleLabel setTextColor:CreateColor(86, 86, 86)];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frameRight, imageView.frameY, 80, 20)];
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setText:@"￥314.00"];
        [priceLabel setTextAlignment:NSTextAlignmentRight];
        [priceLabel setTextColor:CreateColor(146, 110, 253)];
        [priceLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:priceLabel];
        
        UILabel *formatLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frameX, titleLabel.frameBottom, SCREEN_WIDTH - 20, 20)];
        [formatLabel setBackgroundColor:[UIColor clearColor]];
        [formatLabel setText:@"简装书20P"];
        [formatLabel setTextColor:CreateColor(86, 86, 86)];
        [formatLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:formatLabel];
        
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frameX, formatLabel.frameBottom + 15, SCREEN_WIDTH - 20, 15)];
        [sizeLabel setBackgroundColor:[UIColor clearColor]];
        [sizeLabel setText:@"1132mm*2455mm"];
        [sizeLabel setTextColor:CreateColor(177, 177, 177)];
        [sizeLabel setFont:[UIFont systemFontOfSize:12]];
        [cell.contentView addSubview:sizeLabel];
        
        UILabel *contLabl = [[UILabel alloc] initWithFrame:CGRectMake(10, middleView.frameBottom, SCREEN_WIDTH - 20, 40)];
        [contLabl setBackgroundColor:[UIColor clearColor]];
        [contLabl setTextAlignment:NSTextAlignmentRight];
        [contLabl setText:@"共1件商品 合计：￥317.00（含运费￥3.00）"];
        [contLabl setTextColor:CreateColor(86, 86, 86)];
        [contLabl setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:contLabl];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, contLabl.frameBottom, SCREEN_WIDTH, 1)];
        [lineLabel setBackgroundColor:CreateColor(237, 237, 239)];
        [cell.contentView addSubview:lineLabel];
        
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn setFrame:CGRectMake(SCREEN_WIDTH - 86, lineLabel.frameBottom + 7, 76, 28)];
        [delBtn setTitle:@"删除订单" forState:UIControlStateNormal];
        [delBtn setTitleColor:BASELINE_COLOR forState:UIControlStateNormal];
        [delBtn setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
        [delBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [delBtn.layer setMasksToBounds:YES];
        [delBtn.layer setCornerRadius:3];
        [delBtn.layer setBorderWidth:1];
        [delBtn.layer setBorderColor:BASELINE_COLOR.CGColor];
        [cell.contentView addSubview:delBtn];
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    [imageView setBackgroundColor:[UIColor redColor]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 210;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 0 : 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

@end
