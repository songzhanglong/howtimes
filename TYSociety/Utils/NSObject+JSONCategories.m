//
//  NSObject+JSONCategories.m
//  NewTeacher
//
//  Created by 杨海波 on 15/2/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NSObject+JSONCategories.h"

@implementation NSObject (JSONCategories)
- (id)toArrayOrNSDictionary:(NSString *)jsonString{
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSError *error = nil;
    jsonString =[jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    
    if (jsonObject != nil||error == nil){
        return jsonObject;
    }else{
        NSLog(@"json解析失败：%@",error);
        // 解析错误
        return nil;
    }
    
}
@end
