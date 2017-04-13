//
//  MyCustomTextView.m
//  TYSociety
//
//  Created by szl on 16/7/29.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyCustomTextView.h"
#import "Masonry.h"

@implementation MyCustomTextView
{
    UIButton *_editBtn;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _alphaColor = 1;
        
        UIImageView *imgView = [[UIImageView alloc] init];
        [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imgView setImage:CREATE_IMG(@"textBack")];
        [imgView setBackgroundColor:[UIColor clearColor]];
        [self.contentImg addSubview:imgView];
        
        self.contentImg.layer.borderWidth = 0;
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentImg).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        UIButton *dragBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [dragBtn setFrame:CGRectMake(frame.size.width - 25, 0, 25, 25)];
        [dragBtn setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin];
        _editBtn = dragBtn;
        [dragBtn setImage:CREATE_IMG(@"dragEdit") forState:UIControlStateNormal];
        [dragBtn setBackgroundColor:[UIColor clearColor]];
        [dragBtn addTarget:self action:@selector(editDecoText:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dragBtn];
    }
    return self;
}

- (void)editDecoText:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editDecoTxtContent:)]) {
        [self.delegate editDecoTxtContent:self];
    }
}

- (void)hiddenButton
{
    [super hiddenButton];
    _editBtn.hidden = _deleteBut.hidden;
}

- (void)controlHiddenOrShow
{
    [super controlHiddenOrShow];
    _editBtn.hidden = _deleteBut.hidden;
}

@end
