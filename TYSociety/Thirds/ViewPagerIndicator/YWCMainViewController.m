//
//  YWCMainViewController.m
//  网易首页
//
//  Created by City--Online on 15/9/1.
//  Copyright (c) 2015年 City--Online. All rights reserved.
//

#import "YWCMainViewController.h"
#import "YWCTopScrollView.h"
#import "YWCBottomScrollView.h"
#import "HomePageUserController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "SizeReferenceViewController.h"
#import "KxMenu.h"
#import "CheckTemplateController.h"
#import "HorizontalButton.h"
#import "CustomerListViewController.h"

@interface YWCMainViewController ()<TopScrollViewDelegate>

@property(nonatomic,strong) YWCBottomScrollView *bottomScrollView;
@property(nonatomic,strong) NSMutableArray *titleArray;
@property(nonatomic,strong) NSMutableArray *viewControllerArray;
@property(nonatomic,strong) HorizontalButton *horiBtn;
@property(nonatomic,strong) NSMutableArray *addArr;

@end

@implementation YWCMainViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        _titleVcModelArray=[[NSMutableArray alloc]init];
        _titleArray=[[NSMutableArray alloc]init];
        _viewControllerArray=[[NSMutableArray alloc]init];
        _addArr = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showBack = _isCenter ? NO : YES;
    //self.titleLable.text = @"模版选择";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO ;
    [_addArr addObject:[NSNumber numberWithInteger:_initIdx].stringValue];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    for (YWCTitleVCModel *model in _titleVcModelArray) {
        [_titleArray addObject:model.title];
        [_viewControllerArray addObject:model.viewController];
        [self addChildViewController:model.viewController];
    }
    
    if (_showFiltrate) {
        [self createRightBarButton];
        
        HorizontalButton *hori = [HorizontalButton buttonWithType:UIButtonTypeCustom];
        self.horiBtn = hori;
        hori.leftText = YES;
        hori.textSize = CGSizeMake(33, 18);
        hori.imgSize = CGSizeMake(13, 14);
        [hori setTitle:@"筛选" forState:UIControlStateNormal];
        [hori setTitleColor:rgba(114, 114, 114, 1) forState:UIControlStateNormal];
        [hori setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
        [hori.titleLabel setFont:[UIFont systemFontOfSize:KTopButtonFont]];
        [hori setFrame:CGRectMake(winSize.width - 10 - 46, 11.5, 46, 21)];
        [hori setImage:CREATE_IMG(@"filtrate") forState:UIControlStateNormal];
        [hori addTarget:self action:@selector(filtrateItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:hori];
    }
    
    if (_rightItemType) {
        [self createRightNavButton];
    }
    
    CGFloat topWei = winSize.width - (_showFiltrate ? (10 + 46 + 5) : 0);
    _topScrollView = [[YWCTopScrollView alloc] initWithFrame:CGRectMake(0, 0, topWei, 44) andItems:_titleArray Index:_initIdx];
    _topScrollView.topViewDelegate = self;
     [self.view addSubview:_topScrollView];
    
    //bottom
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, _topScrollView.frame.size.height - 0.5, winSize.width, 0.5)];
    [bottomLine setBackgroundColor:KRGBCOLOR(200, 198, 202)];
    [self.view addSubview:bottomLine];
   
    __weak YWCMainViewController *weakSelf = self;
    CGFloat hei = (_bottomSize.height != 0) ? (_bottomSize.height - 44) : (winSize.height - 64 - 44);
    _bottomScrollView = [[YWCBottomScrollView alloc] initWithFrame:CGRectMake(0, 44, winSize.width, hei) andItems:_viewControllerArray Index:_initIdx];
    _bottomScrollView.pageChangedBlock = ^(CGFloat offsetX){
        [weakSelf.topScrollView changeOffset:offsetX];
    };
    _bottomScrollView.pageChangeIndexBlock = ^(NSInteger index){
        weakSelf.topScrollView.selectedIndex = index;
        [weakSelf toNewIndex:index];
    };
    [self.view addSubview:_bottomScrollView];
}

- (void)backToPreControl:(id)sender
{
    if (_rightItemType) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    for (id viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[HomePageUserController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createRightNavButton
{
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 15 + 20, 16 + 14)];
    [rightBut setImage:CREATE_IMG(@"customer_server_normal") forState:UIControlStateNormal];
    [rightBut setImage:CREATE_IMG(@"customer_server_down") forState:UIControlStateHighlighted];
    [rightBut setImageEdgeInsets:UIEdgeInsetsMake(7, 10, 7, 10)];
    [rightBut addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
}

- (void)rightAction:(id)sender
{
    QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:@"3492435469"];
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

#pragma mark - UI
- (void)createRightBarButton
{
    UIButton *leftBut = (UIButton *)[[self.navigationItem.leftBarButtonItems lastObject] customView];
    UIFont *font = [UIFont systemFontOfSize:12.5];
    NSString *tipStr = @"尺寸参考";
    CGSize size = [NSString calculeteSizeBy:tipStr Font:font MaxWei:SCREEN_WIDTH];
    [leftBut setFrameWidth:size.width];
    [leftBut setImageEdgeInsets:UIEdgeInsetsMake(6.5, 0, 6.5, size.width - 10)];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, size.width, size.height)];
    [rightBut setTitle:tipStr forState:UIControlStateNormal];
    [rightBut setTitleColor:rgba(252, 252, 252, 1) forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(sizeConsult:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut.titleLabel setFont:font];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
}

#pragma mark - delegate
- (void)toNewIndex:(NSInteger)index
{
    NSString *str = [NSNumber numberWithInteger:index].stringValue;
    if ([_addArr containsObject:str]) {
        if ([self.childViewControllers count] == 5) {
            id controller = self.childViewControllers[3];
            if ([controller isKindOfClass:[CustomerListViewController class]]) {
                [((CustomerListViewController *)controller) beginRefresh];
            }
        }
    }
    else{
        [_addArr addObject:str];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(changeSelectedIndex:)]) {
        [_delegate changeSelectedIndex:index];
    }
}

#pragma mark - actions
- (void)sizeConsult:(id)sender
{
    SizeReferenceViewController *sizeController = [[SizeReferenceViewController alloc] init];
    sizeController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sizeController animated:YES];
}

- (void)selectAction:(NSString *)sender
{
    NSInteger row = [sender integerValue] - 1;
    NSString *size_id = nil,*titleStr = nil;
    if (row != 0) {
        NSDictionary *dic = [[GlobalManager shareInstance].sizeReferences objectAtIndex:row - 1];
        size_id = [dic valueForKey:@"id"];
        titleStr = [dic valueForKey:@"craft_name"];
    }
    else{
        titleStr = @"筛选";
    }
    if ([_horiBtn.titleLabel.text isEqualToString:titleStr]) {
        return;
    }
    [_horiBtn setTitle:titleStr forState:UIControlStateNormal];
    
    YWCTitleVCModel *curModel = _titleVcModelArray[_topScrollView.selectedIndex];
    for (YWCTitleVCModel *model in self.titleVcModelArray) {
        id viewController = model.viewController;
        if ([viewController isKindOfClass:[CheckTemplateController class]]) {
            [(CheckTemplateController *)viewController setSize_id:size_id];
            if ([viewController isViewLoaded]) {
                if (curModel == model) {
                    [(CheckTemplateController *)viewController beginRefresh];
                }
                else{
                    [(CheckTemplateController *)viewController startPullRefresh];
                }
            }
        }
    }
}

- (void)filtrateItem:(UIButton *)sender
{
    NSMutableArray *indexArray = [NSMutableArray array];
    for (int i = 0; i <= [[GlobalManager shareInstance].sizeReferences count]; i++) {
        if (i == 0) {
            id object = [KxMenuItem menuItem:@"  全部  " image:nil target:self action:@selector(selectAction:) ItemType:[NSString stringWithFormat:@"%ld",(long)(i + 1)]];
            [indexArray addObject:object];
        }
        else{
            NSDictionary *dic = [[GlobalManager shareInstance].sizeReferences objectAtIndex:i - 1];
            id object = [KxMenuItem menuItem:[NSString stringWithFormat:@"  %@  ",[dic valueForKey:@"craft_name"]] image:nil target:self action:@selector(selectAction:) ItemType:[NSString stringWithFormat:@"%ld",(long)(i + 1)]];
            [indexArray addObject:object];
        }
    }

    CGRect rect = [[sender superview] convertRect:sender.frame toView:self.view];
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
                 menuItems:indexArray];
}

#pragma mark - TopScrollViewDelegate
- (void)barSelectedIndexChanged:(NSInteger)newIndex
{
    [_bottomScrollView setShowPageWithIndex:newIndex];
    [self toNewIndex:newIndex];
}

@end
