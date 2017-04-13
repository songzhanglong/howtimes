//
//  LaunchViewController.m
//  TYSociety
//
//  Created by szl on 16/8/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "LaunchViewController.h"
#import "Masonry.h"
#import "MyTableBarViewController.h"
#import "DataBaseOperation.h"
#import "AppDelegate.h"

@interface LaunchViewController ()

@property (nonatomic,strong)UIImageView *contentImg;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.contentImg];
    [_contentImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
    }];
    
    [self autoLoginRequest];
}

#pragma mark - 登录完成
- (void)autoLoginRequest
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *password = [userDefault valueForKey:User_Password];
    NSString *phone = [userDefault valueForKey:User_Phone];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"login"];
    [param setObject:phone forKey:@"loginname"];
    [param setObject:password forKey:@"password"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"user"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf loginFinish:error Data:data];
        });
    }];
}

- (void)loginFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    if (error == nil) {
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
        NSString *maxShootTime = [operation selectMaxShootingTime] ?: @"0";
        //偷偷加载新拍的
        [[GlobalManager shareInstance] loadNewImgAssets:[NSDate dateWithTimeIntervalSince1970:maxShootTime.doubleValue]];
    }
    [APPWindow setRootViewController:[MyTableBarViewController new]];
}

#pragma mark status
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - lazy load
- (UIImageView *)contentImg
{
    if (!_contentImg) {
        _contentImg = [[UIImageView alloc] init];
        [_contentImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSString *imgName = iPhone4 ? @"960" : (iPhone5 ? @"1136" : (iPhone6 ? @"1334" : @"2208"));
        imgName = [@"Default-" stringByAppendingString:imgName];
        [_contentImg setImage:CREATE_IMG(imgName)];
    }
    return _contentImg;
}

@end
