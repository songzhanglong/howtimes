//
//  FastMakeGrowViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "FastMakeGrowViewController.h"
#import "DataBaseOperation.h"
#import "PhotoManagerModel.h"
#import "FastMakeCell.h"
#import "SingleTemplateView.h"
#import "KxMenu.h"

#define FastMakeHeader          @"fastMakeHeader"
#define FastMakeCellID          @"fastMakeCell"
#define kDegreesToRadian(x) (M_PI * (x) / 360.0 )
#define kRadianToDegrees(radian) (radian* 360.0 )/(M_PI)

@interface FastMakeGrowViewController () <SingleTemplateViewDelegate,FastMakeCellDelegate>

@end

@implementation FastMakeGrowViewController 
{
//    UIView *_rightTipView;
//    UILabel *_monthLab,*_yearLab,*_dayLab;
//    CGPoint _beginPoint;
    CGPoint _indexPoint;
    UILabel *_numLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"快速制作";
    self.navigationController.navigationBar.translucent = NO;
    
    [self createRightBarButton];
    
    [self.view setBackgroundColor:CreateColor(240, 239, 244)];
    _datailTemplates = [NSMutableArray array];
    _selectDictory = [NSMutableDictionary dictionary];
    
    [self createHeadView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    NSInteger numPerRow = 4,itemMargin = 10 ,itemWidth = (SCREEN_WIDTH - itemMargin * (numPerRow + 2)) / numPerRow;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.minimumLineSpacing = itemMargin;
    layout.minimumInteritemSpacing = itemMargin;
    layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 26);
    [self createCollectionViewLayout:layout Action:nil Param:nil Header:NO Foot:NO];
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, itemMargin * 1.5, itemMargin, itemMargin * 1.5)];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [self.collectionView setFrame:CGRectMake(0, 80, SCREEN_WIDTH, SCREEN_HEIGHT - 70 - 64)];
    [self.collectionView registerClass:[FastMakeCell class] forCellWithReuseIdentifier:FastMakeCellID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:FastMakeHeader];
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    /*
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
     */
    
    [self sendRequest];
}

- (void)createRightBarButton
{
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 30, 30)];
    [rightBut.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [rightBut setTitle:@"+" forState:UIControlStateNormal];
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    [self.navigationItem setRightBarButtonItems:@[rightItem] animated:YES];
}

- (void)addAction:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"同步"
                     image:CREATE_IMG(@"mark_ synch")
                    target:self
                    action:@selector(submitMarkGrow:)],
      
      [KxMenuItem menuItem:@"插件"
                     image:CREATE_IMG(@"mark_plug")
                    target:self
                    action:NULL],
      
      [KxMenuItem menuItem:@"表单"
                     image:CREATE_IMG(@"mark_table")
                    target:self
                    action:NULL]
      ];
    
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:CGRectMake(sender.frameX, sender.frameY + 18, sender.frameWidth, sender.frameHeight)
                 menuItems:menuItems];
}

- (void)submitMarkGrow:(id)sender
{
    NSMutableArray *selectArray = [NSMutableArray array];
    for (NSInteger i = 0;i < _datailTemplates.count;i++) {
        //NSMutableDictionary *selectDictory = [NSMutableDictionary dictionary];
        GrowDetailModel *model = _datailTemplates[i];
        //[selectDictory setObject:model.template_detail_id forKey:@"template_detail_id"];
        //[selectDictory setObject:model.id forKey:@"c_id"];
        NSString *totalString = [NSString stringWithFormat:@"\"template_detail_id\":\"%@\"",model.template_detail_id];
        totalString = [totalString stringByAppendingFormat:@",\"c_id\":\"%@\"",model.id];
        
        GrowContent *content = model.detail_content;
        if ([model.detail_type integerValue] == 2) {
            NSMutableArray *gallaryList = [NSMutableArray array];
            NSMutableArray *src_image_list = [NSMutableArray array];
            for (ImageCoor *coor in content.image_coor) {
                if ([coor.imgs count] == 0) {
                    [self.view makeToast:@"您还有模板没有制作哦！" duration:1.0 position:@"center"];
                    return;
                }
                
                NSMutableArray *photosList = [NSMutableArray array];
                for (PhotoManagerModel *item in coor.imgs) {
                    if ([item.is_cover integerValue] == 1) {
                        NSString *nString = [NSString stringWithFormat:@"\"%@\"",item.path];
                        [src_image_list addObject:nString];
                    }
                    
                    NSString *nString = [NSString stringWithFormat:@"\"type\":\"%ld\"",(long)[item.file_type integerValue]];
                    nString = [nString stringByAppendingFormat:@",\"path\":\"%@\"",item.path];
                    nString = [nString stringByAppendingFormat:@",\"is_cover\":\"%@\"",[NSString stringWithFormat:@"%@",item.is_cover]];
                    [photosList addObject:[NSString stringWithFormat:@"{%@}",nString]];
                }
                NSString *photoStr = [NSString stringWithFormat:@"[%@]",[photosList componentsJoinedByString:@","]];
                [gallaryList addObject:photoStr];
            }
            NSString *sre_imageList = [NSString stringWithFormat:@"[%@]",[src_image_list componentsJoinedByString:@","]];
            totalString = [totalString stringByAppendingFormat:@",\"src_image_list\":%@",sre_imageList];
            //[selectDictory setObject:sre_imageList forKey:@"src_image_list"];
            
            NSString *sre_gallaryList = [NSString stringWithFormat:@"[%@]",[gallaryList componentsJoinedByString:@","]];
            totalString = [totalString stringByAppendingFormat:@",\"src_gallery_list\":%@",sre_gallaryList];
            //[selectDictory setObject:sre_gallaryList forKey:@"src_gallery_list"];
        }else {
            NSMutableArray *src_image_list = [NSMutableArray array];
            for (ImageCoor *coor in content.image_coor) {
                if ([coor.imgs count] == 0) {
                    [self.view makeToast:@"您封面封底模板没有制作哦！" duration:1.0 position:@"center"];
                    return;
                }
                PhotoManagerModel *item = coor.imgs[0];
                NSString *nString = [NSString stringWithFormat:@"\"%@\"",item.path];
                [src_image_list addObject:nString];
            }
            NSString *sre_imageList = [NSString stringWithFormat:@"[%@]",[src_image_list componentsJoinedByString:@","]];
            totalString = [totalString stringByAppendingFormat:@",\"src_image_list\":%@",sre_imageList];
            //[selectDictory setObject:sre_imageList forKey:@"src_image_list"];
        }
        
        NSMutableArray *src_txt_list = [NSMutableArray array];
        for (WordCoor *coor in content.word_coor) {
            NSString *nString = [NSString stringWithFormat:@"\"txt\":\"%@\"",coor.default_txt];
            nString = [nString stringByAppendingFormat:@",\"voice\":\"%@\"",@""];
            [src_txt_list addObject:[NSString stringWithFormat:@"{%@}",nString]];
        }
        
        NSString *sre_txtList = [NSString stringWithFormat:@"[%@]",[src_txt_list componentsJoinedByString:@","]];
        totalString = [totalString stringByAppendingFormat:@",\"src_txt_list\":%@",sre_txtList];
        //[selectDictory setObject:sre_txtList forKey:@"src_txt_list"];
        
        [selectArray addObject:[NSString stringWithFormat:@"{%@}",totalString]];
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"fastProduction"];
    [param setObject:_grow_id forKey:@"grow_id"];
    [param setObject:_template_id forKey:@"template_id"];
    [param setObject:_batch_id forKey:@"batch_id"];
    [param setObject:manager.detailInfo.user.id forKey:@"user_id"];
    NSString *select = [NSString stringWithFormat:@"[%@]",[selectArray componentsJoinedByString:@","]];
    [param setObject:select forKey:@"data"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"production"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf saveMarkGrowFinish:error Data:data];
        });
    }];
}

#pragma mark - request save mark grow finish
- (void)saveMarkGrowFinish:(NSError *)error Data:(id)result{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)sendRequest
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getUserTemplate"];
    [param setObject:_batch_id forKey:@"batch_id"];
    [param setObject:manager.detailInfo.user.id forKey:@"user_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"templateSet"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getMarkGrowFinish:error Data:data];
        });
    }];
}

#pragma mark - request finish
- (void)getMarkGrowFinish:(NSError *)error Data:(id)result{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [result valueForKey:@"ret_data"];
        NSArray *template = [ret_data valueForKey:@"template"];
        NSMutableArray *array = [NSMutableArray array];
        if (template && [template isKindOfClass:[NSArray class]]) {
            array = [GrowDetailModel arrayOfModelsFromDictionaries:template error:nil];
        }
        _datailTemplates = array;
        
        [self setSingleTemplateView];
    }
}

- (void)setSingleTemplateView
{
    for (int i = 0; i < [_datailTemplates count]; i++) {
        SingleTemplateView *singleView = [[SingleTemplateView alloc] initWithFrame:CGRectMake(_scrollView.frameWidth * i, 0, _scrollView.frameWidth, _scrollView.frameHeight)];
        singleView.delegate = self;
        [singleView setContentView:_datailTemplates[i]];
        [_scrollView addSubview:singleView];
    }
    [_scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * [_datailTemplates count], 70)];
}

- (void)createHeadView
{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
        [scrollView setBackgroundColor:[UIColor whiteColor]];
        _scrollView = scrollView;
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        scrollView.clipsToBounds = YES;
        scrollView.scrollEnabled = YES;
        scrollView.bounces = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        scrollView.userInteractionEnabled = YES;
        [self.view addSubview:scrollView];
    }
}

#pragma mark - scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _scrollView)
    {
//        CGFloat pageWidth = scrollView.frame.size.width;
//        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *albums = [[DataBaseOperation shareInstance] selectNetAndLocalAlbum:[GlobalManager shareInstance].detailInfo.user.id];
        NSMutableArray *cusArr = [NSMutableArray array];
        for (NSInteger i = 0; i < albums.count; i++) {
            PhotoManagerModel *model = [albums objectAtIndex:i];
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
            weakSelf.dataSource = cusArr;
            [weakSelf.collectionView reloadData];
//            if ([weakSelf.dataSource count] > 0) {
//                [weakSelf resetSectionHeader];
//            }
//            
        });
    });
}

#pragma mark - SingleTemplateView delegate
- (void)nextTemplateToScrollView:(SingleTemplateView *)view
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    page++;
    if ([_datailTemplates count] <= 0  || page >= [_datailTemplates count]) {
        return;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame) * page, 0.0f);
    [UIView commitAnimations];
}

- (void)selectImageToScrollView:(SingleTemplateView *)view idx:(NSInteger)idx
{
    UIButton *currBtn = (UIButton *)[view viewWithTag:idx + 1];
    if (currBtn) {
        _indexPoint = currBtn.center;
    }
    UILabel *numLabel = (UILabel *)[view viewWithTag:idx + 10];
    if (numLabel) {
        _numLabel = numLabel;
    }
    _selectsData = [NSMutableArray array];
    //[ [{type:1,path:xxx,is_cover:1,picture:""}] , [ ] ]
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    GrowDetailModel *model = [_datailTemplates objectAtIndex:page];
    GrowContent *detail_content = model.detail_content;
    _imgItem = [detail_content.image_coor objectAtIndex:idx];
    
    _selectsData = _imgItem.imgs;
    
    for (int i = 0; i < [self.dataSource count]; i++) {
        NSArray *arr = self.dataSource[i];
        for (int j = 0; j < [arr count]; j++) {
            //PhotoManagerModel *item = arr[j];
            //item.isChecked = NO;
        }
    }
    
    for (PhotoManagerModel *model in _imgItem.imgs) {
        for (int i = 0; i < [self.dataSource count]; i++) {
            NSArray *arr = self.dataSource[i];
            for (int j = 0; j < [arr count]; j++) {
                PhotoManagerModel *item = arr[j];
                if ([model.path isEqualToString:item.path]) {
                    //item.isChecked = YES;
                }
            }
        }
    }
    
    [self.collectionView reloadData];
}
/*
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
        NSArray *array = self.dataSource[newIndexPath.section];
        PhotoManagerModel *model = [array firstObject];
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
    
    NSArray *array = self.dataSource[0];
    PhotoManagerModel *model = [array firstObject];
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
*/
#pragma mark - 触摸滑动
/*
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
}*/

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

- (void)checkItemOf:(UICollectionViewCell *)cell
{
    if (!_selectsData) {
        _selectsData = [NSMutableArray array];
    }
    
    if (!_imgItem) {
        [self.view makeToast:@"请先选择要制作的模板区域" duration:1.0 position:@"center"];
        return;
    }
    
    FastMakeCell *sel_cell = (FastMakeCell *)cell;
    if (!sel_cell.checkBut.isSelected) {
        [_selectsData removeObject:sel_cell.managerPhoto];
        
        _numLabel.hidden = !([_selectsData count] > 0);
        [_numLabel setText:[NSString stringWithFormat:@"%ld",(long)[_selectsData count]]];
        return;
    }else {
        if ([_selectsData count] > 8) {
            [self.view makeToast:@"图集最多只能选9个资源文件" duration:1.0 position:@"center"];
            return;
        }
    }
    
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    GrowDetailModel *model = [_datailTemplates objectAtIndex:page];
    if ([model.detail_type integerValue] == 2) {
        
        BOOL find = NO;
        for (PhotoManagerModel *model in _selectsData) {
            if ([model.is_cover integerValue] == 1) {
                find = YES;
                break;
            }
        }
        
        if (!find && [sel_cell.managerPhoto.file_type integerValue] == 1) {
            sel_cell.managerPhoto.is_cover = @"1";
        }else {
            sel_cell.managerPhoto.is_cover = @"0";
        }
        [_selectsData addObject:sel_cell.managerPhoto];
        _imgItem.imgs = _selectsData;
    }
    else {
        if ([_selectsData count] > 0) {
            sel_cell.checkBut.selected = NO;
            [self.view makeToast:@"只能选择一张图片来制作封面封底模板" duration:1.0 position:@"center"];
            return;
        }
        
        if ([sel_cell.managerPhoto.file_type integerValue] == 1) {
            sel_cell.managerPhoto.is_cover = @"1";
            [_selectsData addObject:sel_cell.managerPhoto];
            _imgItem.imgs = _selectsData;
        }else {
            sel_cell.checkBut.selected = NO;
            [self.view makeToast:@"只能选择图片来制作封面封底模板" duration:1.0 position:@"center"];
        }
    }
    
    CGRect rectInTableView = [self.collectionView convertRect:cell.frame toView:self.collectionView];
    CGRect rect = [self.collectionView convertRect:rectInTableView toView:[self.collectionView superview]];
    
    UIImageView *tempImg = [[UIImageView alloc] initWithFrame:rect];
    [tempImg setImage:sel_cell.contentImg.image];
    [self.view addSubview:tempImg];
    
    [self rotate360DegreeWithImageView:tempImg];
    [UIView animateWithDuration:0.5 // 动画时长
                          delay:0.0 // 动画延迟
                        options:UIViewAnimationOptionCurveEaseIn // 动画过渡效果
                     animations:^{
                         // code...
                         CGPoint point = tempImg.center;
                         point.y = _indexPoint.y;
                         point.x = _indexPoint.x;
                         tempImg.frameWidth = 0.0;
                         tempImg.frameHeight = 0.0;
                         [tempImg setCenter:point];
                     }
                     completion:^(BOOL finished) {
                         // 动画完成后执行
                         // code...
                         [self.view.layer removeAllAnimations];
                         [tempImg removeFromSuperview];
                         _numLabel.hidden = !([_selectsData count] > 0);
                         [_numLabel setText:[NSString stringWithFormat:@"%ld",(long)[_selectsData count]]];
                     }];
}

#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = [self.dataSource count];
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *assets = [self.dataSource objectAtIndex:section];
    return assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = FastMakeCellID;
    
    FastMakeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    NSArray *assets = [self.dataSource objectAtIndex:indexPath.section];
    PhotoManagerModel *model = assets[indexPath.item];
    [cell resetPhotoData:model];
    
    return cell;
}

#pragma mark - 头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:FastMakeHeader forIndexPath:indexPath];
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
    NSArray *array = self.dataSource[indexPath.section];
    PhotoManagerModel *model = [array firstObject];
    NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:model.shooting_time.doubleValue];
    NSString* nsALAssetPropertyDate = [NSString stringByDate:@"yyyy年MM月dd日" Date:curDate];
    [timeLab setText:nsALAssetPropertyDate];
    
    UILabel *numLab = (UILabel *)[view viewWithTag:2];
    NSString *str = nil;
    NSInteger count = MIN(10, array.count);
    for (NSInteger i = 0; i < count; i++) {
        PhotoManagerModel *assetModel = array[i];
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
    
}

@end
