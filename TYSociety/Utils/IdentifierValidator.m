//
//  DJTIdentifierValidator.m
//  MZJD
//
//  Created by user on 4/21/14.
//  Copyright (c) 2014 DIGIT. All rights reserved.
//

#import "IdentifierValidator.h"

BOOL isNumber (char ch);
BOOL isCharactor (char ch);

BOOL isNumber (char ch)
{
    if (!(ch >= '0' && ch <= '9')) {
        return FALSE;
    }
    return TRUE;
}
BOOL isCharactor (char ch)
{
    if ((ch >= 'a' && ch <= 'z')||(ch >= 'A' && ch <= 'Z')) {
        return TRUE;
    }
    return FALSE;
}

@implementation IdentifierValidator

+ (BOOL) isValidNumberOrEnglish:(NSString *)value
{
    const char *cvalue = [value UTF8String];
    long len = strlen(cvalue);
    for (int i = 0; i < len; i++) {
        if(!(isNumber(cvalue[i]) || isCharactor(cvalue[i]))){
            return FALSE;
        }
    }
    return TRUE;
}

+ (BOOL) isValidNumber:(NSString*)value{
    const char *cvalue = [value UTF8String];
    long len = strlen(cvalue);
    for (int i = 0; i < len; i++) {
        if(!isNumber(cvalue[i])){
            return FALSE;
        }
    }
    return TRUE;
}

+ (BOOL) isValidPhone:(NSString*)value {
    const char *cvalue = [value UTF8String];
    long len = strlen(cvalue);
    if (len != 11) {
        return FALSE;
    }
    if (![IdentifierValidator isValidNumber:value])
    {
        return FALSE;
    }
    NSString *preString = [[NSString stringWithFormat:@"%@",value] substringToIndex:1];
    if (/*[preString isEqualToString:@"13"] ||
        [preString isEqualToString: @"14"] ||
        [preString isEqualToString: @"15"] ||
        [preString isEqualToString: @"18"]*/[preString isEqualToString:@"1"])
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
    return TRUE;
}

@end
