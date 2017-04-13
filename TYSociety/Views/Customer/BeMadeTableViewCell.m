//
//  BeMadeTableViewCell.m
//  TYSociety
//
//  Created by zhangxs on 16/8/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BeMadeTableViewCell.h"

@interface BeMadeTableViewCell ()
{
    UIView *_backView;
    UIImageView *_imgView;
    UILabel *_nameLab,*_tipLabel,*_addressLabel,*_phoneLabel;
    CustomerModel *_currModel;
    UILabel *_undoNumsLabel;
    NSInteger _indexNum;
    UIButton *_checkBtn;
}
@end

@implementation BeMadeTableViewCell

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
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 10, _imgView.frameY, SCREEN_WIDTH - _imgView.frameRight - 10, 25)];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [_nameLab setTextColor:CreateColor(100, 100, 100)];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_nameLab];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom, SCREEN_WIDTH - _nameLab.frameX- 90, 15)];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        [_tipLabel setTextColor:CreateColor(182, 182, 182)];
        [_tipLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:_tipLabel];
        
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_tipLabel.frameX, _tipLabel.frameBottom, SCREEN_WIDTH - _tipLabel.frameX- 105, 30)];
        [_addressLabel setBackgroundColor:[UIColor clearColor]];
        [_addressLabel setTextColor:CreateColor(182, 182, 182)];
        [_addressLabel setFont:[UIFont systemFontOfSize:12]];
        _addressLabel.numberOfLines = 2;
        [self.contentView addSubview:_addressLabel];
        
        NSArray *imgsn = @[@"customer_edit",@"cust_local",@"cust_set"];
        NSArray *imgsh = @[@"cust_edit_press",@"cust_local_press",@"cust_set_press"];
        for (int i = 0; i < 3; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(SCREEN_WIDTH - 15 - 28 * (i + 1), _addressLabel.frameY - 5, 28, 28)];
            [button setImage:CREATE_IMG(imgsn[i]) forState:UIControlStateNormal];
            [button setImage:CREATE_IMG(imgsh[i]) forState:UIControlStateHighlighted];
            [button setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [button setTag:10 + i];
            [button addTarget:self action:@selector(singleActions:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
        }
    }
    return self;
}

- (void)singleActions:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(editActionsToController:Index:)]) {
        [_delegate editActionsToController:self Index:[sender tag] - 10];
    }
}

- (void)checkAction:(UIButton *)sender
{
    if (([_currModel.finish_num integerValue] != [_currModel.nums integerValue] || [_currModel.finish_num integerValue] == 0 || [_currModel.nums integerValue] == 0)) {
        [self.window makeToast:@"该档案没有制作完哦" duration:1.0 position:@"center"];
        return;
    }else {
        sender.selected = !sender.selected;
        _currModel.isSelected = sender.selected;
        if (_delegate && [_delegate respondsToSelector:@selector(isReloadSectionToController:)]) {
            [_delegate isReloadSectionToController:self];
        }
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
    [_tipLabel setText:item.template_name];
    //[_addressLabel setText:item.address ?: @""];
    NSInteger pNum = [item.nums integerValue];
    NSInteger pFinish = [item.finish_num integerValue];
    if (item.is_double.integerValue == 1) {
        pNum = [item.nums integerValue] * 2;
        pFinish = [item.finish_num integerValue] * 2;
    }
    if ((pFinish == pNum) && (pFinish > 0)) {
        if ([item.address length] > 0) {
            [_addressLabel setText:item.address];
        }else {
            [_addressLabel setText:[NSString stringWithFormat:@"已完成%ld/%ld页",(long)pFinish,(long)pNum]];
        }
    }else {
        [_addressLabel setText:[NSString stringWithFormat:@"已完成%ld/%ld页",(long)pFinish,(long)pNum]];
    }
}

@end
