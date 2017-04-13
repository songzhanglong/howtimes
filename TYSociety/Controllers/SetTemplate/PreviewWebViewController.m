//
//  PreviewWebViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/8/5.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "PreviewWebViewController.h"
#import "Toast+UIView.h"
#import "LoginViewController.h"
#import "BatchMakeViewController.h"
#import "SetTemplateViewController.h"
#import "TimeRecordInfo.h"
#import "YWCMainViewController.h"
#import "CustomerListViewController.h"
#import "AddressBookViewController.h"
#import "ProductDetailViewController.h"
#import "DJTOrderViewController.h"
#import "UMSocial.h"
#import "HomePageUserController.h"
#import "UserInfoViewController.h"
#import <WebKit/WebKit.h>
#import "NavigationController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <AlipaySDK/AlipaySDK.h>

@interface PreviewWebViewController ()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,UMSocialUIDelegate,UIAlertViewDelegate
>

@property (nonatomic,strong)id realWebView;
@property (nonatomic,assign)BOOL usingUIWebView;
@property (nonatomic,assign)BOOL firstReload;
@property (nonatomic,strong)NSString *lastTitle;
@property (nonatomic,assign)BOOL isLoginStatue;

@end

@implementation PreviewWebViewController

- (void)dealloc
{
    if (_recordItem) {
        NSDictionary *infoAgentDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3",@"UserAgent",nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:infoAgentDic];
    }
    
    if (_usingUIWebView) {
        if (_recordItem) {
            [self deleteCookie];
        }
        UIWebView* webView = _realWebView;
        webView.delegate = nil;
    }
    else
    {
        if (_recordItem) {
            NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
            NSError *errors;
            [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        }
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALIPAY_WEBPLAY object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO ;
    self.titleLable.textColor = [UIColor whiteColor];
    
    if (_recordItem) {
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:@"How-times1.0@ios", @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    }
    _isLoginStatue = ([GlobalManager shareInstance].detailInfo != nil);
    if ([GlobalManager shareInstance].detailInfo) {
        self.usingUIWebView = (NSClassFromString(@"WKWebView") == nil);
    }
    else {
        self.usingUIWebView = YES;
    }
    
    self.usingUIWebView = YES;
    if (_usingUIWebView) {
        [self initUIWebView];
    }
    else{
        [self initWKWebView];
    }
    [self.view addSubview:self.realWebView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAlipayFinish:) name:ALIPAY_WEBPLAY object:nil];
}

#pragma mark - WKWebView&UIWebView
- (void)initWKWebView
{
    WKWebViewConfiguration* configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    configuration.preferences = [NSClassFromString(@"WKPreferences") new];
    configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
    WKUserContentController* userContentController = [NSClassFromString(@"WKUserContentController") new];//how-times.com
    WKUserScript * cookieScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:[NSString stringWithFormat:@"document.cookie = 'user_id=%@;'",[GlobalManager shareInstance].detailInfo.user.id ?: @""] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    configuration.userContentController = userContentController;
    WKWebView* webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds configuration:configuration];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    webView.navigationDelegate = self;
    webView.backgroundColor = [UIColor whiteColor];
    webView.opaque = NO;
    _realWebView = webView;
}

-(void)initUIWebView
{
    if (_recordItem) {
        [self setCookie];
    }
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

#pragma mark - actions
- (void)backToPreControl:(id)sender
{
    if (_isLandscape) {
        [self changeOrientation:NO Com:^(BOOL finished) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)changeOrientation:(BOOL)landscape Com:(void (^ )(BOOL finished))completion
{
    _isLandscape = landscape;
    int oriention = landscape ? UIInterfaceOrientationLandscapeRight :  UIInterfaceOrientationPortrait;
    [UIView animateWithDuration:0.2 animations:^{
        
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:oriention];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

#pragma mark - actions
- (void)createRightButs
{
    self.navigationItem.rightBarButtonItems = nil;
    
    NSString *requestUrl = _usingUIWebView ? [[(UIWebView *)_realWebView request] URL].absoluteString : [(WKWebView *)_realWebView URL].absoluteString;
    if ([requestUrl rangeOfString:@"book/b"].location == NSNotFound) {
        return;
    }
    
    UIView *lastView = [[self.navigationItem.rightBarButtonItems lastObject] customView];
    if ([lastView isKindOfClass:[UIButton class]]) {
        return;
    }

    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 35, 35)];
    [rightBut addTarget:self action:@selector(shareToUmeng:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut setImage:CREATE_IMG(@"shareItems") forState:UIControlStateNormal];
    [rightBut setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
}

- (void)shareToUmeng:(id)sender
{
    UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
    if (!detail) {
        [self changeToLogin];
        
        return;
    }
    
    if (_usingUIWebView) {
        BOOL is_open = NO;
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSEnumerator *enumerator = [cookies objectEnumerator];
        NSHTTPCookie *cookie;
        while (cookie = [enumerator nextObject]) {
            if ([[cookie name] isEqualToString:@"is_open"]) {
                is_open = [[cookie value] integerValue];
                break;
            }
        }
        [self isShowAlert:is_open];
    }
    else{
        __weak typeof(self)weakSelf = self;
        [_realWebView evaluateJavaScript:@"document.cookie" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if ([result isKindOfClass:[NSString class]] && [result length] > 0) {
                NSArray *array = [result componentsSeparatedByString:@";"];
                for (NSString *str in array) {
                    if (([str rangeOfString:@"is_open"].location != NSNotFound)) {
                        NSString *value = [str substringFromIndex:[str length] - 1];
                        [weakSelf isShowAlert:[value integerValue]];
                    }
                }
            }
        }];
    }
}

- (void)isShowAlert:(BOOL)show
{
    NSUserDefaults *standDefault = [NSUserDefaults standardUserDefaults];
    BOOL public = [standDefault boolForKey:Public_Tip];
    if (!public && !show) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您分享的信息将会公开给所有用户看见，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        [alert show];
        return;
    }
    
    [self sharePublicInfo];
}

#pragma mark - appera
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL is_login = ([GlobalManager shareInstance].detailInfo != nil);
    if (_isLoginStatue != is_login) {
        if (_usingUIWebView && _recordItem) {
            [self setCookie];
        }
        [(UIWebView *)_realWebView reload];
    }
    
    if (!_hasLoaded) {
        _hasLoaded = YES;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
        if (_usingUIWebView) {
            [(UIWebView *)_realWebView loadRequest:request];
        }
        else {
            _firstReload = YES;
            [(WKWebView *)_realWebView loadRequest:request];
        }
    }
    
    if (_isLandscape) {
        [self changeOrientation:YES Com:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - cookie
- (void)setCookie{
    NSURL *cookieHost = [NSURL URLWithString:_url];
    
    // 设定 cookie
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [cookieHost host], NSHTTPCookieDomain,
                             [cookieHost path], NSHTTPCookiePath,
                             @"user_id",  NSHTTPCookieName,
                             [GlobalManager shareInstance].detailInfo.user.id ?: @"", NSHTTPCookieValue,
                             nil]];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)deleteCookie{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSURL *url = _usingUIWebView ? ((UIWebView *)_realWebView).request.URL : [_realWebView URL];
    if ([url.absoluteString length] == 0) {
        return;
    }
    NSArray *cookieAry = [cookieJar cookiesForURL:[NSURL URLWithString:url.absoluteString]];
    for (cookie in cookieAry) {
        [cookieJar deleteCookie: cookie];
    }
}

#pragma mark - 切换
- (void)pushViewController:(UIViewController *)viewController
{
    if (_isLandscape) {
        [self changeOrientation:NO Com:^(BOOL finished) {
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
            self.isLandscape = YES;
        }];
    }
    else{
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)pushTocontroller:(NSString *)p_id
{
    if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue == 1) {
        BatchCustomers *item = [[BatchCustomers alloc] init];
        item.grow_id = _recordItem.grow_id;
        AddressBookViewController *addressBook = [[AddressBookViewController alloc] init];
        addressBook.product_id = p_id;
        addressBook.batchCustomers = item;
        [self pushViewController:addressBook];
    }else {
        SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
        setController.batch_id = _recordItem.batch_id;
        setController.grow_id = _recordItem.grow_id;
        setController.customers = _customers;
        [self pushViewController:setController];
    }
}

- (void)changeToLogin
{
    if (_isLandscape) {
        [self changeOrientation:NO Com:^(BOOL finished) {
            [self presentViewController:[[NavigationController alloc] initWithRootViewController:[LoginViewController new]] animated:YES completion:nil];
            self.isLandscape = YES;
        }];
    }
    else{
        [self presentViewController:[[NavigationController alloc] initWithRootViewController:[LoginViewController new]] animated:YES completion:nil];
    }
}

#pragma mark - 打印
- (void)getPrintInfo
{
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSMutableDictionary *param = [manager requestinitParamsWith:@"queryGrowIsPrint"];
    [param setObject:_recordItem.grow_id forKey:@"grow_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"growAlbum"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
    rightItem.enabled = NO;
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getPrintAddress:error Data:data];
        });
    }];
}

- (void)getPrintAddress:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
    rightItem.enabled = YES;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        NSString *url = [result valueForKey:@"ret_data"];
        NSString *printUrl = @"";
        if ([url isKindOfClass:[NSString class]] && url.length > 0) {
            printUrl = url;
        }
        
        if (printUrl.length > 0) {
            DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
            order.url = printUrl;
            [self pushViewController:order];
            return;
        }
        else{
            [self.view makeToast:@"打印地址解析异常" duration:1.0 position:@"center"];
        }
    }
}

- (void)callBackToStatue:(NSInteger)idx
{
    CustomerModel *model = [[CustomerModel alloc] init];
    model.user_id = _recordItem.user_id;
    model.batch_id = _recordItem.batch_id;
    model.is_print = _recordItem.is_print;
    BOOL isBack = NO;
    for (id controller in self.navigationController.viewControllers) {
        if (([controller isKindOfClass:[HomePageUserController class]] && [self.navigationController.viewControllers count] > 3) || [controller isKindOfClass:[UserInfoViewController class]]) {
            isBack = YES;
            break;
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(reloadToCustomerList:Idx:)]) {
        if (_isLandscape) {
            [self changeOrientation:NO Com:^(BOOL finished) {
                [_delegate reloadToCustomerList:model Idx:idx];
            }];
        }else {
            [_delegate reloadToCustomerList:model Idx:idx];
        }
    }
    if (isBack) {
        if (_isLandscape) {
            [self changeOrientation:NO Com:^(BOOL finished) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)getOrderInfo
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"queryGrowOrderInfo"];
    [param setValue:_recordItem.grow_id forKey:@"grow_id"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"growAlbum"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getOrderInfoFinish:error Data:data];
        });
    }];
}

- (void)getOrderInfoFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [data valueForKey:@"ret_data"];
        _recordItem.is_print = [ret_data valueForKey:@"is_print"];
        _recordItem.user_id = [ret_data valueForKey:@"user_id"];
        _recordItem.batch_id = [ret_data valueForKey:@"batch_id"];
        _recordItem.sys_order_num = [ret_data valueForKey:@"sys_order_num"];
        _recordItem.grow_id = [ret_data valueForKey:@"grow_id"];
        _recordItem.finish_num = [NSNumber numberWithInteger:[[ret_data valueForKey:@"finish_num"] integerValue]];
        _recordItem.detail_num = [NSNumber numberWithInteger:[[ret_data valueForKey:@"nums"] integerValue]];
        
        if (([_recordItem.finish_num integerValue] == [_recordItem.detail_num integerValue]) && [_recordItem.finish_num integerValue] > 0 && [_recordItem.detail_num integerValue] > 0) {
            [self submitOrder];
        }
        else {
            [self.view makeToast:@"您还有档案没有制作完哦" duration:1.0 position:@"center"];
        }
    }
}

#pragma mark - 提交订单
- (void)submitOrder
{
    if ([_recordItem.is_print integerValue] == 1) {
        [self callBackToStatue:2];
        return;
    }
    else if ([_recordItem.is_print integerValue] == 2) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://mall.goonbaby.com/moblie/times/print?user_id=%@&order_id=%@&type=orderDetail&orientation=portrait", [GlobalManager shareInstance].detailInfo.user.id, _recordItem.sys_order_num]]];
        [(UIWebView *)_realWebView loadRequest:request];
        return;
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"consumerCreateOrder"];
    [param setValue:_recordItem.grow_id forKey:@"grow_ids"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"consumer"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf submitOrderFinish:error Data:data];
        });
    }];
}

- (void)submitOrderFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        _recordItem.is_print = @"1";
        CustomerModel *model = [[CustomerModel alloc] init];
        model.user_id = _recordItem.user_id;
        model.batch_id = _recordItem.batch_id;
        model.is_print = _recordItem.is_print;
        [[NSNotificationCenter defaultCenter] postNotificationName:RefreshCustomer object:nil];
        
        BOOL isBack = NO;
        for (id controller in self.navigationController.viewControllers) {
            if (([controller isKindOfClass:[HomePageUserController class]] && [self.navigationController.viewControllers count] > 3) || [controller isKindOfClass:[UserInfoViewController class]]) {
                isBack = YES;
                break;
            }
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(reloadToCustomerList:Idx:)]) {
            if (_isLandscape) {
                [self changeOrientation:NO Com:^(BOOL finished) {
                    [_delegate reloadToCustomerList:model Idx:2];
                }];
            }else {
                [_delegate reloadToCustomerList:model Idx:2];
            }
        }
        if (isBack) {
            if (_isLandscape) {
                [self changeOrientation:NO Com:^(BOOL finished) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
        [self.view makeToast:@"您的模版已成功提交打印" duration:1.0 position:@"center"];
    }
}

- (void)getPayInfo
{
    if (_usingUIWebView) {
        NSString *pay_key = @"";
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSEnumerator *enumerator = [cookies objectEnumerator];
        NSHTTPCookie *cookie;
        while (cookie = [enumerator nextObject]) {
            if ([[cookie name] isEqualToString:@"pay_key"]) {
                pay_key = [cookie value];
                break;
            }
        }
        [self payPriceToApliy:pay_key];
    }
    else {
        __weak typeof(self)weakSelf = self;
        [_realWebView evaluateJavaScript:@"document.cookie" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if ([result isKindOfClass:[NSString class]] && [result length] > 0) {
                NSArray *array = [result componentsSeparatedByString:@";"];
                for (NSString *str in array) {
                    if (([str rangeOfString:@"pay_key"].location != NSNotFound)) {
                        NSString *value = [str componentsSeparatedByString:@"="].lastObject;
                        [weakSelf payPriceToApliy:value];
                    }
                }
            }
        }];
    }
}

- (void)payPriceToApliy:(NSString *)pay_key
{
    NSString *result = [pay_key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    NSString *prestr = [dic valueForKey:@"prestr"];
    NSString *sign = [dic valueForKey:@"sign"];
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",prestr, sign, @"RSA"];
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    if ([orderString length] > 0) {
        [GlobalManager shareInstance].isWebAlipay = YES;
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:@"society" callback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"] integerValue] == 9000) {
                [self refreshAlipayFinish:nil];
            }
        }];
    }else {
        [self.view makeToast:@"订单信息获取失败！" duration:1.0 position:@"center"];
    }
}

#pragma mark - Alipay delegate
- (void)refreshAlipayFinish:(id)sender
{
    [(UIWebView *)_realWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mall.goonbaby.com/moblie/times/order"]]];
}

#pragma mark - 分享信息公开
- (void)sharePublicInfo
{
    UIImage *image = CREATE_IMG(@"180");
    [UMSocialData defaultData].extConfig.title = @"好时光";
    [UMSocialData defaultData].extConfig.wechatSessionData.url = _url;
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _url;
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.qqData.url = _url;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UMENG_APPKEY shareText:self.titleLable.text shareImage:image shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ] delegate:self];
    
    [self publicTemplateInfo];
}

#pragma mark - 提交订单
- (void)publicTemplateInfo
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"openGrow"];
    [param setValue:_recordItem.grow_id forKey:@"grow_id"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    [param setValue:@"1" forKey:@"is_open"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"templateSet"];
    //__weak typeof(self)weakSelf = self;
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        //[weakSelf publishInfoFinish:error Data:data];
    }];
}

- (void)publishInfoFinish:(NSError *)error Data:(id)data
{
    if (error == nil) {
        NSLog(@"%@",data);
    }
}

#pragma mark - 自己创建一本
- (void)resetSelfToRequest
{
    SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
    setController.batch_id = _recordItem.batch_id;
    setController.grow_id = _recordItem.grow_id;
    setController.customers = _customers;
    [self pushViewController:setController];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Public_Tip];
        [self sharePublicInfo];
    }
}

#pragma mark - URL判断
- (BOOL)checkRequestURL:(NSURL *)url
{
    NSString *str = url.absoluteString;
    if (str == nil) {
        return YES;
    }
    if ([str rangeOfString:@"landscape"].location != NSNotFound) {
        if (!_isLandscape) {
            [self changeOrientation:YES Com:nil];
        }
    }else if ([str rangeOfString:@"portrait"].location != NSNotFound) {
        if (_isLandscape) {
            [self changeOrientation:NO Com:nil];
        }
    }
    else if ([str rangeOfString:@"makebybookid/p"].location != NSNotFound) {
        UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
        if (!detail) {
            [self changeToLogin];
        }else {
            NSString *path = [str lastPathComponent];
            NSString *p_id = [[path componentsSeparatedByString:@"_"] objectAtIndex:0];
            p_id = [p_id substringFromIndex:1];
            [self pushTocontroller:p_id];
        }
        return NO;
    }
    if ([str rangeOfString:@"makebybookid/b"].location != NSNotFound) {
        UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
        if (!detail) {
            [self changeToLogin];
        }else {
            SetTemplateViewController *setController = [[SetTemplateViewController alloc] init];
            setController.batch_id = _recordItem.batch_id;
            setController.grow_id = _recordItem.grow_id;
            setController.customers = _customers;
            [self pushViewController:setController];
        }
        return NO;
    }
    else if ([str rangeOfString:@"viewbybookid/b"].location != NSNotFound) {
        ProductDetailViewController *product = [[ProductDetailViewController alloc] init];
        product.recordItem = _recordItem;
        product.customers = _customers;
        [self pushViewController:product];
        return NO;
    }else if ([str rangeOfString:@"setbybookid/b"].location != NSNotFound) {
        if ([_recordItem.is_print integerValue] == 1 || [_recordItem.is_print integerValue] == 2) {
            [self.view makeToast:@"您的档案正在打印中，不能修改哦" duration:1.0 position:@"center"];
            return NO;
        }
        
        for (UIViewController *con in self.navigationController.viewControllers) {
            if ([con isKindOfClass:[BatchMakeViewController class]]) {
                if (_isLandscape) {
                    [self changeOrientation:NO Com:^(BOOL finished) {
                        [self.navigationController popToViewController:con animated:YES];
                    }];
                }
                else{
                    [self.navigationController popToViewController:con animated:YES];
                }
                return NO;
            }
        }
        
        //制作
        BatchMakeViewController *batch = [BatchMakeViewController new];
        batch.batch_id = _recordItem.batch_id;
        batch.user_id = _recordItem.user_id;
        [self pushViewController:batch];
        return NO;
    }else if ([str rangeOfString:@"printbybookid/b"].location != NSNotFound) {
        if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue == 1) {
            [self getOrderInfo];
        }
        else {
            //h5
            [self getPrintInfo];
        }
        return NO;
    }else if ([str rangeOfString:@"selectformat/b"].location != NSNotFound) {
        
        UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
        if (!detail) {
            [self changeToLogin];
            return NO;
        }
    }else if ([str rangeOfString:@"OnlineService?qq="].location != NSNotFound) {
        NSRange range = [str rangeOfString:@"OnlineService?qq="];
        NSInteger location = range.location + range.length;
        NSString *qqStr = [str substringFromIndex:location];
        QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:qqStr];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
        return NO;
    }else if ([str rangeOfString:@"times/client_pay"].location != NSNotFound) {
        [self getPayInfo];
        return NO;
    }
    return YES;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL resultBOOL = [self checkRequestURL:request.URL];
    if (!resultBOOL) {
        _lastTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    return resultBOOL;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
    self.titleLable.text = @"加载中...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // new for memory cleaning
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] synchronize];
    // new for memory cleanup
    [[NSURLCache sharedURLCache] setMemoryCapacity: 0];
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    NSString *theTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.titleLable.text = theTitle;
    
    [self createRightButs];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = ([_lastTitle length] > 0);
    self.titleLable.text = _lastTitle ?: @"加载失败";
    _lastTitle = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark- WKNavigationDelegate
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{
//    NSLog(@"%@",webView.URL.absoluteString);
//    BOOL resultBOOL = [self checkRequestURL:webView.URL];
//    if(resultBOOL)
//    {
//        decisionHandler(WKNavigationActionPolicyAllow);
//    }
//    else
//    {
//        _lastTitle = webView.title;
//        decisionHandler(WKNavigationActionPolicyCancel);
//    }
//}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSString *str = webView.URL.absoluteString;
    if ([str length] > 0) {
        if ([str rangeOfString:@"times/product"].location != NSNotFound || [str rangeOfString:@"times/order"].location != NSNotFound) {
            if (_isLandscape) {
                [self changeOrientation:NO Com:nil];
            }
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    BOOL resultBOOL = [self checkRequestURL:webView.URL];
    if(resultBOOL)
    {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    else
    {
        _lastTitle = webView.title;
        decisionHandler(WKNavigationResponsePolicyCancel);
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
            if (_firstReload) {
                _firstReload = NO;
                [(WKWebView *)_realWebView reload];
            }else {
                weakSelf.titleLable.text = result;
                [weakSelf createRightButs];
            }
        });
    }];
}

- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = ([_lastTitle length] > 0);
    self.titleLable.text = _lastTitle ?: @"加载失败";
    _lastTitle = nil;
}

- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = ([_lastTitle length] > 0);
    self.titleLable.text = _lastTitle ?: @"加载失败";
    _lastTitle = nil;
}

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
#pragma mark - 旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return _isLandscape ? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskPortrait;
}

@end
