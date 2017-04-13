//
//  GrowTemplateModel.m
//  TYSociety
//
//  Created by zhangxs on 16/7/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "GrowTemplateModel.h"

@implementation Theme

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation GrowTemplateModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (GrowTemplateModel *)itemCopy
{
    GrowTemplateModel *model = [[GrowTemplateModel alloc] init];
    model.id = _id;
    model.theme_name = _theme_name;
    model.sort = _sort;
    model.template = _template;
    return model;
}

@end
