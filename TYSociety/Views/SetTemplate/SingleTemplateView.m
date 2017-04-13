//
//  SingleTemplateView.m
//  TYSociety
//
//  Created by zhangxs on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SingleTemplateView.h"

@implementation SingleTemplateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)setContentView:(GrowDetailModel *)model
{
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 55, 55)];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.clipsToBounds = YES;
    [_imgView setBackgroundColor:CreateColor(240, 239, 244)];
    [self addSubview:_imgView];
    NSString *url = model.image_thumb_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_imgView sd_setImageWithURL:[NSURL URLWithString:url]];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 5, _imgView.frameY + 10, SCREEN_WIDTH / 2 - _imgView.frameRight - 5, 20)];
    [_nameLabel setBackgroundColor:[UIColor whiteColor]];
    [_nameLabel setText:model.title];
    [_nameLabel setTextColor:CreateColor(100, 100, 100)];
    [_nameLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:_nameLabel];
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setFrame:CGRectMake(_nameLabel.frameX, _nameLabel.frameBottom, _nameLabel.frameWidth, _nameLabel.frameHeight)];
//    [btn setTitle:@"点击编辑文本" forState:UIControlStateNormal];
//    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 5, 0)];
//    [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
//    [btn setTitleColor:CreateColor(100, 100, 100) forState:UIControlStateNormal];
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    [btn addTarget:self action:@selector(editTitle:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:btn];
    
    GrowContent *content = model.detail_content;
    for (int i = 0; i < [content.image_coor count]; i++) {
        UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [imgBtn setFrame:CGRectMake(SCREEN_WIDTH / 2 + 50 * i, _imgView.frameY, 40, 40)];
        [imgBtn setImage:CREATE_IMG(@"mark_loction") forState:UIControlStateNormal];
        [imgBtn setImage:CREATE_IMG(@"mark_loction_sel") forState:UIControlStateSelected];
        [imgBtn addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
        [imgBtn setTag:i + 1];
        [self addSubview:imgBtn];
        
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgBtn.frameX + imgBtn.frameWidth - 10, imgBtn.frameY + imgBtn.frameHeight - 10, 12, 12)];
        [numLabel setBackgroundColor:CreateColor(141, 105, 251)];
        [numLabel.layer setMasksToBounds:YES];
        [numLabel.layer setCornerRadius:6];
        [numLabel setTextColor:[UIColor whiteColor]];
        [numLabel setFont:[UIFont systemFontOfSize:8]];
        [numLabel setTag:i + 10];
        numLabel.hidden = YES;
        [numLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:numLabel];
    }
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setFrame:CGRectMake(self.frameWidth - 80 - 15, self.frameHeight - 20, 80, 20)];
    [nextBtn setTitle:@"下一个主题" forState:UIControlStateNormal];
    [nextBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 5, 0)];
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [nextBtn setTitleColor:CreateColor(146, 119, 241) forState:UIControlStateNormal];
    nextBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [nextBtn addTarget:self action:@selector(nextTemplate:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
}

//- (void)editTitle:(id)sender
//{
//    
//}

- (void)selectImage:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    for (id subview in [[btn superview] subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            if ([(UIButton *)subview tag] != [btn tag]) {
                [(UIButton *)subview setSelected:NO];
            }
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(selectImageToScrollView:idx:)]) {
        [_delegate selectImageToScrollView:self idx:[btn tag] - 1];
    }
}

- (void)nextTemplate:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(nextTemplateToScrollView:)]) {
        [_delegate nextTemplateToScrollView:self];
    }
}

@end
