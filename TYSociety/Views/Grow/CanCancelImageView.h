//
//  CanCancelImageView.h
//  NewTeacher
//
//  Created by szl on 16/2/23.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MIN_WEIGHT  40.0
#define MIN_HEIGHT  40.0

@class CanCancelImageView;
@protocol CanCancelImageViewDelegate <NSObject>

@optional
- (void)CancelImageView:(CanCancelImageView *)imageView;
- (void)moveImageView:(CanCancelImageView *)imageView;
- (void)checkCancelImgView:(CanCancelImageView *)imageView;
- (void)touchUpinsideImgView:(CanCancelImageView *)imageView;
- (void)editDecoTxtContent:(CanCancelImageView *)imageView;

@end

@interface CanCancelImageView : UIView
{
    BOOL _isHidden;
    UIButton *_deleteBut;
    UIImageView *_dragImgView;
    CGPoint prevPoint;
    CGFloat deltaAngle;
}

@property (nonatomic,strong)UIImageView *contentImg;
@property (nonatomic,assign)CGFloat nRotation;
@property (nonatomic,strong)NSString *imgPath;
@property (nonatomic,assign)id<CanCancelImageViewDelegate> delegate;

/**
 *	@brief	控制显示与隐藏
 */
- (void)controlHiddenOrShow;

- (void)hiddenButton;

@end
