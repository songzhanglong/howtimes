//
//  CircleGestureView.h
//  TYSociety
//
//  Created by szl on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircleGestureViewDelegate <NSObject>

@optional
- (void)changeLocation:(CGPoint)prePoint To:(CGPoint)nextPoint Angle:(CGFloat)angle;
- (void)changeLocationFinish;

@end

@interface CircleGestureView : UIView

@property (nonatomic,assign)id<CircleGestureViewDelegate> delegate;

@end
