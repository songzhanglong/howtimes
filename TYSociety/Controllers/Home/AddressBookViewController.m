//
//  AddressBookViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AddressBookViewController.h"
#import <AddressBook/AddressBook.h>
#import "PerInforModel.h"
#import "VerticalButton.h"
#import "CustomerView.h"
#import "SetTemplateViewController.h"
#import "CopyCustomerTemplateController.h"
#import "ChineseString.h"
#import "CustomerModel.h"
#import "YWCMainViewController.h"
#import "CheckTemplateController.h"
#import "Masonry.h"
@interface AddressBookViewController ()<CustomerViewDelegate,UITextFieldDelegate>
{
    UIView *_backView, *_bottomView;
    NSMutableArray *_addressBooks,*_existingBooks;
    CustomerView *_customerView;
    NSInteger _lastIndex;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
@implementation AddressBookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = _batchCustomers.grow_name ? [NSString stringWithFormat:@"为%@导入客户",_batchCustomers.grow_name] : @"导入客户";
    self.navigationController.navigationBar.translucent = NO;

    [self createRightNavButton];
    
    _addressBooks = [NSMutableArray array];
    _existingBooks = [NSMutableArray array];
    _dataSource = [NSMutableArray array];
    
    for (CustomerModel *item in _batchCustomers.consumers) {
        PerInforModel *model = [[PerInforModel alloc] init];
        model.name = item.name;
        model.phone = item.phone;
        model.user_id = item.user_id;
        model.isDelete = NO;
        [self.dataSource addObject:model];
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    [view setBackgroundColor:[UIColor whiteColor]];
    _backView = view;
    [self.view addSubview:view];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SelectCell1"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SelectCell2"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SelectCell3"];
    [view addSubview:_tableView];
//    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(view.mas_centerX);
//        make.centerY.equalTo(view.mas_centerY);
//        make.width.equalTo(view.mas_width);
//        make.height.equalTo(view.mas_height);
//    }];
    
    [self createBottom];
    [self readInfo];
    [self createTableHeaderView];
}

- (void)createTableHeaderView{
    if ([self.dataSource count] > 0) {
        UIView *headView = (UIView *)[self.view viewWithTag:29];
        if (!headView) {
            CGRect butRec = _backView.frame;
            [UIView animateWithDuration:0.2 animations:^{
                [_backView setFrame:CGRectMake(butRec.origin.x, 20, butRec.size.width, SCREEN_HEIGHT - 64 - 50 - 20)];
                _tableView.frameHeight = MIN(_tableView.frameHeight, _backView.frameHeight);
            }];
            
            headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            [headView setTag:29];
            [headView setBackgroundColor:CreateColor(245, 242, 253)];
            [self.view addSubview:headView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont systemFontOfSize:10]];
            [label setTextColor:rgba(155, 128, 251, 1)];
            [label setText:[NSString stringWithFormat:@"已加入%ld人",(long)[self.dataSource count]]];
            [label setTag:11];
            [headView addSubview:label];
        }else {
            UILabel *label = (UILabel *)[headView viewWithTag:11];
            if (label) {
                [label setText:[NSString stringWithFormat:@"已加入%ld人",(long)[self.dataSource count]]];
            }
        }
    }else {
        UIView *headView = (UIView *)[self.view viewWithTag:29];
        if (headView) {
            CGRect butRec = _backView.frame;
            [UIView animateWithDuration:0.2 animations:^{
                [_backView setFrame:CGRectMake(butRec.origin.x, 0, butRec.size.width, SCREEN_HEIGHT - 64 - 50)];
                _tableView.frameHeight = MIN(_tableView.frameHeight, _backView.frameHeight);
            } completion:^(BOOL finished) {
                [headView removeFromSuperview];
            }];
        }
    }
}

- (void)createBottom
{
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 50, SCREEN_WIDTH, 50)];
    _bottomView = bottom;
    [bottom setBackgroundColor:CreateColor(240, 239, 244)];
    [bottom setUserInteractionEnabled:YES];
    [self.view addSubview:bottom];
    
    _lastIndex = 2;
    for (int i = 0; i < 2; i++) {
        VerticalButton *button = [VerticalButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(SCREEN_WIDTH / 2 * i, 0, SCREEN_WIDTH / 2, 50)];
        [button setTag:1 + i];
        button.imgSize = CGSizeMake((i == 0) ? (67.0 / 3) : 28, 22);
        button.textSize = CGSizeMake(SCREEN_WIDTH / 2, 20);
        button.margin = 1;
        [button setImage:CREATE_IMG((i == 0) ? @"customer_existing_nor" : @"customer_loction_nor") forState:UIControlStateNormal];
        [button setImage:CREATE_IMG((i == 0) ? @"customer_existing_sel" : @"customer_loction_sel") forState:UIControlStateSelected];
        button.selected = (i == 1);
        [button setTitle:(i == 0) ? @"插入已存在客户" : @"从电话本导入客户" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:11]];
        [button setTitleColor:(i == 0) ? rgba(97, 97, 97, 1) : rgba(155, 128, 251, 1) forState:UIControlStateNormal];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button addTarget:self action:@selector(customerAction:) forControlEvents:UIControlEventTouchUpInside];
        [bottom addSubview:button];
        
        if ( i == 0) {
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 0.5, 0, 1, bottom.frameHeight)];
            [lineLabel setBackgroundColor:CreateColor(229, 228, 233)];
            [bottom addSubview:lineLabel];
        }
    }
}

- (void)customerAction:(VerticalButton *)sender
{
    if (sender.tag != _lastIndex) {
        sender.selected = YES;
        [sender setTitleColor:rgba(155, 128, 251, 1) forState:UIControlStateNormal];
        VerticalButton *lastBtn = (VerticalButton *)[_bottomView viewWithTag:_lastIndex];
        lastBtn.selected = NO;
        [lastBtn setTitleColor:rgba(97, 97, 97, 1) forState:UIControlStateNormal];
        _lastIndex = sender.tag;
    }
    switch ([sender tag] - 1) {
        case 0:
        {
            if ([_existingBooks count] == 0) {
                if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
                    [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
                    return;
                }
                GlobalManager *manager = [GlobalManager shareInstance];
                NSMutableDictionary *param = [manager requestinitParamsWith:@"queryConsumerList"];
                [param setObject:manager.detailInfo.token forKey:@"token"];
                NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
                [param setObject:text forKey:@"signature"];
                
                [self.view makeToastActivity];
                self.view.userInteractionEnabled = NO;
                NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"consumer"];
                __weak typeof(self)weakSelf = self;
                self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf getCoustomerFinish:error Data:data];
                    });
                }];
            }else {
                NSInteger num = 0;
                for (NSArray *arr in _existingBooks) {
                    num += [arr count];
                }
                CGFloat hei = MIN(num * 55 + [_existingBooks count] * 15, SCREEN_HEIGHT / 3);
                [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50 - hei)];
                [_customerView setFrame:CGRectMake(0, _tableView.frameBottom, SCREEN_WIDTH, hei)];
                _customerView.dataSource = _existingBooks;
                _customerView.tableView.frameHeight = hei;
                [_customerView.tableView reloadData];
            }
        }
            break;
        case 1:
        {
            if ([_addressBooks count] == 0) {
                [self.view.window makeToast:@"您的通讯录中没有联系人哦" duration:1.0 position:@"center"];
                return;
            }
            NSInteger num = 0;
            for (NSArray *arr in _addressBooks) {
                num += [arr count];
            }
            CGFloat hei = MIN([_addressBooks count] * 15 + num * 55, SCREEN_HEIGHT / 3);
            [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50 - hei)];
            [_customerView setFrame:CGRectMake(0, _tableView.frameBottom, SCREEN_WIDTH, hei)];
            _customerView.dataSource = _addressBooks;
            _customerView.tableView.frameHeight = hei;
            [_customerView.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - CustomerView delegate
- (void)selectPhone:(PerInforModel *)model
{
    if (!self.dataSource) {
        self.dataSource = [NSMutableArray array];
    }

    NSString *tel = [model.phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    tel = [tel stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([tel hasPrefix:@"086"]) {
        tel = [tel stringByReplacingOccurrencesOfString:@"086" withString:@""];
    }
    else if ([tel hasPrefix:@"+86"]) {
        tel = [tel stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    }
    
    if ([tel length] != 11) {
        [self.view.window makeToast:@"请输入正确的手机号码" duration:1.0 position:@"center"];
        return;
    }
    
    for (PerInforModel *subModel in self.dataSource) {
        if ([tel isEqualToString:subModel.phone]) {
            [self.view.window makeToast:@"该手机号码已经存在了" duration:1.0 position:@"center"];
            return;
        }
    }
    
    NSString *name = model.name;
    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    PerInforModel *item = [[PerInforModel alloc] init];
    item.name = name;
    item.phone = tel;
    item.user_id = model.user_id ?: @"";
    item.isDelete = YES;
    [self.dataSource addObject:item];
    
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self createTableHeaderView];
}

#pragma mark - 获取客户
- (void)getCoustomerFinish:(NSError *)error Data:(id)data
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [data valueForKey:@"ret_data"];
        NSMutableArray *array = [NSMutableArray array];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            array = [PerInforModel arrayOfModelsFromDictionaries:ret_data error:nil];
        }
        if ([array count] == 0) {
            [self.view makeToast:@"您现在还没有已存在的客户哦" duration:1.0 position:@"center"];
            [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
      
            [_customerView setFrame:CGRectMake(0, _tableView.frameBottom, SCREEN_WIDTH, 0)];
            _customerView.tableView.frameHeight = 0;
            
        }else {
            NSArray *tempArray = [array sortedArrayUsingFunction:nickNameSort context:NULL];
            NSMutableArray *lastArr = [NSMutableArray array];
            NSString *firstLetter = @"A";
            for (PerInforModel *item in tempArray) {
                if ([item.name length] == 0) {
                    continue;
                }
                NSString *toFirst = [self pinyinFirstLetter:item.name];
                if (![firstLetter isEqualToString:toFirst]) {
                    firstLetter = toFirst;
                    NSMutableArray *tmpArr = [NSMutableArray arrayWithObject:item];
                    [lastArr addObject:tmpArr];
                }
                else{
                    NSMutableArray *sufArr = [lastArr lastObject];
                    [sufArr addObject:item];
                }
            }
            _existingBooks = lastArr;
            CGFloat hei = MIN([array count] * 55 + [lastArr count] * 15, SCREEN_HEIGHT / 3);
            [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50 - hei)];
            
            [_customerView setFrame:CGRectMake(0, _tableView.frameBottom, SCREEN_WIDTH, hei)];
            _customerView.dataSource = lastArr;
            _customerView.tableView.frameHeight = hei;
            [_customerView.tableView reloadData];
        }
    }
}

NSInteger nickNameSort(id user1, id user2, void *context)
{
    PerInforModel *item1,*item2;
    //类型转换
    item1 = (PerInforModel *)user1;
    item2 = (PerInforModel *)user2;
    return  [item1.name localizedCompare:item2.name];
}

- (void)readInfo{
    ABAddressBookRef addressBooks = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0){
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
        //获取通讯录权限
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else{
        CFDictionaryRef options;
        CFErrorRef *error;
        addressBooks = ABAddressBookCreateWithOptions(options,error);
    }
    
    //获取通讯录中的所有人
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    //通讯录中人数
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    NSMutableArray *addressBookArray = [NSMutableArray array];
    //循环，获取每个人的个人信息
    for (NSInteger i = 0; i < nPeople; i++)
    {
        //新建一个addressBook model类
        PerInforModel *addressBook = [[PerInforModel alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        } else {
            if ((__bridge id)abLastName != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        addressBook.name = nameString;
        addressBook.recordID = (int)ABRecordGetRecordID(person);;
        
        NSData *imageData = (__bridge NSData*)ABPersonCopyImageData(person);
        UIImage *image = [UIImage imageWithData:imageData];
        addressBook.faceImg = image;
        
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
            
            if (valuesCount == 0) {
                CFRelease(valuesRef);
                continue;
            }
            //获取电话号码和email
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
                        addressBook.phone = (__bridge NSString*)value;
                        break;
                    }
                    case 1: {// Email
                        addressBook.email = (__bridge NSString*)value;
                        break;
                    }
                }
                CFRelease(value);
            }
            CFRelease(valuesRef);
        }
        //将个人信息添加到数组中，循环完成后addressBookTemp中包含所有联系人的信息
        [addressBookArray addObject:addressBook];
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    
    NSArray *tempArray = [addressBookArray sortedArrayUsingFunction:nickNameSort context:NULL];
    NSMutableArray *lastArr = [ChineseString LetterSortArray:tempArray];
    _addressBooks = lastArr;
    
    if ([_addressBooks count] == 0) {
        [self.view.window makeToast:@"您的通讯录中没有联系人哦" duration:1.0 position:@"center"];
        return;
    }
    
    NSInteger num = 0;
    for (NSArray *arr in _addressBooks) {
        num += [arr count];
    }
    CGFloat hei = MIN([_addressBooks count] * 15 + num * 55, SCREEN_HEIGHT / 3);
    [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50 - hei)];
    
    _customerView = [[CustomerView alloc] initWithFrame:CGRectMake(0, _tableView.frameBottom, SCREEN_WIDTH, hei)];
    _customerView.dataSource = _addressBooks;
    _customerView.delegate = self;
    [_backView addSubview:_customerView];
}

-(NSString*)pinyinFirstLetter:(NSString *)hanzi
{
    NSString *result = @"";
    NSMutableString *ms = [[NSMutableString alloc] initWithString:hanzi];
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
    }
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)){
    }
    if (ms.length>0) {
        result = [ms substringToIndex:1];
    }
    return [result uppercaseString];
}

- (void)createRightNavButton
{
    UIFont *tipFont = [UIFont systemFontOfSize:14];
    CGSize size = [NSString calculeteSizeBy:@"下一步" Font:tipFont MaxWei:SCREEN_WIDTH];
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, size.width + 10, size.height + 5)];
    [rightBut setTitle:@"下一步" forState:UIControlStateNormal];
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut.titleLabel setFont:tipFont];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
    
}

#pragma mark - 保存客户
- (void)configCoustomerFinish:(NSError *)error Data:(id)data
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        NSMutableArray *array = [NSMutableArray array];
        id ret_data = [data valueForKey:@"ret_data"];
        if (_batchCustomers.batch_id) {
            if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
                array = [PerInforModel arrayOfModelsFromDictionaries:ret_data error:nil];
            }
        }
        else {
            id userlist = [ret_data valueForKey:@"userlist"];
            if (userlist && [userlist isKindOfClass:[NSArray class]]) {
                array = [PerInforModel arrayOfModelsFromDictionaries:userlist error:nil];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:RefreshCustomer object:nil];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for (PerInforModel *item in array) {
            CustomerModel *model = [[CustomerModel alloc] init];
            model.name = item.name;
            model.phone = item.phone;
            model.user_id = item.user_id;
            [tempArray addObject:model];
        }
        SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
        setController.batch_id = _batchCustomers.batch_id ?: [ret_data valueForKey:@"batch_id"];
        setController.grow_id = _batchCustomers.grow_id;
        setController.customers = tempArray;
        [self.navigationController pushViewController:setController animated:YES];
    }
}

- (void)rightAction:(id)sender
{
    BOOL find = NO;
    for (PerInforModel *item in self.dataSource) {
        if (item.isDelete) {
            find = YES;
            break;
        }
    }
    
    if (!find || [self.dataSource count] == 0) {
        [self.view.window makeToast:@"您还没有导入客户哦" duration:1.0 position:@"center"];
        return;
    }
    
    NSMutableArray *idnexArray = [NSMutableArray array];
    for (PerInforModel *item in self.dataSource) {
        if (item.isDelete) {
            [idnexArray addObject:item];
        }
    }
    
    if (_batchCustomers.is_create_grow.integerValue == 1) {
        //copy customer
        CopyCustomerTemplateController *copyCustomer = [[CopyCustomerTemplateController alloc] init];
        copyCustomer.dataSource = _batchCustomers.consumers;
        copyCustomer.userList = idnexArray;
        //copyCustomer.batch_id = _batchCustomers.batch_id;
        //copyCustomer.grow_id = _batchCustomers.grow_id;
        //copyCustomer.isNeedSet = _goBack;
        [self.navigationController pushViewController:copyCustomer animated:YES];
        
        return;
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    GlobalManager *manager = [GlobalManager shareInstance];
    NSString *ckey = _batchCustomers.batch_id ? @"addConsumerToTemp" : @"createConsumer";
    NSMutableDictionary *param = [manager requestinitParamsWith:ckey];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (PerInforModel *item in idnexArray) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:item.name forKey:@"name"];
        [dic setValue:item.phone forKey:@"phone"];
        [dic setValue:item.user_id ?: @"" forKey:@"user_id"];
        [tempArray addObject:dic];
    }
    [param setObject:tempArray forKey:@"userlist"];
    if (_batchCustomers.batch_id) {
        [param setObject:_batchCustomers.batch_id forKey:@"batch_id"];
    }else {
        [param setObject:_product_id forKey:@"product_id"];
        [param setObject:_batchCustomers.grow_id forKey:@"grow_id"];
    }
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"consumer"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf configCoustomerFinish:error Data:data];
        });
    }];
}

- (void)deleteAction:(UIButton *)sender
{
    UITableViewCell *cell = [GlobalManager findViewFrom:sender To:[UITableViewCell class]];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    
    UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    UITextField *nameField = (UITextField *)[cell1.contentView viewWithTag:10];
    [nameField resignFirstResponder];
    UITextField *phoneField = (UITextField *)[cell1.contentView viewWithTag:12];
    [phoneField resignFirstResponder];
    
    [self.dataSource removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([self.dataSource count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self createTableHeaderView];
}

- (void)confirmAction:(UIButton *)sender
{
    if (!self.dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    UITableViewCell *cell = [GlobalManager findViewFrom:sender To:[UITableViewCell class]];
    PerInforModel *item = [[PerInforModel alloc] init];
    
    UITextField *nameField = (UITextField *)[cell.contentView viewWithTag:10];
    if ([nameField.text length] == 0) {
        [self.view.window makeToast:@"请输入客户姓名" duration:1.0 position:@"center"];
        return;
    }

    UITextField *phoneField = (UITextField *)[cell.contentView viewWithTag:12];
    NSString *str = phoneField.text;
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([str length] != 11) {
        [self.view.window makeToast:@"请输入正确的手机号码" duration:1.0 position:@"center"];
        return;
    }
    
    for (PerInforModel *model in self.dataSource) {
        if ([model.phone isEqualToString:phoneField.text]) {
            [self.view.window makeToast:@"该手机号码已经存在了" duration:1.0 position:@"center"];
            return;
        }
    }
    NSString *name = nameField.text;
    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    item.name = name;
    item.phone = str;
    item.user_id = @"";
    item.isDelete = YES;
    [nameField setText:@""];
    [phoneField setText:@""];
    [nameField resignFirstResponder];
    [phoneField resignFirstResponder];
    
    [self.dataSource addObject:item];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self createTableHeaderView];
}

#pragma mark- UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat tabHeight = 0.0;
    switch (indexPath.section) {
        case 0:
        {
            tabHeight = 30;
        }
            break;
        case 1:
        {
            tabHeight = 25;
        }
            break;
        case 2:
        {
            tabHeight = 45;
        }
            break;
            
        default:
            break;
    }
    return tabHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    switch (section) {
        case 0:
        {
            num = 1;
        }
            break;
        case 1:
        {
            num = [self.dataSource count];
        }
            break;
        case 2:
        {
            num = 1;
        }
            break;
            
        default:
            break;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = (indexPath.section == 0) ? @"SelectCell1" : ((indexPath.section == 1) ? @"SelectCell2" : @"SelectCell3");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
        {
            UIView *backView = (UIView *)[cell.contentView viewWithTag:1];
            if (!backView) {
                backView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
                [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
                [backView setBackgroundColor:CreateColor(252, 252, 252)];
                [backView setTag:1];
                [cell.contentView addSubview:backView];
            }
            
            UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
            if (!nameLabel) {
                nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 100, 20)];
                [nameLabel setBackgroundColor:[UIColor clearColor]];
                [nameLabel setTextColor:rgba(155, 128, 251, 1)];
                [nameLabel setFont:[UIFont systemFontOfSize:14]];
                [nameLabel setTag:2];
                [cell.contentView addSubview:nameLabel];
            }
            [nameLabel setText:@"客户姓名"];
            
            UILabel *phoneLabel = (UILabel *)[cell.contentView viewWithTag:3];
            if (!phoneLabel) {
                phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 5, 120, 20)];
                [phoneLabel setBackgroundColor:[UIColor clearColor]];
                [phoneLabel setTextColor:rgba(155, 128, 251, 1)];
                [phoneLabel setFont:[UIFont systemFontOfSize:14]];
                [phoneLabel setTag:3];
                [cell.contentView addSubview:phoneLabel];
            }
            [phoneLabel setText:@"手机号码"];
        }
            break;
        case 1:
        {
            UIView *backView = (UIView *)[cell.contentView viewWithTag:4];
            if (!backView) {
                backView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
                [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
                [backView setBackgroundColor:[UIColor whiteColor]];
                [backView setTag:4];
                [cell.contentView addSubview:backView];
            }
            
            PerInforModel *item = [self.dataSource objectAtIndex:indexPath.row];
            UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:5];
            if (!nameLabel) {
                nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, 25)];
                [nameLabel setBackgroundColor:[UIColor clearColor]];
                [nameLabel setTextColor:CreateColor(100, 100, 100)];
                [nameLabel setFont:[UIFont systemFontOfSize:14]];
                [nameLabel setTag:5];
                [cell.contentView addSubview:nameLabel];
            }
            [nameLabel setText:item.name ?: @""];
            
            UILabel *phoneLabel = (UILabel *)[cell.contentView viewWithTag:6];
            if (!phoneLabel) {
                phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 0, 120, 25)];
                [phoneLabel setBackgroundColor:[UIColor clearColor]];
                [phoneLabel setTextColor:CreateColor(100, 100, 100)];
                [phoneLabel setFont:[UIFont systemFontOfSize:14]];
                [phoneLabel setTag:6];
                [cell.contentView addSubview:phoneLabel];
            }
            [phoneLabel setText:item.phone ?: @""];
            
            UIButton *delBtn = (UIButton *)[cell.contentView viewWithTag:7];
            if (!delBtn) {
                delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [delBtn setFrame:CGRectMake(SCREEN_WIDTH - 13 - 20, 0, 13 + 17, 13 + 12)];
                [delBtn setImage:CREATE_IMG(@"customer_delete") forState:UIControlStateNormal];
                [delBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 8.5, 6, 8.5)];
                [delBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                [delBtn setTag:7];
                [cell.contentView addSubview:delBtn];
            }
            delBtn.hidden = !item.isDelete;
        }
            break;
        case 2:
        {
            UIView *backView = (UIView *)[cell.contentView viewWithTag:8];
            if (!backView) {
                backView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
                [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
                [backView setBackgroundColor:[UIColor whiteColor]];
                [backView setTag:8];
                [cell.contentView addSubview:backView];
            }
            
            UIView *fieldBack = (UIView *)[cell.contentView viewWithTag:9];
            if (!fieldBack) {
                fieldBack = [[UIView alloc] initWithFrame:CGRectMake(20, 10, 95, 25)];
                [fieldBack setBackgroundColor:CreateColor(245, 245, 245)];
                [fieldBack setUserInteractionEnabled:YES];
                [fieldBack setTag:9];
                [cell.contentView addSubview:fieldBack];
            }
            
            UITextField *nameField = (UITextField *)[cell.contentView viewWithTag:10];
            if (!nameField) {
                nameField = [[UITextField alloc] initWithFrame:CGRectMake(30, 10, 75, 25)];
                [nameField setBackgroundColor:CreateColor(245, 245, 245)];
                [nameField setPlaceholder:@"请输入姓名"];
                nameField.delegate = self;
                //nameField.keyboardType = UIKeyboardTypeASCIICapable;
                nameField.returnKeyType = UIReturnKeyDone;
                [nameField setFont:[UIFont systemFontOfSize:14]];
                [nameField setTextColor:CreateColor(100, 100, 100)];
                [nameField setTag:10];
                [cell.contentView addSubview:nameField];
            }
            
            UIView *fieldBack2 = (UIView *)[cell.contentView viewWithTag:11];
            if (!fieldBack2) {
                fieldBack2 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, 10, 145, 25)];
                [fieldBack2 setBackgroundColor:CreateColor(245, 245, 245)];
                [fieldBack2 setUserInteractionEnabled:YES];
                [fieldBack2 setTag:11];
                [cell.contentView addSubview:fieldBack2];
            }
            
            UITextField *phoneField = (UITextField *)[cell.contentView viewWithTag:12];
            if (!phoneField) {
                phoneField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 10, 125, 25)];
                [phoneField setBackgroundColor:CreateColor(245, 245, 245)];
                [phoneField setPlaceholder:@"请输入联系电话"];
                phoneField.delegate = self;
                phoneField.keyboardType = UIKeyboardTypeNumberPad;
                phoneField.returnKeyType = UIReturnKeyDone;
                [phoneField setFont:[UIFont systemFontOfSize:14]];
                [phoneField setTextColor:CreateColor(100, 100, 100)];
                [phoneField setTag:12];
                [cell.contentView addSubview:phoneField];
            }
            
            UIButton *checkBtn = (UIButton *)[cell.contentView viewWithTag:13];
            if (!checkBtn) {
                checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [checkBtn setFrame:CGRectMake(SCREEN_WIDTH - 13 - 20, 7.5, 13 + 17, 13 + 17)];
                [checkBtn setImage:CREATE_IMG(@"customer_cheak") forState:UIControlStateNormal];
                [checkBtn setImageEdgeInsets:UIEdgeInsetsMake(8.5, 8.5, 8.5, 8.5)];
                [checkBtn setTag:13];
                [checkBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:checkBtn];
            }
            
            UILabel *lineLabel = (UILabel *)[cell.contentView viewWithTag:14];
            if (!lineLabel) {
                lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
                [lineLabel setBackgroundColor:CreateColor(228, 228, 228)];
                [lineLabel setTag:14];
                [cell.contentView addSubview:lineLabel];
            }
        }
            break;
            
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    UITextField *nameField = (UITextField *)[cell.contentView viewWithTag:10];
    [nameField resignFirstResponder];
    UITextField *phoneField = (UITextField *)[cell.contentView viewWithTag:12];
    [phoneField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL isNameText = (textField.tag == 10);
    BOOL isPhoneText = (textField.tag == 12);
    BOOL reback = (range.location > 0 && range.length == 1 && string.length == 0);
    if (reback) {
        return YES;
    }
    else if (isNameText && textField.text.length >= 8) {
        [self.view.window makeToast:@"姓名不能超过8位" duration:1.0 position:@"center"];
        return NO;
    }
    else if (isPhoneText && textField.text.length >= 11) {
        [self.view.window makeToast:@"手机号不能超过11位" duration:1.0 position:@"center"];
        return NO;
    }
    return YES;
}

@end
