//
//  MyCustomTextView.h
//  TYSociety
//
//  Created by szl on 16/7/29.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CanCancelImageView.h"

@interface MyCustomTextView : CanCancelImageView

@property (nonatomic,strong)NSString *colorStr;
@property (nonatomic,assign)CGFloat alphaColor;
@property (nonatomic,strong)NSString *textStr;
@property (nonatomic,strong)NSString *font_key;

@end
