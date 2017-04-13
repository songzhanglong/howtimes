//
//  MakeView.h
//  NewTeacher
//
//  Created by szl on 16/2/23.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragMakeView.h"

@class MakeView;

@protocol MakeViewDelegate <NSObject>

@optional
- (void)touchMakeView:(MakeView *)makeView;
- (void)hiddPreView:(UIView *)preView Make:(MakeView *)makeView;

@end
#pragma mark - 自定义拖拽视图

@interface MakeView : UIView<DragMakeViewDelegate>

@property (nonatomic,readonly)UIImageView *curImg;
@property (nonatomic,assign)id<MakeViewDelegate> delegate;
@property (nonatomic,assign)CGFloat nRotation;
@property (nonatomic,assign)NSInteger checkIdx;
@property (nonatomic,assign)CGSize oriImgSize;

/**
 *	@brief	视图重设
 *
 *	@param 	image 	图片内容
 */
- (void)resetImageView:(UIImage *)image;

@end
