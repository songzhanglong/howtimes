//
//  PaymentTableViewCell.h
//  TYSociety
//
//  Created by zhangxs on 16/7/31.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerModel.h"

@class PaymentTableViewCell;
@protocol PaymentTableViewCellDelegate <NSObject>

@optional
- (void)isReloadSectionToController:(UITableViewCell *)cell;
- (void)editAddressToController:(PaymentTableViewCell *)cell;
- (void)reloadPriceToController:(PaymentTableViewCell *)cell IsAdd:(BOOL)is_add;

@end

@interface PaymentTableViewCell : UITableViewCell

@property (nonatomic,assign)id<PaymentTableViewCellDelegate> delegate;
@property (nonatomic,assign)NSInteger num;
@property (nonatomic,assign)BOOL isUndoPrint;

- (void)resetDataSource:(CustomerModel *)item;

@end
