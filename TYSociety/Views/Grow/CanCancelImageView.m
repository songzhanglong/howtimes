//
//  CanCancelImageView.m
//  NewTeacher
//
//  Created by szl on 16/2/23.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import "CanCancelImageView.h"
#import "Masonry.h"

@implementation CanCancelImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(12.5, 12.5, frame.size.width - 25, frame.size.height - 25)];
        _contentImg.userInteractionEnabled = YES;
        _contentImg.layer.masksToBounds = YES;
        _contentImg.layer.borderWidth = 2.0;
        _contentImg.layer.borderColor = CreateColor(244, 174, 97).CGColor;
        [self addSubview:_contentImg];
        
        _deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBut setImage:CREATE_IMG(@"detailDel") forState:UIControlStateNormal];
        [_deleteBut setBackgroundColor:[UIColor clearColor]];
        [_deleteBut addTarget:self action:@selector(deleteSelf:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteBut setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_deleteBut];
        [_deleteBut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.top.equalTo(@(0));
            make.width.equalTo(@(25));
            make.height.equalTo(@(25));
        }];
        
        _dragImgView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 25, frame.size.height - 25, 25, 25)];
        [_dragImgView setImage:CREATE_IMG(@"dragImg")];
        [_dragImgView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
        [_dragImgView setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *singleTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [_dragImgView addGestureRecognizer:singleTap];
        [self addSubview:_dragImgView];
        
        deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                           self.frame.origin.x+self.frame.size.width - self.center.x);
        
        // 移动手势
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [_contentImg addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [_contentImg addGestureRecognizer:tapGestureRecognizer];
        _nRotation = 0;
        
    }
    return self;
}

- (void)deleteSelf:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(CancelImageView:)]) {
        [_delegate CancelImageView:self];
    }
}

/**
 *	@brief	控制显示与隐藏
 */
- (void)controlHiddenOrShow
{
    _isHidden = !_isHidden;
    [_deleteBut setHidden:_isHidden];
    [_dragImgView setHidden:_isHidden];
    
    UIColor *color = _isHidden ? [UIColor clearColor] : CreateColor(244, 174, 97);
    _contentImg.layer.borderColor = color.CGColor;
}

- (void)hiddenButton
{
    _isHidden = YES;
    [_deleteBut setHidden:_isHidden];
    [_dragImgView setHidden:_isHidden];
    _contentImg.layer.borderColor = [UIColor clearColor].CGColor;
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
        CGSize imgSize = _contentImg.image.size;
        if (self.bounds.size.width < MIN_WEIGHT || self.bounds.size.height < MIN_HEIGHT)
        {
            CGFloat wei = MIN_WEIGHT;
            CGFloat hei = wei * imgSize.height / imgSize.width;
            if (hei < MIN_HEIGHT) {
                hei = MIN_HEIGHT;
                wei = hei * imgSize.width / imgSize.height;
            }
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     wei + 25,
                                     hei + 25);
            _contentImg.bounds = CGRectMake(_contentImg.bounds.origin.x, _contentImg.bounds.origin.y, wei, hei);
            _contentImg.center = CGPointMake(12.5 + wei / 2, 12.5 + hei / 2);
            prevPoint = [recognizer locationInView:self];
            
        } else {
            CGPoint point = [recognizer locationInView:self];
            CGFloat wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            hChange = (point.y - prevPoint.y);
            
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
                prevPoint = [recognizer locationInView:self];
                return;
            }
            
            CGFloat wei,hei;
            if (ABS(wChange) > ABS(hChange)) {
                wei = self.bounds.size.width + wChange;
                hei = (wei - 25) * imgSize.height / imgSize.width + 25;
            }
            else{
                hei = self.bounds.size.height + hChange;
                wei = (hei - 25) * imgSize.width / imgSize.height + 25;
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, wei, hei);
            _contentImg.bounds = CGRectMake(_contentImg.bounds.origin.x, _contentImg.bounds.origin.y, wei - 25, hei - 25);
            _contentImg.center = CGPointMake(12.5 + _contentImg.bounds.size.width / 2, 12.5 + _contentImg.bounds.size.height / 2);
            prevPoint = [recognizer locationInView:self];
        }
        
        /* Rotation */
        CGFloat ang = atan2([recognizer locationInView:self.superview].y - self.center.y,[recognizer locationInView:self.superview].x - self.center.x);
        CGFloat angleDiff = deltaAngle - ang;
        self.transform = CGAffineTransformMakeRotation(-angleDiff);
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        double radians = atan2(self.transform.b, self.transform.a);
        _nRotation = radians * (180 / (CGFloat)M_PI);
    }
}

#pragma mark - self 手势
// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:self.superview];
        CGPoint point = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        [self setCenter:point];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(moveImageView:)]) {
            [_delegate moveImageView:self];
        }
    }
}

- (void)tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self controlHiddenOrShow];
    if (_delegate && [_delegate respondsToSelector:@selector(touchUpinsideImgView:)]) {
        [_delegate touchUpinsideImgView:self];
    }
}

@end
