//
//  SizeReferenceViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/8/3.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SizeReferenceViewController.h"

@implementation SizeReferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.navigationController.navigationBar.translucent = NO;
    self.titleLable.text = @"相册尺寸";
    
    [self.view setBackgroundColor:CreateColor(240, 239, 244)];
    
    UIScrollView *scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - self.navigationController.navigationBar.frameHeight)];
    [scrollerView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:scrollerView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 316) / 2, 15, 316, 528.5)];//632 1057
    [imgView setImage:CREATE_IMG(@"size_reference")];
    [scrollerView addSubview:imgView];
    [scrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, imgView.frameBottom + 40)];
}

@end
