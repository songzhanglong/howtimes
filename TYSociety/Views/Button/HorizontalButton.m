//
//  MyButton.m
//  XHQiu
//
//  Created by songzhanglong on 15/8/26.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "HorizontalButton.h"

@implementation HorizontalButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat combineWei = _textSize.width + _imgSize.width;
    if (_leftText) {
        return CGRectMake((contentRect.size.width - combineWei) / 2, (contentRect.size.height - _textSize.height) / 2, _textSize.width, _textSize.height);
    }
    else{
        return CGRectMake((contentRect.size.width - combineWei) / 2 + _imgSize.width, (contentRect.size.height - _textSize.height) / 2, _textSize.width, _textSize.height);
    }
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat combineWei = _textSize.width + _imgSize.width;
    if (_leftText) {
        return CGRectMake((contentRect.size.width - combineWei) / 2 + _textSize.width, (contentRect.size.height - _imgSize.height) / 2, _imgSize.width, _imgSize.height);
    }
    else{
        return CGRectMake((contentRect.size.width - combineWei) / 2, (contentRect.size.height - _imgSize.height) / 2, _imgSize.width, _imgSize.height);
    }
}

@end
