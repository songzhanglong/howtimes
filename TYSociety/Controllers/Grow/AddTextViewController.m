//
//  AddTextViewController.m
//  TYSociety
//
//  Created by szl on 16/7/27.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AddTextViewController.h"
#import "VerticalButton.h"
#import "UIColor+Hex.h"
#import "Masonry.h"
#import "CustomFont.h"

@interface AddTextViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)UIView *styleView;
@property (nonatomic,strong)UILabel *topLab;
@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,strong)UILabel *percentLab;
@property (nonatomic,strong)UIImageView *upBackImg;
@property (nonatomic,strong)UIView *colorView;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *fontSource;
@property (nonatomic,strong)NSMutableArray *downArr;

@end

@implementation AddTextViewController
{
    NSInteger _nCheckIdx;
    NSArray *_colorArr;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *img = CREATE_IMG(@"color_set_bg");
    [self.view addSubview:self.upBackImg];
    [_upBackImg setImage:img];
    [_upBackImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(_upBackImg.mas_width).with.multipliedBy(img.size.height / img.size.width);
    }];
    
    _colorArr = @[@"#ffffff",@"#cccccc",@"#808080",@"#404040",@"#362f2d",@"#000000",@"#be8145",@"#800000",@"#cc0000",@"#ff0000",@"#ff5500",@"#ff8000",@"#ffbf00",@"#a8e000",@"#6cbf00",@"#008c00",@"#80d4ff",@"#0095ff",@"#0066cc",@"#001a66",@"#3c0066",@"#75008c",@"#ff338f",@"#ffbfd4"];
    self.downArr = [NSMutableArray array];
    NSString *plistPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",NSStringFromClass([AddTextViewController class])]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:plistPath]) {
        NSArray *arr = [[NSArray alloc] initWithContentsOfFile:plistPath];
        self.fontSource = [CustomFont arrayOfModelsFromDictionaries:arr error:nil];
        __weak typeof(self)weakSelf = self;
        for (CustomFont *font in _fontSource) {
            font.downLoadBlock = ^(CustomFont *netFont,NSError *error, NSURL *filePath){
                [weakSelf downLoadFinish:netFont Error:error Url:filePath];
            };
        }
    }
    else{
        [self getFont];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    //监视键盘高度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (_textStr.length > 0) {
        
    }
    else{
        _color = @"#000000";
        _alpha = 1;
    }
    
    [self.view addSubview:self.topLab];
    [self.view addSubview:self.bottomView];
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 文本换行
- (void)resetTopLabelHei
{
    if (_textStr.length > 0) {
        CGSize size = [NSString calculeteSizeBy:_textStr Font:_topLab.font MaxWei:_maxWei];
        if (size.height > _topLab.frameHeight) {
            [_topLab setFrameHeight:size.height];
        }
    }
}

#pragma mark - 下载完毕
- (void)downLoadFinish:(CustomFont *)font Error:(NSError *)error Url:(NSURL *)fileUrl
{
    @synchronized (_downArr) {
        [_downArr removeObject:font];
        if ([_downArr count] > 0) {
            CustomFont *firstFont = [_downArr firstObject];
            [firstFont startDownLoadTTFFile];
        }
    }
    NSInteger index = [_fontSource indexOfObject:font];
    if (index == NSNotFound) {
        return;
    }
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - 字体资源
- (void)getFont
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"system"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getFont"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getFontFinish:error Data:data];
        });
    }];
}

- (void)getFontFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        self.fontSource = [CustomFont arrayOfModelsFromDictionaries:ret_data error:nil];
        __weak typeof(self)weakSelf = self;
        for (CustomFont *font in _fontSource) {
            font.downLoadBlock = ^(CustomFont *netFont,NSError *error, NSURL *filePath){
                [weakSelf downLoadFinish:netFont Error:error Url:filePath];
            };
        }
        if (_tableView) {
            [_tableView reloadData];
        }
        
        //文件存储
        NSString *plistPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",NSStringFromClass([AddTextViewController class])]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [ret_data writeToFile:plistPath atomically:NO];
        });
    }
}

#pragma mark - 分行
- (NSArray *)getSeparatedLinesFromLabel:(UILabel *)label
{
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    return (NSArray *)linesArray;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self checkIndexBy:[_bottomView viewWithTag:1]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGFloat yOri = SCREEN_HEIGHT - _bottomView.frameHeight - 140;
    if (_bottomView.frameY != yOri) {
        [_bottomView setFrameY:yOri];
    }
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    [self.bottomView setFrameY:SCREEN_HEIGHT - _bottomView.frameHeight - keyboardRect.size.height];
}

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField != _textField) {
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
        NSInteger lenght = emoji % Emoji_Count;
        NSInteger location = emoji / Emoji_Count;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        [_textField setText:lastStr];
    }
    _textStr = lastStr;
    [_topLab setText:lastStr];
    [self resetTopLabelHei];
}

#pragma mark - actions
- (void)finishEdit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(addTextFinish:Arr:)]) {
        //字体库没下载，就传默认的回去
        if (_font_key.length > 0) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *path = [APPDocumentsDirectory stringByAppendingPathComponent:[_font_key stringByAppendingString:@".ttf"]];
            if (![fileManager fileExistsAtPath:path]) {
                _font_key = nil;
            }
        }
        NSArray *arr = [self getSeparatedLinesFromLabel:_topLab];
        [_delegate addTextFinish:self Arr:arr];
    }
}

- (void)checkIndexBy:(id)sender
{
    NSInteger index = [sender tag] - 1;
    if (_nCheckIdx == index) {
        return;
    }
    
    UIButton *preBtn = (UIButton *)[_bottomView viewWithTag:_nCheckIdx + 1];
    preBtn.selected = NO;
    
    _nCheckIdx = index;
    
    [sender setSelected:YES];
    switch (index) {
        case 0:
        {
            [_textField becomeFirstResponder];
            if (_styleView) {
                _styleView.hidden = YES;
            }
            
            if (_tableView) {
                _tableView.hidden = YES;
            }
        }
            break;
        case 1:
        {
            if (_textField.isFirstResponder) {
                [_textField resignFirstResponder];
            }
            
            self.styleView.hidden = NO;
            if (![_styleView isDescendantOfView:self.view]) {
                [self.view addSubview:_styleView];
            }
            
            if (_tableView) {
                _tableView.hidden = YES;
            }
        }
            break;
        case 2:
        {
            if (_textField.isFirstResponder) {
                [_textField resignFirstResponder];
            }
            
            self.tableView.hidden = NO;
            if (![_tableView isDescendantOfView:self.view]) {
                [self.view addSubview:_tableView];
            }
            
            if (_styleView) {
                _styleView.hidden = YES;
            }
        }
            break;
        default:
            break;
    }
}

- (void)tapLabView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!_textField.isFirstResponder) {
        [_textField becomeFirstResponder];
    }
}

- (void)sliderChangeValue:(UISlider *)slider
{
    [_percentLab setText:[NSString stringWithFormat:@"%.0f%%",slider.value * 100]];
    _alpha = slider.value;
    [_topLab setAlpha:_alpha];
}

- (void)colorSliderChangeValue:(UISlider *)slider
{
    NSInteger index = slider.value * 23;
    _color = _colorArr[index];
    [_topLab setTextColor:[UIColor colorWithHexString:_color]];
    [_colorView setBackgroundColor:_topLab.textColor];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fontSource count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *fontCellId = @"fontCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fontCellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fontCellId];
        cell.textLabel.highlightedTextColor = BASELINE_COLOR;
        cell.textLabel.textColor = rgba(153, 153, 153, 1);
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        [cell.imageView setImage:[UIImage imageNamed:@"fontCheck.png"]];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView setCenter:CGPointMake(SCREEN_WIDTH - 50, 22)];
        [activityIndicatorView setTag:2];
        [cell.contentView addSubview:activityIndicatorView];
        
        
        UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [downBtn setFrame:CGRectMake(activityIndicatorView.center.x - 15, activityIndicatorView.center.y - 15, 30, 30)];
        [downBtn setImage:CREATE_IMG(@"downLoadIcon") forState:UIControlStateNormal];
        [downBtn setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        [downBtn setTag:3];
        downBtn.userInteractionEnabled = NO;
        [cell.contentView addSubview:downBtn];
    }
    
    UIButton *downBtn = (UIButton *)[cell.contentView viewWithTag:3];
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:2];
    
    NSInteger findIdx = NSNotFound;
    if (_font_key.length > 0) {
        for (NSInteger i = 0; i < [_fontSource count]; i++) {
            CustomFont *font = _fontSource[i];
            if ([font.font_key isEqualToString:_font_key]) {
                findIdx = i + 1;
                break;
            }
        }
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"默认字体";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.imageView.hidden = (findIdx != NSNotFound);
        downBtn.hidden = YES;
        activityIndicatorView.hidden = YES;
    }
    else{
        CustomFont *font = _fontSource[indexPath.row - 1];
        cell.textLabel.text = font.font_name;
        cell.textLabel.font = [NSString customFontWithPath:[APPDocumentsDirectory stringByAppendingPathComponent:[font.font_key stringByAppendingString:@".ttf"]] size:15];
        cell.imageView.hidden = !(findIdx == indexPath.row);
        
        if ([font fileHasDownLoaded]) {
            downBtn.hidden = YES;
            activityIndicatorView.hidden = YES;
        }
        else
        {
            @synchronized (_downArr) {
                downBtn.hidden = [_downArr containsObject:font];
                activityIndicatorView.hidden = !downBtn.hidden;
            }
        }
    }
    
    //动画
    if (activityIndicatorView.hidden) {
        if (activityIndicatorView.isAnimating) {
            [activityIndicatorView stopAnimating];
        }
    }
    else{
        if (!activityIndicatorView.isAnimating) {
            [activityIndicatorView startAnimating];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (!cell.imageView.hidden) {
//        return;
//    }
    
    NSIndexPath *lastPath = nil;
    if (_font_key.length == 0) {
        lastPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else{
        for (NSInteger i = 0; i < [_fontSource count]; i++) {
            CustomFont *font = _fontSource[i];
            if ([font.font_key isEqualToString:_font_key]) {
                lastPath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
                break;
            }
        }
    }
    if (indexPath.row == 0) {
        _font_key = nil;
    }
    else{
        CustomFont *font = _fontSource[indexPath.row - 1];
        @synchronized (_downArr) {
            if ([_downArr containsObject:font]) {
                return;
            }
            else if (![font fileHasDownLoaded])
            {
                [_downArr addObject:font];
                if ([_downArr count] == 1) {
                    //保证同一时刻只下载一个
                    [font startDownLoadTTFFile];
                }
                
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                return;
            }
        }
        _font_key = font.font_key;
    }
    NSMutableArray *paths = [NSMutableArray array];
    [paths addObject:indexPath];
    if (lastPath) {
        [paths addObject:lastPath];
    }
    [tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    if (_font_key.length > 0) {
        [_topLab setFont:[NSString customFontWithPath:[APPDocumentsDirectory stringByAppendingPathComponent:[_font_key stringByAppendingString:@".ttf"]] size:12]];
    }
    else{
        [_topLab setFont:[UIFont systemFontOfSize:12]];
    }
    [self resetTopLabelHei];
}

#pragma mark - lazy load
- (UIView *)bottomView
{
    if (!_bottomView) {
        CGFloat bottomHei = 10 + 44 + 20 + 40 + 10;
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - bottomHei, SCREEN_WIDTH, bottomHei)];
        [_bottomView setBackgroundColor:rgba(239, 239, 244, 1)];
        
        [_bottomView addSubview:self.textField];
        //finish
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(_textField.frameRight + _textField.frameX, _textField.frameY, 40, _textField.frameHeight)];
        [button setTitleColor:rgba(153, 153, 153, 1) forState:UIControlStateNormal];
        [button setTitleColor:BASELINE_COLOR forState:UIControlStateHighlighted];
        [button setBackgroundColor:_bottomView.backgroundColor];
        [button.titleLabel setFont:_textField.font];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:button];
        
        //
        CGFloat yOri = _textField.frameBottom + 20;
        NSArray *imgN = @[@"addKeyboardN",@"addTextStyleN",@"makeFontN"],*imgH = @[@"addKeyboardH",@"addTextStyleH",@"makeFontH"],*titles = @[@"键盘",@"样式",@"字体"];
        CGFloat itemWei = 32,itemHei = 40, margin = (SCREEN_WIDTH - itemWei * imgN.count) / (imgN.count * 2);
        for (NSInteger i = 0; i < 3; i++) {
            VerticalButton *vertical = [VerticalButton buttonWithType:UIButtonTypeCustom];
            vertical.imgSize = (i == 2) ? CGSizeMake(17, 17) : CGSizeMake(21, 17);
            vertical.textSize = CGSizeMake(32, 17);
            vertical.margin = 6;
            [vertical setFrame:CGRectMake(margin + (itemWei + margin * 2) * i, yOri, itemWei, itemHei)];
            [vertical setBackgroundColor:_bottomView.backgroundColor];
            NSString *imgName = imgN[i];
            NSString *imgNameH = imgH[i];
            [vertical setImage:CREATE_IMG(imgName) forState:UIControlStateNormal];
            [vertical setImage:CREATE_IMG(imgNameH) forState:UIControlStateSelected];
            [vertical setTitle:titles[i] forState:UIControlStateNormal];
            [vertical setTitleColor:button.titleLabel.textColor forState:UIControlStateNormal];
            [vertical setTitleColor:BASELINE_COLOR forState:UIControlStateSelected];
            [vertical setTag:i + 1];
            vertical.selected = (i == _nCheckIdx);
            [vertical.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [vertical.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [vertical addTarget:self action:@selector(checkIndexBy:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:vertical];
        }
    }
    return _bottomView;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH - 15 * 3 - 40, 44)];
        _textField.delegate = self;
        [_textField setBackgroundColor:[UIColor whiteColor]];
        [_textField.layer setMasksToBounds:YES];
        _textField.layer.cornerRadius = 5;
        _textField.placeholder = @"点击输入文字";
        _textField.text = _textStr;
        [_textField setFont:[UIFont systemFontOfSize:14]];
        [_textField setTextColor:[UIColor blackColor]];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_textField setValue:UnEditTextColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    return _textField;
}

- (UIView *)styleView
{
    if (!_styleView) {
        CGFloat hei = 44 + 30 + 20 + 30 + 20;
        _styleView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - hei, SCREEN_WIDTH, hei)];
        [_styleView setBackgroundColor:[UIColor whiteColor]];
        
        //imag
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(15, 44, 30, 30)];
        _colorView.layer.masksToBounds = YES;
        _colorView.layer.cornerRadius = 4;
        _colorView.layer.borderColor = rgba(153, 153, 153, 1).CGColor;
        _colorView.layer.borderWidth = 2;
        [_colorView setBackgroundColor:[UIColor colorWithHexString:_color]];
        [_styleView addSubview:_colorView];
       
        CGFloat wei = SCREEN_WIDTH - _colorView.frameRight - 30,imgHei = wei * 20 / 924;
        UIImageView *colorImg = [[UIImageView alloc] initWithFrame:CGRectMake(_colorView.frameRight + 15, _colorView.frameY + (_colorView.frameHeight - imgHei) / 2, wei, imgHei)];
        [colorImg setImage:CREATE_IMG(@"addColorRight")];
        [_styleView addSubview:colorImg];
        
        //透明slider
        UISlider *clearSlider = [[UISlider alloc] initWithFrame:CGRectMake(colorImg.frameX, _colorView.frameY, colorImg.frameWidth, _colorView.frameHeight)];
        NSInteger index = [_colorArr indexOfObject:_color];
        if (index != NSNotFound) {
            [clearSlider setValue:index / 23.0];
        }
        else{
            [clearSlider setValue:0];
        }
        [clearSlider setMaximumValue:1];
        [clearSlider setMinimumValue:0];
        [clearSlider setThumbImage:[UIImage imageNamed:@"addSlider.png"] forState:UIControlStateNormal];
        [clearSlider setMinimumTrackTintColor:[UIColor clearColor]];
        [clearSlider setMaximumTrackTintColor:[UIColor clearColor]];
        [clearSlider addTarget:self action:@selector(colorSliderChangeValue:) forControlEvents:UIControlEventValueChanged];
        [_styleView addSubview:clearSlider];
        
        _percentLab = [[UILabel alloc] initWithFrame:CGRectMake(_colorView.frameX, _colorView.frameBottom + 20, _colorView.frameWidth, _colorView.frameHeight)];
        [_percentLab.layer setMasksToBounds:YES];
        [_percentLab setText:[NSString stringWithFormat:@"%.0f%%",_alpha * 100]];
        [_percentLab setTextAlignment:NSTextAlignmentCenter];
        [_percentLab setFont:[UIFont systemFontOfSize:9]];
        [_percentLab setTextColor:[UIColor whiteColor]];
        _percentLab.layer.cornerRadius = 15;
        [_percentLab setBackgroundColor:rgba(160, 160, 160, 1)];
        [_styleView addSubview:_percentLab];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(colorImg.frameX, _percentLab.frameY, colorImg.frameWidth, _percentLab.frameHeight)];
        [slider setValue:_alpha];
        [slider setMaximumValue:1];
        [slider setMinimumValue:0];
        [slider setThumbImage:[UIImage imageNamed:@"addSlider.png"] forState:UIControlStateNormal];
        [slider setMinimumTrackTintColor:BASELINE_COLOR];
        [slider setMaximumTrackTintColor:_percentLab.backgroundColor];
        [slider addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
        [_styleView addSubview:slider];
    }
    return _styleView;
}

- (UILabel *)topLab
{
    if (!_topLab) {
        CGFloat hei = 50;
        _topLab = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - _maxWei) / 2, 80, _maxWei, hei)];
        [_topLab setBackgroundColor:[UIColor clearColor]];
        if (_font_key.length > 0) {
            [_topLab setFont:[NSString customFontWithPath:[APPDocumentsDirectory stringByAppendingPathComponent:[_font_key stringByAppendingString:@".ttf"]] size:12]];
        }
        else{
            [_topLab setFont:[UIFont systemFontOfSize:12]];
        }
        
        [_topLab setTextAlignment:NSTextAlignmentCenter];
        [_topLab setTextColor:[UIColor colorWithHexString:_color]];
        [_topLab setText:_textStr ?: @"点击输入文字"];
        [_topLab setNumberOfLines:0];
        [_topLab setAlpha:_alpha];
        [_topLab setUserInteractionEnabled:YES];
        [_topLab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabView:)]];
        [self resetTopLabelHei];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:_topLab.bounds];
        [img setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [img setImage:CREATE_IMG(@"textBack")];
        [img setBackgroundColor:[UIColor clearColor]];
        [_topLab addSubview:img];
        [_topLab sendSubviewToBack:img];
    }
    return _topLab;
}

- (UIImageView *)upBackImg
{
    if (!_upBackImg) {
        _upBackImg = [[UIImageView alloc] init];
        [_upBackImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _upBackImg;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat hei = 44 + 30 + 20 + 30 + 20;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - hei, SCREEN_WIDTH, hei) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:footView];
    }
    return _tableView;
}

@end
