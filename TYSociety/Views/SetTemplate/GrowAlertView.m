//
//  GrowAlertView.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowAlertView.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"

@implementation GrowAlertView
{
    UIView *mview;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        
        defaultTheme = @"";
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.3;
        bgView.userInteractionEnabled = YES;
        [self addSubview:bgView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapGestureRecognizer:)];
        [bgView addGestureRecognizer:tapGesture];
        
        mview = [[UIView alloc] initWithFrame:CGRectMake(20, (SCREEN_HEIGHT - 143 - 64 - 50) / 2, SCREEN_WIDTH - 40, 143)];
        [mview setBackgroundColor:[UIColor whiteColor]];
        mview.layer.masksToBounds = YES;
        mview.layer.cornerRadius = 5.0;
        mview.userInteractionEnabled = YES;
        [self addSubview:mview];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, mview.frame.size.width - 30, 20)];
        _titleLabel = titleLabel;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"修改名称：";
        [titleLabel setTextColor:CreateColor(100, 100, 100)];
        titleLabel.font = [UIFont systemFontOfSize:16];
        [mview addSubview:titleLabel];
        
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(15, 40, mview.frame.size.width - 30, 40)];
        tempView.backgroundColor = CreateColor(223, 227, 232);
        tempView.layer.masksToBounds = YES;
        tempView.layer.cornerRadius = 3.0;
        [mview addSubview:tempView];
        
        _textFiled = [[UITextField alloc] initWithFrame:CGRectMake(25, 45, mview.frame.size.width - 50, 30)];
        _textFiled.autocorrectionType = UITextAutocorrectionTypeNo;
        _textFiled.contentVerticalAlignment = 0 ;
        _textFiled.returnKeyType = UIReturnKeyDone;
        _textFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textFiled.font = [UIFont systemFontOfSize:16];
        [_textFiled setClearButtonMode:UITextFieldViewModeWhileEditing];
        _textFiled.delegate = self;
        [mview addSubview:_textFiled];

        
        UIButton *canelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, mview.frameHeight - 50, (mview.frameWidth - 45) / 2, 30)];
        canelBtn.layer.masksToBounds = YES;
        canelBtn.layer.cornerRadius = 3.0;
        canelBtn.backgroundColor = CreateColor(177, 182, 189);
        [canelBtn setTitle:@"取 消" forState:UIControlStateNormal];
        [canelBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [canelBtn setTag:1];
        [canelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [canelBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [mview addSubview:canelBtn];
        
        UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(canelBtn.frameRight + 15, canelBtn.frameY, canelBtn.frameWidth, canelBtn.frameHeight)];
        doneBtn.layer.masksToBounds = YES;
        doneBtn.layer.cornerRadius = 3.0;
        doneBtn.backgroundColor = CreateColor(155, 124, 252);
        [doneBtn setTitle:@"确 定" forState:UIControlStateNormal];
        [doneBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [doneBtn setTag:2];
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [mview addSubview:doneBtn];
        
    }
    return self;
}

- (void)setDefaultTheme:(NSString *)theme
{
    defaultTheme = theme;
    [_textFiled setText:theme];
}

- (void)buttonPressed:(UIButton *)sender
{
    if (sender.tag == 2) {
//        if ([[_textFiled text] length] == 0 || [[_textFiled text] isEqualToString:defaultTheme]) {
//            [self makeToast:@"您还没有编辑主题" duration:1.0 position:@"center"];
//            return;
//        }
        if (_delegate && [_delegate respondsToSelector:@selector(submitThemeToGrowAlertView:Theme:)]) {
            [_delegate submitThemeToGrowAlertView:self Theme:[_textFiled text]];
        }
    }
    [self tapGestureRecognizer:nil];
}

-(void)tapGestureRecognizer:(id)sender
{
    [_textFiled resignFirstResponder];
    
    if (_delegate && [_delegate respondsToSelector:@selector(closeGrowAlertView)]) {
        [_delegate closeGrowAlertView];
    }
}

#pragma mark - UITextFieldTextDidChangeNotification
- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField != _textFiled) {
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
            [self emojiStrSplit:textField.text];
            
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
        [_textFiled setText:lastStr];
    }
    
    if (lastStr.length > 7) {
        //[mview makeToast:@"最多输入7个字" duration:1.0 position:@"center"];
        //_textFiled.text = [lastStr substringToIndex:7];
    }
}
#pragma maerk UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
