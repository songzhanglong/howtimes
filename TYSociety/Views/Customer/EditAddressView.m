//
//  EditAddressView.m
//  TYSociety
//
//  Created by zhangxs on 16/7/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "EditAddressView.h"
#import "AddressModel.h"

@implementation EditAddressView
{
    UIView *mview;
    UIButton *_canelBtn,*_doneBtn;
    NSIndexPath *_lastIndexPath;
    NSInteger _maxLength;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _dataSource = [NSMutableArray array];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        defaultTheme = @"";
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.3;
        bgView.userInteractionEnabled = YES;
        [self addSubview:bgView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapGestureRecognizer:)];
        [bgView addGestureRecognizer:tapGesture];
        
        mview = [[UIView alloc] initWithFrame:CGRectMake(20, (SCREEN_HEIGHT - 212 - 64 + 80) / 2, SCREEN_WIDTH - 40, 212 - 80)];
        [mview setBackgroundColor:CreateColor(231, 225, 252)];
        mview.layer.masksToBounds = YES;
        mview.layer.cornerRadius = 5.0;
        mview.userInteractionEnabled = YES;
        [self addSubview:mview];
        
        UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(15, 11, 100, 32)];
        nameView.backgroundColor = CreateColor(207, 193, 252);
        nameView.layer.masksToBounds = YES;
        nameView.layer.cornerRadius = 5.0;
        [mview addSubview:nameView];
        
        _nameField = [[UITextField alloc] initWithFrame:CGRectMake(25, 16, 80, 22)];
        _nameField.autocorrectionType = UITextAutocorrectionTypeNo;
        _nameField.contentVerticalAlignment = 0 ;
        _nameField.returnKeyType = UIReturnKeyDone;
        _nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _nameField.font = [UIFont systemFontOfSize:14];
        [_nameField setPlaceholder:@"姓名"];
        _nameField.delegate = self;
        [mview addSubview:_nameField];
        
        UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(nameView.frameRight + 10, 11, mview.frame.size.width - nameView.frameRight - 25, 32)];
        phoneView.backgroundColor = CreateColor(207, 193, 252);
        phoneView.layer.masksToBounds = YES;
        phoneView.layer.cornerRadius = 5.0;
        [mview addSubview:phoneView];
        
        _phoneField = [[UITextField alloc] initWithFrame:CGRectMake(phoneView.frameX  +10, 16, phoneView.frameWidth - 20, 22)];
        _phoneField.autocorrectionType = UITextAutocorrectionTypeNo;
        _phoneField.contentVerticalAlignment = 0 ;
        _phoneField.returnKeyType = UIReturnKeyDone;
        _phoneField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _phoneField.font = [UIFont systemFontOfSize:14];
        [_phoneField setPlaceholder:@"手机号码"];
        _phoneField.delegate = self;
        [mview addSubview:_phoneField];
        
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(15, 51, mview.frame.size.width - 30, 32)];
        tempView.backgroundColor = CreateColor(207, 193, 252);
        tempView.layer.masksToBounds = YES;
        tempView.layer.cornerRadius = 5.0;
        [mview addSubview:tempView];
        
        _addressFiled = [[UITextField alloc] initWithFrame:CGRectMake(25, 56, mview.frame.size.width - 50, 22)];
        _addressFiled.autocorrectionType = UITextAutocorrectionTypeNo;
        _addressFiled.contentVerticalAlignment = 0 ;
        _addressFiled.returnKeyType = UIReturnKeyDone;
        _addressFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _addressFiled.font = [UIFont systemFontOfSize:14];
        [_addressFiled setPlaceholder:@"添加地址"];
        _addressFiled.delegate = self;
        [mview addSubview:_addressFiled];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tempView.frameBottom + 5, mview.frameWidth, 0)];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [mview addSubview:_tableView];
        
        UIButton *canelBtn = [[UIButton alloc] initWithFrame:CGRectMake((mview.frameWidth - 100 * 2 - 10) / 2, mview.frameHeight - 40, 100, 30)];
        _canelBtn = canelBtn;
        canelBtn.layer.masksToBounds = YES;
        canelBtn.layer.cornerRadius = 5.0;
        canelBtn.backgroundColor = CreateColor(153, 125, 251);
        [canelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [canelBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [canelBtn setTag:1];
        [canelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [canelBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [mview addSubview:canelBtn];
        
        UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(canelBtn.frameRight + 10, canelBtn.frameY, canelBtn.frameWidth, canelBtn.frameHeight)];
        _doneBtn = doneBtn;
        doneBtn.layer.masksToBounds = YES;
        doneBtn.layer.cornerRadius = 5.0;
        doneBtn.backgroundColor = CreateColor(153, 125, 251);
        [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [doneBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [doneBtn setTag:2];
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [mview addSubview:doneBtn];
        
        //[self sendRequest];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)setFramToSelf
{
    CGFloat height = MIN(80, [_dataSource count] * 40);
    _tableView.frameHeight = height;
    [mview setFrame:CGRectMake(20, (SCREEN_HEIGHT - 212 + (80 - height) - 64) / 2, SCREEN_WIDTH - 40, 212 - (80 - height))];
    [_canelBtn setFrame:CGRectMake((mview.frameWidth - 100 * 2 - 10) / 2, mview.frameHeight - 40, 100, 30)];
    [_doneBtn setFrame:CGRectMake(_canelBtn.frameRight + 10, _canelBtn.frameY, _canelBtn.frameWidth, _canelBtn.frameHeight)];
    if (!_isSetAll) {
        _nameField.text = _customer.consignee;
        _phoneField.text = _customer.mobile_num;
        _addressFiled.text = _customer.address;
    }
    
    BOOL isEdit = ([_customer.address_id length] > 0 || !_isSetAll);
    if (isEdit) {
        for (int i = 0; i < [_dataSource count]; i++) {
            AddressModel *item = _dataSource[i];
            if ([item.id isEqualToString:_customer.address_id]) {
                item.is_select = YES;
                _lastIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            }
        }
    }

    [_tableView reloadData];
}

- (void)sendRequest
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self setUserInteractionEnabled:NO];
    [self makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"address"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAddress"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getAddressFinish:error Data:data];
        });
    }];
}

#pragma mark - 请求结束
- (void)getAddressFinish:(NSError *)error Data:(id)result
{
    [self hideToastActivity];
    [self setUserInteractionEnabled:YES];
    if (error) {
        [self makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [AddressModel arrayOfModelsFromDictionaries:ret_data error:nil];
        _dataSource = array;
        CGFloat height = MIN(80, [array count] * 40);
        _tableView.frameHeight = height;
        [mview setFrame:CGRectMake(20, (SCREEN_HEIGHT - 212 + (80 - height) - 64) / 2, SCREEN_WIDTH - 40, 212 - (80 - height))];
        [_canelBtn setFrame:CGRectMake((mview.frameWidth - 100 * 2 - 10) / 2, mview.frameHeight - 40, 100, 30)];
        [_doneBtn setFrame:CGRectMake(_canelBtn.frameRight + 10, _canelBtn.frameY, _canelBtn.frameWidth, _canelBtn.frameHeight)];
        [_tableView reloadData];
    }
}

- (void)addAddressFinish:(NSError *)error Data:(id)result
{
    if (error) {
        [self hideToastActivity];
        [self setUserInteractionEnabled:YES];
        [self makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{

        id ret_data = [result valueForKey:@"ret_data"];
        if ([[ret_data valueForKey:@"address_id"] length] > 0) {
            //edit
            if ([[ret_data valueForKey:@"address_id"] isEqualToString:_customer.address_id]) {
                [self hideToastActivity];
                [self setUserInteractionEnabled:YES];
                [self setContentView:[ret_data valueForKey:@"address_id"]];
            }
            else {
                [self chooseAddressRequest:[ret_data valueForKey:@"address_id"]];
            }
        }
        else {
            //add
            [self chooseAddressRequest:[ret_data valueForKey:@"a_id"]];
        }
    }
    
}

- (void)chooseAddressRequest:(NSString *)a_id
{
    GlobalManager *manager = [GlobalManager shareInstance];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"address"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"chooseAddress"];
    [param setObject:_customer.batch_id forKey:@"batch_id"];
    [param setObject:_isSetAll ? @"" : _customer.grow_id forKey:@"grow_id"];
    [param setObject:a_id ?: @"" forKey:@"address_id"];
    [param setObject:_isSetAll ? @"1" : @"2" forKey:@"set_type"];
    [param setObject:_isSetAll ? @"1" : @"0" forKey:@"is_all"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf submitAddressFinish:error Data:data Address_id:a_id];
        });
    }];
}

- (void)submitAddressFinish:(NSError *)error Data:(id)result Address_id:(NSString *)a_id
{
    [self hideToastActivity];
    [self setUserInteractionEnabled:YES];
    if (error) {
        [self makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self setContentView:a_id];
    }
}

- (void)setContentView:(NSString *)a_id
{
    [self tapGestureRecognizer:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(submitAddress:Address:)]) {
        CustomerModel *info = [[CustomerModel alloc] init];
        info.address = [_addressFiled text];
        info.address_id = a_id;
        [_delegate submitAddress:self Address:info];
    }
    
    AddressModel *model = [[AddressModel alloc] init];
    model.address = [_addressFiled text];
    model.consignee = [_nameField text];
    model.mobile_num = [_phoneField text];
    [_dataSource addObject:model];
    
    CGFloat height = 40;
    _tableView.frameHeight += height;
    [mview setFrame:CGRectMake(20, (SCREEN_HEIGHT - 212 + (80 - height) - 64) / 2, SCREEN_WIDTH - 40, 212 - (80 - height))];
    [_canelBtn setFrame:CGRectMake((mview.frameWidth - 100 * 2 - 10) / 2, mview.frameHeight - 40, 100, 30)];
    [_doneBtn setFrame:CGRectMake(_canelBtn.frameRight + 10, _canelBtn.frameY, _canelBtn.frameWidth, _canelBtn.frameHeight)];
    [_tableView reloadData];
}

- (void)setDefaultTheme:(NSString *)theme
{
    defaultTheme = theme;
    [_addressFiled setText:theme];
}

- (void)buttonPressed:(UIButton *)sender
{
    if (sender.tag == 2) {
        if ([[_nameField text] length] == 0) {
            [self makeToast:@"您还没有输入姓名" duration:1.0 position:@"center"];
            return;
        }
        
        if ([[_nameField text] length] > 4) {
            [self makeToast:@"姓名最多4个字" duration:1.0 position:@"center"];
            return;
        }
        
        if ([[_phoneField text] length] != 11) {
            [self makeToast:@"请输入正确的手机号码" duration:1.0 position:@"center"];
            return;
        }
        
        if ([[_addressFiled text] length] == 0) {
            [self makeToast:@"您还没有填入地址" duration:1.0 position:@"center"];
            return;
        }
        
        [_nameField resignFirstResponder];
        [_phoneField resignFirstResponder];
        [_addressFiled resignFirstResponder];
        
        if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
            [self makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            return;
        }
        
        [self setUserInteractionEnabled:NO];
        [self makeToastActivity];
        GlobalManager *manager = [GlobalManager shareInstance];
        __weak typeof(self)weakSelf = self;
        
        BOOL isEdit = NO;
        NSString *address_id = @"";
        for (AddressModel *item in _dataSource) {
            if (item.is_select) {
                isEdit = YES;
                address_id = item.id;
                break;
            }
        }
        NSString *ckey = isEdit ? @"editAddress" : @"addAddress";
        NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"address"];
        NSMutableDictionary *param = [manager requestinitParamsWith:ckey];
        [param setObject:@"000000" forKey:@"province"];
        [param setObject:@"000000" forKey:@"city"];
        [param setObject:@"000000" forKey:@"area"];
        [param setObject:@"000000" forKey:@"postal"];
        [param setObject:@"000000" forKey:@"area_code"];
        [param setObject:[_addressFiled text] forKey:@"address"];
        [param setObject:[_nameField text] forKey:@"consignee"];
        [param setObject:[_phoneField text] forKey:@"mobile_num"];
        if (isEdit) {
            [param setObject:address_id forKey:@"address_id"];
            [param setObject:_customer.grow_id forKey:@"grow_id"];
        }
        [param setObject:manager.detailInfo.token forKey:@"token"];
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
        [param setObject:text forKey:@"signature"];
        [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf addAddressFinish:error Data:data];
            });
        }];
    } else {
        [self tapGestureRecognizer:nil];
    }
}

-(void)tapGestureRecognizer:(id)sender
{
    [_nameField resignFirstResponder];
    [_phoneField resignFirstResponder];
    [_addressFiled resignFirstResponder];
    
    if (_delegate && [_delegate respondsToSelector:@selector(closeEditAddressView)]) {
        [_delegate closeEditAddressView];
    }
}

#pragma mark - UITextFieldTextDidChangeNotification
- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField == _nameField) {
        _maxLength = 4;
    }
    else if (textField == _phoneField){
        _maxLength = 11;
    }
    else if (textField == _addressFiled){
        _maxLength = 50;
    }
    else {
        return;
    }
    NSString *toBeString = textField.text;
    NSString *lang = textField.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            [self emojiStrSplit:toBeString];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        [self emojiStrSplit:toBeString];
    }
}

- (void)emojiStrSplit:(NSString *)str
{
    NSInteger emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        NSInteger lenght = emoji % 10000;
        NSInteger location = emoji / 10000;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        if (_maxLength == 4) {
            [_nameField setText:lastStr];
        }else if (_maxLength == 11){
            [_phoneField setText:lastStr];
        }else{
            [_addressFiled setText:lastStr];
        }
    }
    
    if ([lastStr length] > _maxLength) {
        lastStr = [lastStr substringToIndex:_maxLength];
        if (_maxLength == 4) {
            [mview makeToast:@"姓名最多输入4个字" duration:1.0 position:@"center"];
            [_nameField setText:lastStr];
        }else if (_maxLength == 11){
             [mview makeToast:@"手机号码为11位" duration:1.0 position:@"center"];
            [_phoneField setText:lastStr];
        }else{
            [mview makeToast:@"地址最多输入50个字" duration:1.0 position:@"center"];
            [_addressFiled setText:lastStr];
        }
    }
}
#pragma maerk UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *recordCellId = @"AddressCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recordCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recordCellId];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, mview.frameWidth - 30 - 35, 40)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:CreateColor(100, 100, 100)];
        [nameLabel setFont:[UIFont systemFontOfSize:12]];
        nameLabel.numberOfLines = 2;
        [nameLabel setTag:1];
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(mview.frameWidth - 15 - 16, 12, 16, 16)];
        [imgView setImage:CREATE_IMG(@"cust_address_nor")];
        [imgView setTag:2];
        [cell.contentView addSubview:imgView];
        
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setFrame:CGRectMake(mview.frameWidth - 15 - 16 - 7, 5, 16 + 14, 16 + 14)];
//        [btn setImage:CREATE_IMG(@"cust_address_nor") forState:UIControlStateNormal];
//        [btn setImage:CREATE_IMG(@"cust_address_sel") forState:UIControlStateSelected];
//        [btn setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
//        [btn setTag:2];
//        [cell.contentView addSubview:btn];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frameX, nameLabel.frameBottom - 0.5, mview.frameWidth - 30, 0.5)];
        [lineLabel setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:lineLabel];
    }
    
    AddressModel *model = [_dataSource objectAtIndex:indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    [nameLabel setText:model.address];
    
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:2];
    [imgView setImage:CREATE_IMG(model.is_select ? @"cust_address_sel" : @"cust_address_nor")];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_lastIndexPath) {
        if (_lastIndexPath.row == indexPath.row) {
            return;
        }
        AddressModel *item = [_dataSource objectAtIndex:_lastIndexPath.row];
        item.is_select = NO;
        [tableView reloadRowsAtIndexPaths:@[_lastIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    AddressModel *model = [_dataSource objectAtIndex:indexPath.row];
    model.is_select = YES;
    [_addressFiled setText:model.address];
    [_nameField setText:model.consignee];
    [_phoneField setText:model.mobile_num];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    _lastIndexPath = indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

@end
