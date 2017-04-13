//
//  MakeView.m
//  NewTeacher
//
//  Created by szl on 16/2/23.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import "MakeView.h"
#import "HorizontalButton.h"

//#define MinImageWeight  30

@implementation MakeView
{
    HorizontalButton *_addBut;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = CreateColor(220, 220, 221);
        self.clipsToBounds = YES;
        [self addGestureRecognizerToView:self];
        
        _checkIdx = -1;
        
        _addBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
        _addBut.enabled = NO;
        [_addBut setFrame:CGRectMake((frame.size.width - 104) / 2, (frame.size.height - 14) / 2, 104, 14)];
        _addBut.imgSize = CGSizeMake(14, 14);
        _addBut.textSize = CGSizeMake(90, 14);
        [_addBut setBackgroundColor:[UIColor clearColor]];
        [_addBut setTitle:@"添加图片或者小视频" forState:UIControlStateNormal];
        [_addBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_addBut.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [_addBut setImage:CREATE_IMG(@"addMileageN") forState:UIControlStateNormal];
        [self addSubview:_addBut];
        
        _nRotation = 0;
    }
    
    return self;
}

- (void)changeContentImgSize:(CGSize)newSize
{
    CGFloat ratio = sqrt(2),minScale = MIN(self.bounds.size.width, self.bounds.size.height) / ratio;
    CGSize imgSize = _curImg.image.size;
    CGSize lastSize = CGSizeZero;
    if (_curImg.bounds.size.width < minScale || _curImg.bounds.size.width < minScale)
    {
        CGFloat wei = minScale;
        CGFloat hei = wei * imgSize.height / imgSize.width;
        if (hei < minScale) {
            hei = minScale;
            wei = hei * imgSize.width / imgSize.height;
        }
        lastSize = CGSizeMake(wei, hei);
    } else {
        CGFloat newWei = MIN(newSize.width, _oriImgSize.width * ratio);
        CGFloat newHei = newWei * imgSize.height / imgSize.width;
        lastSize = CGSizeMake(newWei, newHei);
        
    }
    if (!CGSizeEqualToSize(_curImg.bounds.size, lastSize)) {
        _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, lastSize.width, lastSize.height);
    }
}

#pragma mark - 手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
    
    // 单击
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [view addGestureRecognizer:tapGestureRecognizer];
    
    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (!_curImg) {
        return;
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGSize newSize = CGSizeMake(_curImg.bounds.size.width * pinchGestureRecognizer.scale, _curImg.bounds.size.height * pinchGestureRecognizer.scale);
        [self changeContentImgSize:newSize];
        pinchGestureRecognizer.scale = 1;
    }
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    if (!_curImg) {
        return;
    }
    
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        _curImg.transform = CGAffineTransformRotate(_curImg.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
    else if (rotationGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        double radians = atan2(_curImg.transform.b, _curImg.transform.a);
        _nRotation = radians * (180 / (CGFloat)M_PI);
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!_curImg) {
        return;
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGestureRecognizer translationInView:self.superview];
        CGPoint point = CGPointMake(_curImg.center.x + translation.x, _curImg.center.y + translation.y);
        [_curImg setCenter:point];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
}

- (void)tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchMakeView:)]) {
        [_delegate touchMakeView:self];
    }
}

#pragma mark - 视图重设
/**
 *	@brief	视图重设
 *
 *	@param 	image 	图片内容
 */
- (void)resetImageView:(UIImage *)image
{
    if (_curImg) {
        [_curImg removeFromSuperview];
        _curImg = nil;
    }
    
    if (!image) {
        _nRotation = 0;
        _addBut.hidden = NO;
        return;
    }
    
    _nRotation = 0;
    _addBut.hidden = YES;
    _curImg = [[UIImageView alloc] init];
    _curImg.backgroundColor = [UIColor blackColor];
    [_curImg setUserInteractionEnabled:YES];
    [_curImg setMultipleTouchEnabled:YES];
    _curImg.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_curImg];
    [self sendSubviewToBack:_curImg];
    
    [_curImg setImage:image];
}

#pragma mark - DragMakeViewDelegate
- (void)changeLocation:(CGPoint)prePoint To:(CGPoint)nextPoint Angle:(CGFloat)angle
{
    if (!_curImg) {
        return;
    }
    CGFloat ratio = sqrt(2),minScale = MIN(self.bounds.size.width, self.bounds.size.height) / ratio;
    CGSize imgSize = _curImg.image.size;
    if (_curImg.bounds.size.width < minScale || _curImg.bounds.size.width < minScale)
    {
        CGFloat wei = minScale;
        CGFloat hei = wei * imgSize.height / imgSize.width;
        if (hei < minScale) {
            hei = minScale;
            wei = hei * imgSize.width / imgSize.height;
        }
        if (!CGSizeEqualToSize(_curImg.bounds.size, CGSizeMake(wei, hei))) {
            _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, wei, hei);
        }
        
    } else {
        CGFloat wChange = 0.0, hChange = 0.0;
        
        wChange = (nextPoint.x - prePoint.x) * self.bounds.size.width / 100;
        hChange = (nextPoint.y - prePoint.y) * self.bounds.size.width / 100;
        
        CGFloat wei,hei;
        if (ABS(wChange) > ABS(hChange)) {
            wei = _curImg.bounds.size.width + wChange;
            wei = MIN(wei, _oriImgSize.width * ratio);
            hei = wei * imgSize.height / imgSize.width;
        }
        else{
            hei = _curImg.bounds.size.height + hChange;
            hei = MIN(hei, _oriImgSize.height * ratio);
            wei = hei * imgSize.width / imgSize.height;
        }
        
        if (!CGSizeEqualToSize(_curImg.bounds.size, CGSizeMake(wei, hei))) {
            _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, wei, hei);
        }
        CGFloat curRotation = _nRotation * M_PI / 180.0;
        _curImg.transform = CGAffineTransformMakeRotation(curRotation-angle);
    }
}

- (void)changeLocationFinish
{
    if (!_curImg) {
        return;
    }
    double radians = atan2(_curImg.transform.b, _curImg.transform.a);
    _nRotation = radians * (180 / (CGFloat)M_PI);
}

- (void)hiddenMakePreView:(UIView *)view
{
    if (_delegate && [_delegate respondsToSelector:@selector(hiddPreView:Make:)]) {
        [_delegate hiddPreView:view Make:self];
    }
}

- (void)movePoint:(CGPoint)translation
{
    if (!_curImg) {
        return;
    }
    CGPoint point = CGPointMake(_curImg.center.x + translation.x, _curImg.center.y + translation.y);
    [_curImg setCenter:point];
}

- (void)beginToScaleMakeView:(CGFloat)scale
{
    if (!_curImg) {
        return;
    }
    
    CGSize newSize = CGSizeMake(_curImg.bounds.size.width * scale, _curImg.bounds.size.height * scale);
    [self changeContentImgSize:newSize];
}

- (void)beginToRotationMakeView:(CGFloat)angle
{
    if (!_curImg) {
        return;
    }
    
    _curImg.transform = CGAffineTransformRotate(_curImg.transform, angle);
}

@end
