//
//  BatchMakeViewController.m
//  TYSociety
//
//  Created by szl on 16/7/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BatchMakeViewController.h"
#import "TimeRecordInfo.h"
#import "Masonry.h"
#import "JSCarouselLayout.h"
#import "BatchMakeCell.h"
#import "BatchMakeUIService.h"
#import "DataBaseOperation.h"
#import "BatchDetailViewController.h"
#import "HomePageUserController.h"
#import "HomePageViewController.h"
#import "CSStickyHeaderFlowLayout.h"
#import "RMPZoomTransitionAnimator.h"
#import "PreviewWebViewController.h"
#import "DJTOrderViewController.h"
#import "CustomerListViewController.h"
#import "YWCMainViewController.h"
#import "ProgressCircleView.h"
#import "DecoTextView.h"
#import "HomePageUserController.h"

#define COLLECTIONCELLID    @"batchCellId"

@interface BatchMakeViewController ()<BatchMakeCellDelegate,FastMakeCellDelegate,PhotoManagerUploadDelegate,BatchDetailViewControllerDelegate,RMPZoomTransitionAnimating,UIActionSheetDelegate,PreviewWebViewControllerDelegate>

@property (nonatomic, strong) UICollectionView    *carouselCollectionView;
@property (nonatomic, strong) UICollectionView *downCollectinView;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, assign) NSInteger curIdx;
@property (nonatomic, strong) NSMutableArray *selectData;   //包含数组，子数组中又包含图片框的数组
@property (nonatomic, strong) NSMutableArray *uploadArr;
@property (nonatomic, strong) NSMutableArray *commitArr;
@property (nonatomic, strong) BatchMakeUIService *service;
@property (nonatomic, assign) BOOL fullShow;
@property (nonatomic, assign) CGSize fullSize;
@property (nonatomic, assign) CGSize halfSize;
@property (nonatomic, strong) NSString *printUrl;
@property (nonatomic, strong) UIView *failTipView;
@property (nonatomic, strong) ProgressCircleView *circleView;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger curentCount;
@property (nonatomic, assign) BOOL isDoublePage;
//@property (nonatomic, assign) NSInteger requestCount;

@end

@implementation BatchMakeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    [self.titleLable setText:@"制作"];

    //导航
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = CreateColor(235, 233, 247);
    
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundSaveSqlite:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.fullShow = YES;
    self.uploadArr = [NSMutableArray array];
    self.commitArr = [NSMutableArray array];
    self.selectData = [NSMutableArray array];
    //下边图片选择器
    [self.view addSubview:self.downCollectinView];
    self.downCollectinView.hidden = YES;
    [self.view sendSubviewToBack:self.downCollectinView];
    [self beginSelectDataBase];
    
    if (_recordInfo) {
        self.isDoublePage = (_recordInfo.is_double.integerValue == 1);
        [self createUpCollectionView];
    }
    else{
        //网络
        [self getAllTemplateInfo];
    }
    
}

#pragma mark - UI
- (void)createRightBarButton
{
    UIView *lastView = [[self.navigationItem.rightBarButtonItems lastObject] customView];
    if ([lastView isKindOfClass:[UIButton class]]) {
        return;
    }
    
    UIButton *leftBut = (UIButton *)[[self.navigationItem.leftBarButtonItems lastObject] customView];
    UIFont *font = [UIFont systemFontOfSize:14];
    NSString *tipStr = @"保存/分享";
    CGSize size = [NSString calculeteSizeBy:tipStr Font:font MaxWei:SCREEN_WIDTH];
    [leftBut setFrameWidth:size.width];
    [leftBut setImageEdgeInsets:UIEdgeInsetsMake(6.5, 0, 6.5, size.width - 10)];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, size.width, size.height)];
    [rightBut setTitle:tipStr forState:UIControlStateNormal];
    [rightBut setTitleColor:rgba(254, 254, 254, 1) forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(saveShare:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut.titleLabel setFont:font];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
}

- (void)beginSelectDataBase
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *albums = [[DataBaseOperation shareInstance] selectNetAndLocalAlbum:[GlobalManager shareInstance].detailInfo.user.id];
        NSMutableArray *cusArr = [NSMutableArray array];
        for (NSInteger i = 0; i < albums.count; i++) {
            PhotoManagerModel *model = [albums objectAtIndex:i];
            if (model.file_type.integerValue == 3) {
                //过滤掉语音
                continue;
            }
            
            model.delegate = weakSelf;
            
            NSMutableArray *lstArr = [cusArr lastObject];
            if (!lstArr) {
                lstArr = [NSMutableArray arrayWithObject:model];
                [cusArr addObject:lstArr];
            }
            else{
                PhotoManagerModel *lstModel = [lstArr lastObject];
                NSDate *lstDate = [NSDate dateWithTimeIntervalSince1970:lstModel.shooting_time.doubleValue];
                NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:model.shooting_time.doubleValue];
                NSString* lstStr = [NSString stringByDate:@"yyyyMMdd" Date:lstDate];
                NSString* curStr = [NSString stringByDate:@"yyyyMMdd" Date:curDate];
                if ([lstStr isEqualToString:curStr]) {
                    [lstArr addObject:model];
                }
                else{
                    [cusArr addObject:[NSMutableArray arrayWithObject:model]];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.service.dataSource = cusArr;
            [weakSelf.downCollectinView reloadData];
        });
    });
}

- (void)changeUpCollectionFrame
{
    _fullShow = !_fullShow;
    CGRect newRec = CGRectMake(0, 0, SCREEN_WIDTH, _fullShow ? (SCREEN_HEIGHT - 64) : (SCREEN_HEIGHT - 64) / 2);
    
    BatchMakeCell *makeCell = (BatchMakeCell *)[_carouselCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_curIdx inSection:0]];
    CGRect preRect = !_fullShow ? CGRectMake(20, (SCREEN_HEIGHT - _fullSize.height - 64) / 2, _fullSize.width, _fullSize.height) : CGRectMake((SCREEN_WIDTH - _halfSize.width) / 2, 10, _halfSize.width, _halfSize.height);
    CGRect lastRect = _fullShow ? CGRectMake(20, (SCREEN_HEIGHT - _fullSize.height - 64) / 2, _fullSize.width, _fullSize.height) : CGRectMake((SCREEN_WIDTH - _halfSize.width) / 2, 10, _halfSize.width, _halfSize.height);
    UIImageView *tempImg = [[UIImageView alloc] initWithFrame:preRect];
    tempImg.backgroundColor = _carouselCollectionView.backgroundColor;
    [tempImg setImage:makeCell.contentImg.image];
    [self.view addSubview:tempImg];
    
    CGSize itemSize = _fullShow ? _fullSize : _halfSize;
    self.navigationController.view.userInteractionEnabled = NO;
    _carouselCollectionView.hidden = YES;
    NSNumber *atNum = [NSNumber numberWithInteger:makeCell.nSelectIdx];
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        [tempImg setFrame:lastRect];
    } completion:^(BOOL finished) {
        [tempImg removeFromSuperview];
        
        [weakSelf.carouselCollectionView setFrame:newRec];
        JSCarouselLayout *layout = (JSCarouselLayout *)weakSelf.carouselCollectionView.collectionViewLayout;
        layout.itemSize = itemSize;
        [weakSelf.carouselCollectionView reloadData];
        [weakSelf.carouselCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:weakSelf.curIdx inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        weakSelf.carouselCollectionView.hidden = NO;
        weakSelf.navigationController.view.userInteractionEnabled = YES;
        if (!weakSelf.fullShow) {
            [weakSelf performSelector:@selector(resetCellSelectedState:) withObject:atNum afterDelay:0.1];
        }
    }];
}

- (void)scaleTohalfSize
{
    _fullShow = NO;
    CGRect newRec = CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_HEIGHT - 64) / 2);
    CGSize itemSize = _halfSize;
    [_carouselCollectionView setFrame:newRec];
    JSCarouselLayout *layout = (JSCarouselLayout *)_carouselCollectionView.collectionViewLayout;
    layout.itemSize = itemSize;
    [_carouselCollectionView reloadData];
    [_carouselCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_curIdx inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)resetCellSelectedState:(NSNumber *)number
{
    BatchMakeCell *makeCell = (BatchMakeCell *)[_carouselCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_curIdx inSection:0]];
    [makeCell selectButtonAt:number.integerValue];
    [self resetVisibleCells];
}

- (void)createUpCollectionView
{
    RecordTemplate *firstRecord = [_recordInfo.template firstObject];
    CGFloat hei = ((SCREEN_HEIGHT - 64) / 2 - 20),wei = firstRecord.original_width.floatValue * hei / firstRecord.original_height.floatValue;
    if (wei > SCREEN_WIDTH - 20) {
        wei = SCREEN_WIDTH - 20;
        hei = firstRecord.original_height.floatValue * wei / firstRecord.original_width.floatValue;
    }
    self.halfSize = CGSizeMake(wei, hei);
    wei = SCREEN_WIDTH - 40,hei = firstRecord.original_height.floatValue * wei / firstRecord.original_width.floatValue;
    self.fullSize = CGSizeMake(wei, hei);
    
    BOOL canCommit = YES;
    RecordTemplate *firstTem = [_recordInfo.template firstObject];
    DataBaseOperation *operation = [DataBaseOperation shareInstance];
    NSMutableArray *sqlArr = [operation checkTemplateInfo:[RecordTemplate selectAllTemplateSql:firstTem.user_grow_id]];
    __weak typeof(self)weakSelf = self;
    for (NSInteger i = 0; i < _recordInfo.template.count; i++) {
        RecordTemplate *template = _recordInfo.template[i];
        
        //图片框数组
        NSMutableArray *tmpArr = [NSMutableArray array];
        for (NSInteger m = 0; m < [template.detail_content.image_coor count]; m++) {
            [tmpArr addObject:[NSMutableArray array]];
        }
        [_selectData addObject:tmpArr];
        
        //语句块设置
        template.uploadBlock = ^(RecordTemplate *recordPlate){
            [weakSelf uploadTemplateEnd:recordPlate];
        };
        
        //数据库中是否有该模板数据，有责以数据库为准
        BOOL dataFound = NO;
        for (NSArray *subArr in sqlArr) {
            NSString *detail_id = subArr[1];
            if ([template.id isEqualToString:detail_id]) {
                //数据库中找到匹配，替换，提交
                dataFound = YES;
                [sqlArr removeObject:subArr];
                [template resetCustomParam:subArr];
                @synchronized (_commitArr) {
                    if (![_commitArr containsObject:template]) {
                        [_commitArr addObject:template];
                    }
                }
                break;
            }
        }
        
        //数据库中能查到
        if (!dataFound) {
            //模板信息初始化，用于对比后面是否有更新
            template.customParam = [self convertToCustomParater:i];
            if (canCommit) {
                canCommit = [template isFinishedCommit];
            }
            //未发布，提交封面与封底
            if ((_recordInfo.is_public.integerValue != 2) && ([template.detail_content.image_coor count] == 0) && ([template.detail_content.word_coor count] == 0)) {
                //封面或封底
                @synchronized (_commitArr) {
                    if (![_commitArr containsObject:template]) {
                        [_commitArr addObject:template];
                    }
                    [template startUploadChangeInfo];
                }
            }
        }
    }
    if (canCommit) {
        [self createRightBarButton];
    }
    
    //删除多余的数据，以免影响判断
    for (NSArray *subArr in sqlArr) {
        NSString *record_id = subArr[1];
        [operation resetTemplateInfo:[RecordTemplate deleteTemplateSqlBy:record_id]];
    }
    
    //模板滑动页
    [self.view addSubview:self.carouselCollectionView];
    
    //索引标签
    [self.view addSubview:self.indexLabel];
    self.downCollectinView.hidden = NO;
}

#pragma mark - 判断是否显示分享按钮
- (void)resetButtonShow
{
    //按钮已显示
    UIView *lastView = [[self.navigationItem.rightBarButtonItems lastObject] customView];
    if ([lastView isKindOfClass:[UIButton class]]) {
        return;
    }
    
    BOOL hasAllFinish = YES;
    for (RecordTemplate *template in _recordInfo.template) {
        if (![template isFinishedCommit]) {
            hasAllFinish = NO;
            break;
        }
    }
    
    if (hasAllFinish) {
        [self createRightBarButton];
    }
}

- (void)resetButtonShowOutOf:(RecordTemplate *)tem
{
    //按钮已显示
    UIView *lastView = [[self.navigationItem.rightBarButtonItems lastObject] customView];
    if ([lastView isKindOfClass:[UIButton class]]) {
        return;
    }
    
    BOOL hasAllFinish = YES;
    for (RecordTemplate *template in _recordInfo.template) {
        if (template == tem) {
            //当前页面不判断
            continue;
        }
        if (![template isFinishedCommit]) {
            hasAllFinish = NO;
            break;
        }
    }
    
    if (hasAllFinish) {
        [self createRightBarButton];
    }
}

#pragma mark - 上传结果反馈
- (void)uploadTemplateEnd:(RecordTemplate *)template
{
    //上传成功则删除
    if (template.uploadEnd.integerValue == 1) {
        @synchronized (_commitArr) {
            [_commitArr removeObject:template];
        }
    }
    
    if (!_circleView) {
        return;
    }
    
    _curentCount++;
    if (_curentCount >= _totalCount) {
        [_circleView removeFromSuperview];
        _circleView = nil;
        
        self.view.userInteractionEnabled = YES;
        UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
        rightItem.enabled = YES;
        
        @synchronized (_commitArr) {
            if ([_commitArr count] > 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"您有%ld张模板数据提交失败",(long)[_commitArr count]] delegate:self cancelButtonTitle:@"取消上传" otherButtonTitles:@"继续上传", nil];
                [alert show];
            }
            else{
                _totalCount = 0,_curentCount = 0;
                //[self popPrintItems];
                [self beginPublicInfo];
            }
        }
    }
    else{
        [_circleView.loadingIndicator setProgress:(((CGFloat)_curentCount) / _totalCount) animated:YES];
    }
}

#pragma mark - notification
- (void)backgroundSaveSqlite:(NSNotification *)notifi
{
    //进入后台
    [self commitPreData:_curIdx To:NSNotFound];
}

#pragma mark - actions
- (void)saveShare:(id)sender
{
    //先对当前页面数据处理
    [self commitPreData:_curIdx To:NSNotFound];
    
    @synchronized (_commitArr) {
        if ([_commitArr count] > 0) {
            self.view.userInteractionEnabled = NO;
            UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
            rightItem.enabled = NO;
            _totalCount = [_commitArr count];
            _curentCount = 0;
            for (RecordTemplate *tem in _commitArr) {
                if (!tem.sessionTask && tem.uploadEnd.integerValue == 2) {
                    //上传失败，且没有在上传
                    [tem startUploadChangeInfo];
                }
            }
            
            [self.view addSubview:self.circleView];
        }
        else{
            //[self popPrintItems];
            [self beginPublicInfo];
        }
    }
}

- (void)blowUpTemplate:(NSInteger)idx
{
    self.navigationController.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    @try {
        RecordTemplate *template = [_recordInfo.template objectAtIndex:_curIdx];
        NSString *url = template.template_image_url;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
        if (width.floatValue < template.image_width.floatValue) {
            url = [NSString getPictureAddress:@"2" width:width height:@"0" original:url];
        }
        [manager downloadImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf downImgFinish:(error == nil) ? image : nil At:idx];
            });
        }];
    } @catch (NSException *e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf downImgFinish:nil At:idx];
        });
    }
}

- (void)downImgFinish:(UIImage *)img At:(NSInteger)idx
{
    [self.view hideToastActivity];
    if (img == nil) {
        self.navigationController.view.userInteractionEnabled = YES;
        [self.view makeToast:@"模板下载出错啦，请稍候重试" duration:1.0 position:@"center"];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        RecordTemplate *template = [_recordInfo.template objectAtIndex:_curIdx];
        CGSize imgSize = CGSizeMake(template.image_width.floatValue, template.image_height.floatValue);
        CGFloat maxHei = winSize.height - 20;
        CGFloat fRate = MIN((winSize.width - 20) / imgSize.width, maxHei / imgSize.height);
        CGFloat newMaxHei = winSize.height - 44 - 140 - 49;
        CGFloat newRate = MIN(winSize.width / imgSize.width, newMaxHei / imgSize.height);
        CGFloat imgWei = imgSize.width * fRate;
        CGFloat imgHei = imgSize.height * fRate;
        CGRect lstRect = CGRectMake((winSize.width - imgWei) / 2, (winSize.height - imgHei) / 2, imgWei, imgHei);

        self.navigationController.view.userInteractionEnabled = YES;
        BatchDetailViewController *detail = [[BatchDetailViewController alloc] init];
        detail.recordTemplate = [_recordInfo.template objectAtIndex:_curIdx];
        detail.templateImg = img;
        detail.templateSize = lstRect.size;
        detail.fRate = fRate;
        detail.newRate = newRate;
        detail.localArr = [_selectData objectAtIndex:_curIdx];
        detail.delegate = self;
        detail.initIdx = idx;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)popPrintItems
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"继续编辑",@"打印", nil];
    [sheet showInView:self.view];
}

- (void)backToPreControl:(id)sender
{
    if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue != 1) {
        [[GlobalManager shareInstance] requestMyProfiles];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:RefreshCustomer object:nil];
    }
    if (!_recordInfo) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    //sdwebimg清除缓存
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    //提交当前页，如果有修改
    [self commitPreData:_curIdx To:NSNotFound];
    
    NSInteger count = [self.navigationController.viewControllers count];
    for (NSInteger i = 0; i < count; i++) {
        UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:i];
        if ([controller isKindOfClass:[YWCMainViewController class]]) {
            for (id list in ((YWCMainViewController *)controller).childViewControllers) {
                if ([list isKindOfClass:[CustomerListViewController class]]) {
                    if (((CustomerListViewController *)list).isViewLoaded) {
                        [((CustomerListViewController *)list) beginRefresh];
                    }
                }
            }
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    if ([self.navigationController.viewControllers count] > 2) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
    else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)tryAgainRequest:(id)sender
{
    [_failTipView removeFromSuperview];
    _failTipView = nil;
    [self getAllTemplateInfo];
}

#pragma mark - PreviewWebViewController delegate
- (void)reloadToCustomerList:(CustomerModel *)item Idx:(NSInteger)idx
{
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[HomePageUserController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _totalCount = 0;
    _curentCount = 0;
    if (buttonIndex == 1) {
        if (alertView.tag == 10) {
            RecordTemplate *model = [_recordInfo.template firstObject];
            
            TimeRecordModel *item = [[TimeRecordModel alloc] init];
            item.grow_id = model.user_grow_id;
            item.user_id = _user_id;
            item.batch_id = _batch_id;
            item.is_double = (_halfSize.width > _halfSize.height) ? @"1" : @"0";
            item.finish_num = [NSNumber numberWithInteger:[_recordInfo.template count]];
            item.detail_num = [NSNumber numberWithInteger:[_recordInfo.template count]];
            
            PreviewWebViewController *preview = [[PreviewWebViewController alloc] init];
            preview.url = [G_PLAYER_ADDRESS stringByAppendingString:[NSString stringWithFormat:@"book/b%@.htm",model.user_grow_id]];
            preview.recordItem = item;
            preview.delegate = self;
            preview.isLandscape = ([item.is_double integerValue] == 1);
            [self.navigationController pushViewController:preview animated:YES];
            /*
            if ([item.is_double integerValue] == 1) {
                preview.isLandscape = YES;
                [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:preview] animated:YES completion:nil];
            }
            else {
                [self.navigationController pushViewController:preview animated:YES];
            }
             */
        }
        else{
            self.view.userInteractionEnabled = NO;
            UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
            rightItem.enabled = NO;
            
            _totalCount = [_commitArr count];
            
            for (RecordTemplate *tem in _commitArr) {
                if (!tem.sessionTask && tem.uploadEnd.integerValue == 2) {
                    //上传失败，且没有在上传
                    [tem startUploadChangeInfo];
                }
            }
            
            [self.view addSubview:self.circleView];
        }
    }
    else if (buttonIndex == 0)
    {
        if (alertView.tag == 300) {
            NSInteger count = [self.navigationController.viewControllers count];
            for (NSInteger i = 0; i < count; i++) {
                UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:i];
                if ([controller isKindOfClass:[YWCMainViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                    return;
                }
            }
            if ([self.navigationController.viewControllers count] > 2) {
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
            }
            else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"编辑");
        }
            break;
        case 1:
        {
            if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue == 1) {
                [self submitOrder];
            }else {
                [self getPrintInfo];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 模板数据
- (void)getAllTemplateInfo
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    self.silentAnimation = YES;
    GlobalManager *manager = [GlobalManager shareInstance];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"templateSet"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getUserTemplate"];
    [param setObject:_batch_id forKey:@"batch_id"];
    [param setObject:_user_id forKey:@"user_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf checkTemplateFinish:error Data:data];
        });
    }];
}

- (void)checkTemplateFinish:(NSError *)error Data:(id)result
{
    [self stopAnimation];
    self.sessionTask = nil;
    if (error) {
        [self.navigationController.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [result valueForKey:@"ret_data"];
        TimeRecordInfo *info = [[TimeRecordInfo alloc] initWithDictionary:ret_data error:nil];
//        if (info.is_public.integerValue == 1) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的该套成长档案模板正在制作中，请稍候再试" delegate:self cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
//            alert.tag = 300;
//            [alert show];
//            return;
//        }
        if (!info || [info.template count] == 0) {
            [self.view addSubview:self.failTipView];
            [self.failTipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view.mas_centerX);
                make.centerY.equalTo(self.view.mas_centerY);
                make.width.equalTo(@(65));
                make.height.equalTo(@(100));
            }];
        }
        else{
            for (RecordTemplate *template in info.template) {
                NSMutableArray *image_path = template.production_parameter.image_path;
                for (NSInteger i = 0;i < [template.production_parameter.src_gallery_list count];i++) {
                    NSArray *subArr = template.production_parameter.src_gallery_list[i];
                    NSMutableArray *gallerys = [ProductImageGallery arrayOfModelsFromDictionaries:subArr error:nil];
                    [template.production_parameter.src_gallery_list replaceObjectAtIndex:i withObject:gallerys];
                    
                    //避免封面没有宽高数据
                    if ([image_path count] > i) {
                        ProductImagePath *proPath = [image_path objectAtIndex:i];
                        BOOL found = NO;
                        if (proPath.image_url.length > 0) {
                            if (!proPath.original_width || !proPath.original_height) {
                                for (ProductImageGallery *gallery in gallerys) {
                                    if ([proPath.image_url rangeOfString:gallery.path].location != NSNotFound || [gallery.path rangeOfString:proPath.image_url].location != NSNotFound) {
                                        proPath.original_height = gallery.original_height;
                                        proPath.original_width = gallery.original_width;
                                        found = YES;
                                        break;
                                    }
                                }
                            }
                        }
                        if (!found) {
                            proPath.original_height = [NSNumber numberWithFloat:3264];
                            proPath.original_width = [NSNumber numberWithFloat:2448];
                        }
                    }
                    
                }
            }
            self.recordInfo = info;
            self.isDoublePage = (info.is_double.integerValue == 1);
            [self createUpCollectionView];
        }
        
    }
}

- (void)getGrowProgress
{
    GlobalManager *manager = [GlobalManager shareInstance];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"production"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getGrowProgress"];
    RecordTemplate *temp = [_recordInfo.template firstObject];
    [param setObject:temp.user_grow_id forKey:@"grow_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getGrowProgressFinish:error Data:data];
        });
    }];
}

- (void)getGrowProgressFinish:(NSError *)error Data:(id)data
{
    //_requestCount--;
    self.sessionTask = nil;
    if (error) {
        [self performSelector:@selector(getGrowProgress) withObject:nil afterDelay:3];
    }
    else{
        BOOL find = NO;
        id ret_data = [data valueForKey:@"ret_data"];
        if (ret_data) {
            NSString *progress = [ret_data valueForKey:@"progress"];
            find = [progress integerValue] >= [_recordInfo.template count];
        }
        if (find) {
            [self.view hideToastActivity];
            self.view.userInteractionEnabled = YES;
            UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
            rightItem.enabled = YES;
            
            _recordInfo.is_public = [NSNumber numberWithInteger:2];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的时光相册已成功发布" delegate:self cancelButtonTitle:@"继续编辑" otherButtonTitles:@"立即查看", nil];
            alert.tag = 10;
            [alert show];
        }
        else{
            [self performSelector:@selector(getGrowProgress) withObject:nil afterDelay:3];
        }
    }
}

#pragma mark - 提交订单
- (void)submitOrder
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    RecordTemplate *temp = [_recordInfo.template firstObject];
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"consumerCreateOrder"];
    [param setValue:temp.user_grow_id forKey:@"grow_ids"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"consumer"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf submitOrderFinish:error Data:data];
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
        mainVc.initIdx = 2;
        [self.navigationController pushViewController:mainVc animated:YES];
    }
}

#pragma mark - 打印
- (void)getPrintInfo
{
    if (_printUrl.length > 0) {
        DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
        order.url = _printUrl;
        [self.navigationController pushViewController:order animated:YES];
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    RecordTemplate *temp = [_recordInfo.template firstObject];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"queryGrowIsPrint"];
    [param setObject:temp.user_grow_id forKey:@"grow_id"];
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
        if ([url isKindOfClass:[NSString class]] && url.length > 0) {
            self.printUrl = url;
        }
        
        if (_printUrl.length > 0) {
            DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
            order.url = _printUrl;
            [self.navigationController pushViewController:order animated:YES];
            return;
        }
        else{
            [self.view makeToast:@"打印地址解析异常" duration:1.0 position:@"center"];
        }
    }
}

#pragma mark - 发布
- (void)beginPublicInfo
{
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    RecordTemplate *temp = [_recordInfo.template firstObject];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"releaseProduction"];
    [param setObject:temp.user_grow_id forKey:@"grow_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"production"];
    
    [self.view makeToastActivityToMsg:@"模板正在保存中..."];
    self.view.userInteractionEnabled = NO;
    UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
    rightItem.enabled = NO;
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf publishTemplate:error Data:data];
        });
    }];
}

- (void)publishTemplate:(NSError *)error Data:(id)result
{
    if (error) {
        self.sessionTask = nil;
        [self.view hideToastActivity];
        self.view.userInteractionEnabled = YES;
        UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
        rightItem.enabled = YES;
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        if (_delegate && [_delegate respondsToSelector:@selector(batchMakePublishFinish)]) {
            [_delegate batchMakePublishFinish];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:ChangeCustomPublic object:@{@"batch_id":_batch_id,@"user_id":_user_id}];
        }
        
        if (_recordInfo.is_public.integerValue == 2) {
            self.sessionTask = nil;
            [self.view hideToastActivity];
            self.view.userInteractionEnabled = YES;
            UIBarButtonItem *rightItem = [self.navigationItem.rightBarButtonItems lastObject];
            rightItem.enabled = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的时光相册已成功发布" delegate:self cancelButtonTitle:@"继续编辑" otherButtonTitles:@"立即查看", nil];
            alert.tag = 10;
            [alert show];
        }
        else{
            //_requestCount = 5;
            [self performSelector:@selector(getGrowProgress) withObject:nil afterDelay:3];
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的该套成长档案模版已成功提交，正在努力制作中" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
//            [alert show];
        }
    }
}

#pragma mark - 提交上一次数据
- (void)commitPreData:(NSInteger)preIdx To:(NSInteger)newIdx
{
    if (preIdx != newIdx) {
        RecordTemplate *template = _recordInfo.template[preIdx];
        CustomParamter *tmpParam = [self convertToCustomParater:preIdx];
        if ([template.customParam isEqual:tmpParam]) {
            NSLog(@"数据相同，不做提交");
        }
        else{
            template.customParam = tmpParam;
            NSLog(@"第%ld张数据不同,开始提交",(long)preIdx);
            [self resetButtonShow];
            [[DataBaseOperation shareInstance] resetTemplateInfo:[template saveTemplateParam]];
            @synchronized (_commitArr) {
                if (![_commitArr containsObject:template]) {
                    [_commitArr addObject:template];
                }
            }
            [template startUploadChangeInfo];
        }
    }
    
}

- (CustomParamter *)convertToCustomParater:(NSInteger)index
{
    RecordTemplate *model = _recordInfo.template[index];
    NSArray *localArr = _selectData[index];
    NSInteger count = [localArr count];
    
    NSInteger coverCount = [model.production_parameter.image_path count];
    CGFloat temOri = model.original_width.floatValue / model.image_width.floatValue;
    
    //封面
    NSMutableArray *imagepaths = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        if (coverCount > i) {
            ProductImagePath *tmpPath = model.production_parameter.image_path[i];
            if (tmpPath && tmpPath.image_url.length > 0) {
                NSDictionary *dic = @{@"image_url":tmpPath.image_url,@"detail":tmpPath.detail,@"original_width":tmpPath.original_width.stringValue,@"original_height":tmpPath.original_height.stringValue};
                NSString *jsonString = [NSString dictToJsonStr:dic];
                [imagepaths addObject:jsonString];
                continue;
            }
        }
        
        NSString *lastDic = @"{}";
        ImageCoorInfo *coorInfo = [model.detail_content.image_coor objectAtIndex:i];
        NSArray *x = [coorInfo.x componentsSeparatedByString:@","];
        NSArray *y = [coorInfo.y componentsSeparatedByString:@","];
        //框的大小
        CGRect coorRect = CGRectMake([x[0] floatValue], [x[1] floatValue], [y[0] floatValue] - [x[0] floatValue], [y[1] floatValue] - [x[1] floatValue]);
        //图片最低要求大小
        CGFloat unilateralRatio = sqrt(2);
        CGSize oriSize = CGSizeMake(coorRect.size.width * temOri  / unilateralRatio, coorRect.size.height * temOri  / unilateralRatio);
        //本地数组
        NSArray *subArr = [localArr objectAtIndex:i];
        for (NSInteger m = 0; m < subArr.count; m++) {
            PhotoManagerModel *photo = subArr[m];
            if (photo.file_type.integerValue != 1) {
                continue;
            }
            
            if (photo.width.floatValue < oriSize.width || photo.height.floatValue < oriSize.height) {
                continue;
            }
            
            CGSize imgSize = CGSizeMake(photo.width.floatValue, photo.height.floatValue);
            if ((imgSize.width > coorRect.size.width) && (imgSize.height > coorRect.size.height)) {
                //超过2边，保证一边充满，另一边超出
                CGFloat tmpScale = MAX(coorRect.size.width / imgSize.width, coorRect.size.height / imgSize.height);
                imgSize = CGSizeMake(imgSize.width * tmpScale, imgSize.height * tmpScale);
            }
    
            //中心点减去宽高的一版
            CGRect imgRect = CGRectMake(coorRect.size.width / 2 + coorRect.origin.x - imgSize.width / 2, coorRect.size.height / 2 + coorRect.origin.y - imgSize.height / 2, imgSize.width, imgSize.height);
            
            CGFloat rotation = 0;
            NSString *detail = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",imgRect.origin.x,imgRect.origin.y,imgRect.size.width,imgRect.size.height,rotation];
            NSDictionary *dic = @{@"image_url":photo.path,@"detail":detail,@"original_width":photo.width,@"original_height":photo.height};
            lastDic = [NSString dictToJsonStr:dic];
            
            break;
        }
        [imagepaths addObject:lastDic];
    }
    
    //图集
    NSMutableArray *gallerys = [NSMutableArray array];
    NSInteger galCount = [model.production_parameter.src_gallery_list count];
    for (NSInteger i = 0; i < count; i++) {
        NSMutableArray *tmpArr = [NSMutableArray array];
        NSString *imgpath = imagepaths[i];
        BOOL hasFound = NO;
        if (i < galCount) {
            NSArray *subGallerys = [model.production_parameter.src_gallery_list objectAtIndex:i];
            for (ProductImageGallery *gal in subGallerys) {
                NSString *type = gal.type.stringValue;
                NSString *is_cover = @"0";
                if (!hasFound && [imgpath rangeOfString:gal.path].location != NSNotFound) {
                    hasFound = YES;
                    is_cover = @"1";
                }
                NSDictionary *dic = @{@"type":type,@"path":gal.path,@"is_cover":is_cover,@"picture":gal.picture ?: @"",@"original_width":gal.original_width.stringValue ?: @"",@"original_height":gal.original_height.stringValue ?: @""};
                NSString *jsonString = [NSString dictToJsonStr:dic];
                [tmpArr addObject:jsonString];
            }
        }
        
        //本地数组
        NSArray *subArr = [localArr objectAtIndex:i];
        for (PhotoManagerModel *photo in subArr) {
            NSString *type = photo.file_type;
            NSString *is_cover = @"0";
            if (!hasFound && [imgpath rangeOfString:photo.path].location != NSNotFound) {
                hasFound = YES;
                is_cover = @"1";
            }
            NSDictionary *dic = @{@"type":type,@"path":photo.path,@"is_cover":is_cover,@"picture":@"",@"original_width":photo.width,@"original_height":photo.height};
            NSString *jsonString = [NSString dictToJsonStr:dic];
            [tmpArr addObject:jsonString];
        }
        
        [gallerys addObject:[NSString stringWithFormat:@"[%@]",[tmpArr componentsJoinedByString:@","]]];
    }
    
    //素材地址
    NSMutableArray *decoArr = [NSMutableArray array];
    NSArray *decoPaths = model.production_parameter.deco_path;
    for (NSInteger i = 0; i < [decoPaths count]; i++) {
        ProductImagePath *imgPath = [decoPaths objectAtIndex:i];
        NSDictionary *dic = @{@"image_url":imgPath.image_url,@"detail":imgPath.detail};
        NSString *jsonString = [NSString dictToJsonStr:dic];
        [decoArr addObject:jsonString];
    }
    
    //输入文字
    NSMutableArray *textArr = [NSMutableArray array];
    NSArray *txtList = model.production_parameter.input_text;
    for (NSInteger i = 0; i < [txtList count]; i++) {
        ProductImageInput *input = [txtList objectAtIndex:i];
        NSDictionary *dic = @{@"txt":input.txt ?: @"",@"voice":input.voice ?: @""};
        NSString *jsonString = [NSString dictToJsonStr:dic];
        [textArr addObject:jsonString];
    }
    
    //自定义文本
    NSMutableArray *decoImgs = [NSMutableArray array];
    NSArray *decoTxts = model.production_parameter.deco_text;
    for (NSInteger i = 0; i < [decoTxts count]; i++) {
        ProductImageDecotext *tmpTxt = [decoTxts objectAtIndex:i];
        if (tmpTxt.txt.length > 0) {
            NSDictionary *dic = @{@"txt":tmpTxt.txt ?: @"",@"size":@"12",@"detail":tmpTxt.detail,@"color":tmpTxt.color,@"font":tmpTxt.font ?: @""};
            NSString *jsonString = [NSString dictToJsonStr:dic];
            [decoImgs addObject:jsonString];
        }
    }
    
    CustomParamter *param = [[CustomParamter alloc] init];
    param.imgpath = [NSString stringWithFormat:@"[%@]",[imagepaths componentsJoinedByString:@","]];
    param.gallery = [NSString stringWithFormat:@"[%@]",[gallerys componentsJoinedByString:@","]];
    param.imgdeco = [NSString stringWithFormat:@"[%@]",[decoArr componentsJoinedByString:@","]];
    param.decoTxt = [NSString stringWithFormat:@"[%@]",[decoImgs componentsJoinedByString:@","]];
    param.imginput = [NSString stringWithFormat:@"[%@]",[textArr componentsJoinedByString:@","]];
    
    return param;
}

#pragma mark - RMPZoomTransitionAnimating
- (UIImageView *)transitionSourceImageView
{
    CGSize itemSize = [(JSCarouselLayout *)_carouselCollectionView.collectionViewLayout itemSize];
    CGRect imgRect = CGRectMake((SCREEN_WIDTH - itemSize.width) / 2, 64 + (_carouselCollectionView.frame.size.height - itemSize.height) / 2, itemSize.width, itemSize.height);
    
    BatchMakeCell *makeCell = (BatchMakeCell *)[_carouselCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_curIdx inSection:0]];
    UIImageView *tempImg = [[UIImageView alloc] initWithFrame:imgRect];
    //[tempImg setImage:makeCell.contentImg.image];
    [tempImg setImage:[DecoTextView convertSelfToImage:makeCell.contentView]];
    [tempImg setBackgroundColor:makeCell.backgroundColor];
    
    return tempImg;
}

- (UIColor *)transitionSourceBackgroundColor
{
    return _carouselCollectionView.backgroundColor;
}

- (CGRect)transitionDestinationImageViewFrame
{
    CGSize itemSize = [(JSCarouselLayout *)_carouselCollectionView.collectionViewLayout itemSize];
    CGRect imgRect = CGRectMake((SCREEN_WIDTH - itemSize.width) / 2, 64 + (_carouselCollectionView.frame.size.height - itemSize.height) / 2, itemSize.width, itemSize.height);
    return imgRect;
}

#pragma mark - BatchDetailViewControllerDelegate
- (void)changeDetailFinishAt:(NSInteger)index Type:(kBackMakeType)backType
{
    if ((backType == kBackMakeAddPicture || backType == kBackMakeBlank) && _fullShow) {
        [self scaleTohalfSize];
    }
    else{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_curIdx inSection:0];
        [self.carouselCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
    //成功数据替换
    if (backType == kBackMakeFinish) {
        RecordTemplate *template = [_recordInfo.template objectAtIndex:_curIdx];
        template.customParam = [self convertToCustomParater:_curIdx];
        //判断完成分享按钮是否显示
        [self resetButtonShow];
    }

    if (index == NSNotFound) {
        _service.checkArr = nil;
        _service.gallerys = nil;
        [self resetVisibleCells];
    }
    else{
        _service.checkArr = _selectData[_curIdx][index];
        RecordTemplate *model = _recordInfo.template[_curIdx];
        NSMutableArray *gallerys = nil;
        if ([model.production_parameter.src_gallery_list count] > index) {
            gallerys = [model.production_parameter.src_gallery_list objectAtIndex:index];
        }
        _service.gallerys = gallerys;
        [self performSelector:@selector(resetCellSelectedState:) withObject:[NSNumber numberWithInteger:index] afterDelay:0.1];
    }
}

#pragma mark - BatchMakeCellDelegate
- (BOOL)canCheckTemeplate:(UICollectionViewCell *)collectionViewCell
{
    if (self.carouselCollectionView.isDragging || self.carouselCollectionView.isDecelerating) {
        return NO;
    }
    
    NSIndexPath *indexPath = [_carouselCollectionView indexPathForCell:collectionViewCell];
    BOOL canCheck = (indexPath.item == _curIdx);
    if (!canCheck) {
        if (!_fullShow) {
            [self changeUpCollectionFrame];
        }
    }
    else{
        RecordTemplate *template = _recordInfo.template[indexPath.item];
        if (template.is_operate.integerValue == 0) {
            [self.view makeToast:@"该页暂时还没有开放给您制作" duration:1.0 position:@"center"];
            return NO;
        }
    }
    return canCheck;
}

- (void)checkCell:(UICollectionViewCell *)collectionViewCell At:(NSInteger)index
{
    if (index < 0) {
        _service.checkArr = nil;
        _service.gallerys = nil;
    }
    else{
        RecordTemplate *model = _recordInfo.template[_curIdx];
        NSMutableArray *gallerys = nil;
        if ([model.production_parameter.src_gallery_list count] > index) {
            gallerys = [model.production_parameter.src_gallery_list objectAtIndex:index];
        }
        _service.gallerys = gallerys;
        _service.checkArr = _selectData[_curIdx][index];
    }
    [self resetVisibleCells];
    
    NSIndexPath *indexPath = [_carouselCollectionView indexPathForCell:collectionViewCell];
    RecordTemplate *model = _recordInfo.template[indexPath.item];
    BOOL hasFound = NO;
    if ([model.production_parameter.src_gallery_list count] > index) {
        NSArray *srcArr = model.production_parameter.src_gallery_list[index];
        hasFound = ([srcArr count] > 0);
    }
    if (!hasFound) {
        NSArray *subArr = _selectData[indexPath.item];
        if ([subArr count] > index) {
            NSArray *subSub = [subArr objectAtIndex:index];
            hasFound = [subSub count] > 0;
        }
    }
    if (hasFound) {
        [self blowUpTemplate:index];
    }
    else{
        if (_fullShow) {
            //缩回去选图片
            [self changeUpCollectionFrame];
        }
    }
}

#pragma mark - 可见cell状态改变
- (void)resetVisibleCells
{
    CGSize size = [self minImageSizeByMakeView];
    for (FastMakeCell *fastCell in _downCollectinView.visibleCells) {
        NSIndexPath *indexPath = [_downCollectinView indexPathForCell:fastCell];
        PhotoManagerModel *photo = _service.dataSource[indexPath.section][indexPath.item];
        if (photo.path.length == 0) {
            //未上传过的，无需判断
            fastCell.checkImg.hidden = YES;
        }
        else if ([_service.checkArr containsObject:photo]) {
            fastCell.checkImg.hidden = NO;
        }
        else{
            BOOL hasFound = NO;
            for (ProductImageGallery *gallery in _service.gallerys) {
                if ([gallery.path rangeOfString:photo.path].location != NSNotFound) {
                    hasFound = YES;
                    break;
                }
            }
            fastCell.checkImg.hidden = !hasFound;
        }
        [fastCell resetImgShowQuality:size];
    }
}

- (void)hideVisibleCellsBy:(NSString *)path At:(NSIndexPath *)offPath
{
    for (FastMakeCell *fastCell in _downCollectinView.visibleCells) {
        NSIndexPath *indexPath = [_downCollectinView indexPathForCell:fastCell];
        if ([indexPath isEqual:offPath]) {
            continue;
        }
        PhotoManagerModel *photo = _service.dataSource[indexPath.section][indexPath.item];
        if ((photo.path.length > 0) && [photo.path isEqualToString:path]) {
            fastCell.checkImg.hidden = YES;
        }
    }
}

//更换索引，提交所有状态
- (void)clearAllCellStatus
{
    for (BatchMakeCell *cell in _carouselCollectionView.visibleCells) {
        NSIndexPath *indexPath = [_carouselCollectionView indexPathForCell:cell];
        if (indexPath.item != _curIdx) {
            [cell clearAllStatus];
        }
    }
}

#pragma mark - PhotoManagerUploadDelegate
- (void)photoManagerUpload:(PhotoManagerModel *)model Suc:(BOOL)suc
{
    [self uploadFinishPhotoModel:model];
    @synchronized (_uploadArr) {
        [_uploadArr removeObject:model];
        if ([_uploadArr count] > 0) {
            PhotoManagerModel *next = [_uploadArr firstObject];
            [next beginUploadData];
        }
    }
}

- (void)uploadFinishPhotoModel:(PhotoManagerModel *)model
{
    for (FastMakeCell *fastCell in _downCollectinView.visibleCells) {
        NSIndexPath *indexPath = [_downCollectinView indexPathForCell:fastCell];
        PhotoManagerModel *photo = _service.dataSource[indexPath.section][indexPath.item];
        if (photo == model) {
            [fastCell photoUplodFinish];
            break;
        }
    }
}

#pragma mark - UICollectionView Delegate / DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return _recordInfo.template.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BatchMakeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTIONCELLID forIndexPath:indexPath];
    cell.delegate = self;
    
    CGSize itemSize = [(JSCarouselLayout *)collectionView.collectionViewLayout itemSize];
    RecordTemplate *model = _recordInfo.template[indexPath.item];
    [cell resetBatchMakeModel:model Arr:_selectData[indexPath.item] Size:itemSize fullSize:_fullSize];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!(collectionView.isDecelerating || collectionView.isDecelerating)) {
        RecordTemplate *model = _recordInfo.template[indexPath.item];
        if (([model.detail_content.image_coor count] == 0) && (model.is_operate.integerValue == 1)) {
            [self blowUpTemplate:NSNotFound];
            return;
        }
        if (!_fullShow) {
            [self changeUpCollectionFrame];
        }
    }
}

#pragma mark - FastMakeCellDelegate
- (BOOL)checkItemOf:(UICollectionViewCell *)cell Check:(BOOL)check
{
    //
    BatchMakeCell *makeCell = (BatchMakeCell *)[_carouselCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_curIdx inSection:0]];
    if (makeCell.nSelectIdx < 0) {
        [self.view makeToast:@"请先选择您要装饰的图片框" duration:1.0 position:@"center"];
        return NO;
    }
    
    NSMutableArray *curArr = [_selectData objectAtIndex:_curIdx];
    NSMutableArray *subArr = curArr[makeCell.nSelectIdx];
    
    NSIndexPath *indexPath = [_downCollectinView indexPathForCell:cell];
    PhotoManagerModel *photo = _service.dataSource[indexPath.section][indexPath.item];
    
    if (check) {
        //上边模板删除
        if ([subArr containsObject:photo]) {
            [subArr removeObject:photo];
        }
        else{
            NSMutableArray *delArr = [NSMutableArray array];
            for (ProductImageGallery *gallery in _service.gallerys) {
                if ([gallery.path rangeOfString:photo.path].location != NSNotFound) {
                    [delArr addObject:gallery];
                }
            }
            [_service.gallerys removeObjectsInArray:delArr];
            if ([delArr count] > 1) {
                //重复的地址
                [self hideVisibleCellsBy:photo.path At:indexPath];
            }
        }
        [makeCell resetNewArr:curArr];
        
        return YES;
    }
    else{
        //判断是否已上传
        if (photo.path.length > 0 || photo.uploadState == kPhotoUploadSuc) {
            if (makeCell.nSelectIdx == -1) {
                [self.view makeToast:@"请先选择模板框" duration:1.0 position:@"center"];
                return NO;
            }
            RecordTemplate *template = [_recordInfo.template objectAtIndex:_curIdx];
            NSInteger totalCount = [subArr count];
            NSArray *srcArr = nil;
            if ([template.production_parameter.src_gallery_list count] > makeCell.nSelectIdx) {
                srcArr = template.production_parameter.src_gallery_list[makeCell.nSelectIdx];
                totalCount += [srcArr count];
            }
            if (totalCount >= 9) {
                [self.view makeToast:@"不可选择超过9张" duration:1.0 position:@"center"];
                return NO;
            }
            
            BOOL canAdd = (totalCount != 8);
            if (!canAdd) {
                //图片需要判断分辨率
                BOOL shouldCheck = NO;
                ImageCoorInfo *coorInfo = [template.detail_content.image_coor objectAtIndex:makeCell.nSelectIdx];
                NSArray *x = [coorInfo.x componentsSeparatedByString:@","];
                NSArray *y = [coorInfo.y componentsSeparatedByString:@","];
                CGFloat scale = template.original_width.floatValue / template.image_width.floatValue;
                CGSize oriSize = CGSizeMake(([y[0] floatValue] - [x[0] floatValue]) * scale, ([y[1] floatValue] - [x[1] floatValue]) * scale);
                CGFloat unilateralRatio = sqrt(2);
                oriSize = CGSizeMake(oriSize.width / unilateralRatio, oriSize.height / unilateralRatio);
                
                //判断前面是否有可作为封面的内容，视频直接过滤掉
                //本地判断
                for (PhotoManagerModel *subModel in subArr) {
                    if (subModel.file_type.integerValue == 1) {
                        CGSize tmpSize = CGSizeMake(subModel.width.floatValue, subModel.height.floatValue);
                        if (tmpSize.width >= oriSize.width && tmpSize.height >= oriSize.height) {
                            shouldCheck = YES;
                            break;
                        }
                    }
                }
                //网络判断
                for (ProductImageGallery *gallery in srcArr) {
                    if (gallery.type.integerValue == 1) {
                        CGSize tmpSize = CGSizeMake(gallery.original_width.floatValue, gallery.original_height.floatValue);
                        if (tmpSize.width >= oriSize.width && tmpSize.height >= oriSize.height) {
                            shouldCheck = YES;
                            break;
                        }
                    }
                }
                if (!shouldCheck) {
                    //如果当前的满足条件，则不做处理，如果当前不满足条件，
                    if (photo.file_type.integerValue == 1) {
                        CGSize imgSize = CGSizeMake(photo.width.floatValue, photo.height.floatValue);
                        if (imgSize.width >= oriSize.width && imgSize.height >= oriSize.height) {
                            //
                    
                        }
                        else{
                            [self.view makeToast:@"您选择的图片分辨率过低，不适合作为打印封面" duration:1.0 position:@"center"];
                            return NO;
                        }
                    }
                    else{
                        [self.view makeToast:@"您需要选择1张高清图片作为封面用于打印" duration:1.0 position:@"center"];
                        return NO;
                    }
                }
            }
            //是否显示完成分享按钮
            [self resetButtonShowOutOf:template];
            
            CGRect rectInTableView = [_downCollectinView convertRect:cell.frame toView:self.view];
            CGSize itemSize = [(JSCarouselLayout *)_carouselCollectionView.collectionViewLayout itemSize];
            CGRect makeRect = [makeCell getRectBySelectIdx];
            CGRect rect = CGRectMake((SCREEN_WIDTH - itemSize.width) / 2 + makeRect.origin.x, makeRect.origin.y + 10, makeRect.size.width, makeRect.size.height);
            
            UIImageView *tempImg = [[UIImageView alloc] initWithFrame:rectInTableView];
            [tempImg setImage:([(FastMakeCell *)cell contentImg]).image];
            [self.view addSubview:tempImg];
            
            self.view.window.userInteractionEnabled = NO;
            [self rotate360DegreeWithImageView:tempImg];
            
            //上边模板添加
            [subArr addObject:photo];
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [tempImg setFrame:CGRectMake(rect.origin.x + rect.size.width / 4, rect.origin.y + rect.size.height / 4, rect.size.width / 2, rect.size.height / 2)];
            } completion:^(BOOL finished) {
                [self.view.layer removeAllAnimations];
                [tempImg removeFromSuperview];
                [makeCell resetNewArr:curArr];
                self.view.window.userInteractionEnabled = YES;
            }];
            
            return YES;
        }
        else{
            //避免重复上传
            @synchronized (_uploadArr) {
                if (![_uploadArr containsObject:photo]) {
                    NSInteger count = _uploadArr.count;
                    [_uploadArr addObject:photo];
                    if (count == 0) {
                        [photo beginUploadData];
                    }
                    else{
                        photo.uploadState = kPhotoUploadWait;
                    }
                }
                else{
                    //取消上传操作
                    NSInteger index = [_uploadArr indexOfObject:photo];
                    if (index != NSNotFound) {
                        [_uploadArr removeObject:photo];
                        [photo clearUploadData];
                        if (index == 0) {
                            PhotoManagerModel *first = [_uploadArr firstObject];
                            [first beginUploadData];
                        }
                    }
                }
                [(FastMakeCell *)cell changeUploadState];
            }
            
            return NO;
        }
    }
}

- (CGSize)minImageSizeByMakeView
{
    BatchMakeCell *makeCell = (BatchMakeCell *)[_carouselCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_curIdx inSection:0]];
    if (!makeCell || makeCell.nSelectIdx < 0) {
        return CGSizeZero;
    }
    else{
        RecordTemplate *template = [_recordInfo.template objectAtIndex:_curIdx];
        ImageCoorInfo *coorInfo = [template.detail_content.image_coor objectAtIndex:makeCell.nSelectIdx];
        NSArray *x = [coorInfo.x componentsSeparatedByString:@","];
        NSArray *y = [coorInfo.y componentsSeparatedByString:@","];
        CGFloat scale = template.original_width.floatValue / template.image_width.floatValue;
        CGSize oriSize = CGSizeMake(([y[0] floatValue] - [x[0] floatValue]) * scale, ([y[1] floatValue] - [x[1] floatValue]) * scale);
        CGFloat unilateralRatio = sqrt(2);
        oriSize = CGSizeMake(oriSize.width / unilateralRatio, oriSize.height / unilateralRatio);
        return oriSize;
    }
}

- (void)rotate360DegreeWithImageView:(UIImageView *)imageView{
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    //围绕Z轴旋转，垂直与屏幕
    animation.toValue = [ NSValue valueWithCATransform3D:
                         
                         CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    animation.duration = 0.1;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = 1000;
    
    //在图片边缘添加一个像素的透明区域，去图片锯齿
    CGRect imageRrect = CGRectMake(0, 0,imageView.frame.size.width, imageView.frame.size.height);
    UIGraphicsBeginImageContext(imageRrect.size);
    [imageView.image drawInRect:CGRectMake(1,1,imageView.frame.size.width-2,imageView.frame.size.height-2)];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView.layer addAnimation:animation forKey:nil];
}

#pragma mark - lazy load
- (UICollectionView *)carouselCollectionView
{
    if (!_carouselCollectionView) {
        JSCarouselLayout *layout                = [[JSCarouselLayout alloc] init];
        __weak typeof (self)weakSelf            = self;
        NSInteger pageCount                     = _isDoublePage ? 2 : 1;
        layout.carouselSlideIndexBlock          = ^(NSInteger index){
            weakSelf.indexLabel.text            = [NSString stringWithFormat:@"%ld/%ld",(long)(index + 1) * pageCount,(long)([weakSelf.recordInfo.template count] * pageCount)];
            [weakSelf commitPreData:weakSelf.curIdx To:index];
            weakSelf.curIdx = index;
            [weakSelf clearAllCellStatus];
            
            weakSelf.service.checkArr = nil;
            weakSelf.service.gallerys = nil;
            [weakSelf resetVisibleCells];
        };
        layout.itemSize = _fullSize;
        _carouselCollectionView                 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCREEN_HEIGHT - 64) collectionViewLayout:layout];
        _carouselCollectionView.backgroundColor = self.view.backgroundColor;
        _carouselCollectionView.dataSource      = self;
        _carouselCollectionView.delegate        = self;
        _carouselCollectionView.showsHorizontalScrollIndicator = NO;
        _carouselCollectionView.showsVerticalScrollIndicator = NO;
        [_carouselCollectionView registerClass:[BatchMakeCell class] forCellWithReuseIdentifier:COLLECTIONCELLID];
    }
    
    return _carouselCollectionView;
}

- (BatchMakeUIService *)service{
    if (!_service) {
        _service = [[BatchMakeUIService alloc] init];
        _service.delegate = self;
    }
    return _service;
}

- (UICollectionView *)downCollectinView
{
    if (!_downCollectinView) {
        CSStickyHeaderFlowLayout *layout = [[CSStickyHeaderFlowLayout alloc] init];
        NSInteger numPerRow = 4,itemMargin = 5 ,itemWidth = (SCREEN_WIDTH - itemMargin * (numPerRow + 3)) / numPerRow;
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.minimumLineSpacing = itemMargin;
        layout.minimumInteritemSpacing = itemMargin;
        layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 26);
        CGFloat yOri = (SCREEN_HEIGHT - 64) / 2;
        
        _downCollectinView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, yOri, SCREEN_WIDTH, yOri) collectionViewLayout:layout];
        _downCollectinView.backgroundColor = [UIColor whiteColor];
        //[_downCollectinView setFrame:CGRectMake(0, yOri, SCREEN_WIDTH, yOri)];
        [_downCollectinView setContentInset:UIEdgeInsetsMake(0, itemMargin * 2, itemMargin, itemMargin * 2)];
        _downCollectinView.dataSource = self.service;
        _downCollectinView.delegate = self.service;
        [_downCollectinView registerClass:[FastMakeCell class] forCellWithReuseIdentifier:FastMakeCellID];
        [_downCollectinView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:FastMakeHeader];
    }
    
    return _downCollectinView;
}

- (UILabel *)indexLabel{
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 55, 22)];
        [_indexLabel setBackgroundColor:rgba(163, 163, 163, 0.5)];
        [_indexLabel setFont:[UIFont systemFontOfSize:14]];
        [_indexLabel setTextAlignment:NSTextAlignmentCenter];
        [_indexLabel setTextColor:[UIColor whiteColor]];
        _indexLabel.layer.masksToBounds = YES;
        _indexLabel.layer.cornerRadius = 11;
        NSInteger pageCount = _isDoublePage ? 2 : 1;
        [_indexLabel setText:[NSString stringWithFormat:@"%@/%ld",[[NSNumber numberWithInteger:pageCount] stringValue],(long)[_recordInfo.template count] * pageCount]];
    }
    return _indexLabel;
}

- (UIView *)failTipView
{
    if (!_failTipView) {
        _failTipView = [[UIView alloc] init];
        [_failTipView setBackgroundColor:self.view.backgroundColor];
        [_failTipView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imgView setImage:CREATE_IMG(@"order_default")];
        [_failTipView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.top.equalTo(@(0));
            make.width.equalTo(_failTipView.mas_width);
            make.height.equalTo(imgView.mas_width).with.multipliedBy(80.0 / 65);
        }];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitle:@"再试一次" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button setTitleColor:CreateColor(86, 86, 86) forState:UIControlStateNormal];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:5];
        [button.layer setBorderWidth:1];
        [button.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [button addTarget:self action:@selector(tryAgainRequest:) forControlEvents:UIControlEventTouchUpInside];
        [_failTipView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_failTipView.mas_centerX);
            make.top.equalTo(imgView.mas_bottom);
            make.width.equalTo(imgView.mas_width);
            make.height.equalTo(@(20));
        }];
    }
    return _failTipView;
}

- (ProgressCircleView *)circleView
{
    if (!_circleView) {
        _circleView = [[ProgressCircleView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) / 2, (SCREEN_HEIGHT - 64 - 120) / 2, 120, 120)];
        [_circleView.progressLab setText:@"模板信息正在上传..."];
    }
    return _circleView;
}

@end
