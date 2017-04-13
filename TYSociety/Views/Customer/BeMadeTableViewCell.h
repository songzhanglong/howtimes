//
//  BeMadeTableViewCell.h
//  TYSociety
//
//  Created by zhangxs on 16/8/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomerModel.h"

@class BeMadeTableViewCell;
@protocol BeMadeTableViewCellDelegate <NSObject>

@optional
- (void)editActionsToController:(BeMadeTableViewCell *)cell Index:(NSInteger)idx;
- (void)isReloadSectionToController:(UITableViewCell *)cell;

@end

@interface BeMadeTableViewCell : UITableViewCell

@property (nonatomic,assign)id<BeMadeTableViewCellDelegate> delegate;
@property (nonatomic,assign)NSInteger num;
@property (nonatomic,assign)BOOL isUndoPrint;

- (void)resetDataSource:(CustomerModel *)item;

@end
