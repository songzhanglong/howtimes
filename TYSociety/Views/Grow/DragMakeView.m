//
//  DragMakeView.m
//  TYSociety
//
//  Created by szl on 16/7/27.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "DragMakeView.h"
#import "Masonry.h"

#define MinBorderImageWeight  50

@implementation DragMakeView
{
    UIView *_borderView;
    CGFloat deltaAngle;
    CGPoint prevPoint;
    CGRect _initRect;
}

- (id)initWithFrame:(CGRect)frame Off:(CGPoint)offset
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _initRect = frame;
        
        UIView *imgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 20)];
        _borderView = imgView;
        [imgView setBackgroundColor:[UIColor clearColor]];
        imgView.layer.masksToBounds = YES;
        imgView.layer.borderColor = [UIColor blackColor].CGColor;
        imgView.layer.borderWidth = 1;
        [self addSubview:imgView];
        
        UIButton *dragImgView = [UIButton buttonWithType:UIButtonTypeCustom];
        [dragImgView setFrame:CGRectMake(frame.size.width - 45 + offset.x, frame.size.height - 45 + offset.y, 45, 45)];
        [dragImgView setImage:CREATE_IMG(@"dragImg") forState:UIControlStateNormal];
        [dragImgView setImageEdgeInsets:UIEdgeInsetsMake(20, 20, 0, 0)];
        [dragImgView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
        [dragImgView setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *singleTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [dragImgView addGestureRecognizer:singleTap];
        [self addSubview:dragImgView];
        
        deltaAngle = atan2(self.frame.origin.y + self.frame.size.height - self.center.y,self.frame.origin.x + self.frame.size.width - self.center.x);
        
        // 移动手势
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [self addGestureRecognizer:panGestureRecognizer];
        
        // 旋转手势
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
        [self addGestureRecognizer:rotationGestureRecognizer];
        
        // 缩放手势
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        [self addGestureRecognizer:pinchGestureRecognizer];
    }
    return self;
}

- (void)deleteSelf:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(hiddenMakePreView:)]) {
        [_delegate hiddenMakePreView:self];
    }
}

#pragma mark - 右下角手势
- (void)singleTap:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGSize imgSize = self.bounds.size;
        CGPoint point = [recognizer locationInView:self];
        CGFloat wChange = 0.0, hChange = 0.0;
        
        wChange = (point.x - prevPoint.x);
        hChange = (point.y - prevPoint.y);
        if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
            prevPoint = point;
            return;
        }
        CGFloat fatherWei = self.superview.bounds.size.width,fatherHei = self.superview.bounds.size.height;
        CGFloat wei = MIN(MAX(imgSize.width + wChange, MinBorderImageWeight), fatherWei);
        CGFloat hei = MIN(fatherHei, MAX(imgSize.height + hChange, MinBorderImageWeight));
        
        self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, wei, hei);
        _borderView.bounds = CGRectMake(_borderView.bounds.origin.x, _borderView.bounds.origin.y, wei - 20, hei - 20);
        _borderView.center = CGPointMake(10 + _borderView.bounds.size.width / 2, 10 + _borderView.bounds.size.height / 2);
        
        //        /* Rotation */
        CGPoint fatherPoint = [recognizer locationInView:self.superview];
        CGFloat ang = atan2(fatherPoint.y - self.center.y,fatherPoint.x - self.center.x);
        CGFloat angleDiff = deltaAngle - ang;
        self.transform = CGAffineTransformMakeRotation(-angleDiff);
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeLocation:To:Angle:)]) {
            [_delegate changeLocation:prevPoint To:point Angle:angleDiff];
        }
        prevPoint = point;
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        if (_delegate && [_delegate respondsToSelector:@selector(changeLocationFinish)]) {
            [_delegate changeLocationFinish];
        }
        
        //deltaAngle = atan2(self.frame.origin.y + self.frame.size.height - self.center.y,self.frame.origin.x + self.frame.size.width - self.center.x);
        
        self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, _initRect.size.width, _initRect.size.height);
        _borderView.bounds = CGRectMake(_borderView.bounds.origin.x, _borderView.bounds.origin.y, _initRect.size.width - 20, _initRect.size.height - 20);
        _borderView.center = CGPointMake(10 + _borderView.bounds.size.width / 2, 10 + _borderView.bounds.size.height / 2);
        self.transform = CGAffineTransformIdentity;
    }
}

#pragma mark - self 手势
// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:self.superview];
        if (_delegate && [_delegate respondsToSelector:@selector(movePoint:)]) {
            [_delegate movePoint:translation];
        }
        [panGestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {

    }
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat scale = pinchGestureRecognizer.scale;
        pinchGestureRecognizer.scale = 1;
        if (_delegate && [_delegate respondsToSelector:@selector(beginToScaleMakeView:)]) {
            [_delegate beginToScaleMakeView:scale];
        }
    }
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat angle = rotationGestureRecognizer.rotation;
        [rotationGestureRecognizer setRotation:0];
        if (_delegate && [_delegate respondsToSelector:@selector(beginToRotationMakeView:)]) {
            [_delegate beginToRotationMakeView:angle];
        }
    }
    else if (rotationGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(changeLocationFinish)]) {
            [_delegate changeLocationFinish];
        }
    }
}

@end
