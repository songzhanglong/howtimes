//
//  MyTableBarViewController.m
//  TYSociety
//
//  Created by szl on 16/7/6.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyTableBarViewController.h"
#import "HomePageViewController.h"
#import "StoryViewController.h"
#import "ActivityViewController.h"
#import "UserInfoViewController.h"
#import "RZPopupMenuView.h"
#import "LoginViewController.h"
#import "NavigationController.h"
#import "YWCMainViewController.h"
#import "CheckTemplateController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MyTableBarViewController ()<RZPopupMenuViewDelegate,UIAlertViewDelegate>

@end

@implementation MyTableBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINavigationController *navHome = [[NavigationController alloc] initWithRootViewController:[HomePageViewController new]];
    UINavigationController *navWork = [[NavigationController alloc] initWithRootViewController:[StoryViewController new]];
    UINavigationController *navMsg = [[NavigationController alloc] initWithRootViewController:[ActivityViewController new]];
    UINavigationController *navSet = [[NavigationController alloc] initWithRootViewController:[UserInfoViewController new]];
    YWCMainViewController *mainVc = [YWCMainViewController new];
    CGSize tmpSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 49 - 64);
    mainVc.bottomSize = tmpSize;
    HomeRecommond *recommond = [self dealWithRecommondData];
    NSInteger tagCount = [recommond.tags count];
    for (NSInteger i = 0; i < tagCount; i++) {
        AdTags *adTag = recommond.tags[i];
        if (adTag.status.integerValue == 0) {
            continue;
        }
        YWCTitleVCModel *titleVcModel = [[YWCTitleVCModel alloc] init];
        titleVcModel.title = adTag.name;
        CheckTemplateController *checkTem = [[CheckTemplateController alloc] init];
        checkTem.tag_id = adTag.id;
        titleVcModel.viewController = checkTem;
        [mainVc.titleVcModelArray addObject:titleVcModel];
    }
    mainVc.isCenter = YES;
    mainVc.showFiltrate = YES;
    mainVc.titleLable.text = @"作品展示";
    mainVc.initIdx = 0;
    UINavigationController *navCenter = [[NavigationController alloc] initWithRootViewController:mainVc];
    
    
    self.viewControllers = @[navHome,navWork,navCenter,navMsg,navSet];
    
    _customTabBar = [[MyTableBar alloc] initWithFrame:self.tabBar.bounds];
    _customTabBar.delegate = self;
    [self.tabBar addSubview:_customTabBar];
    [self.tabBar setBackgroundImage:[UIImage new]];
    [self.tabBar setShadowImage:[UIImage new]];
    
    [self checkAlbumAuthorization];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.selectedViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.selectedViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.selectedViewController beginAppearanceTransition: NO animated: animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.selectedViewController endAppearanceTransition];
}

- (void)checkAlbumAuthorization
{
    int author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        // The user has explicitly denied permission for media capture.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法使用相册" message:@"请在iPhone的\"设置-隐私-照片\"中允许访问照片。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Photos"]];
    }
}

#pragma mark - 初始数据
- (HomeRecommond *)dealWithRecommondData
{
    //文件存储
    NSString *jsPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",NSStringFromClass([HomePageViewController class])]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:jsPath]) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:jsPath];
        HomeRecommond *recommond = [[HomeRecommond alloc] initWithDictionary:dic error:nil];
        return recommond;
    }
    else{
        NSString *resource = [[NSBundle mainBundle] pathForResource:NSStringFromClass([HomePageViewController class]) ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:resource];
        HomeRecommond *recommond = [[HomeRecommond alloc] initWithDictionary:dic error:nil];
        return recommond;
    }
}

#pragma mark - MyTableBarDelegate
- (void)selectTableIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        case 1:
        {
            self.selectedIndex = index;
            _customTabBar.nSelectedIndex = index;
        }
            break;
        case 2:
        {
            self.selectedIndex = index;
            _customTabBar.nSelectedIndex = index;
            
            //[RZPopupMenuView showWithDelegate:self];
        }
            break;
        case 3:
        {
            _customTabBar.nSelectedIndex = index;
            self.selectedIndex = index;
        }
            break;
        case 4:
        {
            UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
            if (!detail) {
                [self presentViewController:[[NavigationController alloc] initWithRootViewController:[LoginViewController new]] animated:YES completion:nil];
            }else {
                _customTabBar.nSelectedIndex = index;
                self.selectedIndex = index;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - RZPopupMenuViewDelegate
- (void)popupMenuView:(RZPopupMenuView *)view selectedIndex:(NSInteger)index
{
    NSLog(@"%ld",(long)index);
}

#pragma mark - 状态栏&旋转
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.selectedViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.selectedViewController.prefersStatusBarHidden;
}

- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end
