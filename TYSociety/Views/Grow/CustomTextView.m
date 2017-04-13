//
//  CustomTextView.m
//  TYSociety
//
//  Created by szl on 16/7/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CustomTextView.h"
#import "Masonry.h"
#import "UIColor+Hex.h"

@implementation CustomTextView
{
    
    CGSize _oriSize;
}

- (UIImage *)addText:(UIImage *)img text:(NSString *)text1 Font:(UIFont *)font Color:(NSString *)color
{
    UIGraphicsBeginImageContext(img.size);
    [img drawAtPoint: CGPointZero];
    //[text1 drawAtPoint: CGPointMake(0, 0) withFont: font];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    UIColor *tmpColor = [UIColor colorWithHexString:color];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
    NSDictionary *attributes = @{NSFontAttributeName: font,NSForegroundColorAttributeName:tmpColor, NSParagraphStyleAttributeName: paragraphStyle};
    [text1 drawInRect:CGRectMake(0, 0, img.size.width, img.size.height) withAttributes:attributes];
    UIImage *watermarkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return watermarkedImage;
}

- (id)initWithFrame:(CGRect)frame Str:(NSString *)str Color:(NSString *)color Alpha:(CGFloat)alpha
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.textStr = str;
        self.colorStr = color;
        self.alphaColor = alpha;
        _oriSize = CGSizeMake(frame.size.width - 25, frame.size.height - 25);
        UIImage *img = [self addText:CREATE_IMG(@"textBack") text:str Font:[UIFont systemFontOfSize:17] Color:color];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(12.5, 12.5, frame.size.width - 25, frame.size.height - 25)];
        _borderImg = imgView;
        [imgView setBackgroundColor:[UIColor clearColor]];
        [imgView setImage:img];
        [self addSubview:imgView];
        /*
        //_fontSize = 17;
        _textView = [[UILabel alloc] initWithFrame:_borderImg.frame];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor blackColor];
        [_textView setTextAlignment:NSTextAlignmentCenter];
        [_textView setNumberOfLines:0];
        //[_textView setFont:[UIFont systemFontOfSize:_fontSize]];
        [_textView sizeThatFits:_textView.bounds.size];
        [self addSubview:_textView];
         */
        
        _editBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBut setFrame:CGRectMake(frame.size.width - 25, 0, 25, 25)];
        [_editBut setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin];
        [_editBut setImage:CREATE_IMG(@"dragEdit") forState:UIControlStateNormal];
        [_editBut setBackgroundColor:[UIColor clearColor]];
        [_editBut addTarget:self action:@selector(dragEditSelf:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_editBut];
        
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
        
        deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,self.frame.origin.x+self.frame.size.width - self.center.x);
        
        // 移动手势
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [self addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        _nRotation = 0;
    }
    return self;
}

- (void)deleteSelf:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteCustomText:)]) {
        [_delegate deleteCustomText:self];
    }
}

- (void)dragEditSelf:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(beginEditCustomText:)]) {
        [_delegate beginEditCustomText:self];
    }
}

/**
 *	@brief	控制显示与隐藏
 */
- (void)controlHiddenOrShow
{
    _isHidden = !_isHidden;
    [_editBut setHidden:_isHidden];
    [_deleteBut setHidden:_isHidden];
    [_dragImgView setHidden:_isHidden];
}

- (void)hiddenButton
{
    _isHidden = YES;
    [_editBut setHidden:_isHidden];
    [_deleteBut setHidden:_isHidden];
    [_dragImgView setHidden:_isHidden];
}

- (void)resetBoundSize:(CGSize)size
{
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, size.width, size.height);
    _oriSize = CGSizeMake(size.width - 25, size.height - 25);
    _borderImg.bounds = CGRectMake(_borderImg.bounds.origin.x, _borderImg.bounds.origin.y, size.width - 25, size.height - 25);
    _borderImg.center = CGPointMake(size.width / 2, size.height / 2);
    /*
    _textView.bounds = _borderImg.bounds;
    _textView.center = _borderImg.center;
    [_textView sizeThatFits:_textView.bounds.size];
     */
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
        CGPoint point = [recognizer locationInView:self];
        if (self.bounds.size.width < MIN_CUSTOMWEIGHT || self.bounds.size.height < MIN_CUSTOMWEIGHT)
        {
            CGFloat wei = MIN_CUSTOMWEIGHT - 25;
            CGFloat hei = wei * _oriSize.height / _oriSize.width;
            if (hei < MIN_CUSTOMWEIGHT - 25) {
                hei = MIN_CUSTOMWEIGHT - 25;
                wei = hei * _oriSize.width / _oriSize.height;
            }
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     wei + 25,
                                     hei + 25);
            _borderImg.bounds = CGRectMake(_borderImg.bounds.origin.x, _borderImg.bounds.origin.y, wei, hei);
            _borderImg.center = CGPointMake(12.5 + wei / 2, 12.5 + hei / 2);
            /*
            _textView.bounds = _borderImg.bounds;
            _textView.center = _borderImg.center;
            [_textView sizeThatFits:_textView.bounds.size];
             */
            prevPoint = point;
            
        }
        else{
            CGFloat wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            hChange = (point.y - prevPoint.y);
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
                prevPoint = point;
                return;
            }
            
            CGFloat wei,hei;
            if (ABS(wChange) > ABS(hChange)) {
                wei = self.bounds.size.width + wChange;
                hei = (wei - 25) * _oriSize.height / _oriSize.width + 25;
            }
            else{
                hei = self.bounds.size.height + hChange;
                wei = (hei - 25) * _oriSize.width / _oriSize.height + 25;
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, wei, hei);
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, wei, hei);
            _borderImg.bounds = CGRectMake(_borderImg.bounds.origin.x, _borderImg.bounds.origin.y, wei - 25, hei - 25);
            _borderImg.center = CGPointMake(wei / 2, hei / 2);
            /*
            _textView.bounds = _borderImg.bounds;
            _textView.center = _borderImg.center;
            [_textView sizeThatFits:_textView.bounds.size];
             */
            prevPoint = point;
            
            //        /* Rotation */
            CGPoint fatherPoint = [recognizer locationInView:self.superview];
            CGFloat ang = atan2(fatherPoint.y - self.center.y,fatherPoint.x - self.center.x);
            CGFloat angleDiff = deltaAngle - ang;
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
        }
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
        
    }
}

- (void)tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self controlHiddenOrShow];
}

@end
