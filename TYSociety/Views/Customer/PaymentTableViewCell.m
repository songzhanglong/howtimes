//
//  PaymentTableViewCell.m
//  TYSociety
//
//  Created by zhangxs on 16/7/31.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "PaymentTableViewCell.h"

@interface PaymentTableViewCell ()
{
    UIView *_backView,*_shadowView,*_numsView;
    UIImageView *_imgView;
    UILabel *_nameLab,*_numsLab,*_tipLabel,*_addressLabel,*_priceLabel;
    CustomerModel *_currModel;
    UILabel *_undoNumsLabel;
    NSInteger _indexNum;
    UIButton *_checkBtn, *_editBtn;
}
@end

@implementation PaymentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _num = 1;
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frameWidth, self.contentView.frameHeight - 5)];
        [_backView setBackgroundColor:CreateColor(248, 248, 248)];
        [_backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:_backView];
        
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setFrame:CGRectMake(7.5, 25, 30, 30)];
        [_checkBtn setImage:CREATE_IMG(@"cust_check") forState:UIControlStateNormal];
        [_checkBtn setImage:CREATE_IMG(@"cust_checked") forState:UIControlStateSelected];
        [_checkBtn setImageEdgeInsets:UIEdgeInsetsMake(12.5, 7.5, 2.5, 7.5)];
        [_checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_checkBtn];
    
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(_checkBtn.frameRight + 2.5, 10, 60, 60)];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.clipsToBounds = YES;
        [_imgView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_imgView];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 10, _imgView.frameY, SCREEN_WIDTH - _imgView.frameRight - 10 - 80, 25)];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [_nameLab setTextColor:CreateColor(100, 100, 100)];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_nameLab];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, _nameLab.frameY, 70, 25)];
        [_priceLabel setBackgroundColor:[UIColor clearColor]];
        [_priceLabel setTextColor:CreateColor(131, 84, 251)];
        [_priceLabel setFont:[UIFont systemFontOfSize:12]];
        [_priceLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_priceLabel];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom, SCREEN_WIDTH - _nameLab.frameX- 90, 15)];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        [_tipLabel setTextColor:CreateColor(182, 182, 182)];
        [_tipLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:_tipLabel];
        
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBtn setFrame:CGRectMake(_tipLabel.frameX - 10, _tipLabel.frameBottom, 30, 30)];
        [_editBtn setImage:CREATE_IMG(@"customer_edit") forState:UIControlStateNormal];
        [_editBtn setImage:CREATE_IMG(@"cust_edit_press") forState:UIControlStateHighlighted];
        [_editBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 10, 6, 2)];
        [_editBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_editBtn];
        
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_editBtn.frameRight, _tipLabel.frameBottom, SCREEN_WIDTH - _editBtn.frameRight- 105, 30)];
        [_addressLabel setBackgroundColor:[UIColor clearColor]];
        [_addressLabel setTextColor:CreateColor(182, 182, 182)];
        [_addressLabel setFont:[UIFont systemFontOfSize:12]];
        _addressLabel.numberOfLines = 2;
        [self.contentView addSubview:_addressLabel];
        
        _numsView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 55, 90, 20)];
        [_numsView setBackgroundColor:CreateColor(242, 241, 246)];
        [_numsView.layer setCornerRadius:2];
        [_numsView.layer setMasksToBounds:YES];
        [_numsView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_numsView];
        
        for (int i = 0; i < 3; i++) {
            if (i != 1) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(30 * i, 0, 30, 20)];
                [btn setTitle:(i == 0) ? @"-" : @"+" forState:UIControlStateNormal];
                [btn setTitleColor:(i == 0) ? [UIColor lightGrayColor] : CreateColor(121, 121, 123) forState:UIControlStateNormal];
                btn.tag = i + 1;
                [btn addTarget:self action:@selector(addOrSubtractAction:) forControlEvents:UIControlEventTouchUpInside];
                [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
                [_numsView addSubview:btn];
            }else {
                UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 30, 20)];
                _numsLab = tipLab;
                [tipLab setBackgroundColor:[UIColor clearColor]];
                [tipLab setTextColor:CreateColor(131, 84, 251)];
                [tipLab setFont:[UIFont systemFontOfSize:14]];
                [tipLab setTextAlignment:NSTextAlignmentCenter];
                [_numsView addSubview:tipLab];
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30 + 30 * i, 0, 1, _numsView.frameHeight)];
            [label setBackgroundColor:CreateColor(248, 248, 248)];
            [_numsView addSubview:label];
        }
    }
    return self;
}

- (void)editAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(editAddressToController:)]) {
        [_delegate editAddressToController:self];
    }
}

- (void)checkAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _currModel.isSelected = sender.selected;
    //_currModel.print_num = _num;
    if (_delegate && [_delegate respondsToSelector:@selector(isReloadSectionToController:)]) {
        [_delegate isReloadSectionToController:self];
    }
}

- (void)addOrSubtractAction:(id)sender
{
    BOOL isAdd;
    UIButton *btn = (UIButton *)sender;
    if ([btn tag] == 1) {
        //subtract
        if (_num == 1) {
            return;
        }
        _num--;
        isAdd = NO;
    }else {
        //add
        if (_num >= _indexNum && _isUndoPrint) {
            return;
        }
        _num++;
        isAdd = YES;
    }
    [_numsLab setText:[NSString stringWithFormat:@"%ld",(long)_num]];
    UIButton *tempBtn = (UIButton *)[_numsView viewWithTag:1];
    if (tempBtn) {
        [tempBtn setTitleColor:(_num == 1) ? [UIColor lightGrayColor] : [UIColor blackColor] forState:UIControlStateNormal];
    }
    if (_isUndoPrint) {
        UIButton *addBtn = (UIButton *)[_numsView viewWithTag:3];
        if (addBtn) {
            [addBtn setTitleColor:(_num >= _indexNum) ? [UIColor lightGrayColor] : [UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    _currModel.print_num = _num;
    
    if (_currModel.isSelected && _delegate && [_delegate respondsToSelector:@selector(reloadPriceToController:IsAdd:)]) {
        [_delegate reloadPriceToController:self IsAdd:isAdd];
    }
}

- (void)resetDataSource:(CustomerModel *)item
{
    _currModel = item;
    
    _checkBtn.selected = item.isSelected;
    
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
    [_priceLabel setText:[NSString stringWithFormat:@"￥%0.2lf",[item.sale_price doubleValue]]];
    [_tipLabel setText:item.template_name];
    [_addressLabel setText:([item.address length] > 0) ? item.address : @"请输入收货地址"];
    
    _num = item.print_num;
    [_numsLab setText:[NSString stringWithFormat:@"%ld", (long)_num]];
    
    UIButton *tempBtn = (UIButton *)[_numsView viewWithTag:1];
    if (tempBtn) {
        [tempBtn setTitleColor:(_num == 1) ? [UIColor lightGrayColor] : [UIColor blackColor] forState:UIControlStateNormal];
    }
    
    if (_isUndoPrint) {
        _indexNum = _num;
        if (_num > 0) {
            [_numsLab setText:[NSString stringWithFormat:@"%ld",(long)_num]];
        }
        
        _undoNumsLabel.hidden = (_num > 1);
        _numsView.hidden = (_num == 1);
        
        UIButton *btn = (UIButton *)[_numsView viewWithTag:1];
        if (btn) {
            [btn setTitleColor:(_num > 1) ? [UIColor blackColor] : [UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        UIButton *tempBtn = (UIButton *)[_numsView viewWithTag:3];
        if (tempBtn) {
            [tempBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
}

@end
