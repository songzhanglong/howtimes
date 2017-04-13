//
//  CustomerTableViewCell.m
//  TYSociety
//
//  Created by zhangxs on 16/8/24.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CustomerTableViewCell.h"

@interface CustomerTableViewCell ()
{
    UIView *_backView;
    UIImageView *_imgView;
    UILabel *_nameLab,*_tipLabel,*_addressLabel,*_phoneLabel,*_numLabel;
    CustomerModel *_currModel;
    UILabel *_undoNumsLabel;
    NSInteger _indexNum;
    UIButton *_detailBtn;
}
@end

@implementation CustomerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frameWidth, self.contentView.frameHeight - 5)];
        [_backView setBackgroundColor:CreateColor(248, 248, 248)];
        [_backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:_backView];
        
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.clipsToBounds = YES;
        [_imgView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_imgView];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 10, _imgView.frameY, SCREEN_WIDTH - _imgView.frameRight - 10, 25)];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [_nameLab setTextColor:CreateColor(100, 100, 100)];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_nameLab];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom, SCREEN_WIDTH - _nameLab.frameX- 90, 20)];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        [_tipLabel setTextColor:CreateColor(182, 182, 182)];
        [_tipLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:_tipLabel];
        
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(_tipLabel.frameX, _tipLabel.frameBottom, SCREEN_WIDTH - _tipLabel.frameX- 90, 20)];
        [_numLabel setBackgroundColor:[UIColor clearColor]];
        [_numLabel setTextColor:CreateColor(182, 182, 182)];
        [_numLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:_numLabel];
        
        NSArray *imgsn = @[@"customer_edit",@"cust_local",@"cust_set"];
        NSArray *imgsh = @[@"cust_edit_press",@"cust_local_press",@"cust_set_press"];
        for (int i = 0; i < 3; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(SCREEN_WIDTH - 15 - 28 * (i + 1), _numLabel.frameY - 5, 28, 28)];
            [button setImage:CREATE_IMG(imgsn[i]) forState:UIControlStateNormal];
            [button setImage:CREATE_IMG(imgsh[i]) forState:UIControlStateHighlighted];
            [button setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [button setTag:10 + i];
            [button addTarget:self action:@selector(singleActions:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
        }
        
        _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_detailBtn setFrame:CGRectMake(SCREEN_WIDTH - 99, _numLabel.frameY - 5, 84, 30)];
        [_detailBtn setTitle:@"订单详情" forState:UIControlStateNormal];
        [_detailBtn setTitleColor:CreateColor(131, 84, 251) forState:UIControlStateNormal];
        [_detailBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _detailBtn.hidden = YES;
        _detailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_detailBtn addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_detailBtn];
        
    }
    return self;
}

- (void)singleActions:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(editActionsToSelf:Index:)]) {
        [_delegate editActionsToSelf:self Index:[sender tag] - 10];
    }
}

- (void)detailAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(orderInfo:)]) {
        [_delegate orderInfo:_currModel];
    }
}
- (void)resetDataSource:(CustomerModel *)item CurrState:(NSInteger)state
{
    _currModel = item;
    
    NSString *url = item.template_image;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_imgView sd_setImageWithURL:[NSURL URLWithString:url]];
    
    NSString *str = [NSString stringWithFormat:@"%@  %@",item.user_name,item.phone];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range_name = [str rangeOfString:item.user_name];
    [attStr addAttribute:NSForegroundColorAttributeName value:CreateColor(100, 100, 100) range:range_name];
    NSRange range_phone = [str rangeOfString:item.phone];
    [attStr addAttribute:NSForegroundColorAttributeName value:CreateColor(182, 182, 182) range:range_phone];
    [_nameLab setAttributedText:attStr];
    
    [_tipLabel setText:item.template_name];
    
    NSInteger pNum = [item.nums integerValue];
    NSInteger pFinish = [item.finish_num integerValue];
    if (item.is_double.integerValue == 1) {
        pNum = [item.nums integerValue] * 2;
        pFinish = [item.finish_num integerValue] * 2;
    }
    if ((pFinish == pNum) && (pFinish > 0)) {
        if ([item.address length] > 0) {
            [_numLabel setText:item.address];
        }else {
            [_numLabel setText:[NSString stringWithFormat:@"已完成%ld/%ld页",(long)pFinish,(long)pNum]];
        }
    }else {
        [_numLabel setText:[NSString stringWithFormat:@"已完成%ld/%ld页",(long)pFinish,(long)pNum]];
    }
    
    _detailBtn.hidden = ([item.is_print integerValue] != 2);
    if (state == 0) {
        for (int i = 0; i < 3; i++) {
            UIButton *button = (UIButton *)[self.contentView viewWithTag:10 + i];
            button.hidden = ([item.is_print integerValue] == 2);
        }
    }else {
        for (int i = 0; i < 3; i++) {
            UIButton *button = (UIButton *)[self.contentView viewWithTag:10 + i];
            button.hidden = YES;
        }
    }
}

@end
