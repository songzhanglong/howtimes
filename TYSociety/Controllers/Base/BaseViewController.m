//
//  BaseViewController.m
//  TYSociety
//
//  Created by szl on 16/6/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc
{
    if (_sessionTask && (_sessionTask.state == NSURLSessionTaskStateRunning)) {
        [_sessionTask cancel];
    }
    self.sessionTask = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //避免push时会看似停顿
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setShowBack:(BOOL)showBack
{
    if (showBack) {
        //返回按钮
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
        backBtn.backgroundColor = [UIColor clearColor];
        [backBtn setImage:CREATE_IMG(@"navBack@2x") forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToPreControl:) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(6.5, 0, 6.5, 30)];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        //negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, backBarButtonItem];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        [rightView setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *rigBtn = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,rigBtn];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = nil;
    }
}

/**
 *	@brief	返回事件，子类可复写
 *
 *	@param 	sender 	按钮
 */
- (void)backToPreControl:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 标题
- (UILabel *)titleLable
{
    if (!_titleLable) {
        
//        CGRect leftViewbounds = ((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView.bounds;
//        CGRect rightViewbounds = ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.bounds;
//        CGFloat maxWidth = MAX(leftViewbounds.size.width + 25, rightViewbounds.size.width + 25);

        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 120, 21)];
        [_titleLable setFont:BigFont];
        [_titleLable setTextAlignment:NSTextAlignmentCenter];
        [_titleLable setTextColor:[UIColor whiteColor]];
        [_titleLable setBackgroundColor:[UIColor clearColor]];
        self.navigationItem.titleView = _titleLable;
    }
    
    return _titleLable;
}

- (UIButton *)titleButton
{
    if (!_titleButton) {
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleButton setFrame:CGRectMake(0, 0, SCREEN_WIDTH - 120, 21)];
        [_titleButton.titleLabel setFont:BigFont];
        [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleButton setBackgroundColor:[UIColor clearColor]];
        [_titleButton addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = _titleButton;
    }
    
    return _titleButton;
}

- (void)titleAction:(id)sender
{
    
}

#pragma mark - 状态栏与方向
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
