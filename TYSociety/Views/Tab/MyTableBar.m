//
//  MyTableBar.m
//  TYSociety
//
//  Created by szl on 16/7/6.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyTableBar.h"
#import "VerticalButton.h"

@interface MyTableBar ()

@end

@implementation MyTableBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = rgba(245, 245, 245, 1);
        
        //line
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        [lineView setBackgroundColor:rgba(214, 215, 220, 1)];
        [self addSubview:lineView];
        
        //buttons
        CGFloat butWei = 42,butMiddle = 55,butHei = 44;
        CGFloat margin = (frame.size.width - butMiddle - butWei * 4) / 5;
        
        NSArray *titles = @[@"书柜",@"故事汇",@"",@"活动",@"我的"];
        NSArray *titleImgArray = @[@"bookCase",@"storyCollection",@"homePageAdd",@"activity",@"mine"];
        NSArray *titleHeilightImgArray = @[@"bookCaseH",@"storyCollectionH",@"homePageAdd",@"activityH",@"mineH"];
        
        for (NSInteger i = 0 ; i < titles.count; i++) {
            CGFloat xOri = margin / 2 + (butWei + margin) * i + ((i > 2) ? (butMiddle - butWei) : 0);
            VerticalButton *but = [VerticalButton buttonWithType:UIButtonTypeCustom];
            CGFloat wei = (i == 2) ? butMiddle : butWei;
            if(i != 2)
            {
                [but setFrame:CGRectMake(xOri, 5, wei, butHei)];
                [but setTitle:titles[i] forState:UIControlStateNormal];
                but.margin = 5;
                but.imgSize = CGSizeMake(25, 24);
                but.textSize = CGSizeMake(butWei, 14);
            }
            else{
                [but setFrame:CGRectMake(xOri, -butMiddle / 3, butMiddle, butMiddle)];
                but.imgSize = CGSizeMake(butMiddle, butMiddle);
            }
            [but setTitle:titles[i] forState:UIControlStateNormal];
            [but setImage:CREATE_IMG(titleImgArray[i]) forState:UIControlStateNormal];
            [but setImage:CREATE_IMG(titleHeilightImgArray[i]) forState:UIControlStateSelected];
            [but setTitleColor:rgba(167, 166, 166, 1) forState:UIControlStateNormal];
            [but setTitleColor:BASELINE_COLOR forState:UIControlStateSelected];
            [but.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [but.titleLabel setFont:[UIFont systemFontOfSize:10]];

            [but addTarget:self action:@selector(selectController:) forControlEvents:UIControlEventTouchUpInside];
            but.tag = i + 1;
            but.selected = (i == _nSelectedIndex);
            
            [self addSubview:but];
        }
    }
    
    return self;
}

- (void)selectController:(id)sender
{
    NSInteger index = [sender tag] - 1;
    if (_nSelectedIndex != index) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectTableIndex:)]) {
            [_delegate selectTableIndex:index];
        }
    }
}

- (void)setNSelectedIndex:(NSInteger)nSelectedIndex
{
    _nSelectedIndex = nSelectedIndex;
    for (UIView *subView in [self subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [(UIButton *)subView setSelected:(subView.tag - 1 == nSelectedIndex)];
        }
    }
}

@end
