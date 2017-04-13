//
//  SettingViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/6/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SettingViewController.h"
#import "UserHeadCell.h"
#import "ChangePsdViewController.h"
#import "LoginViewController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "UMSocial.h"
#import "FeedbackViewController.h"
#import "ImageCropViewController.h"
#import "UIImage+FixOrientation.h"
#import "MyTableBarViewController.h"
#import "GrowAlertView.h"
#import "RegisterViewController.h"
#import "SysConfigModel.h"
#import "AppDelegate.h"
#import "DJTOrderViewController.h"
#import "NavigationController.h"

@interface SettingViewController ()<UIAlertViewDelegate,UMSocialUIDelegate,UserHeadCellDelegate,UIActionSheetDelegate,ImageCropDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GrowAlertViewDelegate>
{
    NSArray *_titles,*_imgs;
    NSIndexPath *_indexPath;
    UIImagePickerController *_pickerController;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"设置";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _titles = @[@[@"应用评分",@"推送提醒",@"清理缓存",@"反馈建议"],@[@"分享好友",@"联系客服",@"关于好时光"]];
    _imgs = @[@[@"set_app",@"set_push",@"set_clean",@"set_feedback"],@[@"set_share",@"set_service",@"set_about"]];
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self.tableView setBackgroundColor:CreateColor(241, 242, 245)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass:[UserHeadCell class] forCellReuseIdentifier:@"UserHeadCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SettingCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LogOutCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_refreshHead) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        _refreshHead = NO;
    }
}
- (NSString *)fileSizeWithInterge:(NSInteger)size{
    // 1k = 1024, 1m = 1024k
    if (size < 1024) {// 小于1k
        return [NSString stringWithFormat:@"%ldB",(long)size];
    }else if (size < 1024 * 1024){// 小于1m
        CGFloat aFloat = size/1024;
        return [NSString stringWithFormat:@"%.0fK",aFloat];
    }else if (size < 1024 * 1024 * 1024){// 小于1G
        CGFloat aFloat = size/(1024 * 1024);
        return [NSString stringWithFormat:@"%.1fM",aFloat];
    }else{
        CGFloat aFloat = size/(1024*1024*1024);
        return [NSString stringWithFormat:@"%.1fG",aFloat];
    }
}

- (void)switchAction:(id)sender
{
    UISwitch *swi = (UISwitch *)sender;
    BOOL isOn = [swi isOn];
    [[NSUserDefaults standardUserDefaults] setBool:!isOn forKey:Notice_Off];
    if (!isOn) {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
    else{
        [APPDELEGETE registerPush];
    }
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

#pragma mark - UMShare delegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[SDImageCache sharedImageCache] clearDisk];
        
        [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            _pickerController = picker;
            picker.delegate = self;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            _pickerController = imagePicker;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UserHeadCell delegate
- (void)uploadFaceImageToIndex:(UserHeadCell *)cell
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    [sheet showInView:self.view];
}

- (void)upDataUserNameToIndex:(UserHeadCell *)cell
{
    UserInfo *user = [GlobalManager shareInstance].detailInfo.user;
    if ([user.open_id length] > 0 && [user.login_name length] == 0) {
        RegisterViewController *forget = [RegisterViewController new];
        forget.titleLable.text = @"绑定号码";
        [self.navigationController pushViewController:forget animated:YES];
    }else {
        ChangePsdViewController *userController = [[ChangePsdViewController alloc] init];
        [self.navigationController pushViewController:userController animated:YES];
    }
}

#pragma mark GrowAlertView delegate
- (void)closeGrowAlertView
{
    for (id subview in self.view.window.subviews) {
        if ([subview isKindOfClass:[GrowAlertView class]]) {
            [subview removeFromSuperview];
        }
    }
}
- (void)submitThemeToGrowAlertView:(GrowAlertView *)alert Theme:(NSString *)theme
{
    if ([theme length] <= 0) {
        [self.view makeToast:@"您还没有修改昵称哦" duration:1.0 position:@"center"];
        return;
    }
    
    [self uploadImgRequest:nil Name:theme];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //[picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image fixOrientation];
    
    ImageCropViewController *controller = [[ImageCropViewController alloc] init];
    controller.originImage = image;
    controller.delegate= self;
    //controller.hidesBottomBarWhenPushed = YES;
    [picker pushViewController:controller animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ImageCropViewController delegate
-(void)ImageCropVC:(ImageCropViewController*)ivc CroppedImage:(UIImage *)image
{
    if (image) {
        
        NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSString getToday]]]];
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        [data writeToFile:filePath atomically:NO];
        
        NSMutableDictionary *file_info = [NSMutableDictionary dictionary];
        [file_info setObject:@"1" forKey:@"type"];
        [file_info setObject:@"1" forKey:@"is_headimg"];
        
        UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
        NSDictionary *lstDic = @{@"token":detailInfo.token,@"file_info":file_info};
        NSData *json = [NSJSONSerialization dataWithJSONObject:lstDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        lstJson = [NSString encrypt:lstJson];
        NSString *gbkStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)lstJson,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
        NSString *url = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
        
        [self.view makeToastActivity];
        self.view.userInteractionEnabled = NO;
        __weak typeof(self)weakSelf = self;
        self.sessionTask = [HttpClient uploadFile:url filePath:filePath parameters:nil complateBlcok:^(NSError *error, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
                if (error) {
                    [self.view hideToastActivity];
                    self.view.userInteractionEnabled = YES;
                    [self.view makeToast:@"图片上传失败" duration:1.0 position:@"center"];
                }
                else{
                    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString *retJson = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    id retData = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                    if ([retData isKindOfClass:[NSArray class]]) {
                        retData = [retData firstObject];
                    }
                    NSString *ret_code = [retData valueForKey:@"ret_code"];
                    if ((ret_code.length > 0) && [ret_code isEqualToString:@"0000"]) {
                        NSString *path = [retData valueForKey:@"path"];
                        [self uploadImgRequest:path Name:nil];
                    }else {
                        [self.view hideToastActivity];
                        self.view.userInteractionEnabled = YES;
                        [self.view makeToast:@"图片上传失败" duration:1.0 position:@"center"];
                    }
                }
                weakSelf.sessionTask = nil;
            });
        } progressBlock:^(NSProgress *progress) {
            
        }];
    }
    [_pickerController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)uploadImgRequest:(NSString *)imagePath Name:(NSString *)name
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"updateUserInfo"];
    if ([imagePath length] > 0) {
        [param setObject:imagePath forKey:@"head_img"];
    }
    
    if ([name length] > 0) {
        [param setObject:name forKey:@"name"];
    }
    
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"user"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf uploadFaceImageFinish:error Data:data];
        });
    }];
}

#pragma mark - change password
- (void)uploadFaceImageFinish:(NSError *)error Data:(id)data{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [data valueForKey:@"ret_data"];
        [GlobalManager shareInstance].detailInfo.user.head_img = [ret_data valueForKey:@"head_img"];
        [GlobalManager shareInstance].detailInfo.user.name = [ret_data valueForKey:@"name"];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - share data
- (void)getShareDataFinish:(NSError *)error Data:(id)data{
    self.sessionTask = nil;
    if (error) {
        [self.view hideToastActivity];
        self.view.userInteractionEnabled = YES;
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        
        id ret_data = [data valueForKey:@"ret_data"];
        __weak typeof(self)weakSelf = self;
        [HttpClient downloadFileWithProgress:[ret_data valueForKey:@"image_url"] complateBlcok:^(NSError *error, NSURL *filePath) {
            if (error) {
                [self.view makeToast:error.domain duration:1.0 position:@"center"];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hideToastActivity];
                    self.view.userInteractionEnabled = YES;
                    
                    NSString *content = @"";
                    if ([[ret_data valueForKey:@"type"] integerValue] == 1){
                        content = @"我新制作的好时光档案,快来看看吧~";
                    }else{
                        content = @"我想这是你需要的~";
                    }
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePath]];
                    [UMSocialData defaultData].extConfig.title = [ret_data valueForKey:@"name"];
                    [UMSocialData defaultData].extConfig.qqData.url = [ret_data valueForKey:@"url"];
                    [UMSocialSnsService presentSnsIconSheetView:self appKey:UMENG_APPKEY shareText:content shareImage:image ?: CREATE_IMG(@"loginLogo") shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ] delegate:self];
                    
                });
            }
        } progressBlock:^(NSProgress *progress) {
            
        }];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0 || section == 3) ? 1 : ((section == 1) ? 4 : 3);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = (indexPath.section == 0) ? @"UserHeadCell" : ((indexPath.section == 3) ? @"LogOutCell" : @"SettingCell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [(UserHeadCell *)cell setDelegate:self];
        [(UserHeadCell *)cell resetDataSource:nil];
    }
    else if (indexPath.section == 3)
    {
        UILabel *tipLabel = (UILabel *)[cell.contentView viewWithTag:1];
        if (!tipLabel) {
            tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 30)];
            [tipLabel setBackgroundColor:[UIColor clearColor]];
            [tipLabel setTag:1];
            [tipLabel setTextColor:CreateColor(86, 86, 86)];
            [tipLabel setTextAlignment:NSTextAlignmentCenter];
            [tipLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.contentView addSubview:tipLabel];
        }
        [tipLabel setText:@"退出当前账号"];
    }
    else {
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
        if (!imgView) {
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (40 - 65 / 3) / 2, 20, 65 / 3)];
            [imgView setContentMode:UIViewContentModeScaleAspectFill];
            [imgView setClipsToBounds:YES];
            [cell.contentView addSubview:imgView];
        }
        [imgView setImage:CREATE_IMG(_imgs[indexPath.section - 1][indexPath.row])];
        
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 15, 5, 100, 30)];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setTag:2];
            [titleLabel setTextColor:CreateColor(86, 86, 86)];
            [titleLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.contentView addSubview:titleLabel];
        }
        [titleLabel setText:_titles[indexPath.section - 1][indexPath.row]];
        
        if (indexPath.section == 1 && indexPath.row == 1) {
            UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:4];
            if (detailLabel) {
                detailLabel.hidden = YES;
            }
            UISwitch *switchView = (UISwitch *)[cell.contentView viewWithTag:3];
            if (!switchView) {
                switchView = [[UISwitch alloc] init];
                switchView.frameX = SCREEN_WIDTH - switchView.frameWidth - 15;
                switchView.frameY = (40 - switchView.frameHeight) / 2;
                switchView.on = YES;
                switchView.tag = 3;
                [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:switchView];
            }
            switchView.hidden = NO;
            BOOL isOff = [[NSUserDefaults standardUserDefaults] boolForKey:Notice_Off];
            [switchView setOn:!isOff];
        }else if (indexPath.section == 1 && indexPath.row == 2) {
            UISwitch *switchView = (UISwitch *)[cell.contentView viewWithTag:3];
            if (switchView) {
                switchView.hidden = YES;
            }
            UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:4];
            if (!detailLabel) {
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frameRight + 5, titleLabel.frameY, SCREEN_WIDTH - titleLabel.frameRight - 5 - 15, 30)];
                [detailLabel setBackgroundColor:[UIColor whiteColor]];
                [detailLabel setTag:4];
                [detailLabel setTextColor:[UIColor lightGrayColor]];
                [detailLabel setFont:[UIFont systemFontOfSize:14]];
                [detailLabel setTextAlignment:NSTextAlignmentRight];
                [cell.contentView addSubview:detailLabel];
            }
            NSUInteger intg = [[SDImageCache sharedImageCache] getSize];
            NSString * currentVolum = [NSString stringWithFormat:@"%@",[self fileSizeWithInterge:intg]];
            [detailLabel setText:[NSString stringWithFormat:@"已使用%@",currentVolum]];
        }else {
            UISwitch *switchView = (UISwitch *)[cell.contentView viewWithTag:3];
            if (switchView) {
                switchView.hidden = YES;
            }
            UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:4];
            if (detailLabel) {
                detailLabel.hidden = YES;
            }
        }
        
        if ((indexPath.row == 1 || indexPath.row == 2) && indexPath.section == 1) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            GrowAlertView *alertView = [[GrowAlertView alloc] initWithFrame:self.view.window.bounds];
            alertView.delegate = self;
            alertView.titleLabel.text = @"修改昵称：";
            [self.view.window addSubview:alertView];
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                NSString *url = @"";
                for (SysConfigModel *model in [GlobalManager shareInstance].systemConfig) {
                    if ([model.type integerValue] == 3 && [model.data length] > 0) {
                        url = model.data;
                        break;
                    }
                }
                if ([url length] > 0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }
                else {
                    [self.view makeToast:@"应用正在审核中" duration:1.0 position:@"center"];
                }
            }
            else if (indexPath.row == 2) {
                _indexPath = indexPath;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:@"您确定清除缓存吗？清除缓存不影响照片的使用哦" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                [alertView show];
            }
            else if (indexPath.row == 3) {
                FeedbackViewController *feedbackController = [[FeedbackViewController alloc] init];
                [self.navigationController pushViewController:feedbackController animated:YES];
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
                        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
                        return;
                    }
                    
                    GlobalManager *manager = [GlobalManager shareInstance];
                    NSMutableDictionary *param = [manager requestinitParamsWith:@"share"];
                    [param setObject:manager.detailInfo.token forKey:@"token"];
                    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
                    [param setObject:text forKey:@"signature"];
                    
                    [self.view makeToastActivity];
                    self.view.userInteractionEnabled = NO;
                    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"user"];
                    __weak typeof(self)weakSelf = self;
                    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf getShareDataFinish:error Data:data];
                        });
                    }];
                }
                    break;
                case 1:
                {
                    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    [appDel launchQQClient];
                }
                    break;
                case 2:
                {
                    //about   h5
                    DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
                    order.url = @"http://h5v2.goonbaby.com/v-U7084HH7MC";
                    [self.navigationController pushViewController:order animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            [[GlobalManager shareInstance] setDetailInfo:nil];
            [[GlobalManager shareInstance] removeAssetsLibraryChangedNotification];
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_LOGOUT object:nil];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Password];
            
            [self presentViewController:[[NavigationController alloc] initWithRootViewController:[LoginViewController new]] animated:YES completion:^{
                MyTableBarViewController *bar = (MyTableBarViewController *)[APPWindow rootViewController];
                bar.selectedIndex = 0;
                bar.customTabBar.nSelectedIndex = 0;
                [bar.view makeToast:@"当前账号已退出" duration:1.0 position:@"center"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0) ? 75 : 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0 || section == 1) ? 15 : 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

@end
