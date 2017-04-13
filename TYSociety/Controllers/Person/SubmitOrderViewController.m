//
//  SubmitOrderViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/6/29.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SubmitOrderViewController.h"

@implementation SubmitOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"提交订单";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self createTableViewAndRequestAction:nil Param:nil Header:YES Foot:NO];
    [self.tableView setAutoresizingMask:UIViewAutoresizingNone];
    [self.tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50 - 64)];
    [self.tableView setBackgroundColor:CreateColor(241, 242, 245)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AdressCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UserInfoCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NoteMsgCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NormalCell"];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 50, SCREEN_WIDTH, 50)];
    [footerView setBackgroundColor:CreateColor(241, 242, 245)];
    [self.view addSubview:footerView];
    
    UILabel *countLab = [[UILabel alloc] initWithFrame:CGRectMake(14, 15, 200, 20)];
    [countLab setBackgroundColor:[UIColor clearColor]];
    [countLab setTextColor:[UIColor blackColor]];
    [countLab setFont:[UIFont boldSystemFontOfSize:16]];
    [countLab setText:@"数量1  实付款：￥99.00"];
    [footerView addSubview:countLab];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(SCREEN_WIDTH - 103 - 14, 7, 103, 35)];
    [btn setTitle:@"支 付" forState:UIControlStateNormal];
    [btn setBackgroundColor:CreateColor(146, 110, 253)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:3];
    [footerView addSubview:btn];
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
    NSString *cellId = (indexPath.section == 0) ? @"AdressCell" : ((indexPath.section == 1) ? @"UserInfoCell" : ((indexPath.section == 1) ? @"NoteMsgCell" : @"NormalCell"));
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (indexPath.section == 0) {
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
        if (!nameLabel) {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, SCREEN_WIDTH - 40, 25)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [nameLabel setTag:1];
            [cell.contentView addSubview:nameLabel];
        }
        [nameLabel setText:@"许紫默 137****3096"];
        
        UIImageView *adressImg = (UIImageView *)[cell.contentView viewWithTag:2];
        if (!adressImg) {
            adressImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, nameLabel.frameBottom + 5 + (25 - 49.0 / 3) / 2, 41.0 / 3, 49.0 / 3)];
            [adressImg setImage:CREATE_IMG(@"order_address")];
            [adressImg setTag:2];
            [cell.contentView addSubview:adressImg];
        }
        
        UILabel *adressLabel = (UILabel *)[cell.contentView viewWithTag:3];
        if (!adressLabel) {
            adressLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, nameLabel.frameBottom + 5, SCREEN_WIDTH - 40, 25)];
            [adressLabel setBackgroundColor:[UIColor clearColor]];
            [adressLabel setTextColor:CreateColor(86, 86, 86)];
            [adressLabel setFont:[UIFont systemFontOfSize:14]];
            [adressLabel setTag:3];
            [cell.contentView addSubview:adressLabel];
        }
        [adressLabel setText:@"江苏省南京市栖霞区花港幸福城海棠园7栋2单元610"];
        
        UIImageView *lineImg = (UIImageView *)[cell.contentView viewWithTag:4];
        if (!lineImg) {
            lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 75 - 17.0 / 3, SCREEN_WIDTH, 17.0 / 3)];
            [lineImg setImage:CREATE_IMG(@"order_line")];
            [lineImg setTag:4];
            [cell.contentView addSubview:lineImg];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1)
    {
        //imageView
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 5, 60, 60)];
            [imageView setTag:1];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            [cell.contentView addSubview:imageView];
        }
        [imageView setBackgroundColor:[UIColor redColor]];
        
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frameRight + 10, imageView.frameY, SCREEN_WIDTH - 20, 20)];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setText:@"至宝贝"];
            [titleLabel setTag:2];
            [titleLabel setTextColor:CreateColor(86, 86, 86)];
            [titleLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.contentView addSubview:titleLabel];
        }
        
        UILabel *formatLabel = (UILabel *)[cell.contentView viewWithTag:3];
        if (!formatLabel) {
            formatLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frameX, titleLabel.frameBottom, SCREEN_WIDTH - 20, 20)];
            [formatLabel setBackgroundColor:[UIColor clearColor]];
            [formatLabel setText:@"简装书20P"];
            [formatLabel setTag:3];
            [formatLabel setTextColor:CreateColor(86, 86, 86)];
            [formatLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.contentView addSubview:formatLabel];
        }
        
        UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:4];
        if (!priceLabel) {
            priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frameX, formatLabel.frameBottom + 5, SCREEN_WIDTH - 20, 15)];
            [priceLabel setBackgroundColor:[UIColor clearColor]];
            [priceLabel setText:@"￥99.00"];
            [priceLabel setTag:4];
            [priceLabel setTextColor:CreateColor(146, 110, 253)];
            [priceLabel setFont:[UIFont systemFontOfSize:12]];
            [cell.contentView addSubview:priceLabel];
        }
    }else if (indexPath.section == 4) {
        UIView *cellView = (UIView *)[cell.contentView viewWithTag:10];
        if (!cellView) {
            cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 75)];
            [cellView setBackgroundColor:[UIColor whiteColor]];
            [cell.contentView addSubview:cellView];
        }
        
        UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1];
        if (!textField) {
            textField = [[UITextField alloc] initWithFrame:CGRectMake(14, 14, SCREEN_WIDTH - 28, 30)];
            [textField.layer setMasksToBounds:YES];
            [textField.layer setCornerRadius:3];
            [textField.layer setBorderColor:CreateColor(237, 237, 239).CGColor];
            [textField.layer setBorderWidth:1];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setPlaceholder:@"备注信息"];
            [cell.contentView addSubview:textField];
        }
    }
    else {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, 100, 25)];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setTag:1];
            [titleLabel setTextColor:CreateColor(86, 86, 86)];
            [titleLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.contentView addSubview:titleLabel];
        }
        
        UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:2];
        if (!detailLabel) {
            detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frameRight + 10, 10, SCREEN_WIDTH - titleLabel.frameRight - 40, 25)];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            [detailLabel setTag:2];
            [detailLabel setTextAlignment:NSTextAlignmentRight];
            [detailLabel setTextColor:CreateColor(86, 86, 86)];
            [detailLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.contentView addSubview:detailLabel];
        }
        
        if (indexPath.section == 2) {
            [titleLabel setText:@"优惠券"];
            [detailLabel setText:@"未使用"];
        }else {
            [titleLabel setText:@"配送方式"];
            [detailLabel setText:@"普通快递6元"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0 || indexPath.section == 4) ? 75 : ((indexPath.section == 1) ? 70 : 45);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 0 : ((section == 1) ? 10 : 15);
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
