//
//  SelectPickViewCell.h
//  ChildrenKing
//
//  Created by songzhanglong on 15/3/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectPickViewCell;
@protocol SelectPickViewCellDelegate <NSObject>

@optional
- (void)pickChangeContent:(SelectPickViewCell *)cell Item:(NSMutableDictionary *)dictory;
- (void)pickContentToTableHeiht:(SelectPickViewCell *)cell KeyboardHeight:(CGFloat)height;

@end

@interface SelectPickViewCell : UITableViewCell<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,assign)id<SelectPickViewCellDelegate> delegate;
@property (nonatomic,strong)UILabel *tipLabel;
@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,strong)UIPickerView *mPickerView;
@property (nonatomic,strong)NSMutableArray *dataSource;

- (void)restPickerDatas:(NSMutableArray *)datas;

@end
