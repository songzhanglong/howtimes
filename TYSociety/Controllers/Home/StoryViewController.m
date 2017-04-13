//
//  StoryViewController.m
//  TYSociety
//
//  Created by szl on 16/7/18.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "StoryViewController.h"

@interface StoryViewController ()

@end

@implementation StoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLable.text = @"故事汇";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = PortfolioColor;
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self createTableFooterView];
    self.tableView.scrollEnabled = NO;
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        if (self.tableView.tableHeaderView) {
            [self.tableView setTableHeaderView:nil];
        }
    }
    else{
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100 + 96)];
        [headView setBackgroundColor:self.tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, 100, 65, 80)];
        imgView.image = CREATE_IMG(@"order_default");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 10, SCREEN_WIDTH - 80, 30)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"精彩即将开始,敬请期待"];
        [headView addSubview:label];
        
        [self.tableView setTableHeaderView:headView];
    }
}

@end
