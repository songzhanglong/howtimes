//
//  MyTableBarViewController.h
//  TYSociety
//
//  Created by szl on 16/7/6.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTableBar.h"

@interface MyTableBarViewController : UITabBarController<MyTableBarDelegate>

@property (nonatomic,strong)MyTableBar *customTabBar;

@end
