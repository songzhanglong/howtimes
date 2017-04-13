//
//  MyPortfolioViewController.h
//  TYSociety
//
//  Created by szl on 16/7/18.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"
#import "HomeRecommond.h"
@class MyTimeRecord;;

@interface MyPortfolioViewController : TableViewController

@property (nonatomic,strong)MyTimeRecord *timeRecord;
@property (nonatomic,strong)HomeRecommond *recommond;

@end
