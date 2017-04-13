//
//  AppDelegate.h
//  TYSociety
//
//  Created by szl on 16/6/12.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - 客服
- (void)launchQQClient;

#pragma mark - 信鸽推送
- (void)registerPush;
- (void)registerXGPushInfo;

@end

