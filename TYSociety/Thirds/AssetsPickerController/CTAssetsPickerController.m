
/*
 CTAssetsPickerController.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */


#import "CTAssetsPickerController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "MWPhotoBrowser.h"
#import "ProgressCircleView.h"
#import "UIImage+Caption.h"
#import "UIImage+FixOrientation.h"
#import "GlobalManager.h"
//#import "PlayViewController.h"
#import "DataBaseOperation.h"
#import "AssetModel.h"

#define IS_IOS7             ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
#define kThumbnailLength    78.0f
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)


#pragma mark - Interfaces

@interface CTAssetsPickerController ()

@end

@protocol CTAssetsViewCellDelegate <NSObject>

- (void)checkSelectCell:(UICollectionViewCell *)cell;

@end

@interface CTAssetsViewController : UICollectionViewController<MWPhotoBrowserDelegate,CTAssetsViewCellDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *selectAssets;
@property (nonatomic, strong) NSMutableArray *uploadArr;
@property (nonatomic, strong) NSMutableArray *uploadUrls;
@property (nonatomic, strong) NSMutableArray *uploadIdxs;
@property (nonatomic, strong) NSMutableArray *netSource;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@interface CTAssetsViewController ()

@property (nonatomic, strong) NSMutableArray *assetArr;
@property (nonatomic, strong) NSMutableArray *assetModels;

@end

@interface CTAssetsViewCell : UICollectionViewCell

@property (nonatomic,strong)UIButton *button;

- (void)bind:(AssetModel *)assetModel;

@end

@interface CTAssetsViewCell ()

@property (nonatomic, assign) id<CTAssetsViewCellDelegate> delegate;

@end

#pragma mark - CTAssetsPickerController


@implementation CTAssetsPickerController

@dynamic delegate;

- (id)init
{
    CTAssetsViewController *assetViewController = [[CTAssetsViewController alloc] init];
    
    if (self = [super initWithRootViewController:assetViewController])
    {
        _maximumNumberOfSelection   = NSIntegerMax;
        _assetsFilter               = [ALAssetsFilter allAssets];
        _showsCancelButton          = YES;
    }
    
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

#pragma mark - CTAssetsViewController

#define kAssetsViewCellIdentifier           @"AssetsViewCellIdentifier"
#define kAssetsSupplementaryViewIdentifier  @"AssetsSupplementaryViewIdentifier"

@implementation CTAssetsViewController
{
    NSMutableArray *_mwphotos;
    NSInteger _selectIdx;
    UIButton *_finishBut;
    BOOL _shouldTip;
    
    ProgressCircleView *_progressView;
    NSIndexPath *_indexPath;
    UIView *_rightTipView;
    UILabel *_monthLab,*_yearLab,*_dayLab;
    CGPoint _beginPoint;
}

- (void)dealloc{
    if (_operationQueue) {
        [_operationQueue cancelAllOperations];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RefreshAlbum object:nil];
}

- (id)init
{
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                     = kThumbnailSize;
    layout.minimumInteritemSpacing      = 2.0;
    layout.minimumLineSpacing           = 2.0;
    layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 26);
    
    if (self = [super initWithCollectionViewLayout:layout])
    {
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 2, 0)];
        [self.collectionView registerClass:[CTAssetsViewCell class] forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kAssetsSupplementaryViewIdentifier];
        self.collectionView.showsVerticalScrollIndicator = NO;
        
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectAssets = [NSMutableArray array];
    _selectIdx = 0;
    [self setupViews];
    [self localize];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllAlbums:) name:RefreshAlbum object:nil];
}

- (void)refreshAllAlbums:(NSNotification *)notifi
{
    //self.assetArr = [GlobalManager shareInstance].assetsArr;
    //[self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = [UIColor whiteColor];
    }
    
    if (!_assetArr) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakSelf.assetModels = [[DataBaseOperation shareInstance] selectAllAblumsBy:[GlobalManager shareInstance].detailInfo.user.id];
            NSMutableArray *cusArr = [NSMutableArray array];
            for (NSInteger i = 0; i < weakSelf.assetModels.count; i++) {
                AssetModel *model = [weakSelf.assetModels objectAtIndex:i];
                NSMutableArray *lstArr = [cusArr lastObject];
                if (!lstArr) {
                    lstArr = [NSMutableArray arrayWithObject:model];
                    [cusArr addObject:lstArr];
                }
                else{
                    AssetModel *lstModel = [lstArr lastObject];
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
                weakSelf.assetArr = cusArr;
                [weakSelf.collectionView reloadData];
                if ([weakSelf.assetArr count] > 0) {
                    [weakSelf resetSectionHeader];
                }
                
            });
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
}

- (void)localize
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 100, 24)];
    //[titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0]];
    [titleLabel setText:@"图片与视频"];
    [titleLabel setTextAlignment:1];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Setup
- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 60.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:CREATE_IMG(@"back@2x") forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    [backBtn addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backBarButtonItem];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [rightView setBackgroundColor:[UIColor clearColor]];
    UILabel *leftLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 24, 24)];
    [leftLab setBackgroundColor:rgba(44, 188, 239, 1)];
    leftLab.layer.masksToBounds = YES;
    leftLab.layer.cornerRadius = 12;
    [leftLab setTextAlignment:NSTextAlignmentCenter];
    [leftLab setFont:[UIFont systemFontOfSize:10]];
    [leftLab setTag:1];
    [leftLab setText:@"0"];
    [leftLab setTextColor:[UIColor whiteColor]];
    [rightView addSubview:leftLab];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(28, 0, 34, 30)];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    [rightBut setTitle:@"完成" forState:UIControlStateNormal];
    [rightBut setTitleColor:rgba(44, 188, 239, 1) forState:UIControlStateNormal];
    [rightBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightBut addTarget:self action:@selector(finishPickingAssets:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightBut];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
    
    //蛇签
    _rightTipView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 108, 0, 108 + 25, 50)];
    [_rightTipView setBackgroundColor:rgba(243, 101, 25, 1)];
    [_rightTipView.layer setMasksToBounds:YES];
    [_rightTipView.layer setCornerRadius:25];
    [self.view addSubview:_rightTipView];
    UIPanGestureRecognizer *singleTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [_rightTipView addGestureRecognizer:singleTap];
    
    _monthLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 68, 32)];
    [_monthLab setBackgroundColor:_rightTipView.backgroundColor];
    [_monthLab setTextColor:[UIColor whiteColor]];
    [_monthLab setFont:[UIFont systemFontOfSize:28]];
    [_monthLab setTextAlignment:NSTextAlignmentRight];
    [_rightTipView addSubview:_monthLab];
    
    _yearLab = [[UILabel alloc] initWithFrame:CGRectMake(_monthLab.frameRight, _monthLab.frameY, _rightTipView.frameWidth - _monthLab.frameWidth - 25, 15)];
    [_yearLab setBackgroundColor:_rightTipView.backgroundColor];
    [_yearLab setTextColor:[UIColor whiteColor]];
    [_yearLab setFont:[UIFont systemFontOfSize:11]];
    [_yearLab setTextAlignment:NSTextAlignmentCenter];
    [_rightTipView addSubview:_yearLab];
    
    _dayLab = [[UILabel alloc] initWithFrame:CGRectMake(_yearLab.frameX, _yearLab.frameBottom, _yearLab.frameWidth, 17)];
    [_dayLab setBackgroundColor:_rightTipView.backgroundColor];
    [_dayLab setTextColor:[UIColor whiteColor]];
    [_dayLab setFont:[UIFont systemFontOfSize:13]];
    [_dayLab setTextAlignment:NSTextAlignmentCenter];
    [_rightTipView addSubview:_dayLab];
    
    [_rightTipView setHidden:YES];
}

- (void)backButton
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - 触摸滑动
- (void)singleTap:(UIPanGestureRecognizer *)recognizer
{
    if (self.collectionView.contentSize.height <= self.collectionView.frameHeight) {
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        _beginPoint = [recognizer locationInView:self.view];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [recognizer locationInView:self.view];
        
        CGFloat contentHei = self.collectionView.contentSize.height + self.collectionView.contentInset.bottom + self.collectionView.contentInset.top - self.collectionView.frameHeight,frameHei = SCREEN_HEIGHT - _rightTipView.frameHeight - 64;
        CGFloat diffence = point.y - _beginPoint.y;
        
        CGFloat lastY = _rightTipView.frameY + diffence;
        lastY = MAX(0, lastY);
        lastY = MIN(lastY, frameHei);
        [_rightTipView setFrameY:lastY];
        
        CGFloat contentOffY = lastY * contentHei / frameHei;
        [self.collectionView setContentOffset:CGPointMake(0, contentOffY)];
        
        [self changeSectionHeader:CGPointMake(0, contentOffY)];
        
        _beginPoint = point;
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        
    }
}

#pragma mark - CTAssetsViewCellDelegate
- (void)checkSelectCell:(UICollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSArray *assets = [_assetArr objectAtIndex:indexPath.section];
    AssetModel *tmAsset = assets[indexPath.item];
    if ([_selectAssets containsObject:tmAsset]) {
        [_selectAssets removeObject:tmAsset];
        [self setTitleWithSelectedIndexPaths:_selectAssets];
        for (CTAssetsViewCell *curCell in self.collectionView.visibleCells) {
            if (curCell != cell) {
                NSIndexPath *visibleIndexPath = [self.collectionView indexPathForCell:curCell];
                NSArray *visibleAssets = [_assetArr objectAtIndex:visibleIndexPath.section];
                AssetModel *visibleAsset = visibleAssets[visibleIndexPath.item];
                NSUInteger index = [_selectAssets indexOfObject:visibleAsset];
                if (index != NSNotFound) {
                    [curCell.button setTitle:[NSString stringWithFormat:@"%ld",(long)index + 1] forState:UIControlStateNormal];
                    [curCell.button setSelected:YES];
                }
            }
            else{
                ((CTAssetsViewCell *)cell).button.selected = NO;
                [((CTAssetsViewCell *)cell).button setTitle:@"" forState:UIControlStateNormal];
            }
        }
        return;
    }
    
    BOOL shouldChecked = [self shouldCheckedItemAt:indexPath];
    if (shouldChecked) {
        [_selectAssets addObject:tmAsset];
        [self setTitleWithSelectedIndexPaths:_selectAssets];
        ((CTAssetsViewCell *)cell).button.selected = YES;
        [((CTAssetsViewCell *)cell).button setTitle:[NSString stringWithFormat:@"%ld",(long)_selectAssets.count] forState:UIControlStateNormal];
    }
}

- (BOOL)shouldCheckedItemAt:(NSIndexPath *)indexPath
{
    CTAssetsPickerController *pic = (CTAssetsPickerController *)self.navigationController;
    
    NSArray *assets = [_assetArr objectAtIndex:indexPath.section];
    AssetModel *model = [assets objectAtIndex:indexPath.item];
    if (!model.asset) {
        pic.view.userInteractionEnabled = NO;
        //异步变同步
        __block BOOL hasChange = NO;
        __block NSString *tipStr = nil;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        dispatch_queue_t queue = dispatch_queue_create("com.queue.singal", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            [[GlobalManager defaultAssetsLibrary] assetForURL:[NSURL URLWithString:model.url] resultBlock:^(ALAsset *asset) {
                if (asset) {
                    hasChange = YES;
                    model.asset = asset;
                    [model reverseGeocodeLocationAddress];
                }
                else{
                    tipStr = @"该源文件已删除，请另选一张再试";
                }
                dispatch_semaphore_signal(sema);
            } failureBlock:^(NSError *error) {
                dispatch_semaphore_signal(sema);
                tipStr = error.domain;
            }];
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        pic.view.userInteractionEnabled = YES;
        if (!hasChange) {
            [self.view makeToast:tipStr duration:1.0 position:@"center"];
            return NO;
        }
    }
    
    //正常判断
    if (!model.isPhoto) {
        ALAssetRepresentation *representation = [model.asset defaultRepresentation];
        BOOL isMP4 = [representation.url.resourceSpecifier hasSuffix:@"mp4"];
        if (isMP4) {
            if (!_shouldTip) {
                [self.navigationController.view makeToast:@"非常抱歉，暂时不支持这种视频文件" duration:1.0 position:@"center"];
            }
            
            return NO;
        }
        if ([representation size] > 1024 * 1024 * 100) {
            if (!_shouldTip) {
                [self.navigationController.view makeToast:@"非常抱歉，暂时不支持超过100M的视频文件" duration:1.0 position:@"center"];
            }
            
            return NO;
        }
    }
    
    if (!pic.selectAll) {
        BOOL canCombine = pic.combine && (_selectAssets.count > 0);
        if (!model.isPhoto) {
            if (canCombine) {
                if (!_shouldTip) {
                    [self.navigationController.view makeToast:@"图片和视频不能同时选择哦" duration:1.0 position:@"center"];
                }
                
                return NO;
            }
            
            BOOL videoSelected = NO;
            for (AssetModel *model in _selectAssets)
            {
                if (!model.isPhoto){
                    videoSelected   = YES;
                    break;
                }
            }
            
            if (videoSelected) {
                if (!_shouldTip) {
                    [self.navigationController.view makeToast:@"您已经选择了一个视频，暂时不支持选择多个视频" duration:1.0 position:@"center"];
                }
                
                return NO;
            }
        }
        else if(canCombine){
            AssetModel *firstModel = [_selectAssets firstObject];
            if (!firstModel.isPhoto){
                if (!_shouldTip) {
                    [self.navigationController.view makeToast:@"图片和视频不能同时选择哦" duration:1.0 position:@"center"];
                }
                
                return NO;
            }
        }
    }
    
    CTAssetsPickerController *vc = (CTAssetsPickerController *)self.navigationController;
    BOOL should = (_selectAssets.count < vc.maximumNumberOfSelection);
    if (!should) {
        if (!_shouldTip) {
            [self.navigationController.view makeToast:[NSString stringWithFormat:@"非常抱歉，不能选择超过%ld张",(long)vc.maximumNumberOfSelection] duration:1.0 position:@"center"];
        }
    }
    return should;
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _mwphotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _mwphotos.count)
    {
        AssetModel *model = _mwphotos[index];
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:model.url]];
        if (!model.isPhoto) {
            photo.isVideo = YES;
            photo.videoURL = [NSURL URLWithString:model.url];
        }
        return photo;
    }
    return nil;
}

- (BOOL)shouldSelectItemAt:(NSInteger)index
{
    AssetModel *model = _mwphotos[index];
    return [_selectAssets containsObject:model];
}

- (BOOL)isCanSelectItemAt:(NSInteger)index browser:(MWPhotoBrowser *)browser
{
    NSArray *assets = [_assetArr objectAtIndex:_indexPath.section];
    if ([_selectAssets containsObject:assets[index]]) {
        return YES;
    }
    
    return [self shouldCheckedItemAt:[NSIndexPath indexPathForItem:index inSection:_indexPath.section]];
}

- (void)cancelSelectedItemAt:(NSInteger)index Should:(BOOL)sel
{
    AssetModel *model = _mwphotos[index];
    if (sel) {
        if (![_selectAssets containsObject:model]) {
            if (model.asset) {
                [_selectAssets addObject:model];
            }
            else{
                [[GlobalManager defaultAssetsLibrary] assetForURL:[NSURL URLWithString:model.url] resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        model.asset = asset;
                        [model reverseGeocodeLocationAddress];
                        [_selectAssets addObject:model];
                    }
                } failureBlock:^(NSError *error) {
                    NSLog(@"%@",error.description);
                }];
            }
        }
    }
    else{
        [_selectAssets removeObject:model];
    }
    
    for (CTAssetsViewCell *curCell in self.collectionView.visibleCells) {
        
        NSIndexPath *visibleIndexPath = [self.collectionView indexPathForCell:curCell];
        NSArray *visibleAssets = [_assetArr objectAtIndex:visibleIndexPath.section];
        AssetModel *visibleModel = visibleAssets[visibleIndexPath.item];
        NSUInteger index = [_selectAssets indexOfObject:visibleModel];
        if (index != NSNotFound) {
            [curCell.button setTitle:[NSString stringWithFormat:@"%ld",(long)index + 1] forState:UIControlStateNormal];
            [curCell.button setSelected:YES];
        }
        else{
            [curCell.button setTitle:@"" forState:UIControlStateNormal];
            [curCell.button setSelected:NO];
        }
    }
    
    [self setTitleWithSelectedIndexPaths:_selectAssets];
}

- (void)finishPreView:(NSInteger)index
{
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat contentHei = scrollView.contentSize.height + self.collectionView.contentInset.bottom + self.collectionView.contentInset.top - self.collectionView.frameHeight;
    if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= contentHei) {
        CGFloat frameHei = SCREEN_HEIGHT - _rightTipView.frameHeight - 64;
        CGFloat lastY = scrollView.contentOffset.y * frameHei / contentHei;
        [_rightTipView setFrameY:lastY];
        
        [self changeSectionHeader:scrollView.contentOffset];
    }
}

- (void)changeSectionHeader:(CGPoint)point
{
    NSIndexPath *newIndexPath = [self.collectionView indexPathForItemAtPoint:point];
    if (newIndexPath) {
        NSArray *array = _assetArr[newIndexPath.section];
        AssetModel *model = [array firstObject];
        NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:model.shooting_time.doubleValue];
        NSString* nsALAssetPropertyDate = [NSString stringByDate:@"yyyy-MM-dd" Date:curDate];
        NSArray *datesArr = [nsALAssetPropertyDate componentsSeparatedByString:@"-"];
        
        NSNumber *numYear = [NSNumber numberWithInteger:[datesArr[0] integerValue]];
        NSNumber *numMonth = [NSNumber numberWithInteger:[datesArr[1] integerValue]];
        NSNumber *numDay = [NSNumber numberWithInteger:[datesArr[2] integerValue]];
        [_yearLab setText:[numYear.stringValue stringByAppendingString:@"年"]];
        [_monthLab setText:[numMonth.stringValue stringByAppendingString:@"月"]];
        [_dayLab setText:[numDay.stringValue stringByAppendingString:@"日"]];
    }
    
}

- (void)resetSectionHeader
{
    [_rightTipView setHidden:NO];
    
    NSArray *array = _assetArr[0];
    AssetModel *model = [array firstObject];
    NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:model.shooting_time.doubleValue];
    NSString* nsALAssetPropertyDate = [NSString stringByDate:@"yyyy-MM-dd" Date:curDate];
    NSArray *datesArr = [nsALAssetPropertyDate componentsSeparatedByString:@"-"];
    
    NSNumber *numYear = [NSNumber numberWithInteger:[datesArr[0] integerValue]];
    NSNumber *numMonth = [NSNumber numberWithInteger:[datesArr[1] integerValue]];
    NSNumber *numDay = [NSNumber numberWithInteger:[datesArr[2] integerValue]];
    [_yearLab setText:[numYear.stringValue stringByAppendingString:@"年"]];
    [_monthLab setText:[numMonth.stringValue stringByAppendingString:@"月"]];
    [_dayLab setText:[numDay.stringValue stringByAppendingString:@"日"]];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = [_assetArr count];
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *assets = [_assetArr objectAtIndex:section];
    return assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kAssetsViewCellIdentifier;
    
    CTAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    NSArray *assets = [_assetArr objectAtIndex:indexPath.section];
    AssetModel *model = assets[indexPath.item];
    NSUInteger index = [_selectAssets indexOfObject:model];
    if (index == NSNotFound) {
        [cell.button setTitle:@"" forState:UIControlStateNormal];
        [cell.button setSelected:NO];
    }
    else{
        [cell.button setTitle:[NSString stringWithFormat:@"%ld",(long)index + 1] forState:UIControlStateNormal];
        [cell.button setSelected:YES];
    }
    [cell bind:model];
    
    return cell;
}

#pragma mark - 头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kAssetsSupplementaryViewIdentifier forIndexPath:indexPath];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *timeLab = (UILabel *)[view viewWithTag:1];
    if (!timeLab) {
        timeLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 16)];
        [timeLab setBackgroundColor:view.backgroundColor];
        [timeLab setTag:1];
        [timeLab setFont:[UIFont systemFontOfSize:12]];
        [timeLab setTextColor:[UIColor darkGrayColor]];
        [view addSubview:timeLab];
        
        UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 160, 1, 150, 24)];
        [numLab setFont:[UIFont systemFontOfSize:10]];
        [numLab setTag:2];
        [numLab setNumberOfLines:2];
        [numLab setTextColor:[UIColor darkGrayColor]];
        [numLab setTextAlignment:NSTextAlignmentRight];
        [view addSubview:numLab];
    }
    NSArray *array = _assetArr[indexPath.section];
    AssetModel *model = [array firstObject];
    NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:model.shooting_time.doubleValue];
    NSString* nsALAssetPropertyDate = [NSString stringByDate:@"yyyy年MM月dd日" Date:curDate];
    [timeLab setText:nsALAssetPropertyDate];
    
    UILabel *numLab = (UILabel *)[view viewWithTag:2];
    NSString *str = nil;
    NSInteger count = MIN(10, array.count);
    for (NSInteger i = 0; i < count; i++) {
        AssetModel *assetModel = array[i];
        if (assetModel.location_name.length > 0) {
            str = assetModel.location_name;
            break;
        }
    }
    [numLab setText:str];

    return view;
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.navigationController.topViewController != self) {
        return;
    }
    
    _indexPath = indexPath;
    
    _mwphotos = [NSMutableArray array];
    
    NSArray *assets = [_assetArr objectAtIndex:indexPath.section];
    [_mwphotos addObjectsFromArray:assets];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    [browser setCurrentPhotoIndex:indexPath.item];
    browser.selectedCount = [_selectAssets count];
    browser.totalCount = ((CTAssetsPickerController *)self.navigationController).maximumNumberOfSelection;
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)selectItems
{
    UIView *rightView = [[self.navigationItem.rightBarButtonItems lastObject] customView];
    UILabel *leftLab = [rightView viewWithTag:1];
    [leftLab setText:[NSString stringWithFormat:@"%ld",(long)[selectItems count]]];
}

#pragma mark - 压缩完毕
- (void)videoCompressedFinish:(NSString *)filePath
{
    self.navigationController.view.userInteractionEnabled = YES;
    for (NSInteger i = 0;i < _selectAssets.count;i++) {
        AssetModel *model = _selectAssets[i];
        if (!model.isPhoto) {
            [_selectAssets replaceObjectAtIndex:i withObject:filePath];
            break;
        }
    }
    
    CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
        [picker.delegate assetsPickerController:picker didFinishPickingAssets:_selectAssets];
    
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Actions
- (void)finishPickingAssets:(id)sender
{
    NSInteger count = _selectAssets.count;
    CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
    
    if (count == 0) {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [picker.delegate assetsPickerController:picker didFinishPickingAssets:_selectAssets];
        return;
    }
    
    if (!((CTAssetsPickerController *)self.navigationController).selectAll) {
        NSMutableArray *lstArr = [NSMutableArray array];
        for (AssetModel *model in _selectAssets) {
            if (!model.isPhoto) {
                /*
                PlayViewController *play = [[PlayViewController alloc] init];
                play.fileUrl = [NSURL URLWithString:model.url];
                __weak typeof(self)weakSelf = self;
                play.playResult = ^(NSString *path){
                    [weakSelf videoCompressedFinish:path];
                };
                [self.navigationController pushViewController:play animated:YES];
                 */
                return;
            }
            [lstArr addObject:model.asset];
        }
        
        CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [picker.delegate assetsPickerController:picker didFinishPickingAssets:lstArr];
        return;
    }
    
    if (self.operationQueue) {
        //正在请求中
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    if (!_progressView) {
        _progressView = [[ProgressCircleView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) / 2, (SCREEN_HEIGHT - 64 - 120) / 2, 120, 120)];
    }
    [_progressView.progressLab setText:@"图片和视频正在处理..."];
    if (![_progressView isDescendantOfView:self.view]) {
        [self.view addSubview:_progressView];
    }
    picker.view.userInteractionEnabled = NO;
    //先删除文件
    NSFileManager *manager = [NSFileManager defaultManager];
    for (NSString *str in _uploadArr) {
        if ([str isKindOfClass:[NSString class]] && [manager fileExistsAtPath:str]) {
            [manager removeItemAtPath:str error:nil];
        }
    }
    _uploadArr = [NSMutableArray array];
    _uploadUrls = [NSMutableArray array];
    _uploadIdxs = [NSMutableArray array];
    _netSource = [NSMutableArray array];
    _totalCount = count;
    BOOL shouldUpload = NO;
    NSString *timeStr = [NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSString getToday]];
    NSMutableArray *assetIdxs = [NSMutableArray array];
    DataBaseOperation *sqlOperation = [DataBaseOperation shareInstance];
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
    __weak typeof(detailInfo)weakDetail = detailInfo;
    for (NSInteger i = 0; i < count; i++) {
        AssetModel *model = _selectAssets[i];
        PhotoManagerModel *photoModel = [sqlOperation selectPathBy:model.url];
        if (photoModel) {
            photoModel.asset = model.asset;
            _totalCount--;
            [self.netSource addObject:photoModel];
        }
        else{
            shouldUpload = YES;
            @synchronized (weakSelf.uploadArr){
                [self.uploadArr addObject:[NSNull null]];
                [self.uploadUrls addObject:[NSNull null]];
                [self.uploadIdxs addObject:[NSNumber numberWithInteger:i]];
                [self.netSource addObject:[NSNull null]];
            }
            if (!model.isPhoto) {
                NSString *path = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%ld.mp4",(long)i]];
                path = [APPTmpDirectory stringByAppendingPathComponent:path];
                __weak typeof(model)weakAssetModel = model;
                [UIImage converVideoDimissionWithFilePath:[NSURL URLWithString:model.url] andOutputPath:path withCompletion:^(NSError *error) {
                    @synchronized (weakSelf.uploadArr) {
                        weakSelf.totalCount--;
                        if (!error) {
                            NSInteger nullCount = 0;
                            for (NSInteger m = 0; m <= i; m++) {
                                id sub = [weakSelf.netSource objectAtIndex:m];
                                if ([sub isKindOfClass:[NSNull class]]) {
                                    nullCount++;
                                }
                            }
                            [weakSelf.uploadArr replaceObjectAtIndex:nullCount - 1 withObject:path];
                            
                            NSMutableDictionary *file_info = [NSMutableDictionary dictionary];
                            [file_info setObject:weakAssetModel.shooting_time forKey:@"shooting_time"];
                            [file_info setObject:[NSString getFileMD5WithPath:path] forKey:@"md5"];
                            [file_info setObject:[NSString getDeviceUDID] forKey:@"device_no"];
                            [file_info setObject:weakAssetModel.url forKey:@"file_client_path"];
                            [file_info setObject:@"2" forKey:@"type"];
                            if (weakAssetModel.longitude > 0) {
                                [file_info setObject:[NSString stringWithFormat:@"%@,%@",weakAssetModel.latitude,weakAssetModel.longitude] forKey:@"location"];
                            }
                            else{
                                [file_info setObject:@"" forKey:@"location"];
                            }
                            if (weakAssetModel.location_name > 0) {
                                [file_info setObject:weakAssetModel.location_name forKey:@"location_name"];
                            }
                            else{
                                [file_info setObject:@"" forKey:@"location_name"];
                            }
                            NSDictionary *lstDic = @{@"token":weakDetail.token,@"file_info":file_info};
                            NSData *json = [NSJSONSerialization dataWithJSONObject:lstDic options:NSJSONWritingPrettyPrinted error:nil];
                            NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                            lstJson = [NSString encrypt:lstJson];
                            NSString *gbkStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)lstJson,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
                            NSString *url = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
                            [weakSelf.uploadUrls replaceObjectAtIndex:nullCount - 1 withObject:url];
                        }
                    }
                    if (weakSelf.totalCount == 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf uploadSources];
                        });
                    }
                } To:nil Sel:nil];
            }
            else{
                [assetIdxs addObject:[NSNumber numberWithInteger:i]];
                shouldUpload = YES;
            }
        }
    }
    
    if (assetIdxs.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSNumber *number in assetIdxs) {
                NSInteger i = number.integerValue;
                AssetModel *model = weakSelf.selectAssets[i];
                @autoreleasepool {
                    NSString *path = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%ld.jpg",(long)i]];
                    path = [APPTmpDirectory stringByAppendingPathComponent:path];
                    UIImage *image = [UIImage imageWithCGImage:model.asset.defaultRepresentation.fullResolutionImage scale:model.asset.defaultRepresentation.scale orientation:(UIImageOrientation)model.asset.defaultRepresentation.orientation];
                    image = [image fixOrientation];
                    NSData *data = UIImageJPEGRepresentation(image, 0.8);
                    [data writeToFile:path atomically:NO];
                    @synchronized (weakSelf.uploadArr) {
                        weakSelf.totalCount--;
                        NSInteger nullCount = 0;
                        for (NSInteger m = 0; m <= i; m++) {
                            id sub = [weakSelf.netSource objectAtIndex:m];
                            if ([sub isKindOfClass:[NSNull class]]) {
                                nullCount++;
                            }
                        }
                        [weakSelf.uploadArr replaceObjectAtIndex:nullCount - 1 withObject:path];
                        
                        NSMutableDictionary *file_info = [NSMutableDictionary dictionary];
                        [file_info setObject:model.shooting_time forKey:@"shooting_time"];
                        [file_info setObject:[NSString getFileMD5WithPath:path] forKey:@"md5"];
                        [file_info setObject:[NSString getDeviceUDID] forKey:@"device_no"];
                        [file_info setObject:model.url forKey:@"file_client_path"];
                        [file_info setObject:@"1" forKey:@"type"];
                        if (model.longitude > 0) {
                            [file_info setObject:[NSString stringWithFormat:@"%@,%@",model.latitude,model.longitude] forKey:@"location"];
                        }
                        else{
                            [file_info setObject:@"" forKey:@"location"];
                        }
                        if (model.location_name > 0) {
                            [file_info setObject:model.location_name forKey:@"location_name"];
                        }
                        else{
                            [file_info setObject:@"" forKey:@"location_name"];
                        }
                        NSDictionary *lstDic = @{@"token":weakDetail.token,@"file_info":file_info};
                        NSData *json = [NSJSONSerialization dataWithJSONObject:lstDic options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                        lstJson = [NSString encrypt:lstJson];
                        NSString *gbkStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)lstJson,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
                        NSString *url = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
                        [weakSelf.uploadUrls replaceObjectAtIndex:nullCount - 1 withObject:url];
                    }
                }
                if (weakSelf.totalCount == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf uploadSources];
                    });
                }
            }
        });
    }
    else if (!shouldUpload){
        CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [picker.delegate assetsPickerController:picker didFinishPickingAssets:_netSource];
    }
}

#pragma mark - 资源上传
- (void)uploadSources
{
    BOOL videoExcep = NO;
    for (id sub in self.uploadArr) {
        if ([sub isKindOfClass:[NSNull class]]) {
            videoExcep = YES;
            break;
        }
    }
    
    self.navigationController.view.userInteractionEnabled = YES;
    
    if (videoExcep) {
        [_progressView removeFromSuperview];
        [self.view makeToast:@"视频处理异常，请您稍后重试" duration:1.0 position:@"center"];
        return;
    }
    else{
        NSInteger totalCount = [_selectAssets count],uploadCount = [_uploadArr count];
        [_progressView.progressLab setText:[NSString stringWithFormat:@"图片与视频上传进度%ld/%ld",(long)(totalCount - uploadCount),(long)totalCount]];
        _progressView.loadingIndicator.progress = (totalCount - uploadCount) / ((CGFloat)totalCount);
    }
    
    self.view.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    
    self.operationQueue = [HttpClient uploadMutiImages:_uploadArr url:_uploadUrls parameters:nil singleFinishBlock:^(NSInteger index, id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [weakSelf uploadSingleFinish:NO Data:responseObject At:index];
            }
            else{
                NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSString *retJson = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                id retData = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                if ([retData isKindOfClass:[NSArray class]]) {
                    retData = [retData firstObject];
                }
                NSString *ret_code = [retData valueForKey:@"ret_code"];
                if ((ret_code.length > 0) && [ret_code isEqualToString:@"0000"]) {
                    [weakSelf uploadSingleFinish:YES Data:retData At:index];
                }
                else{
                    [weakSelf uploadSingleFinish:NO Data:retData At:index];
                }
                
            }
        });
        
    } completion:^(NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf uploadFinish];
        });
    }];
}

- (void)uploadSingleFinish:(BOOL)suc Data:(id)result At:(NSInteger)index
{
    if (!suc) {
        if (_operationQueue) {
            [_operationQueue cancelAllOperations];
            _operationQueue = nil;
            [self.view makeToast:@"可能因手机网络连接异常导致上传失败，请您稍后重试" duration:1.0 position:@"center"];
        }
        [_progressView removeFromSuperview];
        self.view.userInteractionEnabled = YES;
        
    }
    else{
        NSString *path = [result valueForKey:@"path"];
        NSString *picture = [result valueForKey:@"picture"];
        NSInteger atIdx = [[_uploadIdxs objectAtIndex:index] integerValue];
        AssetModel *assetModel = [_selectAssets objectAtIndex:atIdx];
        NSString *uploadPath = _uploadArr[index];
        
        PhotoManagerModel *managerModel = [[PhotoManagerModel alloc] init];
        managerModel.asset = assetModel.asset;
        managerModel.picture = picture;
        managerModel.upload_time = [[NSNumber numberWithDouble:[[NSString getToday] timeIntervalSince1970]] stringValue];
        managerModel.shooting_time = assetModel.shooting_time;
        managerModel.file_size = @"0";
        managerModel.location = [NSString stringWithFormat:@"%@,%@",assetModel.latitude,assetModel.longitude];
        managerModel.md5 = [NSString getFileMD5WithPath:uploadPath];
        managerModel.path = path;
        managerModel.upload_user = [GlobalManager shareInstance].detailInfo.user.id;
        managerModel.file_type = assetModel.isPhoto ? @"1" : @"2";
        managerModel.file_client_path = assetModel.url;
        managerModel.device_no = [NSString getDeviceUDID];
        managerModel.location_name = assetModel.location_name;
        managerModel.loadState = @(1);
        
        [_netSource replaceObjectAtIndex:atIdx withObject:managerModel];
        
        NSInteger count = 0,totalCount = [_selectAssets count];
        for (id sub in _netSource) {
            if ([sub isKindOfClass:[NSNull class]]) {
                count++;
            }
        }
        [_progressView.loadingIndicator setProgress:(CGFloat)(totalCount - count) / totalCount];
        [_progressView.progressLab  setText:[NSString stringWithFormat:@"图片与视频上传进度%ld/%ld",(long)totalCount - count,(long)totalCount]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DataBaseOperation shareInstance] updateOrReplaceModel:managerModel];
        });
    }
}

- (void)uploadFinish
{
    self.operationQueue = nil;
    [_progressView removeFromSuperview];
    self.view.userInteractionEnabled = YES;
    BOOL success = YES;
    for (id sub in _netSource) {
        if ([sub isKindOfClass:[NSNull class]]) {
            success = NO;
            break;
        }
    }
    if (success) {
        CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [picker.delegate assetsPickerController:picker didFinishPickingAssets:_netSource];
    }
    else{
        [self.view makeToast:@"可能因手机网络连接异常导致上传失败，请您稍后重试" duration:1.0 position:@"center"];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end



#pragma mark - CTAssetsViewCell

@implementation CTAssetsViewCell
{
    UIImageView *_videoIcon,*_backImg;
}

static UIImage *videoIcon;

+ (void)initialize
{
    videoIcon       = [UIImage imageNamed:@"videoPlay2"];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                     = YES;
        self.isAccessibilityElement     = YES;
        self.accessibilityTraits        = UIAccessibilityTraitImage;
        
        _backImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kThumbnailLength, kThumbnailLength)];
        [self.contentView addSubview:_backImg];
        
        _videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 20, 20)];
        [_videoIcon setImage:[UIImage imageNamed:@"videoPlay2"]];
        [self.contentView addSubview:_videoIcon];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setBackgroundImage:CREATE_IMG(@"circleGrey") forState:UIControlStateNormal];
        [_button setBackgroundImage:CREATE_IMG(@"circleGreen") forState:UIControlStateSelected];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.layer.masksToBounds = YES;
        _button.layer.cornerRadius = 13.5;
        [_button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button setFrame:CGRectMake(kThumbnailLength - 25, 2, 25, 25)];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.contentView addSubview:_button];
        
    }
    
    return self;
}

- (void)pressButton:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^{
        _button.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        _button.transform = CGAffineTransformIdentity;
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(checkSelectCell:)]) {
        [_delegate checkSelectCell:self];
    }
}

- (void)bind:(AssetModel *)assetModel
{
    NSString *md5Str = [NSString md5:assetModel.url];
    NSString *lastPath = [[NSString getCachePath:@"thumbnail"] stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
    _backImg.image  = [UIImage imageWithContentsOfFile:lastPath];
    _videoIcon.hidden = assetModel.isPhoto;
}

@end
