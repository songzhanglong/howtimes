//
//  UserInfoViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "UserInfoViewController.h"
#import "MyOrderInfoViewController.h"
#import "MyMessageViewController.h"
#import "SubmitOrderViewController.h"
#import "YWCMainViewController.h"
#import "YWCTitleVCModel.h"
#import "CouponViewController.h"
#import "UIImageView+WebCache.h"
#import "SettingViewController.h"
#import "CTAssetsPickerController.h"
#import "ImageCropViewController.h"
#import "UIImage+FixOrientation.h"
#import "MyPortfolioViewController.h"
#import "CustomerListViewController.h"
#import "PreviewWebViewController.h"
#import "Masonry.h"
#import "ActivityViewController.h"
#import "GrowAlertView.h"
#import "SysConfigModel.h"
#import "MyMessageViewController.h"

#define UserInfoHeaderId    @"userInfoHeaderId"
#define UserInfoCellId      @"userInfoCellId"

typedef enum{
    kModuleCustomer = 0,        //客户
    kModuleBookcase,            //书柜
    kModuleStory,               //故事汇
    kModuleMsg,                 //消息
    kModuleCouponimg,           //优惠券
    kModuleOrder,               //订单
    kModuleAddress,             //收货地址
    kModuleActivity,            //活动
    kModuleMore,                //更多

}kModuleUserType;

@interface ModuleUserInfo : NSObject

@property (nonatomic,assign)kModuleUserType moduleType;
@property (nonatomic,strong)NSString *moduleName;
@property (nonatomic,strong)NSString *imgName;

@end

@implementation ModuleUserInfo

@end

@interface UserInfoViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImageCropDelegate,GrowAlertViewDelegate>

@property (nonatomic,strong)NSMutableArray *allModules;

@end
@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    if ([self.navigationController.viewControllers count] > 1) {
        self.showBack = YES;
    }
    
    [self createRightBarButton];
    
    //数据源
    [self makeAllModules];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    CGFloat itemWei = (SCREEN_WIDTH) / 3,itemHei = itemWei;
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    UIImage *upImg = CREATE_IMG(@"user_head@2x");
    layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH * upImg.size.height / upImg.size.width);
    [self createCollectionViewLayout:layout Action:nil Param:nil Header:NO Foot:NO];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:UserInfoCellId];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UserInfoHeaderId];
}

#pragma mark - 初始化数据源
- (void)makeAllModules
{
    self.allModules = [NSMutableArray array];
    
    NSArray *titles = @[@"客户",@"书柜",@"故事汇",@"消息",@"优惠券",@"订单",@"收货地址",@"活动"];
    NSArray *imgs = @[@"user_customer",@"user_bookcase",@"user_story",@"user_msg",@"user_couponimg",@"user_order",@"user_address",@"user_activity"];
    for (NSInteger i = 0; i < kModuleMore; i++) {
        ModuleUserInfo *module = [[ModuleUserInfo alloc] init];
        module.moduleName = titles[i];
        module.moduleType = (kModuleUserType)i;
        module.imgName = imgs[i];
        [_allModules addObject:module];
    }
}

- (void)titleAction:(id)sender
{
    GrowAlertView *alertView = [[GrowAlertView alloc] initWithFrame:self.view.window.bounds];
    alertView.delegate = self;
    alertView.titleLabel.text = @"修改昵称：";
    [alertView setDefaultTheme:[self.titleButton.titleLabel text]];
    [self.view.window addSubview:alertView];
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

#pragma mark - appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    _navBarHairlineImageView.hidden = YES;
    [self.navigationController.navigationBar cnSetBackgroundColor:[UIColor clearColor]];
    
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
    [self.titleButton setTitle:detailInfo ? detailInfo.user.name : @"" forState:UIControlStateNormal];
    
    if (detailInfo) {
        [self getUserInfo];
    }
    
    if (detailInfo && detailInfo.isDealer.integerValue == 1) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [_allModules count]; i++) {
            ModuleUserInfo *module = [_allModules objectAtIndex:i];
            if (module.moduleType == kModuleBookcase || module.moduleType == kModuleOrder || module.moduleType == kModuleMsg || module.moduleType == kModuleMore) {
                continue;
            }

            [array addObject:module];
        }
        self.dataSource = [NSMutableArray arrayWithArray:array];
    }
    else{
        self.dataSource = [NSMutableArray arrayWithObjects:_allModules[kModuleBookcase],_allModules[kModuleStory],_allModules[kModuleOrder],_allModules[kModuleActivity],_allModules[kModuleCouponimg],_allModules[kModuleAddress], nil];
    }
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _navBarHairlineImageView.hidden = NO;
    [self.navigationController.navigationBar cnReset];
}

#pragma mark - 获取用户信息
- (void)getUserInfo
{
    if (self.sessionTask) {
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"userInfo"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"user"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf userInfoFinish:error Data:data];
        });
    }];
}

- (void)userInfoFinish:(NSError *)error Data:(id)data{
    self.sessionTask = nil;
    if (error == nil) {
        id ret_data = [data valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSDictionary class]]) {
            UserDetailInfo *detail = [GlobalManager shareInstance].detailInfo;
            if (detail && detail.userInfo && [detail.userInfo isEqualToDictionary:ret_data]) {
                return;
            }
            detail.userInfo = ret_data;
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - actions
- (void)createRightBarButton
{
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 20 + 30, 21 + 10)];
    [rightBut setImage:CREATE_IMG(@"set_setting") forState:UIControlStateNormal];
    [rightBut setImageEdgeInsets:UIEdgeInsetsMake(5, 25, 5, 5)];
    [rightBut addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    [self.navigationItem setRightBarButtonItems:@[rightItem] animated:YES];
    
    if ([self.navigationItem.leftBarButtonItems count] == 2) {
        return;
    }
    UIView *leftView = [[UIView alloc] initWithFrame:rightBut.bounds];
    [leftView setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItems = @[leftItem];
}

- (void)settingAction:(id)sender
{
    SettingViewController *controller = [[SettingViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)uploadFaceImage:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    [sheet showInView:self.view];
}

#pragma mark - 头像上传
- (void)uploadImg:(UIImage *)image
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
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
                [weakSelf.view hideToastActivity];
                weakSelf.view.userInteractionEnabled = YES;
                [weakSelf.view makeToast:@"图片上传失败" duration:1.0 position:@"center"];
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
                    [weakSelf uploadImgRequest:path Name:nil];
                }else {
                    [weakSelf.view hideToastActivity];
                    weakSelf.view.userInteractionEnabled = YES;
                    [weakSelf.view makeToast:@"图片上传失败" duration:1.0 position:@"center"];
                }
            }
            weakSelf.sessionTask = nil;
        });
    } progressBlock:^(NSProgress *progress) {
        
    }];
}

- (void)uploadImgRequest:(NSString *)imagePath Name:(NSString *)name
{
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

- (void)uploadFaceImageFinish:(NSError *)error Data:(id)data{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [data valueForKey:@"ret_data"];
        if ([[ret_data valueForKey:@"head_img"] length] > 0) {
            [GlobalManager shareInstance].detailInfo.user.head_img = [ret_data valueForKey:@"head_img"];
        }
        
        if ([[ret_data valueForKey:@"name"] length] > 0) {
            [self.titleButton setTitle:[ret_data valueForKey:@"name"] forState:UIControlStateNormal];
            [GlobalManager shareInstance].detailInfo.user.name = [ret_data valueForKey:@"name"];
        }
        [self.collectionView reloadData];
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
            picker.delegate = self;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }
            break;
            
        default:
            break;
    }
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image fixOrientation];
    
    ImageCropViewController *controller = [[ImageCropViewController alloc] init];
    controller.originImage = image;
    controller.delegate = self;
    [picker pushViewController:controller animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ImageCropViewController delegate
-(void)ImageCropVC:(ImageCropViewController*)ivc CroppedImage:(UIImage *)image
{
    if (image) {
        [self uploadImg:image];
    }
    [ivc.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:UserInfoCellId forIndexPath:indexPath];
    UIView *rightLineView = [cell.contentView viewWithTag:3];
    if (!rightLineView) {
        //right
        rightLineView = [[UIView alloc] init];
        [rightLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [rightLineView setTag:3];
        [rightLineView setBackgroundColor:rgba(237, 237, 239, 1)];
        [cell.contentView addSubview:rightLineView];
        [rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView.mas_right);
            make.top.equalTo(cell.contentView.mas_top);
            make.width.equalTo(@(1));
            make.height.equalTo(cell.contentView.mas_height);
        }];
        
        //bottom
        UIView *bottomView = [[UIView alloc] init];
        [bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [bottomView setBackgroundColor:rightLineView.backgroundColor];
        [cell.contentView addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView.mas_left);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(cell.contentView.mas_width);
            make.height.equalTo(@(1));
        }];
        
        //
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageView setTag:1];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell.contentView.mas_centerX);
            make.centerY.equalTo(cell.contentView.mas_centerY).with.offset(-11.5);
            make.width.equalTo(@(30));
            make.height.equalTo(@(30));
        }];
        
        //uilael
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextColor:rgba(86, 86, 86, 1)];
        [label setTag:2];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell.contentView.mas_centerX);
            make.top.equalTo(cell.contentView.mas_centerY).with.offset(7);
            make.width.equalTo(@(50));
            make.height.equalTo(@(16));
        }];
    }
    
    rightLineView.hidden = ((indexPath.item % 3) == 2);
    
    ModuleUserInfo *module = self.dataSource[indexPath.item];
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:2];
    [imageView setImage:CREATE_IMG(module.imgName)];
    [label setText:module.moduleName];
    if (module.moduleType == kModuleMore) {
        label.hidden = YES;
        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView.mas_centerY);
        }];
    }
    else{
        label.hidden = NO;
        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView.mas_centerY).with.offset(-11.5);
        }];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ModuleUserInfo *module = self.dataSource[indexPath.item];
    switch (module.moduleType) {
        case kModuleCustomer:
        {
            NSArray *titles = @[@"全部",@"待制作",@"待付款",@"打印中",@"待收货"];
            YWCMainViewController *mainVc = [YWCMainViewController new];
            mainVc.titleLable.text = @"客户列表";
            mainVc.rightItemType = YES;
            for (int i = 0; i < [titles count]; i++) {
                CustomerListViewController *customerList = [CustomerListViewController new];
                customerList.status = i;
                YWCTitleVCModel *titleCustomer = [[YWCTitleVCModel alloc] init];
                titleCustomer.title = titles[i];
                titleCustomer.viewController = customerList;
                [mainVc.titleVcModelArray addObject:titleCustomer];
            }
            mainVc.initIdx = 0;
            mainVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mainVc animated:YES];
        }
            break;
        case kModuleBookcase:
        {
            MyPortfolioViewController *viewController = [MyPortfolioViewController new];
            [viewController setShowBack:YES];
            [viewController.titleLable setText:@"我的作品"];
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case kModuleStory:
        {
            [self.view makeToast:@"精彩即将开始,敬请期待" duration:1.0 position:@"center"];
        }
            break;
        case kModuleMsg:
        {
            MyMessageViewController *msg = [[MyMessageViewController alloc] init];
            msg.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:msg animated:YES];
        }
            break;
        case kModuleCouponimg:
        {
            NSArray *titles=@[@"未使用",@"已使用",@"已过期"];
            YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
            mainVc.titleLable.text = @"优惠券";
            for (NSInteger i = 0; i < titles.count; i++) {
                YWCTitleVCModel *titleVcModel = [[YWCTitleVCModel alloc] init];
                titleVcModel.title = [titles objectAtIndex:i];
                
                CouponViewController *coupon = [[CouponViewController alloc] init];
                coupon.status = @(i + 1);
                titleVcModel.viewController = coupon;
                [mainVc.titleVcModelArray addObject:titleVcModel];
            }
            mainVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mainVc animated:YES];
        }
            break;
        case kModuleOrder:
        {
            PreviewWebViewController *order = [[PreviewWebViewController alloc] init];
            order.url = [NSString stringWithFormat:@"http://mall.goonbaby.com/moblie/times/print?user_id=%@&type=order",[GlobalManager shareInstance].detailInfo.user.id];
            order.recordItem = [TimeRecordModel new];
            order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:order animated:YES];
        }
            break;
        case kModuleAddress:
        {
            PreviewWebViewController *order = [[PreviewWebViewController alloc] init];
            order.url = [NSString stringWithFormat:@"http://mall.goonbaby.com/moblie/times/print?user_id=%@&type=address",[GlobalManager shareInstance].detailInfo.user.id];
            order.recordItem = [TimeRecordModel new];
            order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:order animated:YES];
        }
            break;
        case kModuleActivity:
        {
            YWCMainViewController *mainVc = [[YWCMainViewController alloc]init];
            mainVc.titleLable.text = @"活动";
            NSArray *titles = @[@"我参加的活动",@"所有活动"];
            for (NSInteger i = 0; i < titles.count; i++) {
                YWCTitleVCModel *titleVcModel = [[YWCTitleVCModel alloc] init];
                titleVcModel.title = [titles objectAtIndex:i];
                
                ActivityViewController *activity = [[ActivityViewController alloc] init];
                activity.indexType = i + 1;
                titleVcModel.viewController = activity;
                [mainVc.titleVcModelArray addObject:titleVcModel];
            }
            mainVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mainVc animated:YES];
        }
            break;
        case kModuleMore:
        {
            
        }
            break;
        default:
            break;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
}

- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UserInfoHeaderId forIndexPath:indexPath];
        
        UIImageView *headImg = (UIImageView *)[view viewWithTag:1];
        if (!headImg) {
            UIImageView *backImg = [[UIImageView alloc] init];
            [backImg setTranslatesAutoresizingMaskIntoConstraints:NO];
            [backImg setImage:CREATE_IMG(@"user_head@2x")];
            [view addSubview:backImg];
            [backImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            
            //head
            headImg = [[UIImageView alloc] init];
            [headImg setTranslatesAutoresizingMaskIntoConstraints:NO];
            [headImg.layer setMasksToBounds:YES];
            headImg.layer.cornerRadius = 39 * SCREEN_WIDTH / 375.0;
            [headImg setBackgroundColor:[UIColor clearColor]];
            [headImg setTag:1];
            [headImg setUserInteractionEnabled:YES];
            [headImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadFaceImage:)]];
            [view addSubview:headImg];
            [headImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(view.mas_centerX);
                make.centerY.equalTo(view.mas_centerY);
                make.width.equalTo(@(78 * SCREEN_WIDTH / 375.0));
                make.height.equalTo(@(78 * SCREEN_WIDTH / 375.0));
            }];
            
            
            UIFont *font = [UIFont systemFontOfSize:12];
            UILabel *tipLabel = [[UILabel alloc] init];
            [tipLabel setBackgroundColor:[UIColor clearColor]];
            [tipLabel setTextColor:[UIColor whiteColor]];
            [tipLabel setFont:font];
            [tipLabel setTextAlignment:NSTextAlignmentCenter];
            [tipLabel setTag:111];
            [tipLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [view addSubview:tipLabel];
            [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(headImg.mas_bottom).with.offset(10 * SCREEN_WIDTH / 375.0);
                make.centerX.equalTo(view.mas_centerX);
                make.width.equalTo(@(SCREEN_WIDTH - 100));
                make.height.equalTo(@(16 * SCREEN_WIDTH / 375.0));
            }];
            
            //alpha
            UIView *alphaView = [[UIView alloc] init];
            [alphaView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [alphaView setBackgroundColor:rgba(0, 0, 0, 0.1)];
            [view addSubview:alphaView];
            [alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(view.mas_left);
                make.right.equalTo(view.mas_right);
                make.bottom.equalTo(view.mas_bottom);
                make.height.equalTo(@(44 * SCREEN_WIDTH / 375.0));
            }];
            
            //
            NSArray *tips = @[@"欣赏",@"观众",@"积分"];
            for (NSInteger i = 0; i < 3; i++) {
                UILabel *upLab = [[UILabel alloc] init];
                [upLab setTranslatesAutoresizingMaskIntoConstraints:NO];
                [upLab setFont:font];
                [upLab setTextAlignment:NSTextAlignmentCenter];
                [upLab setTextColor:[UIColor whiteColor]];
                [upLab setTag:120 + i];
                [view addSubview:upLab];
                if (i == 0) {
                    [upLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(alphaView.mas_top).with.offset(6);
                        make.left.equalTo(@(0));
                        make.width.equalTo(alphaView.mas_width).with.multipliedBy(1.0 / 3);
                        make.height.equalTo(@(16 * SCREEN_WIDTH / 375.0));
                    }];
                }
                else if (i == 1){
                    [upLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(alphaView.mas_top).with.offset(6 * SCREEN_WIDTH / 375.0);
                        make.centerX.equalTo(view.mas_centerX);
                        make.width.equalTo(alphaView.mas_width).with.multipliedBy(1.0 / 3);
                        make.height.equalTo(@(16 * SCREEN_WIDTH / 375.0));
                    }];
                }
                else{
                    [upLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(alphaView.mas_top).with.offset(6 * SCREEN_WIDTH / 375.0);
                        make.right.equalTo(@(0));
                        make.width.equalTo(alphaView.mas_width).with.multipliedBy(1.0 / 3);
                        make.height.equalTo(@(16 * SCREEN_WIDTH / 375.0));
                    }];
                }
                
                //down
                UILabel *downLab = [[UILabel alloc] init];
                [downLab setTranslatesAutoresizingMaskIntoConstraints:NO];
                [downLab setFont:font];
                [downLab setTextAlignment:NSTextAlignmentCenter];
                [downLab setTextColor:[UIColor whiteColor]];
                [downLab setText:tips[i]];
                [view addSubview:downLab];
                [downLab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(upLab.mas_left);
                    make.top.equalTo(upLab.mas_bottom);
                    make.width.equalTo(upLab.mas_width);
                    make.height.equalTo(upLab.mas_height);
                }];
            }
        }
        
        UILabel *tipLab = (UILabel *)[view viewWithTag:111];
        //text
        NSDictionary *dic = nil;
        UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
        if (detailInfo && detailInfo.userInfo) {
            dic = detailInfo.userInfo;
        }
        NSString *str = [NSString stringWithFormat:@"被赞*%ld 被评价*%ld 已用%0.1fG",(long)[[dic valueForKey:@"praiseNum"] integerValue],(long)[[dic valueForKey:@"commentNum"] integerValue],[[dic valueForKey:@"fileSize"] floatValue] / 1024];
        for (SysConfigModel *model in [GlobalManager shareInstance].systemConfig) {
            if ([model.type integerValue] == 2 && [model.data length] > 0) {
                str = [str stringByAppendingFormat:@"/共%@G",model.data];
                break;
            }
        }
        [tipLab setText:str];
        
        NSString *url = detailInfo.user.head_img;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        [headImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:CREATE_IMG(@"loginLogo")];
        
        NSInteger total_view_nums = [[dic valueForKey:@"total_view_nums"] integerValue],total_view_users = [[dic valueForKey:@"total_view_users"] integerValue],coin_num = [[dic valueForKey:@"coin_num"] integerValue];
        for (NSInteger i = 0; i < 3; i++) {
            UILabel *upLab = (UILabel *)[view viewWithTag:120 + i];
            if (i == 0) {
                [upLab setText:[[NSNumber numberWithInteger:total_view_nums] stringValue]];
            }
            else if (i == 1)
            {
                [upLab setText:[[NSNumber numberWithInteger:total_view_users] stringValue]];
            }
            else{
                [upLab setText:[[NSNumber numberWithInteger:coin_num] stringValue]];
            }
        }
        
        return view;
    }
    
    return nil;
}

@end
