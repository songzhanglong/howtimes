//
//  SyncCollectionCell.m
//  TYSociety
//
//  Created by szl on 16/7/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SyncCollectionCell.h"
#import "Masonry.h"

@implementation SyncCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentImg = [[UIImageView alloc] init];
        [_contentImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_contentImg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_contentImg];
        [_contentImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(0, 0, 20, 0));
        }];
        
        _nameLab = [[UILabel alloc] init];
        [_nameLab setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [_nameLab setFont:[UIFont systemFontOfSize:12]];
        [_nameLab setTextAlignment:NSTextAlignmentCenter];
        [_nameLab setTextColor:rgba(97, 97, 97, 1)];
        [self.contentView addSubview:_nameLab];
        [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.width.equalTo(self.contentView.mas_width);
            make.height.equalTo(@(16));
        }];
        
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setImage:CREATE_IMG(@"syncNor") forState:UIControlStateNormal];
        [_checkBtn setImage:CREATE_IMG(@"syncSel") forState:UIControlStateSelected];
        [_checkBtn setImage:CREATE_IMG(@"syncDis") forState:UIControlStateDisabled];
        _checkBtn.userInteractionEnabled = NO;
        [_checkBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_checkBtn];
        [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.width.equalTo(@(14));
            make.height.equalTo(@(14));
        }];
    }
    return self;
}

@end
