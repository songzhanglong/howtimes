//
//  CouponViewController.h
//  TYSociety
//
//  Created by szl on 16/7/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@interface CouponViewController : TableViewController

@property (nonatomic,strong)NSNumber *status;       //1、未使用  2、已使用  3,已过期  不填为所有

@end
