//
//  DragMakeView.h
//  TYSociety
//
//  Created by szl on 16/7/27.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DragMakeViewDelegate <NSObject>

@optional
- (void)changeLocation:(CGPoint)prePoint To:(CGPoint)nextPoint Angle:(CGFloat)angle;
- (void)changeLocationFinish;
- (void)hiddenMakePreView:(UIView *)view;
- (void)movePoint:(CGPoint)point;
- (void)beginToScaleMakeView:(CGFloat)scale;
- (void)beginToRotationMakeView:(CGFloat)angle;

@end

@interface DragMakeView : UIView

@property (nonatomic,assign)id<DragMakeViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Off:(CGPoint)offset;

@end
