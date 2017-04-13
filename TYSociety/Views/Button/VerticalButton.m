//
//  VerticalButton.m
//  ZChe
//
//  Created by szl on 15/12/19.
//  Copyright (c) 2015年 szl. All rights reserved.
//

#import "VerticalButton.h"

@implementation VerticalButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake((contentRect.size.width - self.textSize.width) / 2, (contentRect.size.height - self.imgSize.height - self.textSize.height - _margin) / 2 + self.imgSize.height + _margin, self.textSize.width, self.textSize.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake((contentRect.size.width - self.imgSize.width) / 2, (contentRect.size.height - self.imgSize.height - self.textSize.height - _margin) / 2, self.imgSize.width, self.imgSize.height);
}

@end
