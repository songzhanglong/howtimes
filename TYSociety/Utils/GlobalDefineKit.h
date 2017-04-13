//
//  DJTGlobalDefineKit.h
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#ifndef TY_DJTGlobalDefineKit_h
#define TY_DJTGlobalDefineKit_h

#define APPDELEGETE                 ((AppDelegate *)[[UIApplication sharedApplication]delegate])
#define APPWindow                   ((UIWindow*)[[[UIApplication sharedApplication] delegate] window])

#define USERDEFAULT                 ([NSUserDefaults standardUserDefaults])
#pragma mark - 路径
#define APPDocumentsDirectory       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]                    //document路径
#define APPCacheDirectory           [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]                 //cache路径
#define APPTmpDirectory             [NSHomeDirectory()  stringByAppendingPathComponent:@"tmp"]   //tmp路径

#pragma mark - 屏幕参数
#define SCREEN_WIDTH                ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT               ([UIScreen mainScreen].bounds.size.height)

#pragma mark - 接口地址

//#define G_INTERFACE_ADDRESS         @"http://public.doupad.net/interface/"      //http服务器地址(生产)
//#define G_IMAGE_ADDRESS             @"http://static.goonbaby.com"   //图片地址前缀(生产)
//#define G_UPLOAD_IMAGE              @"http://public.doupad.net/upload/file?data="  //图片上传（生产）
//#define G_PLAYER_ADDRESS            @"http://player.doupad.net/"

#define G_INTERFACE_ADDRESS         @"http://if.how-times.com/interface/"      //http服务器地址(生产)
#define G_IMAGE_ADDRESS             @"http://static.goonbaby.com"   //图片地址前缀(生产)
#define G_UPLOAD_IMAGE              @"http://if.how-times.com/upload/file?data="  //图片上传（生产）
#define G_PLAYER_ADDRESS            @"http://player.how-times.com/"

#pragma mark - HmacSHA1加密密钥
#define SERCET_KEY                  @"zyxwvutsrqponmlkjlh_sdk"  //HMac1加密秘钥
#define SERCET_KEY2                 @"abcdefghijklmnopqrstuvwx"  //HMac1加密秘钥
#define JS_FILE_NAME                @"society"                  //js文件名称
#define EDIT_INDEX                  @"editIndex"
#define CHECK_GUIDE                 @"checkGuide"               //是否查看引导
#define Seperate_RowStr             @"#r#"

#pragma mark - 背景颜色与字体
#define G_BACKGROUND_COLOR          [UIColor colorWithRed:239.0 / 255.0 green:239.0 / 255.0 blue:239.0 / 255.0 alpha:1.0]
#define CreateColor(x,y,z)          [UIColor colorWithRed:x / 255.0 green:y / 255.0 blue:z / 255.0 alpha:1.0]
#define rgba(r,g,b,a)               [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:a]
#pragma mark - 基调色
#define BASELINE_COLOR              rgba(154,125,251,1)
#define UnEditTextColor             rgba(233,231,231,1)
#define TextSelectColor             rgba(61, 61, 61, 1)
#define PortfolioColor              rgba(240, 239, 245, 1)

#define FontSize(x)                 [UIFont systemFontOfSize:x]

#define BigFont                     [UIFont systemFontOfSize:17]
#define MiddleFont                  [UIFont systemFontOfSize:14]
#define SmallFont                   [UIFont systemFontOfSize:10]

#define CREATE_IMG(name)            [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]]
#define CREATE_JPG(name)            [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"jpg"]]


#pragma mark - 标记特殊文字
#define BEGIN_PATH                  @"<@#"
#define END_PATH                    @"#@>"

#pragma mark - 友盟APPKEY
#define UMENG_APPKEY                @"5790911ee0f55a1d9b000383"

#define NET_WORK_TIP                @"无法连接服务器，请检查你的网络设置。"
#define REQUEST_FAILE_TIP           @"无法连接服务器，请尝试重新打开客户端。"
#define SHARE_TIP_INFO              @"您还需要安装对应的APP"


#define PICTURE_TIP                 @"photoimgTip"
#define CHECKMORE_PICTURE           @"checkMorePicture"
#define RefreshAlbum                @"refreshAblum"
#define USER_LOGOUT                 @"userLogout"
#define RefreshCustomer             @"refreshCustomer"
#define ChangeCustomPublic          @"changeCustomPublic"
#define ScrollToTop                 @"scrollToTop"
#define UserPorfile                 @"userPorfile"      //个人作品
#define ALIPAY_SUCCESS              @"alipayFinish"     //alipay
#define ALIPAY_WEBPLAY              @"alipayWebFinish"
#define User_Phone                  @"userPhone"        //用户名
#define User_Password               @"userPassword"     //用户密码
#define Public_Tip                  @"publicTip"        //发布之前是否给提示
//#define System_Font                 @"helvetica"
#define Notice_Off                  @"noticeOff"        //消息通知开启，关闭

typedef enum
{
    ClassType = 0,//班级动态
    BabyType,     //宝贝相册
    NoneType,     //直接进入
    
}ActivityType;//新建动态

#endif
