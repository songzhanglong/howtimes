//
//  DecoTextView.m
//  TYSociety
//
//  Created by szl on 16/8/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "DecoTextView.h"

@implementation DecoTextView

- (id)initWithFrame:(CGRect)frame Text:(NSString *)text TextColor:(UIColor *)textColor Alpha:(CGFloat)alpha Font:(UIFont *)font
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 20)];
        [label setBackgroundColor:self.backgroundColor];
        [label setFont:font];
        [label setNumberOfLines:0];
        [label setText:text];
        [label setTextColor:textColor];
        label.alpha = alpha;
        [self addSubview:label];
    }
    return self;
}

+ (UIImage *)convertSelfToImage:(UIView *)view
{
    CGSize s = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

@end
