//
//  DJTIdentifierValidator.h
//  MZJD
//
//  Created by user on 4/21/14.
//  Copyright (c) 2014 DIGIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdentifierValidator : NSObject

+ (BOOL) isValidPhone:(NSString*)value;
+ (BOOL) isValidNumberOrEnglish:(NSString *)value;

@end
