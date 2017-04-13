//
//  ProductDetailViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/8/6.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "PreviewWebViewController.h"
#import "SetTemplateViewController.h"

@interface ProductDetailViewController ()
{
    UILabel *_nameLabel,*_createrLabel,*_pLabel,*_typeLabel,*_timeLabel,*_contLabel;
    UIView *_backView;
    UIImageView *_bookImgView;
}
@end
@implementation ProductDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.navigationController.navigationBar.translucent = YES;
    self.titleLable.text = @"商品详情";
    
    [self.view setBackgroundColor:CreateColor(239, 237, 238)];
    
    [self setHeadView];
    
    [self sendRequest];
}

- (void)setHeadView
{
    UIImageView *headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 927.0 / 2)];
    [headImgView setImage:CREATE_IMG(@"detail_head_back@2x")];
    [headImgView setUserInteractionEnabled:YES];
    [self.view addSubview:headImgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 10 + 64, 4, 122)];
    [label setBackgroundColor:CreateColor(112, 112, 112)];
    [headImgView addSubview:label];
    
    //91  122
    UIImageView *bookImgView = [[UIImageView alloc] initWithFrame:CGRectMake(label.frameRight, label.frameY, 87, 122)];
    _bookImgView = bookImgView;
    [headImgView addSubview:bookImgView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(bookImgView.frameRight + 10, bookImgView.frameY + 10, SCREEN_WIDTH - bookImgView.frameRight - 20, 20)];
    _nameLabel = nameLabel;
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setTextColor:[UIColor whiteColor]];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [headImgView addSubview:nameLabel];
    
    UILabel *createrLabel = [[UILabel alloc] initWithFrame:CGRectMake(bookImgView.frameRight + 10, nameLabel.frameBottom, SCREEN_WIDTH - bookImgView.frameRight - 20, 20)];
    _createrLabel = createrLabel;
    [createrLabel setBackgroundColor:[UIColor clearColor]];
    [createrLabel setTextColor:[UIColor whiteColor]];
    [createrLabel setFont:[UIFont systemFontOfSize:10]];
    [headImgView addSubview:createrLabel];
    
    UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(bookImgView.frameRight + 10, createrLabel.frameBottom + 10, SCREEN_WIDTH - bookImgView.frameRight - 20, 20)];
    _pLabel = pLabel;
    [pLabel setBackgroundColor:[UIColor clearColor]];
    [pLabel setTextColor:[UIColor whiteColor]];
    [pLabel setFont:[UIFont systemFontOfSize:12]];
    [headImgView addSubview:pLabel];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(bookImgView.frameRight + 10, pLabel.frameBottom, SCREEN_WIDTH - bookImgView.frameRight - 20, 20)];
    _typeLabel = typeLabel;
    [typeLabel setBackgroundColor:[UIColor clearColor]];
    [typeLabel setTextColor:[UIColor whiteColor]];
    [typeLabel setFont:[UIFont systemFontOfSize:12]];
    [headImgView addSubview:typeLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(bookImgView.frameRight + 10, typeLabel.frameBottom, SCREEN_WIDTH - bookImgView.frameRight - 20, 20)];
    _timeLabel = timeLabel;
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor whiteColor]];
    [timeLabel setFont:[UIFont systemFontOfSize:12]];
    [headImgView addSubview:timeLabel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(30, bookImgView.frameBottom + 10, SCREEN_WIDTH - 60, 30)];
    [btn setBackgroundColor:CreateColor(154, 125, 251)];
    [btn setTitle:@"我也创建一本" forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5];
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [headImgView addSubview:btn];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frameBottom + 10, SCREEN_WIDTH, 60)];
    _backView = backView;
    [backView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:backView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, SCREEN_WIDTH - 30, 20)];
    [tipLabel setBackgroundColor:[UIColor clearColor]];
    [tipLabel setTextColor:CreateColor(129, 128, 129)];
    [tipLabel setFont:[UIFont systemFontOfSize:14]];
    [tipLabel setText:@"简介"];
    [backView addSubview:tipLabel];
    
    UILabel *contLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, tipLabel.frameBottom, SCREEN_WIDTH - 30, 20)];
    _contLabel =contLabel;
    [contLabel setBackgroundColor:[UIColor clearColor]];
    [contLabel setTextColor:CreateColor(172, 172, 172)];
    [contLabel setFont:[UIFont systemFontOfSize:10]];
    contLabel.numberOfLines = 0;
    [backView addSubview:contLabel];
}

- (void)buttonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
    NSInteger count = [self.navigationController.viewControllers count];
    id controller = self.navigationController.viewControllers[count - 2];
    if ([controller isKindOfClass:[PreviewWebViewController class]]) {
        if ([GlobalManager shareInstance].detailInfo.isDealer.integerValue == 1) {
            [(PreviewWebViewController *)controller setHasLoaded:NO];
            [(PreviewWebViewController *)controller setUrl:[G_PLAYER_ADDRESS stringByAppendingString:[NSString stringWithFormat:@"selectformat/b%@.htm?orientation=portrait",_recordItem.grow_id]]];
        }
        else {
            [(PreviewWebViewController *)controller resetSelfToRequest];
        }
    }
}

- (void)sendRequest
{
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"growAlbum"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"queryGrowDetailById"];
    [param setObject:_recordItem.grow_id forKey:@"grow_id"];
    //[param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf growDetailFinish:error Data:data];
        });
    }];
}

- (void)growDetailFinish:(NSError *)error Data:(id)result
{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.sessionTask = nil;
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSString *url = [ret_data valueForKey:@"template_image"];
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        [_bookImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:CREATE_IMG(@"detail_default")];
        
        [_nameLabel setText:[ret_data valueForKey:@"grow_name"]];
        [_createrLabel setText:[NSString stringWithFormat:@"作者：%@",[ret_data valueForKey:@"username"]]];
        [_pLabel setText:[NSString stringWithFormat:@"页数：%@页",[ret_data valueForKey:@"nums"]]];
        [_typeLabel setText:[NSString stringWithFormat:@"标签：%@",[ret_data valueForKey:@"tag_name"]]];
        
        NSString *create_time = [ret_data valueForKey:@"create_time"];
        NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:create_time.doubleValue];
        [_timeLabel setText:[NSString stringWithFormat:@"创建时间：%@",[NSString stringByDate:@"yyyy-MM-dd" Date:updateDate]]];
        
        NSString *contStr = [ret_data valueForKey:@"description"];
        CGSize lastSize = CGSizeZero;
        NSDictionary *attribute = @{NSFontAttributeName: _contLabel.font};
        lastSize = [contStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, CGFLOAT_MAX) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        CGFloat hei = MAX(lastSize.height + 10, 20);
        _backView.frameHeight = hei + 50;
        _contLabel.frameHeight = hei;
        [_contLabel setText:contStr];
    }
}

@end
