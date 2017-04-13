//
//  EditAddressView.h
//  TYSociety
//
//  Created by zhangxs on 16/7/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerModel.h"

@class EditAddressView;
@protocol EditAddressViewDelegate <NSObject>

- (void)closeEditAddressView;
- (void)submitAddress:(EditAddressView *)alert Address:(CustomerModel *)item;

@end
@interface EditAddressView : UIView<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITextField *_addressFiled,*_nameField,*_phoneField;
    NSString *defaultTheme;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CustomerModel *customer;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) id <EditAddressViewDelegate> delegate;
@property (nonatomic, assign) BOOL isSetAll;

- (void)setDefaultTheme:(NSString *)theme;
- (void)setFramToSelf;

@end
