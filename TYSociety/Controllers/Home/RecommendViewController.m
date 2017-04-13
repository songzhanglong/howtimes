//
//  RecommendViewController.m
//  TYSociety
//
//  Created by szl on 16/7/18.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "RecommendViewController.h"
#import "HomeRecommond.h"
#import "YWCMainViewController.h"
#import "CheckTemplateController.h"
#import "HomePageViewController.h"

@interface RecommendViewController ()

@end

@implementation RecommendViewController
{
    BOOL _canPush;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 5, 0)];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *homeBaseCellId = @"homeBaseCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:homeBaseCellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:homeBaseCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        //imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [imageView setTag:1];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.contentView addSubview:imageView];
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    RecommondItem *item = self.dataSource[indexPath.section];
    NSString *str = item.picture;
    if (![str hasPrefix:@"http"]) {
        str = [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
    }
    [imageView sd_setImageWithURL:[NSURL URLWithString:str]];
    
    return cell;
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RecommondItem *item = self.dataSource[indexPath.section];
    
    UINavigationController *nav = (UINavigationController *)[(UITabBarController *)[APPWindow rootViewController] selectedViewController];
    NSInteger curIdx = NSNotFound;
    for (NSInteger i = 0; i < _tags.count; i++) {
        AdTags *adTag = _tags[i];
        if ([adTag.id integerValue] == item.tag_id.integerValue) {
            curIdx = i;
            if (adTag.status.integerValue == 0) {
                [nav.view makeToast:@"精彩即将开始,敬请期待" duration:1.0 position:@"center"];
                return;
            }
            break;
        }
    }
    
    if (curIdx == NSNotFound) {
        [nav.view makeToast:@"精彩即将开始,敬请期待" duration:1.0 position:@"center"];
        return;
    }
    
    YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
    mainVc.showFiltrate = YES;
    mainVc.titleLable.text = @"作品展示";
    for (NSInteger i = 0; i < _tags.count; i++) {
        AdTags *adTag = _tags[i];
        if (adTag.status.integerValue == 0) {
            if (i < curIdx) {
                curIdx--;
            }
            continue;
        }
        
        YWCTitleVCModel *titleVcModel = [[YWCTitleVCModel alloc] init];
        titleVcModel.title = adTag.name;
        
        CheckTemplateController *checkTem = [[CheckTemplateController alloc] init];
        checkTem.tag_id = adTag.id;
        titleVcModel.viewController = checkTem;
        [mainVc.titleVcModelArray addObject:titleVcModel];
    }
    mainVc.initIdx = curIdx;
    mainVc.hidesBottomBarWhenPushed = YES;
    
    [nav pushViewController:mainVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH * 156 / 375;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

@end
