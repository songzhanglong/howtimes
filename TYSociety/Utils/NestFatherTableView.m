//
//  NestFatherTableView.m
//  DesignByKid
//
//  Created by szl on 2017/2/21.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import "NestFatherTableView.h"

@implementation NestFatherTableView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
