//
//  CouponTableViewCell.m
//  TYSociety
//
//  Created by zhangxs on 16/7/21.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CouponTableViewCell.h"
#import "CouponItemModel.h"

@interface CouponTableViewCell ()
{
    UIView *_backView;
    UIImageView *_couponImg,*_imgView;
    UILabel *_nameLabel,*_typeLabel,*_craftLabel,*_priceLabel,*_opriceLabel;
    UILabel *_coupLabel,*_totalLabel;
}
@end
@implementation CouponTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.contentView.frameHeight)];
        [_backView setBackgroundColor:[UIColor whiteColor]];
        [_backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_backView];
        
        _couponImg = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 344)/2, 10, 344, 67)];
        //[_couponImg setClipsToBounds:YES];
        [_couponImg setBackgroundColor:CreateColor(228, 228, 228)];
        [_couponImg setImage:CREATE_IMG(@"couponH")];
        //[_couponImg setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:_couponImg];
        
        UIView *middView = [[UIView alloc] initWithFrame:CGRectMake(0, _couponImg.frameBottom + 10, SCREEN_WIDTH, 85)];
        [middView setBackgroundColor:CreateColor(245, 245, 245)];
        [self.contentView addSubview:middView];
        
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, middView.frameY + 10, 65, 65)];
        [tempLabel setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:tempLabel];
        
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + 7.5, middView.frameY + 10 + 7.5, 50, 50)];
        [_imgView setClipsToBounds:YES];
        [_imgView setBackgroundColor:[UIColor whiteColor]];
        [_imgView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:_imgView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(tempLabel.frameRight + 5, tempLabel.frameY, 150, 20)];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextColor:CreateColor(46, 46, 46)];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_nameLabel];
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frameX, _nameLabel.frameBottom, 150, 20)];
        [_typeLabel setBackgroundColor:[UIColor clearColor]];
        [_typeLabel setTextColor:CreateColor(100, 100, 100)];
        [_typeLabel setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_typeLabel];
        
        _craftLabel = [[UILabel alloc] initWithFrame:CGRectMake(_typeLabel.frameX, _typeLabel.frameBottom + 5, 150, 20)];
        [_craftLabel setBackgroundColor:[UIColor clearColor]];
        [_craftLabel setTextColor:CreateColor(120, 120, 120)];
        [_craftLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:_craftLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, _nameLabel.frameY, 135, 20)];
        [_priceLabel setBackgroundColor:[UIColor clearColor]];
        [_priceLabel setTextColor:CreateColor(152, 122, 255)];
        [_priceLabel setFont:[UIFont systemFontOfSize:14]];
        [_priceLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_priceLabel];
        
        _opriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, _priceLabel.frameBottom, 135, 20)];
        [_opriceLabel setBackgroundColor:[UIColor clearColor]];
        [_opriceLabel setTextColor:CreateColor(100, 100, 100)];
        [_opriceLabel setFont:[UIFont systemFontOfSize:14]];
        [_opriceLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_opriceLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 55, _opriceLabel.frameY + 10, 45, 1)];
        [lineLabel setBackgroundColor:CreateColor(100, 100, 100)];
        [self.contentView addSubview:lineLabel];
        
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, middView.frameBottom + 3, SCREEN_WIDTH, 40)];
        [footView setBackgroundColor:CreateColor(243, 243, 243)];
        [self.contentView addSubview:footView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, footView.frameY + 10, 80, 20)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:CreateColor(100, 100, 100)];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:@"优惠券"];
        [self.contentView addSubview:label];
        
        _coupLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.frameRight + 10, footView.frameY + 10, SCREEN_WIDTH - label.frameRight - 25, 20)];
        [_coupLabel setBackgroundColor:[UIColor clearColor]];
        [_coupLabel setTextColor:CreateColor(100, 100, 100)];
        [_coupLabel setFont:[UIFont systemFontOfSize:14]];
        [_coupLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_coupLabel];
        
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, footView.frameBottom + 10, SCREEN_WIDTH - 30, 20)];
        [_totalLabel setBackgroundColor:[UIColor clearColor]];
        [_totalLabel setTextColor:CreateColor(100, 100, 100)];
        [_totalLabel setFont:[UIFont systemFontOfSize:14]];
        [_totalLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_totalLabel];
    }
    return self;
}

- (void)resetCouponDatas:(id)object
{
    CouponItemModel *model = (CouponItemModel *)object;
    NSString *url = model.coupon_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_couponImg sd_setImageWithURL:[NSURL URLWithString:url]placeholderImage:CREATE_IMG(@"couponH")];
    
    NSDictionary *order = model.order;
    NSString *order_url = [order valueForKey:@"image_url"];
    if (![order_url hasPrefix:@"http"]) {
        order_url = [G_IMAGE_ADDRESS stringByAppendingString:order_url ?: @""];
    }
    [_imgView sd_setImageWithURL:[NSURL URLWithString:order_url]];
    
    [_nameLabel setText:[order valueForKey:@"template_name"] ?: @""];
    [_typeLabel setText:@"简装书20P"];
    [_craftLabel setText:@"1132mm*2455mm"];
    [_priceLabel setText:[NSString stringWithFormat:@"￥%@",[order valueForKey:@"sale_price"]]];
    [_opriceLabel setText:[NSString stringWithFormat:@"￥%@",[order valueForKey:@"original_price"]]];
    [_coupLabel setText:[NSString stringWithFormat:@"-￥%@",[order valueForKey:@"coupon_amount"]]];
    [_totalLabel setText:[NSString stringWithFormat:@"共%@件商品合计：￥%@(含运费￥%@)",[order valueForKey:@"count"],[order valueForKey:@"amount"],[order valueForKey:@"freight"]]];
}

@end
