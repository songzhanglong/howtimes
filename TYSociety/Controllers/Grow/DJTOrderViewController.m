//
//  DJTOrderViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/6/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTOrderViewController.h"
#import "Toast+UIView.h"
#import <WebKit/WebKit.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface DJTOrderViewController ()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong)id realWebView;
@property (nonatomic,assign)BOOL usingUIWebView;

@end

@implementation DJTOrderViewController
{
    BOOL _hasLoaded;
}

- (void)dealloc
{
    if (_usingUIWebView) {
        UIWebView* webView = _realWebView;
        webView.delegate = nil;
    }
    else
    {
        WKWebView* webView = _realWebView;
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
    }
    [_realWebView scrollView].delegate = nil;
    [_realWebView stopLoading];
    [(UIWebView *)_realWebView loadHTMLString:@"" baseURL:nil];
    [_realWebView stopLoading];
    [_realWebView removeFromSuperview];
    _realWebView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.titleLable.textColor = [UIColor whiteColor];
    [self createLeftBut];
    [self createRightButton];
    
    self.usingUIWebView = (NSClassFromString(@"WKWebView") != nil);
    self.usingUIWebView = YES;
    if (_usingUIWebView) {
        [self initUIWebView];
    }
    else{
        [self initWKWebView];
    }
    [self.view addSubview:self.realWebView];
}

#pragma mark - WKWebView&UIWebView
- (void)initWKWebView
{
    WKWebViewConfiguration* configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    configuration.preferences = [NSClassFromString(@"WKPreferences") new];
    configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
    
    WKWebView* webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds configuration:configuration];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    webView.navigationDelegate = self;
    webView.backgroundColor = [UIColor whiteColor];
    webView.opaque = NO;
    
    _realWebView = webView;
}

-(void)initUIWebView
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    webView.backgroundColor = [UIColor whiteColor];
    webView.opaque = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    [webView setScalesPageToFit:YES];
    [webView setDelegate:self];
    
    _realWebView = webView;
}

#pragma mark - Appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setBarTintColor:BASELINE_COLOR];
    
    if (!_hasLoaded) {
        _hasLoaded = YES;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
        if ([_param length] > 0) {
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[_param dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [(UIWebView *)_realWebView loadRequest:request];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([_realWebView isLoading]) {
        [_realWebView stopLoading];
    }
}

#pragma mark - navigation buttons
- (void)createLeftBut
{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:CREATE_IMG(@"navBack@2x") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToFather:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(6.5, 0, 6.5, 30)];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, backBarButtonItem];
}

- (void)createLeftButs
{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:CREATE_IMG(@"navBack@2x") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToFather:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(6.5, 0, 6.5, 30)];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(40, 0, 30.0, 30.0);
    [saveBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"closedWeb" ofType:@"png"]] forState:UIControlStateNormal];
    [saveBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"closedWeb_1" ofType:@"png"]] forState:UIControlStateHighlighted];
    [saveBtn addTarget:self action:@selector(backToFather2:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [backView setBackgroundColor:[UIColor clearColor]];
    [backView addSubview:backBtn];
    [backView addSubview:saveBtn];
    UIBarButtonItem *barButItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,barButItem];
}

- (void)createRightButton
{
    UIView *leftView = [(UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject] customView];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftView.bounds.size.width, 20)];
    [view setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:view];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBtn];
}

#pragma mark - actions
- (void)reloadCurentPage
{
    if (![_realWebView isLoading]) {
        [(UIWebView *)_realWebView reload];
    }
}

- (void)backToFather:(UIButton *)sender{
    if ([_realWebView canGoBack]) {
        [(UIWebView *)_realWebView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backToFather2:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - QQ
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - URL检测
- (BOOL)checkRequestURL:(NSURL *)url
{
    NSString *str = url.absoluteString;
    if (str == nil) {
        return YES;
    }
    if ([str rangeOfString:@"OnlineService?qq="].location != NSNotFound) {
        NSRange range = [str rangeOfString:@"OnlineService?qq="];
        NSInteger location = range.location + range.length;
        NSString *qqStr = [str substringFromIndex:location];
        QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:qqStr];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
        return NO;
    }
    else if ([str hasPrefix:@"tyapp://growlist"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    else if ([str rangeOfString:@"times/client_pay"].location != NSNotFound) {
        NSRange range = [str rangeOfString:@"OnlineService?qq="];
        NSInteger location = range.location + range.length;
        NSString *qqStr = [str substringFromIndex:location];
        QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:qqStr];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
        return NO;
    }
    
    return YES;
}

- (void)loadWebviewFinished:(NSString *)title
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    self.titleLable.text = title;
    
    UIBarButtonItem *barBut = [self.navigationItem.leftBarButtonItems lastObject];
    UIView *customView = barBut.customView;
    if ([customView isKindOfClass:[UIButton class]]) {
        if ([_realWebView canGoBack]) {
            [self createLeftButs];
        }
    }
    else
    {
        if (![_realWebView canGoBack]) {
            [self createLeftBut];
        }
    }
    [self createRightButton];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSEnumerator *enumerator = [cookies objectEnumerator];
    NSHTTPCookie *cookie;
    while (cookie = [enumerator nextObject]) {
        NSLog(@"COOKIE_NAME=%@",[cookie name]);
        NSLog(@"COOKIE_VALUE=%@",[cookie value]);
    }
    return [self checkRequestURL:request.URL];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
    self.titleLable.text = @"加载中...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // new for memory cleaning
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    // new for memory cleanup
    [[NSURLCache sharedURLCache] setMemoryCapacity: 0];
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    NSString *theTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self loadWebviewFinished:theTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    self.titleLable.text = @"加载失败";
}

#pragma mark- WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL resultBOOL = [self checkRequestURL:webView.URL];
    if(resultBOOL)
    {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
    self.titleLable.text = @"加载中...";
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    __weak typeof(self)weakSelf = self;
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf loadWebviewFinished:result];
        });
    }];
}

- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    self.titleLable.text = @"加载失败";
}

- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error
{
    self.titleLable.text = @"加载失败";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
