//
//  UINavigationController+Status.m
//  XHQiu
//
//  Created by szl on 15/9/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "UINavigationController+Status.h"


@implementation UINavigationController(status)

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.topViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.topViewController prefersStatusBarHidden];
}

- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end
