//
//  BatchDetailViewController.h
//  TYSociety
//
//  Created by szl on 16/7/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"

typedef enum{
    kBackMakeFinish = 0,    //制作完成后返回
    kBackMakeReturnKey,     //返回键
    kBackMakeBlank,         //空白框
    kBackMakeAddPicture     //添加图片
}kBackMakeType;

@class RecordTemplate;
@protocol BatchDetailViewControllerDelegate <NSObject>

@optional
- (void)changeDetailFinishAt:(NSInteger)index Type:(kBackMakeType)backType;

@end

@interface BatchDetailViewController : BaseViewController

@property (nonatomic,strong)RecordTemplate *recordTemplate;
@property (nonatomic,assign)CGSize templateSize;
@property (nonatomic,strong)UIImage *templateImg;
@property (nonatomic,assign)CGFloat fRate;
@property (nonatomic,assign)CGFloat newRate;
@property (nonatomic,strong)NSMutableArray *localArr;
@property (nonatomic,assign)NSInteger initIdx;
@property (nonatomic,assign)id<BatchDetailViewControllerDelegate> delegate;

@end
