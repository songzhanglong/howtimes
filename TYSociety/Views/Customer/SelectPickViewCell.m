//
//  SelectPickViewCell.m
//  ChildrenKing
//
//  Created by songzhanglong on 15/3/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectPickViewCell.h"
#import "GlobalDefineKit.h"
#import "NSString+Common.h"
#import "GlobalManager.h"

@implementation SelectPickViewCell
{
    NSMutableDictionary *_selectDictory;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //监视键盘高度变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        _selectDictory = [NSMutableDictionary dictionary];
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 40)];
        [backView setBackgroundColor:rgba(231, 225, 252, 1)];
        [backView.layer setMasksToBounds:YES];
        [backView.layer setCornerRadius:5];
        [self.contentView addSubview:backView];

        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 70, 40)];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        [_tipLabel setFont:[UIFont systemFontOfSize:14]];
        [_tipLabel setTextColor:CreateColor(100, 100, 100)];
        [self.contentView addSubview:_tipLabel];
                
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(_tipLabel.frameRight + 15, 0, backView.frameWidth - _tipLabel.frameRight - 15, backView.frameHeight)];
        _textField = field;
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self resetInputViewAndAccessoryView];
        self.textField.inputAccessoryView = [self getInputAccessoryView];
        [self.contentView addSubview:field];
    }
    
    return self;
}

- (void)resetInputViewAndAccessoryView
{
    // 初始化UIDatePicker
    _mPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    _mPickerView.frame = CGRectMake(0.0f, 44.0f, SCREEN_WIDTH, 216.0f);
    _mPickerView.delegate = self;
    _mPickerView.dataSource = self;
    _mPickerView.showsSelectionIndicator = YES;
    _mPickerView.backgroundColor = [UIColor whiteColor];
    _textField.inputView = _mPickerView;
}

/**
 *	@brief	获取inputAccessoryView，如无，则新建
 *
 *	@return	UIToolbar
 */
- (UIToolbar *)getInputAccessoryView
{
    //inputAccessoryView
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIToolbar *_inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, winSize.width, 44)];
    [_inputAccessoryView setBackgroundColor:CreateColor(153, 125, 251)];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doresignFirstResponderOfTextField:)];
    [left setTag:1];
    UIBarButtonItem *apace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    apace.width = [[UIScreen mainScreen] bounds].size.width - 120;

    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doresignFirstResponderOfTextField:)];
    [right setTag:2];
    _inputAccessoryView.items = [NSArray arrayWithObjects:left,apace,right, nil];
    return _inputAccessoryView;
}

- (void)doresignFirstResponderOfTextField:(id)sender
{
    [_textField resignFirstResponder];
    
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    if (item.tag == 2) {
        [_textField setText:[_selectDictory valueForKey:@"craft_name"]];
        if (_delegate && [_delegate respondsToSelector:@selector(pickChangeContent:Item:)]) {
            [_delegate pickChangeContent:self Item:_selectDictory];
        }
    }
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!_textField.isFirstResponder) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    if (_delegate && [_delegate respondsToSelector:@selector(pickContentToTableHeiht:KeyboardHeight:)]) {
        [_delegate pickContentToTableHeiht:self KeyboardHeight:keyboardRect.size.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UITableView *tableView = [GlobalManager findViewFrom:self To:[UITableView class]];
    CGRect tabRect = tableView.frame;
    if (tabRect.origin.y == 0) {
        return;
    }
    [UIView animateWithDuration:0.1 animations:^{
        [tableView setFrame:CGRectMake(tabRect.origin.x, 0, tabRect.size.width, tabRect.size.height)];
    }];
}

- (void)restPickerDatas:(NSMutableArray *)datas
{
    if ([datas count] == 0) {
        return;
    }
    _dataSource = datas;
    [_mPickerView reloadAllComponents];
    _selectDictory = [_dataSource objectAtIndex:0];
}

#pragma mark-
#pragma mark UIPickerView dataSouce
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_dataSource count];
}
#pragma mark UIPickerView delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dic = [_dataSource objectAtIndex:row];
    NSString *name = [dic valueForKey:@"craft_name"];
    return name ?: @"";
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectDictory = [_dataSource objectAtIndex:row];
    [_textField setText:[_selectDictory valueForKey:@"craft_name"]];
}

@end
