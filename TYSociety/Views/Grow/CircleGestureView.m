//
//  CircleGestureView.m
//  TYSociety
//
//  Created by szl on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CircleGestureView.h"

@interface CircleGestureView()

@property (nonatomic,strong)UIView *dotView;

@end

@implementation CircleGestureView
{
    CGPoint _prePoint,_centerPoint;
    CGFloat deltaAngle;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.width / 2;
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        _dotView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 20) / 2, (frame.size.width - 20) / 2, 20, 20)];
        _dotView.layer.masksToBounds = YES;
        _dotView.layer.cornerRadius = 10;
        [_dotView setBackgroundColor:BASELINE_COLOR];
        [self addSubview:_dotView];
        
        deltaAngle = atan2(self.frame.origin.y + self.frame.size.height - self.center.y,self.frame.origin.x + self.frame.size.width - self.center.x);
        _centerPoint = self.center;
        
        // 移动手势
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        _prePoint = [panGestureRecognizer locationInView:self];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [panGestureRecognizer locationInView:self];
        CGFloat wChange = 0.0, hChange = 0.0;
        
        wChange = (point.x - _prePoint.x);
        hChange = (point.y - _prePoint.y);
        
        if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
            _prePoint = point;
            return;
        }
        
        CGPoint fatherPoint = [panGestureRecognizer locationInView:self.superview];
        /* Rotation */
        CGFloat ang = atan2(fatherPoint.y - _centerPoint.y,fatherPoint.x - _centerPoint.x);
        CGFloat angleDiff = deltaAngle - ang;
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeLocation:To:Angle:)]) {
            [_delegate changeLocation:_prePoint To:point Angle:angleDiff];
        }
        CGPoint center = _dotView.center;
        [_dotView setCenter:CGPointMake(center.x + point.x - _prePoint.x, center.y + point.y - _prePoint.y)];
        
        _prePoint = point;
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [_dotView setCenter:CGPointMake(self.frameWidth / 2, self.frameHeight / 2)];
        if (_delegate && [_delegate respondsToSelector:@selector(changeLocationFinish)]) {
            [_delegate changeLocationFinish];
        }
    }
}

@end
