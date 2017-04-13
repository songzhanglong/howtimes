//
//  GoodsInfoView.h
//  TYSociety
//
//  Created by zhangxs on 16/8/2.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoodsInfoView;
@protocol GoodsInfoViewDelegate <NSObject>

- (void)cancelGoodsInfoView;

@end

@interface GoodsInfoView : UIView
@property (nonatomic, assign) id <GoodsInfoViewDelegate> delegate;

- (void)restDatas:(NSMutableArray *)dataSource;

@end
