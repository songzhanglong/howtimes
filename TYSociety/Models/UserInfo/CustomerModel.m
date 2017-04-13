//
//  CustomerModel.m
//  TYSociety
//
//  Created by zhangxs on 16/7/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CustomerModel.h"

@implementation CustomerModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation BatchCustomers

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
