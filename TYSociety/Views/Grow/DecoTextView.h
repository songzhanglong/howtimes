//
//  DecoTextView.h
//  TYSociety
//
//  Created by szl on 16/8/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DecoTextView : UIView

- (id)initWithFrame:(CGRect)frame Text:(NSString *)text TextColor:(UIColor *)textColor Alpha:(CGFloat)alpha Font:(UIFont *)font;

+ (UIImage *)convertSelfToImage:(UIView *)view;

@end
