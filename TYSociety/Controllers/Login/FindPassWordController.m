//
//  FindPassWordController.m
//  TYSociety
//
//  Created by szl on 16/7/18.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "FindPassWordController.h"
#import "IdentifierValidator.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIColor+Hex.h"
#import "FindPass2ViewController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "AppDelegate.h"

@interface FindPassWordController ()<UITextFieldDelegate>

@end

@implementation FindPassWordController
{
    UIButton *_nextBtn;
    NSTimer *_timer;
    NSInteger _maxSeconds;
    NSString *_verilyCode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"短信验证";
    [self createRightBarButton];
    
    _params = [NSMutableArray arrayWithObjects:@"",@"", nil];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self createTableFooterView];
    [self checkNextBtnState];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)createRightBarButton
{
    if ([QQApiInterface isQQInstalled]) {
        UIButton * backBtn = [[self.navigationItem.leftBarButtonItems lastObject] customView];
        UIFont *font = [UIFont systemFontOfSize:15];
        NSString *tipStr = @"联系客服";
        CGSize size = [NSString calculeteSizeBy:tipStr Font:font MaxWei:SCREEN_WIDTH];
        [backBtn setFrameWidth:size.width];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(6.5, 0, 6.5, size.width - 10)];
        
        UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBut setFrame:CGRectMake(0, 0, size.width, size.height)];
        [rightBut addTarget:(AppDelegate *)[[UIApplication sharedApplication] delegate] action:@selector(launchQQClient) forControlEvents:UIControlEventTouchUpInside];
        [rightBut setTitle:tipStr forState:UIControlStateNormal];
        [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
        [rightBut setBackgroundColor:[UIColor clearColor]];
        [rightBut.titleLabel setFont:font];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
    }
    
}

- (void)createTableFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn = btn;
    [btn setFrame:CGRectMake(33, 20, footerView.frameWidth - 66, 40)];
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5];
    [btn setTitleColor:rgba(254, 253, 253, 1) forState:UIControlStateNormal];
    [btn setTitleColor:UnEditTextColor forState:UIControlStateDisabled];
    [btn setBackgroundImage:[UIColor createImageWithColor:BASELINE_COLOR Size:btn.frameSize] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIColor createImageWithColor:rgba(187, 167, 251, 1) Size:btn.frameSize] forState:UIControlStateDisabled];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(gotoNext:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:btn];
    
    [self.tableView setTableFooterView:footerView];
}

- (void)backToPreControl:(id)sender
{
    [self clearTimer];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 下一步
- (void)gotoNext:(id)sender
{
    if (self.sessionTask) {
        return;
    }
    
    if (!_verilyCode || ![_verilyCode isEqualToString:_params[1]]) {
        [self.view makeToast:@"短信验证码错误" duration:1.0 position:@"center"];
        return;
    }
    
    NSString *phoneNumber = _params[0];
    NSString *dynamicPass = _params[1];
    FindPass2ViewController *change = [FindPass2ViewController new];
    change.phoneNumber = phoneNumber;
    change.verificationCode = dynamicPass;
    [self.navigationController pushViewController:change animated:YES];
}

- (void)textFieldRightBtn:(id)sender{
    if (self.sessionTask) {
        return;
    }
    
    switch ([sender tag]) {
        case 0:
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1];
            [textField setText:@""];
            _params[0] = @"";
        }
            break;
        case 1:
        {
            if (self.sessionTask) {
                return;
            }
            
            if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
                [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
                return;
            }
            
            GlobalManager *manager = [GlobalManager shareInstance];
            NSMutableDictionary *param = [manager requestinitParamsWith:@"getCode"];
            NSString *phoneNumber = _params[0];
            [param setObject:phoneNumber forKey:@"phone"];
            [param setObject:@"2" forKey:@"type"];
            NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
            [param setObject:text forKey:@"signature"];
            
            [self.view makeToastActivity];
            self.view.userInteractionEnabled = NO;
            NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"user"];
            __weak typeof(self)weakSelf = self;
            self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf getVerilyCode:error Data:data];
                });
            }];
        }
            break;
        default:
            break;
    }
}

- (void)checkNextBtnState
{
    NSString *phoneNumber = _params[0];
    NSString *dynamicPass = _params[1];
    BOOL isPhone = [IdentifierValidator isValidPhone:phoneNumber];
    _nextBtn.enabled = isPhone && (dynamicPass.length > 0);
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *textFiled = (UITextField *)[cell.contentView viewWithTag:1];
    ((UIButton *)textFiled.rightView).enabled = isPhone && !_timer;
}

#pragma mark - 验证码
- (void)getVerilyCode:(NSError *)error Data:(id)result{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [result valueForKey:@"ret_data"];
        _verilyCode = [ret_data valueForKey:@"code"];
        
        _maxSeconds = 60;
        [self startTimerCreate];
        [self checkNextBtnState];
        
        [self.view makeToast:@"验证码已发送成功" duration:1.0 position:@"center"];
    }
}

#pragma mark - timer
- (void)startTimer:(NSTimeInterval)time
{
    _maxSeconds--;
    if (_maxSeconds < 0) {
        [self clearTimer];
    }
    [self resetVerilyCodeText];
    [self checkNextBtnState];
}

- (void)resetVerilyCodeText
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *textFiled = (UITextField *)[cell.contentView viewWithTag:1];
    [((UIButton *)textFiled.rightView) setTitle:(_maxSeconds >= 0) ? [NSString stringWithFormat:@"请等待%ld秒",(long)_maxSeconds] : @"发送验证码" forState:UIControlStateNormal];
}

- (void)clearTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startTimerCreate
{
    [self clearTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer:) userInfo:nil repeats:YES];
    [self resetVerilyCodeText];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _params.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *registerCell = @"registerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:registerCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:registerCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(33, 0, SCREEN_WIDTH - 66, 40)];
        [backView setBackgroundColor:rgba(239, 237, 243, 1)];
        [backView.layer setMasksToBounds:YES];
        [backView.layer setCornerRadius:5];
        [cell.contentView addSubview:backView];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(backView.frameX + 15, 0, backView.frameWidth - 15, backView.frameHeight)];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [textField setTag:1];
        [textField setFont:[UIFont systemFontOfSize:14]];
        [textField setValue:UnEditTextColor forKeyPath:@"_placeholderLabel.textColor"];
        [cell.contentView addSubview:textField];
    }
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1];
    textField.rightViewMode = (indexPath.section == 0) ? UITextFieldViewModeWhileEditing : UITextFieldViewModeAlways;
    textField.keyboardType = (indexPath.section == 0) ? UIKeyboardTypeNumberPad : UIKeyboardTypeASCIICapable;
    
    switch (indexPath.section) {
        case 0:
        {
            [textField setPlaceholder:@"请输入手机号码"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(0, 0, 43, textField.frameHeight)];
            [button setImage:CREATE_IMG(@"textClear@2x") forState:UIControlStateNormal];
            CGFloat marginTop = (textField.frameHeight - 13) / 2;
            [button setImageEdgeInsets:UIEdgeInsetsMake(marginTop, 15, marginTop, 15)];
            [button setTag:indexPath.section];
            [button addTarget:self action:@selector(textFieldRightBtn:) forControlEvents:UIControlEventTouchUpInside];
            textField.rightView = button;
        }
            break;
        case 1:
        {
            [textField setPlaceholder:@"请输入验证码"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(0, 0, 110, textField.frameHeight)];
            [button.layer setMasksToBounds:YES];
            [button.layer setCornerRadius:5];
            [button setTitle:@"发送验证码" forState:UIControlStateNormal];
            [button setTitleColor:rgba(254, 253, 253, 1) forState:UIControlStateNormal];
            [button setTitleColor:UnEditTextColor forState:UIControlStateDisabled];
            [button setBackgroundImage:[UIColor createImageWithColor:rgba(221, 100, 241, 1) Size:button.frameSize] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIColor createImageWithColor:rgba(221, 100, 241, 0.5) Size:button.frameSize] forState:UIControlStateDisabled];
            NSString *phoneNumber = _params[0];
            button.enabled = [IdentifierValidator isValidPhone:phoneNumber] && !_timer;
            [button setTag:indexPath.section];
            [button.titleLabel setFont:textField.font];
            [button addTarget:self action:@selector(textFieldRightBtn:) forControlEvents:UIControlEventTouchUpInside];
            textField.rightView = button;
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return !self.sessionTask;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location > 0
        && range.length == 1
        && string.length == 0) {
        return YES;
    }
    else if(textField.text.length >= 11){
        UITableViewCell *cell = [GlobalManager findViewFrom:textField To:[UITableViewCell class]];
        if (cell == nil) {
            return YES;
        }
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.section == 0) {
            [self.view.window makeToast:@"手机号不能超过11位" duration:1.0 position:@"center"];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            return NO;
        }
    }
    
    return YES;
}

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (!textField) {
        return;
    }
    
    UITableViewCell *cell = [GlobalManager findViewFrom:textField To:[UITableViewCell class]];
    if (cell == nil) {
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [_params replaceObjectAtIndex:indexPath.section withObject:textField.text ?: @""];
    [self checkNextBtnState];
}

@end
