//
//  AddressManagerViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AddressManagerViewController.h"
#import "AddAddressViewController.h"

@implementation AddressManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"地址管理";
    self.navigationController.navigationBar.translucent = NO;
    [self createRightBarButton];

    [self createTableViewAndRequestAction:nil Param:nil Header:YES Foot:NO];
    [self.tableView setBackgroundColor:CreateColor(241, 242, 245)];
}

- (void)createRightBarButton
{
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 40, 30)];
    [rightBut setTitle:@"添加" forState:UIControlStateNormal];
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightBut addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    [self.navigationItem setRightBarButtonItems:@[rightItem] animated:YES];
}

- (void)addAction:(id)sender
{
    AddAddressViewController *addController = [[AddAddressViewController alloc] init];
    [self.navigationController pushViewController:addController animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"AddressManagerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH - 22, 25)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor blackColor]];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [nameLabel setTag:1];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *adressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, nameLabel.frameBottom + 5, SCREEN_WIDTH - 22 - 30, 25)];
        [adressLabel setBackgroundColor:[UIColor clearColor]];
        [adressLabel setTextColor:CreateColor(86, 86, 86)];
        [adressLabel setFont:[UIFont systemFontOfSize:14]];
        [adressLabel setTag:2];
        [cell.contentView addSubview:adressLabel];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(adressLabel.frameRight, adressLabel.frameY + 3.5, 30, 18)];
        [tipLabel setBackgroundColor:CreateColor(155, 127, 251)];
        [tipLabel setTextColor:[UIColor whiteColor]];
        [tipLabel.layer setMasksToBounds:YES];
        [tipLabel.layer setCornerRadius:3];
        [tipLabel setFont:[UIFont systemFontOfSize:14]];
        [tipLabel setTag:3];
        [tipLabel setText:@"默认"];
        [cell.contentView addSubview:tipLabel];
    };
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    [nameLabel setText:@"许紫默 137****3096"];
    
    UILabel *adressLabel = (UILabel *)[cell.contentView viewWithTag:2];
    [adressLabel setText:@"收货地址：江苏省南京市栖霞区花港幸福城海棠园"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
