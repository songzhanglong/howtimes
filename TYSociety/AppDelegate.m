//
//  AppDelegate.m
//  TYSociety
//
//  Created by szl on 16/6/12.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"           //微信SSO免登录
#import "UMSocialQQHandler.h"               //QQ空间和QQ SSO面认证
#import <JSPatch/JPEngine.h>
#import "HttpClient.h"
#import "GuideScrollView.h"
#import "MyTableBarViewController.h"
#import "CTAssetsPickerController.h"
#import "XGPush.h"
#import "MobClick.h"
#import <AlipaySDK/AlipaySDK.h>
#import "SysConfigModel.h"
////#import <WSPX/WSPX.h>
#import "MWCommon.h"
#import "LaunchViewController.h"

@interface AppDelegate ()<GuideScrollViewDelegate/*,WSPXConfigurationDelegate*/>

@property (nonatomic,strong)NSData *deviceToken;

@end

@implementation AppDelegate

#pragma mark - 错误处理
- (void)dealWithError
{
    if (_window) {
        if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
            [self performSelector:@selector(dealWithError) withObject:nil afterDelay:5];
            return;
        }
    }
    else{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app版本
        NSString *app_Version = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
        NSString *jsPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.js",JS_FILE_NAME,app_Version]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:jsPath]) {
            [JPEngine evaluateScriptWithPath:jsPath];
        }
    }
    
    //网络请求
    NSMutableDictionary *param = [[GlobalManager shareInstance] requestinitParamsWith:@"getJs"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"iphonejs"] parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf dealWithErrorFinish:error Data:data];
        });
    }];
}

- (void)dealWithErrorFinish:(NSError *)error Data:(id)result
{
    if (!error) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSString class]]) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            // app版本
            NSString *app_Version = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
            NSString *jsPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.js",JS_FILE_NAME,app_Version]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:jsPath]) {
                NSString *jsContent = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
                if (![jsContent isEqualToString:ret_data]) {
                    [ret_data writeToFile:jsPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    [JPEngine evaluateScriptWithPath:jsPath];
                }
            }
            else{
                [ret_data writeToFile:jsPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                [JPEngine evaluateScriptWithPath:jsPath];
            }
        }
    }
    else{
        [self performSelector:@selector(dealWithError) withObject:nil afterDelay:5];
    }
}

#pragma mark - 客服
- (void)launchQQClient
{
    NSString *qqNumber = @"3492435469";
    for (SysConfigModel *model in [GlobalManager shareInstance].systemConfig) {
        if ([model.type integerValue] == 1 && [model.data length] > 0) {
            qqNumber = model.data;
            break;
        }
    }
    QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:qqNumber];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
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

#pragma mark - 注册推送
- (void)registerPush
{
    BOOL isOff = [[NSUserDefaults standardUserDefaults] boolForKey:Notice_Off];
    if (isOff) {
        return;
    }
    
    //推送新策略
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert |UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication]registerForRemoteNotifications];
    } else{
        //注册启用push
        [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeBadge)];
        
    }
}

- (void)registerXGPushInfo
{
    if (!_deviceToken) {
        return;
    }
    
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush Demo]register successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush Demo]register errorBlock");
    };
    
    // 设置账号
    NSString *str = [GlobalManager shareInstance].detailInfo.user.id;
    [XGPush setAccount:str];
    
    //注册设备
    /*NSString * deviceTokenStr = */[XGPush registerDevice:_deviceToken successCallback:successBlock errorCallback:errorBlock];
    
    //如果不需要回调
    //[XGPush registerDevice:deviceToken];
    
    //打印获取的deviceToken的字符串
    //NSLog(@"[XGPush Demo] deviceTokenStr is %@",deviceTokenStr);
}

#pragma mark - 友盟配置
- (void)umengTrack {
    [MobClick setAppVersion:XcodeAppVersion];
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy)SEND_INTERVAL channelId:nil];
    //[MobClick updateOnlineConfig];  //在线参数配置
    [MobClick setCrashReportEnabled:YES];
    [MobClick setLogEnabled:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}

- (void)configUMShare{
    //设置友盟社会化组件APPKEY
    [UMSocialData setAppKey:UMENG_APPKEY];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wx8f09f6ce47beba8d" appSecret:@"87b427248e975556d8884f2901da35c6" url:@"http://www.how-times.com"];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"1105476905" appKey:@"Ox89N7YyTtzqWM8c" url:@"http://www.how-times.com"];
    
    NSString *tip = @"好时光";
    [UMSocialData defaultData].extConfig.qzoneData.title = tip;
    [UMSocialData defaultData].extConfig.qqData.title = tip;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = tip;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = tip;
    
    //对未安装客户端平台进行隐藏
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
}

#pragma mark - 获取配置信息
- (void)getSystemConfig
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getSysConfig"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"system"];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sysConfigFinish:error Data:data];
        });
    }];
}

- (void)sysConfigFinish:(NSError *)error Data:(id)data{
    if (!error) {
        id ret_data = [data valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            [GlobalManager shareInstance].systemConfig = [SysConfigModel arrayOfModelsFromDictionaries:ret_data error:nil];
        }
    }
}


#pragma mark - GuideScrollViewDelegate
- (void)startLaunchApp:(GuideScrollView *)guideView
{
    [UIView animateWithDuration:0.3 animations:^{
        guideView.alpha = 0;
    } completion:^(BOOL finished) {
        [guideView removeFromSuperview];
    }];
}

#pragma mark - 加速
/*
- (void)configSpeedUp
{
    //建议将以下代码写在本函数的开头，在此调用之前的网络请求无法加速
    WSPXConfiguration *config = [WSPXConfiguration defaultConfiguration];
    // 如果你的 App 有做 UDID 方案，可设置进来，用于问题追踪
    config.deviceIdentifier = [NSString getDeviceUDID];
    // 加速正则黑名单示例
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") ||
        (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && 						SYSTEM_VERSION_LESS_THAN(@"8.0"))) {
        // iOS7及iOS9以上，可以对整条URL设置正则黑名单，
        // 以下为过滤所有 https 请求不对其进行加速的示例
        config.blacklistHostRegexString = @"^https";
    } else {
        // iOS6/8只能对URL中的host设置正则黑名单
        // 以下为过滤baidu域名的示例
        config.blacklistHostRegexString = @"www.baidu.com";
    }
    config.delegate = self;
    [WSPX startUsingConfiguration:config];
}

#pragma mark - WSPXConfigurationDelegate
- (void)wspxDidStart:(BOOL)success {
    // 1. 在此函数被调用之前的网络请求不会被加速
    // 2. 如果你也使用了NSURLProtocol，请在此函数里进行注册，以防止其失效
    NSLog(@"MAA started with result : %d", success);
}
*/
#pragma mark - 磁盘空间判断
- (void)systemSpaceObserve
{
    long long freeSize = [NSString freeSpace];
    //500M判断
    if (freeSize > 0 && freeSize < 1024 * 1024 * 500) {
        [_window makeToast:@"您的磁盘空间不足，为免影响使用，请您及时清理" duration:1.0 position:@"center"];
    }
}

#pragma mark - 启动
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //网络加速
    //[self configSpeedUp];
    
    //错误处理
    [self dealWithError];
    
    //信鸽
    [XGPush startApp:2200211769 appKey:@"IMPLB1I7344M"];
    [XGPush handleLaunching:launchOptions];
    [self registerPush];
    
    //友盟分享配置
    [self umengTrack];
    [self configUMShare];
    //系统配置参数
    [self getSystemConfig];
    
    [[UINavigationBar appearance] setBarTintColor:BASELINE_COLOR];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *password = [userDefault valueForKey:User_Password];
    NSString *phone = [userDefault valueForKey:User_Phone];
    BOOL autoLogin = (password.length > 0 && phone.length > 0);
    if (autoLogin) {
        [self.window setRootViewController:[LaunchViewController new]];
    }
    else{
        [self.window setRootViewController:[MyTableBarViewController new]];
    }

    [self.window makeKeyAndVisible];
    
    if (!autoLogin) {
        BOOL checkGuide = [[NSUserDefaults standardUserDefaults] boolForKey:CHECK_GUIDE];
        if (!checkGuide) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CHECK_GUIDE];
            GuideScrollView *guide = [[GuideScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            guide.delegate = self;
            [_window addSubview:guide];
        }
    }
    
    //磁盘空间
    [self systemSpaceObserve];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //停止网络监听
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

/*
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [WSPX activate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [WSPX stop];
}
 */

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //程序进入后台后保持程序运行一段时间，不阻塞
    __block UIBackgroundTaskIdentifier background_task;
    //Create a task object
    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
        //[self hold];
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //网络监听
    __weak typeof(GlobalManager *)manager = [GlobalManager shareInstance];
    __weak typeof(self)weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        [manager setNetworkReachabilityStatus:status];
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
            {
                [weakSelf.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                
            }
                break;
            default:
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"] integerValue] == 9000) {
                if ([GlobalManager shareInstance].isWebAlipay) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ALIPAY_WEBPLAY object:nil];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ALIPAY_SUCCESS object:nil];
                }
            }else {
                NSString *str = [resultDic valueForKey:@"memo"];
                if ([str length] == 0) {
                    str = @"支付失败";
                }
                [self.window makeToast:str duration:1.0 position:@"center"];
            }
            [GlobalManager shareInstance].isWebAlipay = NO;
        }];
        return YES;
    }
    return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"] integerValue] == 9000) {
                if ([GlobalManager shareInstance].isWebAlipay) {
                    [GlobalManager shareInstance].isWebAlipay = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:ALIPAY_WEBPLAY object:nil];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ALIPAY_SUCCESS object:nil];
                }
            }else {
                NSString *str = [resultDic valueForKey:@"memo"];
                if ([str length] == 0) {
                    str = @"支付失败";
                }
                [self.window makeToast:str duration:1.0 position:@"center"];
            }
            [GlobalManager shareInstance].isWebAlipay = NO;
        }];
        return YES;
    }
    return [UMSocialSnsService handleOpenURL:url];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [XGPush handleReceiveNotification:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    self.deviceToken = deviceToken;
    BOOL isOff = [[NSUserDefaults standardUserDefaults] boolForKey:Notice_Off];
    if ([GlobalManager shareInstance].detailInfo && !isOff) {
        [self registerXGPushInfo];
    }
}

@end
