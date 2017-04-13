//
//  PageViewController.h
//  TYSociety
//
//  Created by szl on 16/7/19.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIPageViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic,strong)NSArray *pageContent;
@property (nonatomic,strong)NSMutableArray *arr;

@end
