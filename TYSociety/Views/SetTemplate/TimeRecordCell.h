//
//  TimeRecordCell.h
//  TYSociety
//
//  Created by szl on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeRecordModel;

@protocol TimeRecordCellDelegate <NSObject>

@optional
- (void)selectTimeRecord:(id)record At:(UITableViewCell *)cell;
- (void)setTemplateTimeRecord:(id)record At:(UITableViewCell *)cell;

@end

@interface TimeRecordCell : UITableViewCell

@property (nonatomic,assign)id<TimeRecordCellDelegate> delegate;
@property (nonatomic,strong)NSArray *timeRecords;

- (void)resetTimeRecords:(NSArray *)array;

@end
