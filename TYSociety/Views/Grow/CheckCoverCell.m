//
//  CheckCoverCell.m
//  TYSociety
//
//  Created by szl on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CheckCoverCell.h"
#import "Masonry.h"

@implementation CheckCoverCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _coverImg = [[UIImageView alloc] init];
        [_coverImg setContentMode:UIViewContentModeScaleAspectFill];
        _coverImg.clipsToBounds = YES;
        [_coverImg setBackgroundColor:rgba(220, 220, 221, 1)];
        [_coverImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_coverImg];
        [_coverImg mas_makeConstraints:^(MASConstraintMaker *make) {
           make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(10, 0, 0, 10));
        }];
        
        _qualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_qualityBtn setUserInteractionEnabled:NO];
        [_qualityBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_qualityBtn setImage:CREATE_IMG(@"normalQuality") forState:UIControlStateNormal];
        [_qualityBtn setImage:CREATE_IMG(@"hignQuality") forState:UIControlStateSelected];
        [_coverImg addSubview:_qualityBtn];
        [_qualityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.top.equalTo(@(0));
            make.width.equalTo(@(16));
            make.height.equalTo(@(27));
        }];
        
        _preImg = [[UIImageView alloc] init];
        [_preImg setBackgroundColor:rgba(0, 0, 0, 0.2)];
        [_preImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_preImg];
        [_preImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(10, 0, 0, 10));
        }];
        
        UIImageView *checkImg = [[UIImageView alloc] init];
        [checkImg setBackgroundColor:[UIColor clearColor]];
        [checkImg setImage:CREATE_IMG(@"coverChecked")];
        [checkImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_preImg addSubview:checkImg];
        [checkImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(22));
            make.height.equalTo(@(16));
            make.centerX.equalTo(_preImg.mas_centerX);
            make.centerY.equalTo(_preImg.mas_centerY);
        }];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:CREATE_IMG(@"coverDelete") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deleteCover:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 10, 0)];
        [btn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(0));
            make.right.equalTo(@(0));
            make.width.equalTo(@(30));
            make.height.equalTo(@(30));
        }];
        
        _leftImg = [[UIImageView alloc] init];
        [_leftImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_leftImg];
        [_leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.bottom.equalTo(@(-2));
            make.width.equalTo(@(12));
            make.height.equalTo(@(10));
        }];
    }
    return self;
}

- (void)deleteCover:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteCoverCell:)]) {
        [_delegate deleteCoverCell:self];
    }
}

@end
