//
//  UserHeadCell.m
//  TYSociety
//
//  Created by zhangxs on 16/6/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "UserHeadCell.h"

@implementation UserHeadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _faceImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 55, 55)];
        [_faceImgView setUserInteractionEnabled:YES];
        _faceImgView.layer.masksToBounds = YES;
        _faceImgView.layer.cornerRadius = 3.0;
        [_faceImgView setContentMode:UIViewContentModeScaleAspectFill];
        [_faceImgView setClipsToBounds:YES];
        [self.contentView addSubview:_faceImgView];
        
        [_faceImgView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(uploadFaceImage:)]];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_faceImgView.frameRight + 15, _faceImgView.frameY, SCREEN_WIDTH - _faceImgView.frameRight - 30, 25)];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextColor:CreateColor(86, 86, 86)];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_nameLabel];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(_faceImgView.frameRight + 15, _nameLabel.frameBottom + 10, SCREEN_WIDTH - _faceImgView.frameRight - 30 - 65, 20)];
        [_detailLabel setBackgroundColor:[UIColor clearColor]];
        [_detailLabel setTextColor:CreateColor(86, 86, 86)];
        [_detailLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:_detailLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        _changePsdBtn = button;
        [button setFrame:CGRectMake(_detailLabel.frameRight, _detailLabel.frameY, 60, 30)];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:CreateColor(186, 169, 251) forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button setTitle:@"修改密码" forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
    }
    
    return self;
}

- (void)buttonPressed:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(upDataUserNameToIndex:)]) {
        [_delegate upDataUserNameToIndex:self];
    }
}

- (void)uploadFaceImage:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(uploadFaceImageToIndex:)]) {
        [_delegate uploadFaceImageToIndex:self];
    }
}

- (void)resetDataSource:(id)data;
{
    NSString *url = [GlobalManager shareInstance].detailInfo.user.head_img;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_faceImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:CREATE_IMG(@"loginLogo")];
    NSString *name = [GlobalManager shareInstance].detailInfo.user.name;
    [_nameLabel setText:[name length] > 0 ? name : @"点击添加昵称"];
    [_detailLabel setText:[GlobalManager shareInstance].detailInfo.user.login_name ?: @""];
    UserInfo *user = [GlobalManager shareInstance].detailInfo.user;
    BOOL is_bind = ([user.open_id length] > 0 && [user.login_name length] == 0);
    [_changePsdBtn setTitle:is_bind ? @"绑定号码" : @"修改密码" forState:UIControlStateNormal];
}

@end
