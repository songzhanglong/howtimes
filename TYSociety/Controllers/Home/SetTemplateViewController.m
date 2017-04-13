//
//  SetTemplateViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/7/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SetTemplateViewController.h"
#import "SetTemplateHeader.h"
#import "HorizontalButton.h"
#import "GrowTemplateModel.h"
#import "SelectTempalteViewController.h"
#import "TemplateModel.h"
#import "CollaborationViewController.h"
#import "GrowAlertView.h"
#import "SelectTemplateView.h"
#import "TimeRecordInfo.h"
#import "BatchMakeViewController.h"
#import "CustomerModel.h"
#import "MWPhotoBrowser.h"
#import "GoodsInfoView.h"
#import "YWCMainViewController.h"
#import "CustomerListViewController.h"
#import "CraftInfoModel.h"
#import "AddressBookViewController.h"

@interface SetTemplateViewController ()<GrowAlertViewDelegate,SetTemplateHeaderDelagate,SelectTemplateViewDelegate,MWPhotoBrowserDelegate,UIAlertViewDelegate>
{
    SetTemplateHeader *_templateHeader;
    NSMutableDictionary *_indexDictory;
    NSInteger _currSection;
    UIScrollView *_scrollView;
    NSMutableArray *_otherArray,*_coverArray,*_mwphotos;
    UILabel *_tpl_nums;
    BOOL _goBack;
}
@end
@implementation SetTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"设置模板";
    self.navigationController.navigationBar.translucent = NO;
    [self.view setBackgroundColor:CreateColor(240, 239, 244)];
    
    _currSection = -1;
    _indexDictory = [NSMutableDictionary dictionary];
    _otherArray = [NSMutableArray array];
    _coverArray = [NSMutableArray array];
    _mwphotos = [NSMutableArray array];
    
    [self sendRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isBack) {
        _goBack = YES;
        _isBack = NO;
        
        [self sendRequest];
    }
}

#pragma mark - UI
- (void)initSubContentViews:(NSMutableArray *)indexArr
{
    [self createHeadView:indexArr];
    
    [self.view setUserInteractionEnabled:YES];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5);
    self.collectionView = [[XWDragCellCollectionView alloc] initWithFrame:CGRectMake(10, 137 + 60, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 197 - 64 - 56) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    ((XWDragCellCollectionView *)self.collectionView).shakeLevel = 3.0f;
    [self.collectionView setUserInteractionEnabled:YES];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    self.collectionView.backgroundColor = CreateColor(235, 233, 247);
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SetTemplateCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SetHeadCell"];
    
    [self.view addSubview:self.collectionView];
    
    [self setBottemView];
    
    [self setMayCraftBtn];
}

- (void)backToPreControl:(id)sender
{
//    for (id controller in self.navigationController.viewControllers) {
//        if ([controller isKindOfClass:[AddressBookViewController class]]) {
//            ((AddressBookViewController *)controller).batchCustomers.is_create_grow = [NSNumber numberWithInteger:1];
//            ((AddressBookViewController *)controller).batchCustomers.batch_id = _batch_id;
//            ((AddressBookViewController *)controller).batchCustomers.grow_id = _grow_id;
//            ((AddressBookViewController *)controller).batchCustomers.consumers = (NSMutableArray<CustomerModel> *)_customers;
//            [((AddressBookViewController *)controller) setGoBack:YES];
//            break;
//        }
//    }
//    [self.navigationController popViewControllerAnimated:YES];
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[AddressBookViewController class]]) {
            if ([self.navigationController.viewControllers count] > 2) {
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
            }
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createHeadView:(NSMutableArray *)indexArr
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [headView setBackgroundColor:CreateColor(225, 216, 254)];
    [self.view addSubview:headView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20, 20)];
    [tipLabel setBackgroundColor:[UIColor clearColor]];
    [tipLabel setTextColor:CreateColor(170, 146, 251)];
    [tipLabel setFont:[UIFont systemFontOfSize:14]];
    [tipLabel setText:@"请选择封面封底模板"];
    [headView addSubview:tipLabel];
    
    UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, headView.frameBottom, SCREEN_WIDTH, 137)];
    [bgview setBackgroundColor:CreateColor(240, 239, 244)];
    [bgview setUserInteractionEnabled:YES];
    [self.view addSubview:bgview];
    
    BOOL is_double = [[_indexDictory valueForKey:@"is_double"] integerValue];
    if (!_templateHeader) {
        _templateHeader = [[SetTemplateHeader alloc] init];
        _templateHeader.delegate = self;
        _templateHeader.is_double = is_double;
        _templateHeader.resource = is_double ? _coverArray : indexArr;
        [_templateHeader createCollectionViewTo:bgview];
    }
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, bgview.frameBottom, SCREEN_WIDTH, 30)];
    [footView setBackgroundColor:CreateColor(225, 216, 254)];
    [self.view addSubview:footView];
    
    UILabel *tipLab = tipLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 140, 20)];
    _tpl_nums = tipLab;
    [tipLab setBackgroundColor:headView.backgroundColor];
    [tipLab setFont:[UIFont systemFontOfSize:14]];
    [tipLab setTextColor:CreateColor(170, 146, 251)];
    [tipLab setText:@"请选择内容模板"];
    [footView addSubview:tipLab];
    
    HorizontalButton *_cleanBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
    _cleanBut.imgSize = CGSizeMake(14, 14);
    _cleanBut.textSize = CGSizeMake(56, 30);
    [_cleanBut setFrame:CGRectMake(SCREEN_WIDTH - 175, 0, 70, 30)];
    [_cleanBut addTarget:self action:@selector(cleanTheme:) forControlEvents:UIControlEventTouchUpInside];
    [_cleanBut setImage:CREATE_IMG(@"clean_theme_end") forState:UIControlStateNormal];
    [_cleanBut setTitleColor:CreateColor(100, 100, 100) forState:UIControlStateNormal];
    [_cleanBut setTitle:@"清列表" forState:UIControlStateNormal];
    [_cleanBut.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_cleanBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [footView addSubview:_cleanBut];
    
    HorizontalButton *_horiBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
    _horiBut.imgSize = CGSizeMake(14, 41.0 / 3);
    _horiBut.textSize = CGSizeMake(70, 30);
    [_horiBut setFrame:CGRectMake(SCREEN_WIDTH - 94, 0, 84, 30)];
    [_horiBut addTarget:self action:@selector(addTheme:) forControlEvents:UIControlEventTouchUpInside];
    [_horiBut setImage:CREATE_IMG(@"template_add_theme") forState:UIControlStateNormal];
    [_horiBut setTitleColor:CreateColor(100, 100, 100) forState:UIControlStateNormal];
    [_horiBut setTitle:@"添加主题" forState:UIControlStateNormal];
    [_horiBut.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_horiBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [footView addSubview:_horiBut];
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        UIView *footView = [self.view viewWithTag:13];
        if (footView) {
            [footView removeFromSuperview];
        }
    }
    else {
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        [footView setTag:13];
        [footView setUserInteractionEnabled:YES];
        [footView setBackgroundColor:self.collectionView.backgroundColor];
        [self.view addSubview:footView];
        
        CGFloat margin = (footView.frameHeight - 120) / 2;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, margin, 65, 80)];
        imgView.image = CREATE_IMG(@"order_default");
        [footView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 10, SCREEN_WIDTH - 80, 30)];
        [label setTextAlignment:1];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"您还没有获取到数据，返回试试吧"];
        [footView addSubview:label];
    }
}

#pragma mark - Network
- (void)sendRequest
{
    self.silentAnimation = YES;
    GlobalManager *manager = [GlobalManager shareInstance];
    NSString *ckey = (_statue_set == 0) ? @"copyUserTemplate" : @"getChooseTemplate";
    NSMutableDictionary *param = [manager requestinitParamsWith:ckey];
    if (_statue_set == 0) {
        [param setValue:_grow_id forKey:@"grow_id"];
    }else {
        if (_statue_set == 2) {
            [param setValue:@"2" forKey:@"get_type"];
        }else {
            CustomerModel *item = [_customers objectAtIndex:0];
            [param setValue:@"1" forKey:@"get_type"];
            [param setValue:item.user_id forKey:@"user_id"];
            [param setValue:_grow_id forKey:@"grow_id"];
        }
    }
    [param setValue:_batch_id forKey:@"batch_id"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"templateSet"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getCopyTemplateFinish:error Data:data];
        });
    }];
}

#pragma mark- get other template
- (void)requestOtherTemplate
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getTemplateDetail"];
    //[param setValue:[_indexDictory valueForKey:@"copy_batch_id"] forKey:@"batch_id"];
    [param setValue:[_indexDictory valueForKey:@"template_id"] forKey:@"template_id"];
    //[param setValue:[_indexDictory valueForKey:@"copy_user_id"] forKey:@"user_id"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"template"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getAllTemplateFinish:error Data:data];
        });
    }];
}

- (void)getAllTemplateFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *nr_array = [NSMutableArray array];
        NSMutableArray *fm_array = [NSMutableArray array];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            NSArray * tempArray = [TemplateModel arrayOfModelsFromDictionaries:ret_data error:nil];
            for (TemplateModel *model in tempArray) {
                if ([model.detail_type integerValue] == 2) {
                    [nr_array addObject:model];
                }else {
                    BOOL find = NO;
                    for (Theme *item in _coverArray) {
                        if ([item.template_detail_id isEqualToString:model.id]) {
                            find = YES;
                            break;
                        }
                    }
                    
                    if (!find) {
                        Theme *theme = [[Theme alloc] init];
                        theme.template_index = @"";
                        theme.theme_id = @"0";
                        theme.title = model.title;
                        theme.template_detail_id = model.id;
                        theme.image_url = model.image_url;
                        theme.image_thumb_url = model.image_thumb_url;
                        theme.template_id = [_indexDictory valueForKey:@"template_id"];
                        theme.detail_type = model.detail_type;
                        theme.cover_group = model.cover_group;
                        theme.image_width = model.image_width;
                        theme.image_height = model.image_height;
                        [fm_array addObject:theme];
                    }
                }
            }
        }
        _otherArray = nr_array;
        
        if ([fm_array count] > 0) {
            NSArray *sections = [self sortDatas:fm_array];
            if ([[_indexDictory valueForKey:@"is_double"] integerValue] == 1) {
                sections = fm_array;
            }
            [_templateHeader.resource addObjectsFromArray:sections];
            [_templateHeader.collectionView reloadData];
        }
    }
}

- (NSMutableArray *)sortDatas:(NSMutableArray *)array
{
    NSMutableArray *dataMutablearray = [@[] mutableCopy];
    
    for (int i = 0; i < array.count; i++) {
        Theme *item1 = array[i];
        NSMutableArray *tempArray = [@[] mutableCopy];
        [tempArray addObject:item1];
        
        for (int j = i+1; j < array.count; j++) {
            
            Theme *item2 = array[j];
            
            if([item1.cover_group length] > 0 && [item2.cover_group length] > 0 && [item1.cover_group isEqualToString:item2.cover_group]){
                
                [tempArray addObject:item2];
                [array removeObjectAtIndex:j];
                break;
            }
        }
        
        if ([tempArray count] == 2) {
            [dataMutablearray addObject:tempArray];
        }
    }
    
    return dataMutablearray;
}

#pragma mark - Craft
- (void)getCraftRequest
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getCraft"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"template"];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf craftFinish:error Data:data];
    }];
}

- (void)craftFinish:(NSError *)error Data:(id)data
{
    if (error == nil) {
        id ret_data = [data valueForKey:@"ret_data"];
        NSMutableArray *page = [ret_data valueForKey:@"page_num"];
        if (page && [page isKindOfClass:[NSArray class]]) {
            [[GlobalManager shareInstance] setGzPages:page];
        }
        
        NSMutableArray *size = [ret_data valueForKey:@"size"];
        if (size && [size isKindOfClass:[NSArray class]]) {
            [[GlobalManager shareInstance] setSizeReferences:size];
        }
        
        [self setBottemView];
    }
}

- (void)setBottemView
{
    UIView *toolView = (UIView *)[self.view viewWithTag:10];
    if (toolView) {
        [toolView removeFromSuperview];
    }
    toolView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 56, SCREEN_WIDTH, 56)];
    [toolView setTag:10];
    [toolView setBackgroundColor:CreateColor(245, 245, 245)];
    [toolView setUserInteractionEnabled:YES];
    [self.view addSubview:toolView];
    
    if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue == 1) {
        NSString *page_num = [_indexDictory objectForKey:@"page_num"];
        NSArray *arr = [page_num componentsSeparatedByString:@","];

        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 32 - 30 - 10, toolView.frameHeight)];
        [tipLabel setBackgroundColor:[UIColor clearColor]];
        [tipLabel setText:[NSString stringWithFormat:@"打印成册需要设置%@-%@张模板！",arr.firstObject,arr.lastObject]];
        [tipLabel setTextColor:[UIColor lightGrayColor]];
        [tipLabel setFont:[UIFont systemFontOfSize:14]];
        [toolView addSubview:tipLabel];
    }
    else {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 32 - 30, toolView.frameHeight)];
        [scrollView setBackgroundColor:toolView.backgroundColor];
        [scrollView setUserInteractionEnabled:YES];
        _scrollView = scrollView;
        [toolView addSubview:scrollView];
        
        NSMutableArray *titles = [NSMutableArray array];
        if ([[GlobalManager shareInstance].gzPages count] == 0) {
            [self getCraftRequest];
        }else {
            for (NSDictionary *dic in [GlobalManager shareInstance].gzPages) {
                NSString *craft = [dic valueForKey:@"craft_value"];
                [titles addObject:[[craft componentsSeparatedByString:@","] componentsJoinedByString:@"/"]];
            }
        }
        
        CGFloat magin = (SCREEN_WIDTH - 32 * 5) / 6;
        for (int i = 0; i < [titles count]; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(magin + (magin + 32) * i , 5, 32, 32)];
            [btn setImage:CREATE_IMG(@"grow_set_hide_num") forState:UIControlStateNormal];
            [btn setImage:CREATE_IMG(@"grow_set_show_num") forState:UIControlStateSelected];
            [btn setTag:10 + i];
            [btn addTarget:self action:@selector(craftPressed:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:btn];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(btn.frameX - 5, btn.frameBottom, btn.frameWidth + 10, 18)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setText:titles[i]];
            [label setFont:[UIFont systemFontOfSize:10]];
            [label setTextColor:CreateColor(172, 151, 249)];
            [scrollView addSubview:label];
        }
        [scrollView setContentSize:CGSizeMake(magin + (magin + 32) * [titles count], toolView.frameHeight)];
    }
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setFrame:CGRectMake(SCREEN_WIDTH - 32 - 15 , 0, 32 + 15, 32 + 15)];
    [nextBtn setImage:CREATE_IMG(@"grow_set_next") forState:UIControlStateNormal];
    [nextBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 10, 10)];
    [nextBtn addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:nextBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(nextBtn.frameX, nextBtn.frameBottom - 10, nextBtn.frameWidth - 5, 18)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"下一页"];
    [label setFont:[UIFont systemFontOfSize:10]];
    [label setTextColor:CreateColor(172, 151, 249)];
    [toolView addSubview:label];
}

- (void)craftPressed:(UIButton *)sender
{
    NSDictionary *dic = [[GlobalManager shareInstance].gzPages objectAtIndex:sender.tag - 10];
    NSString *craft = [dic valueForKey:@"craft_value"];
    NSArray *array = [craft componentsSeparatedByString:@","];
    NSInteger pageNum = 0;
    for (NSString *num in array) {
        if ([num length] > 0 && num.integerValue > pageNum) {
            pageNum = num.integerValue;
        }
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getCarftShow"];
    [param setValue:[NSString stringWithFormat:@"%ld",(long)pageNum] forKey:@"page_num"];
    [param setValue:[_indexDictory valueForKey:@"craft_size"] forKey:@"craft_size"];
    [param setValue:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"template"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getCarftShowFinish:error Data:data];
        });
    }];
}

- (void)getCarftShowFinish:(NSError *)error Data:(id)result
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *tempArr = [NSMutableArray array];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            tempArr = [CraftInfoModel arrayOfModelsFromDictionaries:ret_data error:nil];
        }
        
        if ([tempArr count] > 0) {
            GoodsInfoView *goosView = [[GoodsInfoView alloc] initWithFrame:self.view.window.bounds];
            //alertView.delegate = self;
            [goosView restDatas:tempArr];
            [self.view.window addSubview:goosView];
        }else {
            [self.view makeToast:@"没有匹配到相应的规格信息" duration:1.0 position:@"center"];
        }
    }
}

- (void)setMayCraftBtn
{
    BOOL is_double = [[_indexDictory valueForKey:@"is_double"] integerValue];
    NSInteger nums = 0;
    for (GrowTemplateModel *model in self.dataSource) {
        nums += [model.template count];
    }
    nums *= (is_double ? 2 : 1);
    [_tpl_nums setText:[NSString stringWithFormat:@"请选择内容模板(%ld)",(long)nums]];
    
    for (id sub in _scrollView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            [(UIButton *)sub setSelected:NO];
        }
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.detailInfo.isDealer.integerValue == 1) {
        NSString *page_num = [_indexDictory objectForKey:@"page_num"];
        NSArray *arr = [page_num componentsSeparatedByString:@","];
        NSInteger minInt = [arr[0] integerValue];
        NSInteger maxInt = [arr[1] integerValue];
        for (int i = 0; i < [[GlobalManager shareInstance].gzPages count]; i++) {
            NSDictionary *dic = [[GlobalManager shareInstance].gzPages objectAtIndex:i];
            NSString *craft = [dic valueForKey:@"craft_value"];
            NSArray *tempArr = [craft componentsSeparatedByString:@","];
            if (minInt >= [tempArr[0] integerValue] && maxInt <= [tempArr[1] integerValue]) {
                UIButton *btn = (UIButton *)[_scrollView viewWithTag:10 + i];
                if (btn) {
                    btn.selected = YES;
                }
                break;
            }
        }
    }else {
        NSInteger hight = -1;
        for (int i = 0; i < [[GlobalManager shareInstance].gzPages count]; i++) {
            NSDictionary *dic = [[GlobalManager shareInstance].gzPages objectAtIndex:i];
            NSString *craft = [dic valueForKey:@"craft_value"];
            NSArray *arr = [craft componentsSeparatedByString:@","];
            if (nums >= [arr[0] integerValue] && nums <= [arr[1] integerValue]) {
                hight = i;
                break;
            }
        }
        
        UIButton *btn = (UIButton *)[_scrollView viewWithTag:10 + hight];
        if (btn) {
            btn.selected = YES;
        }
    }
}

#pragma mark - 网络请求结束
- (void)getCopyTemplateFinish:(NSError *)error Data:(id)result
{
    [self stopAnimation];
    self.view.userInteractionEnabled = YES;
    if (error == nil) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (!ret_data || [ret_data count] == 0) {
            return;
        }
        [_indexDictory setValue:[ret_data valueForKey:@"copy_batch_id"] forKey:@"copy_batch_id"];
        [_indexDictory setValue:[ret_data valueForKey:@"copy_grow_id"] forKey:@"copy_grow_id"];
        [_indexDictory setValue:[ret_data valueForKey:@"copy_user_id"] forKey:@"copy_user_id"];
        [_indexDictory setValue:[ret_data valueForKey:@"template_id"] forKey:@"template_id"];
        [_indexDictory setValue:[ret_data valueForKey:@"craft_size"] forKey:@"craft_size"];
        [_indexDictory setValue:[ret_data valueForKey:@"page_num"] forKey:@"page_num"];
        [_indexDictory setValue:[ret_data valueForKey:@"is_double"] forKey:@"is_double"];

        NSMutableArray *coverArray = [NSMutableArray array];
        NSArray *cover = [ret_data valueForKey:@"cover"];
        if (cover && [cover isKindOfClass:[NSArray class]]) {
            coverArray = [self sortDatas:[Theme arrayOfModelsFromDictionaries:cover error:nil]];
            _coverArray = [Theme arrayOfModelsFromDictionaries:cover error:nil];
        }
        
        NSMutableArray *themeArray = [NSMutableArray array];
        NSArray *theme = [ret_data valueForKey:@"theme"];
        if (theme && [theme isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in theme) {
                GrowTemplateModel *model = [[GrowTemplateModel alloc] initWithDictionary:dic error:nil];
                if ([model.template count] > 0) {
                    [themeArray addObject:model];
                }
            }
        }
        
        self.dataSource = themeArray;
        
        if (_goBack) {
            [self.collectionView reloadData];
        }else{
            [self initSubContentViews:coverArray];
            if ([_otherArray count] == 0) {
                [self requestOtherTemplate];
            }
        }
    }
    else {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
        [self createTableFooterView];
    }
}

- (NSString *)dictToJsonStr:(NSDictionary *)dic
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in dic.allKeys) {
        NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\"",key,[dic valueForKey:key]];
        [array addObject:str];
    }
    
    return [NSString stringWithFormat:@"{%@}",[array componentsJoinedByString:@","]];
}

- (void)saveAction:(id)sender
{
    NSInteger nums = 0;
    for (GrowTemplateModel *model in self.dataSource) {
        for (int i = 0; i < [model.template count]; i++) {
            nums++;
        }
    }
    
    BOOL is_double = [[_indexDictory valueForKey:@"is_double"] integerValue];
    nums *= (is_double ? 2 : 1);
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.detailInfo.isDealer.integerValue == 1) {
        NSString *page_num = [_indexDictory objectForKey:@"page_num"];
        NSArray *arr = [page_num componentsSeparatedByString:@","];
        if (nums > [arr[1] integerValue] || nums < [arr[0] integerValue]) {
            [self.view makeToast:[NSString stringWithFormat:@"模板页数在%@/%@之间",arr[0],arr[1]] duration:1.0 position:@"center"];
            return;
        }
    }
    else{
        BOOL findSel = NO;
        NSArray *arr = [_scrollView subviews];
        for (id sub in arr) {
            if ([sub isKindOfClass:[UIButton class]] && ((UIButton *)sub).selected) {
                findSel = YES;
                break;
            }
        }
        
        if (!findSel) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"打印提醒" message:@"您选择的模板数量，无法享受打印服务" delegate:self cancelButtonTitle:@"重新设置" otherButtonTitles:@"继续制作", nil];
            [alertView setTag:101];
            [alertView show];
            return;
        }
    }
    
    [self sendSubmitRequest];
}

- (void)sendSubmitRequest
{
    if ([_coverArray count] == 0) {
        [self.view makeToast:@"封面不存在哦" duration:1.0 position:@"center"];
        return;
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSString *ckey = (_statue_set == 0) ? @"chooseTemplate" : @"setTemplate";
    NSMutableDictionary *param = [manager requestinitParamsWith:ckey];
    if (_statue_set == 0) {
        NSInteger p_type = 2;
        if (manager.detailInfo.isDealer.integerValue == 1) {
            [param setObject:_batch_id ?: @"" forKey:@"batch_id"];
            p_type = 1;
        }
        [param setObject:[NSString stringWithFormat:@"%ld",(long)p_type] forKey:@"p_type"]; //1为他人制作，2位自己制作
        [param setObject:[_indexDictory valueForKey:@"template_id"] forKey:@"template_id"];
        NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
        [userDic setObject:manager.detailInfo.user.id forKey:@"id"];
        [userDic setObject:manager.detailInfo.user.name forKey:@"name"];
        NSMutableArray *users = [NSMutableArray array];
        [users addObject:userDic];
        [param setObject:users forKey:@"users"];
        
        NSMutableArray *indexArray = [NSMutableArray array];
        for (GrowTemplateModel *model in self.dataSource) {
            NSMutableArray *tempArray = [NSMutableArray array];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:@"0" forKey:@"theme_id"];
            [dic setValue:model.theme_name forKey:@"theme_name"];
            for (Theme *item in model.template) {
                [tempArray addObject:item.template_detail_id];
            }
            [dic setValue:[tempArray componentsJoinedByString:@","] forKey:@"template_details"];
            [indexArray addObject:dic];
        }
        [param setObject:indexArray forKey:@"content_detail_id"];
    }else {
        if (_statue_set == 2) {
            [param setObject:@"2" forKey:@"update_type"];
        }else {
            CustomerModel *item = _customers[0];
            [param setObject:@"1" forKey:@"update_type"];
            [param setObject:_grow_id forKey:@"grow_id"];
            [param setObject:item.user_id forKey:@"user_id"];
        }
        [param setObject:_batch_id forKey:@"batch_id"];
        
        NSMutableArray *indexArray = [NSMutableArray array];
        for (GrowTemplateModel *model in self.dataSource) {
            NSString *dataStr = [[NSString alloc] initWithFormat:@"\"theme_id\":\"%@\"",model.id];
            dataStr = [dataStr stringByAppendingFormat:@",\"theme_name\":\"%@\"",model.theme_name];
            
            NSMutableArray *tempArray = [NSMutableArray array];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:model.id forKey:@"theme_id"];
            [dic setValue:model.theme_name forKey:@"theme_name"];
            for (Theme *item in model.template) {
                NSString *str = [[NSString alloc] initWithFormat:@"\"detail_id\":\"%@\"",item.template_detail_id];
                str = [str stringByAppendingFormat:@",\"cid\":\"%@\"",item.c_id ?: @"0"];
                [tempArray addObject:[NSString stringWithFormat:@"{%@}",str]];
            }
            dataStr = [dataStr stringByAppendingFormat:@",\"template_detail_ids\":%@",[NSString stringWithFormat:@"[%@]",[tempArray componentsJoinedByString:@","]]];
            [indexArray addObject:[NSString stringWithFormat:@"{%@}",dataStr]];
        }
        [param setObject:[NSString stringWithFormat:@"[%@]",[indexArray componentsJoinedByString:@","]] forKey:@"data"];
    }
    [param setObject:manager.detailInfo.token forKey:@"token"];
    
    if ([[_indexDictory valueForKey:@"is_double"] integerValue] == 1) {
        Theme *model1 = [_coverArray firstObject];
        [param setObject:model1.template_detail_id forKey:@"cover_detail_id"];
        [param setObject:@"" forKey:@"bottom_detail_id"];
    }else {
        Theme *model1 = [_coverArray firstObject];
        Theme *model2 = [_coverArray lastObject];
        [param setObject:model1.template_detail_id forKey:@"cover_detail_id"];
        [param setObject:model2.template_detail_id forKey:@"bottom_detail_id"];
    }
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"templateSet"];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf submitFinish:error Data:data];
        });
    }];
}

#pragma mark - 提交完成
- (void)submitFinish:(NSError *)error Data:(id)data
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue != 1) {
            [[GlobalManager shareInstance] requestMyProfiles];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:RefreshCustomer object:nil];
        }
        
        id ret_data = [data valueForKey:@"ret_data"];
        if (_statue_set == 0) {
            if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue != 1) {
                _grow_id = [ret_data valueForKey:@"usergrow_id"];
                _batch_id = [ret_data valueForKey:@"batch_id"];
            }
            [self pushToController:_batch_id];
        }
        else{
            if (_goBack) {
                [self pushToController:_batch_id];
            }else {
                for (id controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[YWCMainViewController class]]) {
                        for (CustomerListViewController *list in ((YWCMainViewController *)controller).childViewControllers) {
                            if (list.isViewLoaded) {
                                [list beginRefresh];
                            }
                        }
                        [self.navigationController popToViewController:controller animated:YES];
                        return;
                    }
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

- (void)pushToController:(NSString *)batch_id
{
    if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue == 1) {
        CollaborationViewController *collaboration = [[CollaborationViewController alloc] init];
        collaboration.is_double = [[_indexDictory valueForKey:@"is_double"] integerValue];
        collaboration.batch_id = batch_id;
        collaboration.grow_id = _grow_id;
        collaboration.template_id = [_indexDictory valueForKey:@"template_id"];
        collaboration.customers = _customers;
        [self.navigationController pushViewController:collaboration animated:YES];
    }else {
        BatchMakeViewController *batch = [BatchMakeViewController new];
        batch.batch_id = batch_id;
        batch.user_id = [GlobalManager shareInstance].detailInfo.user.id;
        batch.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:batch animated:YES];
    }
}

#pragma mark - SetTemplateHeader delegate
- (void)didTemplateHeadItem:(NSInteger)idx
{
    if ([[_indexDictory valueForKey:@"is_double"] integerValue] == 1) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:@[[_templateHeader.resource objectAtIndex:idx]]];
        _coverArray = array;
    }else {
        _coverArray = [_templateHeader.resource objectAtIndex:idx];
    }
}

- (void)lookPigTemplateHeadItem:(NSInteger)idx
{
    _mwphotos = [NSMutableArray array];
    if ([[_indexDictory valueForKey:@"is_double"] integerValue] == 1) {
        Theme *item = [_templateHeader.resource objectAtIndex:idx];
        NSString *url = item.image_url;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url];
        }
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
        if (width.floatValue < item.image_width.floatValue) {
            url = [NSString getPictureAddress:@"2" width:width height:@"0" original:url];
        }
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:url]];
        [_mwphotos addObject:photo];
    }else{
        for (Theme *item in [_templateHeader.resource objectAtIndex:idx]) {
            NSString *url = item.image_url;
            if (![url hasPrefix:@"http"]) {
                url = [G_IMAGE_ADDRESS stringByAppendingString:url];
            }
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            if (width.floatValue < item.image_width.floatValue) {
                url = [NSString getPictureAddress:@"2" width:width height:@"0" original:url];
            }
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:url]];
            [_mwphotos addObject:photo];
        }
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    [browser setCurrentPhotoIndex:0];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - add template
- (void)addTemplateSource:(TemplateModel *)item Theme:(NSString *)theme_name
{
    if (_currSection >= 0) {
        GrowTemplateModel *model = [self.dataSource objectAtIndex:_currSection];
        Theme *theme = [[Theme alloc] init];
        theme.template_index = @"";
        theme.theme_id = model.id;
        theme.title = item.title;
        theme.template_detail_id = item.id;
        theme.image_url = item.image_url;
        theme.image_thumb_url = item.image_thumb_url;
        theme.template_id = [_indexDictory valueForKey:@"template_id"];
        theme.detail_type = @"2";
        theme.image_width = item.image_width;
        theme.image_height = item.image_height;
        [model.template insertObject:theme atIndex:0];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:_currSection]]];
        //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:_currSection]];
    }else {
        GrowTemplateModel *model = [[GrowTemplateModel alloc] init];
        model.id = @"";
        model.theme_name = theme_name ?: @"";
        NSMutableArray *tempArr = [NSMutableArray array];
        Theme *theme = [[Theme alloc] init];
        theme.template_index = @"";
        theme.theme_id = @"";
        theme.title = item.title;
        theme.template_detail_id = item.id;
        theme.image_url = item.image_url;
        theme.image_thumb_url = item.image_thumb_url;
        theme.template_id = [_indexDictory valueForKey:@"template_id"];
        theme.detail_type = @"2";
        theme.image_width = item.image_width;
        theme.image_height = item.image_height;
        [tempArr insertObject:theme atIndex:0];
        [model setTemplate:(NSMutableArray<Theme> *)tempArr];
        [self.dataSource insertObject:model atIndex:0];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
        //[self.collectionView reloadData];
        
        _currSection = 0;
    }
    
    [self setMayCraftBtn];
}

- (void)cancelTemplateIndex
{
    [UIView animateWithDuration:0.35 animations:^{
        [self.view setFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    }];
}

#pragma mark - add theme
- (void)addTheme:(id)sender
{
    //_otherArray
    if ([_otherArray count] == 0) {
        [self.view makeToast:@"模板获取失败" duration:1.0 position:@"center"];
        return;
    }

    GrowAlertView *alertView = [[GrowAlertView alloc] initWithFrame:self.view.window.bounds];
    [alertView setTag:102];
    alertView.delegate = self;
    alertView.titleLabel.text = @"新增主题";
    [self.view.window addSubview:alertView];
}

- (void)cleanTheme:(id)sender
{
    if ([self.dataSource count] == 0) {
        [self.view makeToast:@"当前列表已经为空哦" duration:1.0 position:@"center"];
        return;
    }
    NSString *message = (_statue_set == 0) ? @"您确定清空全部列表吗" : @"清空操作会清空您原先的制作数据，确定要清空吗？";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清空" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView setTag:100];
    [alertView show];
}


#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag] - 100) {
        case 0:
        {
            if (buttonIndex == 1) {
                if ([self.dataSource count] > 0) {
                    [self.dataSource removeAllObjects];
                }
                [self.collectionView reloadData];
                [self setMayCraftBtn];
            }
        }
            break;
        case 1:
        {
            if (buttonIndex == 1) {
                [self sendSubmitRequest];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - edit template action
- (void)editSectionOrAddTemplate:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger section = [btn tag] % 10000;
    switch ([btn tag] / 10000 - 1) {
        case 0:
        {
            //向下
            if (section == [self.dataSource count] - 1) {
                [self.view makeToast:@"该主题无法下移哦" duration:1.0 position:@"center"];
                return;
            }
            [self.dataSource exchangeObjectAtIndex:section withObjectAtIndex:section + 1];
            [self.collectionView reloadData];
            //[_collectionView moveSection:section toSection:section + 1];
            
        }
            break;
        case 1:
        {
            //向上
            if (section == 0) {
                [self.view makeToast:@"该主题无法上移哦" duration:1.0 position:@"center"];
                return;
            }
            [self.dataSource exchangeObjectAtIndex:section withObjectAtIndex:section - 1];
            [self.collectionView reloadData];
            //[_collectionView moveSection:section toSection:section - 1];
        }
            break;
        case 2:
        {
            //添加
            if ([_otherArray count] == 0) {
                [self.view makeToast:@"模板获取失败" duration:1.0 position:@"center"];
                return;
            }

            _currSection = section;
            
            NSMutableArray *indexArray = [NSMutableArray array];
            [indexArray addObjectsFromArray:_otherArray];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (GrowTemplateModel *model in self.dataSource) {
                for (Theme *item in model.template) {
                    [dic setValue:item forKey:item.template_detail_id];
                }
            }
            
            for (TemplateModel *model in _otherArray) {
                for (Theme *model1 in [dic allValues]) {
                    if ([model.id isEqualToString:model1.template_detail_id]) {
                        [indexArray removeObject:model];
                    }
                }
            }
                                                
            SelectTemplateView *editView = [[SelectTemplateView alloc] initWithFrame:[UIScreen mainScreen].bounds Datas:_otherArray OtherDatas:indexArray];
            editView.delegate = self;
            editView.is_double = [[_indexDictory valueForKey:@"is_double"] integerValue];
            [editView showInView:self.view.window];
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            if (cell) {
                CGRect rect = [self.collectionView convertRect:cell.frame toView:[self.collectionView superview]];
                CGFloat old = rect.origin.y + cell.frameHeight + 5;
                CGFloat add = SCREEN_HEIGHT - (SCREEN_HEIGHT / 3 + 42) - 64;
                if (old > add) {
                    if (old > SCREEN_HEIGHT - 64 - 56) {
                        old = SCREEN_HEIGHT - 64 - 56;
                        CGFloat delt = old - rect.origin.y;
                        CGFloat offset = self.collectionView.contentOffset.y;
                        [self.collectionView setContentOffset:CGPointMake(0, offset + cell.frameHeight + 5 - delt)];
                    }
                    CGRect butRec = self.view.frame;
                    [UIView animateWithDuration:0.35 animations:^{
                        [self.view setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - (old - add), butRec.size.width, butRec.size.height)];
                    }];
                }
            }else {
                NSInteger num = ([[_indexDictory valueForKey:@"is_double"] integerValue] == 1) ? 2 : 3;
                GrowTemplateModel *model = [self.dataSource objectAtIndex:section];
                Theme *item = [model.template objectAtIndex:0];
                CGFloat itemHei = [item.image_height floatValue];
                CGFloat scale = ((self.collectionView.frameWidth - 2 * 5 - 8 * (num - 1)) / num - 5) / [item.image_width floatValue];
                itemHei = 5 + itemHei * scale;
                CGFloat offset = self.collectionView.contentOffset.y;
                [self.collectionView setContentOffset:CGPointMake(0, offset + itemHei + 5)];
                
                CGRect butRec = self.view.frame;
                [UIView animateWithDuration:0.35 animations:^{
                    [self.view setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - (SCREEN_HEIGHT / 3 + 42) - 64 + 56 + 56 + 15, butRec.size.width, butRec.size.height)];
                }];
            }
            
        }
            break;
            
        default:
            break;
    }
}

- (void)editTheme:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    _currSection = btn.tag - 1;
    GrowTemplateModel *model = [self.dataSource objectAtIndex:btn.tag - 1];
    GrowAlertView *alertView = [[GrowAlertView alloc] initWithFrame:self.view.window.bounds];
    [alertView setTag:101];
    alertView.delegate = self;
    alertView.titleLabel.text = @"修改主题";
    [self.view.window addSubview:alertView];
    [alertView setDefaultTheme:model.theme_name];
    
}

- (void)deleteTemplate:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    UICollectionViewCell *cell = [GlobalManager findViewFrom:btn To:[UICollectionViewCell class]];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    GrowTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
    [model.template removeObjectAtIndex:indexPath.item];
    if ([model.template count] > 0) {
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        //[_collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }else {
        [self.dataSource removeObjectAtIndex:indexPath.section];
        [self.collectionView reloadData];
        //[_collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }
    
    [self setMayCraftBtn];
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
    if ([theme length] == 0) {
        [self.view makeToast:@"您还没有编辑主题" duration:1.0 position:@"center"];
        return;
    }

    if (alert.tag == 101) {
        GrowTemplateModel *model = [self.dataSource objectAtIndex:_currSection];
        model.theme_name = theme;
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:_currSection]];
        _currSection = -1;
    }else{
        _currSection = -1;
        
        NSMutableArray *indexArray = [NSMutableArray array];
        [indexArray addObjectsFromArray:_otherArray];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (GrowTemplateModel *model in self.dataSource) {
            for (Theme *item in model.template) {
                [dic setValue:item forKey:item.template_detail_id];
            }
        }
        
        for (TemplateModel *model in _otherArray) {
            for (Theme *model1 in [dic allValues]) {
                if ([model.id isEqualToString:model1.template_detail_id]) {
                    [indexArray removeObject:model];
                }
            }
        }
        SelectTemplateView *editView = [[SelectTemplateView alloc] initWithFrame:[UIScreen mainScreen].bounds Datas:_otherArray OtherDatas:indexArray];
        editView.delegate = self;
        editView.is_double = [[_indexDictory valueForKey:@"is_double"] integerValue];
        editView.theme_name = theme;
        [editView showInView:self.view.window];
    }
}

#pragma mark UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger num = ([[_indexDictory valueForKey:@"is_double"] integerValue] == 1) ? 2 : 3;
    GrowTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
    //Theme *item;
    if (indexPath.item == model.template.count) {
        //return CGSizeMake((self.collectionView.frameWidth - 2 * 5 - 8 * (num - 1)) / num, 0);
    }else {
        //item = [model.template objectAtIndex:indexPath.item];
    }
    Theme *item = [model.template objectAtIndex:indexPath.item];
    CGFloat itemHei = [item.image_height floatValue];
    CGFloat scale = ((self.collectionView.frameWidth - 2 * 5 - 8 * (num - 1)) / num - 5) / [item.image_width floatValue];
    itemHei = 5 + itemHei * scale;
    CGFloat itemWei = (self.collectionView.frameWidth - 2 * 5 - 8 * (num - 1)) / num;
    return CGSizeMake(itemWei, itemHei);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    //return (_collectionView.frameWidth - 2 * 5 - 70 * 5) / 4;
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    //return (_collectionView.frameWidth - 2 * 5 - 70 * 5) / 4;
    return 5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    GrowTemplateModel *model = [self.dataSource objectAtIndex:section];
    return [model.template count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SetTemplateCell" forIndexPath:indexPath];
    XWDragCellCollectionView *dragView = (XWDragCellCollectionView *)collectionView;
    if (!dragView.editing && cell.hidden) {
        cell.hidden = NO;
    }
    UIImageView *_imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, cell.contentView.frameWidth - 5, cell.contentView.frameHeight - 5)];
        //[_imgView setContentMode:UIViewContentModeScaleAspectFill];
        //[_imgView setClipsToBounds:YES];
        [_imgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_imgView setTag:1];
        [_imgView setBackgroundColor:CreateColor(240, 239, 244)];
        [cell.contentView addSubview:_imgView];
    }
    
    UIButton *delBtn = (UIButton *)[cell.contentView viewWithTag:2];
    if (!delBtn) {
        delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn setFrame:CGRectMake(0, 0, 12 + 20, 12 + 20)];
        [delBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 20, 20)];
        [delBtn setImage:CREATE_IMG(@"template_del") forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(deleteTemplate:) forControlEvents:UIControlEventTouchUpInside];
        [delBtn setTag:2];
        [cell.contentView addSubview:delBtn];
    }
    
    GrowTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
    if (indexPath.item == model.template.count) {
        _imgView.hidden = YES;
        delBtn.hidden = YES;
    }
    else {
        Theme *item = [model.template objectAtIndex:indexPath.item];
        NSString *url = item.image_thumb_url;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        _imgView.hidden = NO;
        delBtn.hidden = NO;
        [_imgView sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _mwphotos = [NSMutableArray array];
    NSInteger photoIndex = 0;
    GrowTemplateModel *indexModel = [self.dataSource objectAtIndex:indexPath.section];
    if (indexPath.item == indexModel.template.count) {
        return;
    }
    Theme *indexItem = [indexModel.template objectAtIndex:indexPath.item];
    NSInteger i = 0;
    for (GrowTemplateModel *model in self.dataSource) {
        for (Theme *item in model.template) {
            i++;
            NSString *url = item.image_url;
            if (![url hasPrefix:@"http"]) {
                url = [G_IMAGE_ADDRESS stringByAppendingString:url];
            }
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            if (width.floatValue < item.image_width.floatValue) {
                url = [NSString getPictureAddress:@"2" width:width height:@"0" original:url];
            }
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:url]];
            [_mwphotos addObject:photo];
            if ([item.template_detail_id isEqualToString:indexItem.template_detail_id]) {
                photoIndex = i - 1;
            }
        }
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    [browser setCurrentPhotoIndex:photoIndex];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - 头视图
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    
    return CGSizeMake(SCREEN_WIDTH - 20, 32);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SetHeadCell" forIndexPath:indexPath];
        [view setBackgroundColor:collectionView.backgroundColor];
        
        for (id sub in view.subviews) {
            [sub removeFromSuperview];
        }
        UILabel *label = (UILabel *)[view viewWithTag:200];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frameWidth, view.frameHeight - 25)];
            [label setBackgroundColor:CreateColor(240, 239, 244)];
            [label setTag:200];
            [view addSubview:label];
        }
        
        GrowTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
        NSString *title = model.theme_name ?: @"";
        HorizontalButton *_horiBut = (HorizontalButton *)[view viewWithTag:1 + indexPath.section];
        if (!_horiBut) {
            _horiBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
            _horiBut.imgSize = CGSizeMake(14, 13);
            _horiBut.textSize = CGSizeMake(136, 25);
            [_horiBut setFrame:CGRectMake(10, view.frameHeight - 25, 150, 25)];
            [_horiBut addTarget:self action:@selector(editTheme:) forControlEvents:UIControlEventTouchUpInside];
            [_horiBut setImage:CREATE_IMG(@"template_nor_edit_theme") forState:UIControlStateNormal];
            [_horiBut setImage:CREATE_IMG(@"template_sel_edit_theme") forState:UIControlStateHighlighted];
            [_horiBut setTag:1 + indexPath.section];
            [_horiBut setTitleColor:CreateColor(100, 100, 100) forState:UIControlStateNormal];
            [_horiBut setTitle:title forState:UIControlStateNormal];
            [_horiBut.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [_horiBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [view addSubview:_horiBut];
        }
        [_horiBut setTitle:title forState:UIControlStateNormal];
        
        NSArray *imgsN = @[@"template_nor_down",@"template_nor_up",@"tempalte_nor_add_temp"];
        NSArray *imgsH = @[@"template_sel_down",@"template_sel_up",@"tempalte_sel_add_temp"];
        for (int i = 0; i < 3; i++) {
            UIButton *btn = (UIButton *)[view viewWithTag:(i + 1) * 10000 + indexPath.section];
            if (!btn) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(view.frameWidth - 90 + 30 * i, view.frameHeight - 25, 25, 25)];
                [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
                [btn setImage:CREATE_IMG(imgsN[i]) forState:UIControlStateNormal];
                [btn setImage:CREATE_IMG(imgsH[i]) forState:UIControlStateHighlighted];
                [btn setTag:(i + 1) * 10000 + indexPath.section];
                [btn addTarget:self action:@selector(editSectionOrAddTemplate:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
        }
        return view;
    }
    
    return nil;
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

#pragma mark - <XWDragCellCollectionViewDataSource>
- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView{
    return self.dataSource;
}

#pragma mark - <XWDragCellCollectionViewDelegate>
- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    //self.dataSource = (NSMutableArray *)newDataArray;
}

- (void)dragCellCollectionViewCellEndMoving:(XWDragCellCollectionView *)collectionView{
    BOOL shouleReload = NO;
    NSMutableArray *tempArr = [NSMutableArray array];
    [tempArr addObjectsFromArray:self.dataSource];
    for (int i = 0; i < [self.dataSource count]; i++) {
        GrowTemplateModel *model = self.dataSource[i];
        if ([model.template count] == 0) {
            [tempArr removeObject:model];
            shouleReload = YES;
        }
    }
    if (shouleReload) {
        self.dataSource = tempArr;
        [self.collectionView reloadData];
    }
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
        return _mwphotos[index];
    }
    return nil;
}

@end
