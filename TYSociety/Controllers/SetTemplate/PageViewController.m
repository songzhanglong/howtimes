//
//  PageViewController.m
//  TYSociety
//
//  Created by szl on 16/7/19.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arr = [NSMutableArray array];
    [self createContentPages];
    self.dataSource =self;
    self.delegate =self;
}

- (void)createContentPages
{
    NSArray *colors = @[[UIColor redColor],[UIColor yellowColor],[UIColor greenColor]];
    for (int i = 0; i < 10; i ++) {
        NSInteger index = i % 3;
        UIViewController * viewCtl = [[UIViewController alloc]init];
        viewCtl.view.backgroundColor = colors[index];
        [self.arr addObject:viewCtl];
    }
    [self setViewControllers:@[_arr[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageContent = [[NSArray alloc] initWithArray:_arr];
}

//根据屏幕旋转方向设置书脊位置（Spine Location）和初始化首页
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    BOOL hori = (orientation > UIInterfaceOrientationPortraitUpsideDown);
    NSArray *viewControllers = hori ? @[_arr[0],_arr[1]] : @[_arr[0]];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.doubleSided = NO;
    return hori ? UIPageViewControllerSpineLocationMid : UIPageViewControllerSpineLocationMin;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [_arr indexOfObject:viewController];
    if (index >= 0 && index < _arr.count - 1) {
        return _arr[index + 1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [_arr indexOfObject:viewController];
    if (index > 0 && index <= _arr.count - 1) {
        return _arr[index - 1];
    }
    return nil;
}

@end
