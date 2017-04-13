//
//  GuideScrollView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/3/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "GuideScrollView.h"

@implementation GuideScrollView
{
    UIPageControl *_pageControl;
    BOOL isLaunchApp;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [scrollView setContentSize:CGSizeMake(frame.size.width * 4, frame.size.height)];
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        [self addSubview:scrollView];
        
        CGFloat hScale = SCREEN_WIDTH / 375, vScale = SCREEN_HEIGHT / 667,bottom = vScale * 115,topMar = 90 * vScale,imgMar = 190 * vScale;
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 10 - bottom, frame.size.width, 10)];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = rgba(225, 218, 254, 1);
        _pageControl.currentPageIndicatorTintColor = BASELINE_COLOR;
        _pageControl.numberOfPages = 4;
        [self addSubview:_pageControl];
        
        NSArray *imgArr = @[@"guide1",@"guide2",@"guide3",@"guide4"],
        *titlesArr = @[@"这是一款神奇的APP",@"私人定制 拒绝平庸",@"花样定制 册由你定",@"优质服务"],
        *sutTitles = @[@"随时随地 分秒成书",@"轻松书写自己的人生故事",@"能打印的多媒体相册 视频语音任您添加",@"一键成册 下单即印 全国配送"];
        NSInteger fontSize = 30,subFont = 20;
        if (hScale < 1) {
            fontSize = (NSInteger)(fontSize * hScale);
            subFont = (NSInteger)(subFont * hScale);
        }
        CGFloat imgWei = SCREEN_WIDTH - 60;
        for (NSInteger i = 0; i < imgArr.count; i++) {
            //title
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10 + SCREEN_WIDTH * i, topMar, SCREEN_WIDTH - 20, fontSize + 4)];
            [title setFont:[UIFont systemFontOfSize:fontSize]];
            [title setTextAlignment:NSTextAlignmentCenter];
            [title setTextColor:BASELINE_COLOR];
            [title setText:titlesArr[i]];
            [title setBackgroundColor:[UIColor whiteColor]];
            [scrollView addSubview:title];
            
            //sub title
            UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(title.frameX, title.frameBottom + 7, title.frameWidth, 24)];
            [subTitle setFont:[UIFont systemFontOfSize:subFont]];
            [subTitle setTextAlignment:NSTextAlignmentCenter];
            [subTitle setTextColor:[UIColor darkGrayColor]];
            [subTitle setText:sutTitles[i]];
            [subTitle setBackgroundColor:[UIColor whiteColor]];
            [scrollView addSubview:subTitle];
            
            UIImage *img = CREATE_IMG(imgArr[i]);
            CGFloat imgHei = imgWei * img.size.height / img.size.width;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 + SCREEN_WIDTH * i, imgMar, imgWei, imgHei)];
            [imageView setImage:img];
            [scrollView addSubview:imageView];
        }
        isLaunchApp = YES;
    }
    return self;
}

- (void)launchApp:(id)sender
{
    [_delegate startLaunchApp:self];
}

#pragma mark -  触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)setNewCurentPage:(UIScrollView *)scrollView
{
    NSInteger lastIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    _pageControl.currentPage = lastIndex;
}

#pragma mark -  滚动停止时，触发该函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setNewCurentPage:scrollView];
}

#pragma mark -  触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self setNewCurentPage:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self setNewCurentPage:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > ((_pageControl.numberOfPages - 1) * scrollView.frame.size.width + 5) && isLaunchApp) {
        [_delegate startLaunchApp:self];
        isLaunchApp = NO;
    }
}

@end
