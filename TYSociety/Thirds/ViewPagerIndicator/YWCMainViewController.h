//
//  YWCMainViewController.h
//  网易首页
//
//  Created by City--Online on 15/9/1.
//  Copyright (c) 2015年 City--Online. All rights reserved.
//

#import "BaseViewController.h"
#import "YWCTitleVCModel.h"
#import "YWCTopScrollView.h"

@protocol YWCMainViewControllerDelegate <NSObject>

@optional
- (void)changeSelectedIndex:(NSInteger)index;

@end

@interface YWCMainViewController : BaseViewController

@property (nonatomic,strong) NSMutableArray *titleVcModelArray;
@property (nonatomic,assign)BOOL showFiltrate;
@property (nonatomic,assign)CGSize bottomSize;
@property (nonatomic,assign)NSInteger initIdx;
@property (nonatomic,assign)BOOL rightItemType;
@property (nonatomic,assign)BOOL isCenter;
@property (nonatomic,strong) YWCTopScrollView *topScrollView;
@property (nonatomic,assign)id<YWCMainViewControllerDelegate> delegate;

@end
