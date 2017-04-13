//
//  HAMURLSessionWrapperOperation.h
//  TYSociety
//
//  Created by szl on 16/6/20.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAMURLSessionWrapperOperation : NSOperation

+ (instancetype)operationWithURLSessionTask:(NSURLSessionTask*)task;

@end
