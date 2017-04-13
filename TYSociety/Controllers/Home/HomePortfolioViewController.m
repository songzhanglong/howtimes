//
//  HomePortfolioViewController.m
//  TYSociety
//
//  Created by szl on 16/8/8.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "HomePortfolioViewController.h"

@implementation HomePortfolioViewController

- (void)createInitDataView
{
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    NSArray *array = [GlobalManager shareInstance].detailInfo.profiles;
    self.dataSource = array;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ScrollToTop object:nil];
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
        scrollView.scrollEnabled = NO;
    }
}

@end
