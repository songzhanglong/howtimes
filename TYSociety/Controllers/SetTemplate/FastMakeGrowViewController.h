//
//  FastMakeGrowViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/7/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"
#import "GrowDetailModel.h"

@interface FastMakeGrowViewController : TableViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSString *batch_id;
@property (nonatomic, strong) NSString *grow_id;
@property (nonatomic, strong) NSString *template_id;
@property (nonatomic, strong) NSMutableArray *datailTemplates;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *selectsData;
@property (nonatomic, strong) NSMutableDictionary *selectDictory;
@property (nonatomic, strong) ImageCoor *imgItem;
@end
