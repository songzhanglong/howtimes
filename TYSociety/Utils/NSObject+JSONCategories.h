//
//  NSObject+JSONCategories.h
//  NewTeacher
//
//  Created by 杨海波 on 15/2/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSONCategories)
- (id)toArrayOrNSDictionary:(NSString *)jsonString;
@end
