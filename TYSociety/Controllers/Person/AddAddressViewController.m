//
//  AddAddressViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AddAddressViewController.h"

@implementation AddAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"添加地址";
    self.navigationController.navigationBar.translucent = NO;
    [self createRightBarButton];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:YES Foot:NO];
    //[self.tableView setBackgroundColor:CreateColor(241, 242, 245)];
}

- (void)createRightBarButton
{
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 40, 30)];
    [rightBut setTitle:@"保存" forState:UIControlStateNormal];
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightBut addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    [self.navigationItem setRightBarButtonItems:@[rightItem] animated:YES];
}

- (void)saveAction:(id)sender
{
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"AddressManagerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, SCREEN_WIDTH - 28, 40)];
        [field setBackgroundColor:CreateColor(231, 225, 253)];
        [field.layer setMasksToBounds:YES];
        [field.layer setCornerRadius:3];
        [field setTextColor:[UIColor whiteColor]];
        [field setFont:[UIFont systemFontOfSize:14]];
        if (indexPath.section == 0) {
            [field setPlaceholder:@"收货人姓名"];
        }else if (indexPath.section == 1){
            [field setPlaceholder:@"电话/手机号码"];
        }else if (indexPath.section == 2) {
            [field setPlaceholder:@"邮政编码"];
        }else if (indexPath.section == 3) {
            [field setPlaceholder:@"省/市/区"];
        }else{
            field.frameHeight = 150;
            [field setPlaceholder:@"详细地址"];
        }
        
        [cell.contentView addSubview:field];
    };
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 4) ? 150 : 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 20 : 10;
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
