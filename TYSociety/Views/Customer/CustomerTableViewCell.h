//
//  CustomerTableViewCell.h
//  TYSociety
//
//  Created by zhangxs on 16/8/24.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerModel.h"

@class CustomerTableViewCell;
@protocol CustomerTableViewCellDelegate <NSObject>

@optional
- (void)editActionsToSelf:(CustomerTableViewCell *)cell Index:(NSInteger)idx;
- (void)orderInfo:(CustomerModel *)item;

@end

@interface CustomerTableViewCell : UITableViewCell

@property (nonatomic,assign)id<CustomerTableViewCellDelegate> delegate;

- (void)resetDataSource:(CustomerModel *)item CurrState:(NSInteger)state;

@end
