//
//  LoginViewController.m
//  TYSociety
//
//  Created by szl on 16/6/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "LoginViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RegisterViewController.h"
#import "IdentifierValidator.h"
#import "UMSocial.h"
#import "WXApiObject.h"
#import "DataBaseOperation.h"
#import "ProgressCircleView.h"
#import "AssetModel.h"
#import "Masonry.h"
#import "UIColor+Hex.h"
#import "DJTOrderViewController.h"
#import "FindPassWordController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "AppDelegate.h"
//#import "WebViewController.h"

@interface LoginViewController ()

@property (nonatomic,strong)ALAssetsGroup *group;
@property (nonatomic,strong)ProgressCircleView *progressView;

@end

@implementation LoginViewController
{
    UIView *_outerCircle,*_middleCircle,*_insideCircle;
    UIImageView *_loginLogo;
    UIButton *_loginBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    _agreementCooperate = YES;
    
    _navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    [self createRightBarButton];
    [self createUI];
    [self createFootView];
    
    [self chenageLoginState];
}

#pragma mark - appera
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _navBarHairlineImageView.hidden = YES;
    [self.navigationController.navigationBar cnSetBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    //监视键盘高度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _navBarHairlineImageView.hidden = NO;
    [self.navigationController.navigationBar cnReset];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - UI
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

- (void)createUI{
    //设计尺寸与当前设备比例
    UIImage *upImg = CREATE_IMG(@"upBack@2x");
    UIImageView *upImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * upImg.size.height / upImg.size.width)];
    [upImgView setImage:upImg];
    [self.view addSubview:upImgView];
    
    //外圈,内圈
    UIView *outSide = [[UIView alloc] init];
    [outSide setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:outSide];
    [outSide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).with.multipliedBy(112 / 1334.0);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_height).with.multipliedBy((419 - 112) / 1334.0);
        make.height.equalTo(outSide.mas_width);
    }];
    [outSide setBackgroundColor:[UIColor clearColor]];
    [outSide.layer setMasksToBounds:YES];
    outSide.layer.borderColor = rgba(229, 229, 229, 1).CGColor;
    outSide.layer.borderWidth = 0.5;
    _outerCircle = outSide;
    
    //内圈,
    UIView *middleSide = [[UIView alloc] init];
    [middleSide setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:middleSide];
    CGFloat sideOff = 16 * SCREEN_HEIGHT / 1334;
    [middleSide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(outSide).with.insets(UIEdgeInsetsMake(sideOff, sideOff, sideOff, sideOff));
    }];
    [middleSide setBackgroundColor:[UIColor clearColor]];
    [middleSide.layer setMasksToBounds:YES];
    middleSide.layer.borderColor = outSide.layer.borderColor;
    middleSide.layer.borderWidth = 0.5;
    _middleCircle = middleSide;
    
    //内圈
    UIView *insideSide = [[UIView alloc] init];
    [insideSide setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:insideSide];
    [insideSide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(middleSide).with.insets(UIEdgeInsetsMake(sideOff, sideOff, sideOff, sideOff));
    }];
    [insideSide setBackgroundColor:[UIColor whiteColor]];
    [insideSide.layer setMasksToBounds:YES];
    insideSide.layer.borderColor = outSide.layer.borderColor;
    insideSide.layer.borderWidth = 0.5;
    _insideCircle = insideSide;
    
    //login
    _loginLogo = [[UIImageView alloc] init];
    [_loginLogo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_loginLogo setImage:CREATE_IMG(@"loginLogo")];
    [self.view addSubview:_loginLogo];
    [_loginLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(insideSide.mas_centerX);
        make.centerY.equalTo(insideSide.mas_centerY);
        make.height.equalTo(self.view.mas_height).with.multipliedBy(180 / 1334.0);
        make.width.equalTo(_loginLogo.mas_height);
    }];
    
    //phone
    UIImageView *loginTip = [[UIImageView alloc] initWithImage:CREATE_IMG(@"userName@2x")];
    [loginTip setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:loginTip];
    [loginTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_right).with.multipliedBy(107.0 / 750);
        make.top.equalTo(self.view.mas_bottom).with.multipliedBy(502.0 / 1334);
        make.height.equalTo(self.view.mas_height).with.multipliedBy(54.0 / 1334);
        make.width.equalTo(loginTip.mas_height).with.multipliedBy(48.0 / 54);
    }];
    
    _phoneField = [[UITextField alloc] init];
    [_phoneField setTranslatesAutoresizingMaskIntoConstraints:NO];
    _phoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _phoneField.autocorrectionType = UITextAutocorrectionTypeNo;
    _phoneField.delegate = self;
    [_phoneField setFont:[UIFont systemFontOfSize:17]];
    _phoneField.returnKeyType = UIReturnKeyDone;
    _phoneField.textColor = rgba(254, 253, 253, 1);
    _phoneField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _phoneField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneField.placeholder = @"请输入手机号码";
    NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:User_Phone];
    [_phoneField setText:userPhone ?: @""];
    _phoneField.rightViewMode = UITextFieldViewModeWhileEditing;
    [_phoneField setValue:UnEditTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.view addSubview:_phoneField];
    [_phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(loginTip.mas_right).with.offset(4);
        make.centerY.equalTo(loginTip.mas_centerY);
        make.right.equalTo(self.view.mas_right).with.offset(- loginTip.frameRight - 4 - loginTip.frameX);
        make.height.equalTo(@(21));
    }];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 31, 21)];
    [button setImage:CREATE_IMG(@"textClear@2x") forState:UIControlStateNormal];
    [_phoneField setRightView:button];
    [button setImageEdgeInsets:UIEdgeInsetsMake(4, 9, 4, 9)];
    [button setTag:1];
    [button addTarget:self action:@selector(textFieldRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *lineView = [[UIView alloc] init];
    [lineView setBackgroundColor:[UIColor whiteColor]];
    [lineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(loginTip.mas_left).with.offset(-4);
        make.top.equalTo(self.view.mas_bottom).with.multipliedBy(564.0 / 1334);
        make.right.equalTo(_phoneField.mas_right).with.offset(4);
        make.height.equalTo(@(1));
    }];

    //password
    UIImageView *passTip = [[UIImageView alloc] initWithImage:CREATE_IMG(@"userPass@2x")];
    [passTip setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:passTip];
    [passTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(loginTip.mas_centerX);
        make.top.equalTo(self.view.mas_bottom).with.multipliedBy(630.0 / 1334);
        make.height.equalTo(self.view.mas_height).with.multipliedBy(52.0 / 1334);
        make.width.equalTo(loginTip.mas_height).with.multipliedBy(48.0 / 52);
    }];
    
    _passField = [[UITextField alloc] init];
    [_passField setTranslatesAutoresizingMaskIntoConstraints:NO];
    _passField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passField.delegate = self;
    [_passField setFont:[UIFont systemFontOfSize:17]];
    _passField.returnKeyType = UIReturnKeyDone;
    _passField.textColor = rgba(254, 253, 253, 1);
    _passField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passField.secureTextEntry = YES;
    _passField.keyboardType = UIKeyboardTypeASCIICapable;
    _passField.placeholder = @"请输入密码";
    //[_passField setText:@"123456"];
    _passField.rightViewMode = UITextFieldViewModeAlways;
    [_passField setValue:UnEditTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.view addSubview:_passField];
    [_passField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneField.mas_left);
        make.centerY.equalTo(passTip.mas_centerY);
        make.right.equalTo(_phoneField.mas_right);
        make.height.equalTo(@(21));
    }];
    UIButton *passBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [passBtn setFrame:CGRectMake(0, 0, 31, 21)];
    [passBtn setImage:CREATE_IMG(@"closePassH@2x") forState:UIControlStateNormal];
    [passBtn setImage:CREATE_IMG(@"closePassN@2x") forState:UIControlStateSelected];
    [passBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 7.75, 6, 7.75)];
    [passBtn setTag:2];
    [passBtn setSelected:!_showPass];
    [passBtn addTarget:self action:@selector(textFieldRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    _passField.rightView = passBtn;
    
    UIView *passLine = [[UIView alloc] init];
    [passLine setBackgroundColor:[UIColor whiteColor]];
    [passLine setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:passLine];
    [passLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_left);
        make.top.equalTo(self.view.mas_bottom).with.multipliedBy(696.0 / 1334);
        make.right.equalTo(lineView.mas_right);
        make.height.equalTo(@(1));
    }];
    
    //buttons
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:_phoneField.textColor forState:UIControlStateNormal];
    [loginBtn setTitleColor:UnEditTextColor forState:UIControlStateDisabled];
    [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [loginBtn addTarget:self action:@selector(userLogin:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setTag:1];
    //[loginBtn setBackgroundColor:BASELINE_COLOR];
    _loginBtn = loginBtn;
    [self.view addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passLine.mas_left);
        make.right.equalTo(passLine.mas_right);
        make.top.equalTo(self.view.mas_bottom).with.multipliedBy(807.0 / 1334);
        make.bottom.equalTo(self.view.mas_bottom).with.multipliedBy(901.0 / 1334);
    }];
    
    //注册
    UIButton *regisBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [regisBut setBackgroundColor:[UIColor clearColor]];
    [regisBut setImage:CREATE_IMG(@"loginRegis") forState:UIControlStateNormal];
    [regisBut setTranslatesAutoresizingMaskIntoConstraints:NO];
    [regisBut addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:regisBut];
    [regisBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(85));
        make.height.equalTo(@(22));
        make.right.equalTo(loginBtn.mas_right);
        make.top.equalTo(self.view.mas_bottom).with.multipliedBy(919.0 / 1334);
    }];
    
    //forger
    NSString *str = @"忘记密码?";
    UIFont *font = [UIFont systemFontOfSize:13];
    CGSize strSize = [NSString calculeteSizeBy:str Font:font MaxWei:100];
    UIButton *forgetPass = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPass setTranslatesAutoresizingMaskIntoConstraints:NO];
    [forgetPass setTitle:str forState:UIControlStateNormal];
    [forgetPass setTitleColor:rgba(153, 153, 153, 1) forState:UIControlStateNormal];
    [forgetPass setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [forgetPass.titleLabel setFont:font];
    [forgetPass addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [forgetPass setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    [self.view addSubview:forgetPass];
    [forgetPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(strSize.width + 5));
        make.height.equalTo(@(strSize.height + 10));
        make.left.equalTo(loginBtn.mas_left);
        make.centerY.equalTo(regisBut.mas_centerY);
    }];
    
    //
    UIButton *wxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [wxBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [wxBtn setTitle:@"微信登录" forState:UIControlStateNormal];
    [wxBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [wxBtn setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [wxBtn setTag:2];
    [wxBtn setBackgroundColor:rgba(31, 160, 21, 1)];
    [wxBtn addTarget:self action:@selector(userLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wxBtn];
    [wxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(loginBtn.mas_left);
        make.width.equalTo(loginBtn.mas_width);
        make.height.equalTo(loginBtn.mas_height);
        make.top.equalTo(self.view.mas_bottom).with.multipliedBy(996.0 / 1334);
    }];
}

#pragma mark - 文本绘制
- (void)createFootView{
    CGFloat butWei = 16;
    NSString *str1 = @"我已阅读并同意",*str2 = @"使用条款";
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize size1 = [NSString calculeteSizeBy:str1 Font:font MaxWei:SCREEN_WIDTH];
    CGSize size2 = [NSString calculeteSizeBy:str2 Font:font MaxWei:SCREEN_WIDTH];
    CGFloat xOri = (SCREEN_WIDTH - butWei - 2 - size1.width - size2.width) / 2;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(xOri - 8, self.view.frameBottom - 15 - butWei - 8, butWei + 2 + 16, butWei + 16)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 10)];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [button setImage:CREATE_IMG(@"unCheckAgree@2x") forState:UIControlStateNormal];
    [button setImage:CREATE_IMG(@"checkAgree@2x") forState:UIControlStateSelected];
    [button setSelected:YES];
    [button addTarget:self action:@selector(checkCooperation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *tipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tipBtn setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [tipBtn setFrame:CGRectMake(button.frameRight + 2 - 8, button.frameY + (butWei - size1.height) / 2 + 8, size1.width, size1.height)];
    [tipBtn setTitle:str1 forState:UIControlStateNormal];
    [tipBtn.titleLabel setFont:font];
    [tipBtn setTitleColor:rgba(153, 153, 153, 1) forState:UIControlStateNormal];
    tipBtn.enabled = NO;
    [self.view addSubview:tipBtn];
    
    //协议
    UIButton *agreement = [UIButton buttonWithType:UIButtonTypeCustom];
    [agreement setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [agreement setTitle:str2 forState:UIControlStateNormal];
    [agreement setTitleColor:BASELINE_COLOR forState:UIControlStateNormal];
    [agreement setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [agreement setFrame:CGRectMake(tipBtn.frameRight, tipBtn.frameY, size2.width, size2.height)];
    [agreement.titleLabel setFont:font];
    [agreement addTarget:self action:@selector(checkAgreement:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreement];
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGFloat diff = SCREEN_HEIGHT - _loginBtn.frameBottom - 5 - keyboardRect.size.height;
    if ((diff < 0) && (self.view.frameY != diff)) {
        [UIView animateWithDuration:0.35 animations:^(void) {
            [self.view setFrameY:diff];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.view.frameY != 0) {
        [UIView animateWithDuration:0.35 animations:^(void) {
            [self.view setFrameY:0];
        }];
    }
}

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField != _passField && textField != _phoneField) {
        return;
    }
    
    [self chenageLoginState];
}

- (void)resetAllFieldResponder
{
    if (_phoneField.isFirstResponder) {
        [_phoneField resignFirstResponder];
    }
    else if (_passField.isFirstResponder)
    {
        [_passField resignFirstResponder];
    }
}

#pragma mark - 登陆按钮可选
- (void)chenageLoginState
{
    BOOL enable = _agreementCooperate && [IdentifierValidator isValidPhone:_phoneField.text] && (_passField.text.length >= 6 && _passField.text.length <= 24);
    _loginBtn.enabled = enable;
}

#pragma mark - LayoutSubviews
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_outerCircle.layer setCornerRadius:_outerCircle.frameHeight / 2];
    [_middleCircle.layer setCornerRadius:_middleCircle.frameHeight / 2];
    [_insideCircle.layer setCornerRadius:_insideCircle.frameHeight / 2];
    [_loginBtn setBackgroundImage:[UIColor createImageWithColor:BASELINE_COLOR Size:_loginBtn.frameSize] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIColor createImageWithColor:rgba(187, 167, 251, 1) Size:_loginBtn.frameSize] forState:UIControlStateDisabled];
    [self.view layoutSubviews];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self resetAllFieldResponder];
}

#pragma mark - actions
- (void)userRegister:(id)sender{
    if (self.sessionTask) {
        return;
    }
    [self resetAllFieldResponder];
    RegisterViewController *regis = [RegisterViewController new];
    regis .titleLable.text = @"注册";
    [self.navigationController pushViewController:regis animated:YES];
}

- (void)backToPreControl:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)userLogin:(id)sender
{
    if (self.sessionTask) {
        return;
    }
    
    [self resetAllFieldResponder];
    switch ([sender tag] - 1) {
        case 0:
        {
            [self sendLoginRequest:nil];
        }
            break;
        case 1:
        {
            __weak typeof(self)weakSelf = self;
            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
            
            snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    [weakSelf sendLoginRequest:response];
                }
            });
        }
            break;
        default:
            break;
    }
}

- (void)forgetPassword:(id)sender
{
    if (self.sessionTask) {
        return;
    }
    [self resetAllFieldResponder];
    FindPassWordController *forget = [FindPassWordController new];
    [self.navigationController pushViewController:forget animated:YES];
}

- (void)textFieldRightBtn:(id)sender{
    switch ([sender tag] - 1) {
        case 0:
        {
            [_phoneField setText:nil];
        }
            break;
        case 1:
        {
            _showPass = !_showPass;
            NSString *tempStr = _passField.text;
            //解决切换过程中光标不准的问题
            _passField.text = @"";
            _passField.secureTextEntry = !_passField.secureTextEntry;
            _passField.text = tempStr;
            UIButton *btn = (UIButton *)sender;
            btn.selected = !btn.selected;
        }
            break;
        default:
            break;
    }
}

- (void)checkCooperation:(id)sender{
    if (self.sessionTask) {
        return;
    }
    
    UIButton *agreeBut = (UIButton *)sender;
    [agreeBut setSelected:!agreeBut.selected];
    _agreementCooperate = agreeBut.selected;
    [self chenageLoginState];
}

- (void)checkAgreement:(id)sender
{
    if (self.sessionTask) {
        return;
    }
    
    DJTOrderViewController *employ = [DJTOrderViewController new];
    employ.url = @"http://mall.goonbaby.com/moblie/agreement.html";
    [self.navigationController pushViewController:employ animated:YES];
//    WebViewController *web = [WebViewController new];
//    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark - 登录完成
- (void)sendLoginRequest:(UMSocialResponseEntity *)response
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSString *ckey = (response == nil) ? @"login" : @"otherLogin";
    NSMutableDictionary *param = [manager requestinitParamsWith:ckey];
    if (response) {
        [param setObject:[response.thirdPlatformUserProfile valueForKey:@"openid"] forKey:@"openid"];
        [param setObject:[response.thirdPlatformUserProfile valueForKey:@"sex"] forKey:@"sex"];
        [param setObject:[response.thirdPlatformUserProfile valueForKey:@"nickname"] forKey:@"nickname"];
        [param setObject:[response.thirdPlatformUserProfile valueForKey:@"headimgurl"] forKey:@"headpic"];
        [param setObject:@"" forKey:@"birthday"];
    }else {
        [param setObject:_phoneField.text forKey:@"loginname"];
        NSString *md5 = [NSString md5:_passField.text];
        [param setObject:md5 forKey:@"password"];
    }
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"user"];
    __weak typeof(self)weakSelf = self;
    BOOL isThird = (response == nil) ? NO : YES;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf loginFinish:error Data:data Third:isThird];
        });
    }];
}

- (void)loginFinish:(NSError *)error Data:(id)data Third:(BOOL)third
{
    [self.view hideToastActivity];
    self.sessionTask = nil;
    if (error) {
        self.view.userInteractionEnabled = YES;
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        //保存帐号
        NSUserDefaults *standDefault = [NSUserDefaults standardUserDefaults];
        if (third) {
            [standDefault removeObjectForKey:User_Password];
        }
        else{
            [standDefault setObject:_phoneField.text forKey:User_Phone];
            [standDefault setObject:[NSString md5:_passField.text] forKey:User_Password];
        }
        [standDefault synchronize];
        
        //数据
        id ret_data = [data valueForKey:@"ret_data"];
        UserDetailInfo *detail = [[UserDetailInfo alloc] initWithDictionary:ret_data error:nil];
        [[GlobalManager shareInstance] setDetailInfo:detail];
        [[GlobalManager shareInstance] addAssetsLibraryChangedNotification];
        [APPDELEGETE registerXGPushInfo];
        //我的作品
        if (detail.isDealer.integerValue != 1) {
            [[GlobalManager shareInstance] requestMyProfiles];
        }
        
        //数据库
        NSString *dbPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",detail.user.id]];
        DataBaseOperation *operation = [DataBaseOperation shareInstance];
        [operation openDataBase:dbPath];
        [operation createTableByType:kTableAlbumManager];
        NSString *maxShootTime = [operation selectMaxShootingTime];
        if (maxShootTime) {
            //偷偷加载新拍的
            [[GlobalManager shareInstance] loadNewImgAssets:[NSDate dateWithTimeIntervalSince1970:maxShootTime.doubleValue]];
            [self dealWithFinish];
        }
        else{
            self.view.userInteractionEnabled = YES;
            _progressView = [[ProgressCircleView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) / 2, (SCREEN_HEIGHT - 64 - 120) / 2, 120, 120)];
            [_progressView.progressLab setText:@"相册加载中..."];
            [self.view addSubview:_progressView];
            
            //第一次同步
            __weak typeof(self)weakSelf = self;
            __block NSMutableArray *tmpArr = [NSMutableArray array];
            ALAssetsGroupEnumerationResultsBlock assetsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if (asset)
                {
                    NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
                    if (![assetType isEqualToString:ALAssetTypeUnknown]) {
                        AssetModel *model = [[AssetModel alloc] initWithAsset:asset];
                        [tmpArr addObject:model];
                        [weakSelf.progressView.loadingIndicator setProgress:(CGFloat)tmpArr.count / weakSelf.group.numberOfAssets];
                        [_progressView.progressLab setText:[NSString stringWithFormat:@"%ld/%ld",(long)tmpArr.count,(long)weakSelf.group.numberOfAssets]];
                    }
                }
                else
                {
                    *stop = YES;
                    [[DataBaseOperation shareInstance] updateAllAssets:tmpArr];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf dealWithFinish];
                    });
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group)
                {
                    [group setAssetsFilter:[ALAssetsFilter allAssets]];
                    if (group.numberOfAssets > 0){
                        weakSelf.group = group;
                        [group enumerateAssetsUsingBlock:assetsBlock];
                    }
                    else{
                        *stop = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf dealWithFinish];
                        });
                    }
                }
                else{
                    *stop = YES;
                    if (!weakSelf.group) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf dealWithFinish];
                        });
                    }
                }
            };
            
            
            ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view.window makeToast:@"相册访问异常" duration:1.0 position:@"center"];
                    [weakSelf dealWithFinish];
                });
                
            };
            
            // Enumerate Camera roll first
            [[GlobalManager defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:resultsBlock failureBlock:failureBlock];
        }
    }
}

- (void)dealWithFinish
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
    [[GlobalManager shareInstance] syncAlbumManagerInfo];
}

#pragma mark - 找出底部横线
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
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
    BOOL isPhoneText = (textField == _phoneField);
    BOOL reback = (range.location > 0 && range.length == 1 && string.length == 0);
    if (reback) {
        return YES;
    }
    else if (isPhoneText && textField.text.length >= 11) {
        [self.view.window makeToast:@"手机号不能超过11位" duration:1.0 position:@"center"];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        return NO;
    }
    else if (!isPhoneText && textField.text.length >= 24) {
        [self.view.window makeToast:@"密码不能超过24位" duration:1.0 position:@"center"];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        return NO;
    }

    return YES;
}

@end
