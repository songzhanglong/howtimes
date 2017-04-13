//
//  FeedbackViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "FeedbackViewController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "AppDelegate.h"

@implementation FeedbackViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"反馈建议";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self createRightBarButton];
    
    [self.view setBackgroundColor:CreateColor(239, 239, 243)];
    
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(8, 10, SCREEN_WIDTH - 8 * 2, 295)];
    [tipView setBackgroundColor:[UIColor whiteColor]];
    [tipView setUserInteractionEnabled:YES];
    [tipView.layer setMasksToBounds:YES];
    [tipView.layer setCornerRadius:1];
    [self.view addSubview:tipView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, tipView.frameWidth - 15 * 2, 50)];
    [tipLabel setBackgroundColor:tipView.backgroundColor];
    [tipLabel setText:@"您好，十分感谢您的反馈使用产品的感受和建议。(意见采用将有优惠券奖励)"];
    [tipLabel setTextColor:CreateColor(100, 100, 100)];
    [tipLabel setFont:[UIFont systemFontOfSize:14]];
    tipLabel.numberOfLines = 2;
    [tipView addSubview:tipLabel];
    
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(15, tipLabel.frameBottom + 10, tipView.frameWidth - 30, 105)];
    [textView setBackgroundColor:tipView.backgroundColor];
    [textView.layer setMasksToBounds:YES];
    [textView.layer setCornerRadius:3];
    [textView.layer setBorderColor:CreateColor(237, 237, 237).CGColor];
    [textView.layer setBorderWidth:1];
    [tipView addSubview:textView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, textView.frameWidth - 10, textView.frameHeight - 10)];
    //_textView.text = (_fromType == 0) ? PLACE_TIP_MSG : PLACE_BABY_MSG;
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:12];
    _textView.returnKeyType = UIReturnKeyDone;
    [textView addSubview:_textView];
    
    _placeholderLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 150, 20)];
    [_placeholderLab setBackgroundColor:[UIColor clearColor]];
    [_placeholderLab setFont:[UIFont systemFontOfSize:12]];
    [_placeholderLab setTextColor:[UIColor lightGrayColor]];
    [_placeholderLab setText:@"请填写您宝贵的意见"];
    [_textView addSubview:_placeholderLab];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setFrame:CGRectMake((tipView.frameWidth - 110) / 2, textView.frameBottom + 20, 110, 40)];
    [submitBtn setTitle:@"提 交" forState:UIControlStateNormal];
    [submitBtn.layer setMasksToBounds:YES];
    [submitBtn.layer setCornerRadius:3];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [submitBtn setBackgroundColor:CreateColor(153, 125, 251)];
    [submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:submitBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginChange:) name:UITextViewTextDidChangeNotification object:nil];
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

- (void)submitAction:(id)sender
{
    if ([_textView.text length] == 0) {
        [self.view makeToast:@"反馈的内容不能为空哦" duration:1.0 position:@"center"];
        return;
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"feedback"];
    [param setObject:[_textView text] forKey:@"content"];
    //[param setObject:@"" forKey:@"contact"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"system"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf feedbackFinish:error Data:data];
        });
    }];
}

#pragma mark - change password
- (void)feedbackFinish:(NSError *)error Data:(id)data{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self.navigationController.view makeToast:@"意见已收到，感谢您的评论" duration:1.0 position:@"center"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_placeholderLab) {
        [_placeholderLab setHidden:YES];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if ([[textView text] length] == 0 && _placeholderLab) {
            [_placeholderLab setHidden:NO];
        }
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginChange:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if (textView != _textView) {
        return;
    }
    
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
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
        if ([lastStr length] > 140) {
            lastStr = [lastStr substringToIndex:140];
        }
        [_textView setText:lastStr];
    }
    
}

@end
