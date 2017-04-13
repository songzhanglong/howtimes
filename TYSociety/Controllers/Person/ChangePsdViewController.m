//
//  ChangePsdViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/14.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "ChangePsdViewController.h"
#import "UIColor+Hex.h"
#import <AudioToolbox/AudioToolbox.h>
#import "LoginViewController.h"
#import "MyTableBarViewController.h"

@implementation ChangePsdViewController
{
    UIButton *_nextBtn;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"修改密码";
    
    _params = [NSMutableArray arrayWithObjects:@"",@"",@"", nil];
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self createTableHeaderView];
    [self createTableFooterView];
    [self checkNextBtnState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)createTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(33, 0, SCREEN_WIDTH - 66, 50)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:[NSString stringWithFormat:@"当前账号：%@",[GlobalManager shareInstance].detailInfo.user.login_name ?: @""]];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [headerView addSubview:label];
    [self.tableView setTableHeaderView:headerView];
}

- (void)createTableFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn = btn;
    [btn setFrame:CGRectMake(33, 20, footerView.frameWidth - 66, 40)];
    [btn setTitle:@"确认修改" forState:UIControlStateNormal];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5];
    [btn setTitleColor:rgba(254, 253, 253, 1) forState:UIControlStateNormal];
    [btn setTitleColor:UnEditTextColor forState:UIControlStateDisabled];
    [btn setBackgroundImage:[UIColor createImageWithColor:BASELINE_COLOR Size:btn.frameSize] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIColor createImageWithColor:rgba(187, 167, 251, 1) Size:btn.frameSize] forState:UIControlStateDisabled];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:btn];
    
    [self.tableView setTableFooterView:footerView];
}

- (void)submitAction:(id)sender
{
    for (int i = 0; i < _params.count; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1];
        [textField resignFirstResponder];
    }
    
    NSString *password = _params[0];
    NSString *password1 = _params[1];
    NSString *password2 = _params[2];
    if (![password2 isEqualToString:password1]) {
        [self.view makeToast:@"两次输入的密码不一致" duration:1.0 position:@"center"];
        return;
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"updatePwd"];
    [param setObject:manager.detailInfo.user.id forKey:@"user_id"];
    [param setObject:[NSString md5:password] forKey:@"old_password"];
    [param setObject:[NSString md5:password1] forKey:@"new_password"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"user"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf changePsdFinish:error Data:data];
        });
    }];
}

- (void)textFieldRightBtn:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    NSInteger index = [sender tag] - 10;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
    UITextField *field = [cell.contentView viewWithTag:1];
    field.secureTextEntry = btn.selected;
}

- (void)checkNextBtnState
{
    NSString *phoneNumber = _params[0];
    NSString *dynamicPass = _params[1];
    NSString *code = _params[2];
    _nextBtn.enabled = (phoneNumber.length >= 6 && phoneNumber.length <= 24) && (dynamicPass.length >= 6 && dynamicPass.length <= 24) && (code.length >= 6 && code.length <= 24);
}

#pragma mark - change password
- (void)changePsdFinish:(NSError *)error Data:(id)data{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Password];
        [self.navigationController.view makeToast:@"您的密码已经修改成功！" duration:1.0 position:@"center"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
//        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[LoginViewController new]] animated:YES completion:^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:USER_LOGOUT object:nil];
//            [[GlobalManager shareInstance] setDetailInfo:nil];
//            MyTableBarViewController *bar = (MyTableBarViewController *)[APPWindow rootViewController];
//            bar.selectedIndex = 0;
//            bar.customTabBar.nSelectedIndex = 0;
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_params count];
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
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.secureTextEntry = YES;
        [textField setTag:1];
        [textField setFont:[UIFont systemFontOfSize:14]];
        [textField setValue:UnEditTextColor forKeyPath:@"_placeholderLabel.textColor"];
        [cell.contentView addSubview:textField];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 43, textField.frameHeight)];
        [button setImage:CREATE_IMG(@"registerEyeH@2x") forState:UIControlStateNormal];
        [button setImage:CREATE_IMG(@"registerEyeN@2x") forState:UIControlStateSelected];
        CGFloat marginTop = (textField.frameHeight - 13) / 2;
        [button setImageEdgeInsets:UIEdgeInsetsMake(marginTop, 10, marginTop, 10)];
        [button setTag:indexPath.section];
        button.selected = YES;
        [button setTag:10 + indexPath.section];
        [button addTarget:self action:@selector(textFieldRightBtn:) forControlEvents:UIControlEventTouchUpInside];
        textField.rightView = button;
    }
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1];
    switch (indexPath.section) {
        case 0:
        {
            [textField setPlaceholder:@"请输入6-24位旧密码"];
        }
            break;
        case 1:
        {
            [textField setPlaceholder:@"请输入6-24位新密码"];
        }
            break;
        case 2:
        {
            [textField setPlaceholder:@"请再次输入6-24位新密码"];
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
    return (section == 0) ? 0 : 22;
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
    else if(textField.text.length >= 24){
        [self.view.window makeToast:@"密码不能超过24位" duration:1.0 position:@"center"];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        return NO;
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [_params replaceObjectAtIndex:indexPath.section withObject:textField.text ?: @""];
    [self checkNextBtnState];
}

@end
