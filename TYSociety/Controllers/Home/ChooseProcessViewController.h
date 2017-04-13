//
//  ChooseProcessViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/7/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"
#import "HomeRecommond.h"
@interface ChooseProcessViewController : TableViewController

@property (nonatomic, strong) NSString *batch_id;
@property (nonatomic, strong) HomeRecommond *recommond;

@end
