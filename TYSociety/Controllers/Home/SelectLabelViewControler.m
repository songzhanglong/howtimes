//
//  SelectLabelViewControler.m
//  TYSociety
//
//  Created by zhangxs on 16/7/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SelectLabelViewControler.h"

@implementation SelectLabelViewControler

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"选择标签";
    self.navigationController.navigationBar.translucent = NO;

}

@end
