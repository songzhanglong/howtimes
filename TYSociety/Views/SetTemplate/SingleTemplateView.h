//
//  SingleTemplateView.h
//  TYSociety
//
//  Created by zhangxs on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowDetailModel.h"

@class SingleTemplateView;
@protocol SingleTemplateViewDelegate <NSObject>

- (void)nextTemplateToScrollView:(SingleTemplateView *)view;
- (void)selectImageToScrollView:(SingleTemplateView *)view idx:(NSInteger)idx;

@end

@interface SingleTemplateView : UIView

@property (nonatomic, assign) id <SingleTemplateViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *nameLabel;

- (void)setContentView:(GrowDetailModel *)model;

@end
