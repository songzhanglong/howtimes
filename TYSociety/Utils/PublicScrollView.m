//
//  PublicScrollView.m
//  ChildrenKing
//
//  Created by songzhanglong on 15/2/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "PublicScrollView.h"
#import "UIImage+Caption.h"

#define IMAGE_WIDTH     self.frame.size.width
#define IMAGE_HEIGHT    self.frame.size.height

#define IMAGE_TAG       200

@implementation PublicScrollView

- (void) dealloc
{
    [self clearTimer];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _autoScroll = YES;
    }
    return self;
}

#pragma mark - 定时器
- (void)clearTimer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer:) object:nil];
}

- (void)resetTimer
{
    [self clearTimer];
    if (!_autoScroll || (_nTotalPages < 2)) {
        _autoScroll = NO;
        
        return;
    }
    
    [self performSelector:@selector(startTimer:) withObject:nil afterDelay:3.0];
}

- (void)startTimer:(NSTimeInterval)time
{
    if (!_autoScroll || (_nTotalPages < 2)) {
        _autoScroll = NO;
        [self clearTimer];
        return;
    }
    [_backScrollView scrollRectToVisible:CGRectMake(2 * IMAGE_WIDTH, 0, IMAGE_WIDTH, IMAGE_HEIGHT) animated:YES];
}

#pragma mark - 手势
- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchImageAtIndex:ScrollView:)]) {
        [_delegate touchImageAtIndex:_nCurrentPage ScrollView:self];
    }
}

- (void)playAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(playVideoAtIndex:ScrollView:)]) {
        [_delegate playVideoAtIndex:_nCurrentPage ScrollView:self];
    }
}

#pragma mark - 视图设置
- (void)loadImage
{
    _pageControl.currentPage = _nCurrentPage;
    [_tipLab setText:[NSString stringWithFormat:@"%ld/%ld",(long)_nCurrentPage + 1,(long)_nTotalPages]];
    
    NSString *midUrl = [_imageUrlArray objectAtIndex:_nCurrentPage];
    NSInteger rightIdx = (_nCurrentPage + 1 >= _nTotalPages) ? 0 : (_nCurrentPage + 1);
    NSString *rightUrl = [_imageUrlArray objectAtIndex:rightIdx];
    NSInteger leftIdx = (_nCurrentPage > 0) ? (_nCurrentPage - 1) : (_nTotalPages - 1);
    NSString *leftUrl = [_imageUrlArray objectAtIndex:leftIdx];
    
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = (UIImageView *)[_backScrollView viewWithTag:i + IMAGE_TAG];
        UIButton *button = (UIButton *)[imageView viewWithTag:1];
        switch (i) {
            case 0:
            {
                if (_checkArr) {
                    NSNumber *number = _checkArr[leftIdx];
                    button.hidden = !number.boolValue;
                }
                
                if (_nTotalPages > 1) {
                    NSString *url = leftUrl;
                    if (![url hasPrefix:@"http"]) {
                        url = [[G_IMAGE_ADDRESS stringByAppendingString:url ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    if ([url hasSuffix:@"mp4"]) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:url] atTime:1];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [imageView setImage:image];
                            });
                        });
                    }
                    else{
                        [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
                    }
                    
                }
                else{
                    imageView.image = nil;
                }
            }
                break;
            case 1:
            {
                if (_checkArr) {
                    NSNumber *number = _checkArr[_nCurrentPage];
                    button.hidden = !number.boolValue;
                }
                
                NSString *url = midUrl;
                if (![url hasPrefix:@"http"]) {
                    url = [[G_IMAGE_ADDRESS stringByAppendingString:url ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                if ([url hasSuffix:@"mp4"]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:url] atTime:1];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imageView setImage:image];
                        });
                    });
                }
                else{
                    [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
                }
            }
                break;
            case 2:
            {
                if (_checkArr) {
                    NSNumber *number = _checkArr[rightIdx];
                    button.hidden = !number.boolValue;
                }
                
                if (_nTotalPages > 1) {
                    NSString *url = rightUrl;
                    if (![url hasPrefix:@"http"]) {
                        url = [[G_IMAGE_ADDRESS stringByAppendingString:url ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    if ([url hasSuffix:@"mp4"]) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:url] atTime:1];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [imageView setImage:image];
                            });
                        });
                    }
                    else{
                        [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
                    }
                }
                else{
                    imageView.image = nil;
                }
            }
                break;
            default:
                break;
        }
    }
    
    //数量
    if (_nTotalPages < 2) {
        _backScrollView.scrollEnabled = NO;
        _autoScroll = NO;
    }
    [self resetTimer];
}

- (void)resetSubViews
{
    //清空以前添加过的视图
    for (UIView *subView in [_backScrollView subviews]) {
        if ([subView isKindOfClass:[UIImageView class]] && subView.tag > 0) {
            [subView removeFromSuperview];
        }
    }
    
    if (_pageControl) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
    }
    
    if (_tipLab) {
        [_tipLab removeFromSuperview];
        _tipLab = nil;
    }
    
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * IMAGE_WIDTH, 0, IMAGE_WIDTH, IMAGE_HEIGHT)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setTag:i + IMAGE_TAG];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setUserInteractionEnabled:YES];
        [_backScrollView addSubview:imageView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((imageView.bounds.size.width - 30) / 2, (imageView.bounds.size.height - 30) / 2, 30, 30)];
        [btn setTag:1];
        btn.hidden = YES;
        [btn setImage:CREATE_IMG(@"mileageVideo") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btn];
        
        //手势
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTapGesture setNumberOfTapsRequired:1];
        [imageView addGestureRecognizer:singleTapGesture];
        
    }
    
    [_backScrollView setContentOffset:CGPointMake(IMAGE_WIDTH, 0)];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, IMAGE_HEIGHT - 20, IMAGE_WIDTH, 20)];
    _pageControl.userInteractionEnabled = NO;
    [_pageControl setPageIndicatorTintColor:rgba(225, 218, 254, 1)];
    [_pageControl setCurrentPageIndicatorTintColor:BASELINE_COLOR];
    [self addSubview:_pageControl];
    
    _pageControl.numberOfPages = _nTotalPages;
    _pageControl.currentPage = _nCurrentPage;
    _pageControl.hidden = (_tipShow || !_backScrollView.scrollEnabled);
    
    _tipLab = [[UILabel alloc] initWithFrame:CGRectMake((IMAGE_WIDTH - 40) / 2, IMAGE_HEIGHT - 30, 40, 18)];
    [_tipLab setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [_tipLab setTextColor:[UIColor whiteColor]];
    [_tipLab setTextAlignment:1];
    [_tipLab setFont:[UIFont systemFontOfSize:10]];
    [_tipLab setText:[NSString stringWithFormat:@"1/%ld",(long)_nTotalPages]];
    [self addSubview:_tipLab];
    _tipLab.hidden = (!_tipShow || !_backScrollView.scrollEnabled);
    
    [self loadImage];
}

#pragma mark - 数据源
- (void)setImagesArrayFromModel:(NSArray *)imageUrlArray
{
    //设置scrollview的宽度，为3页内容
    _backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT)];
    _backScrollView.pagingEnabled = YES;
    _backScrollView.delegate = self;
    [_backScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _backScrollView.showsHorizontalScrollIndicator = NO;
    [_backScrollView setContentSize:CGSizeMake(IMAGE_WIDTH * 3, IMAGE_HEIGHT)];
    [self addSubview:_backScrollView];
    
    _imageUrlArray = imageUrlArray;
    _nTotalPages = [imageUrlArray count];
    //背景视图
    _backScrollView.scrollEnabled = (_nTotalPages > 1);
    
    if (_nCurrentPage >= _nTotalPages) {
        _nCurrentPage = (_nTotalPages > 0) ? (_nTotalPages - 1) : 0;
    }
    else if (_nCurrentPage < 0) {
        _nCurrentPage = 0;
    }
    
    [self resetSubViews];
}

- (void)reloadArr:(NSArray *)imgArr
{
    if ([imgArr isEqualToArray:_imageUrlArray]) {
        return;
    }
    
    if (!_backScrollView) {
        [self setImagesArrayFromModel:imgArr];
    }
    else{
        _imageUrlArray = imgArr;
        _nTotalPages = [imgArr count];
        _nCurrentPage = 0;
        _backScrollView.scrollEnabled = (_nTotalPages > 1);
        [self resetSubViews];
    }
}

#pragma mark -  触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)setAlphaAndImages {
    NSInteger lastIndex = _nCurrentPage;
    
    //scrollview结束滚动时判断是否已经换页
    if (_backScrollView.contentOffset.x > IMAGE_WIDTH) {
        
        //如果是最后一张图片，则将主imageview内容置为第一张图片
        //如果不是最后一张图片，则将主imageview内容置为下一张图片
        if (_nCurrentPage < (_nTotalPages - 1)) {
            _nCurrentPage++;
            
        } else {
            _nCurrentPage = 0;
        }
        
        //最左边的图片移到最右边
        UIImageView *leftImg = (UIImageView *)[_backScrollView viewWithTag:IMAGE_TAG];
        [leftImg setTag:IMAGE_TAG + 2];
        [leftImg setFrame:CGRectMake(IMAGE_WIDTH * 2, 0, IMAGE_WIDTH, IMAGE_HEIGHT)];
        
        //改变位置与tag
        for (UIImageView *theView in [_backScrollView subviews]) {
            if ((theView.tag > 0) && (theView != leftImg)) {
                CGRect rect = theView.frame;
                theView.tag -= 1;
                theView.frame = CGRectMake(rect.origin.x - IMAGE_WIDTH, rect.origin.y, rect.size.width, rect.size.height);
            }
        }
        [self loadImage];
    }
    else if (_backScrollView.contentOffset.x < IMAGE_WIDTH) {
        
        //如果是第一张图片，则将主imageview内容置为最后一张图片
        //如果不是第一张图片，则将主imageview内容置为上一张图片
        if (_nCurrentPage > 0) {
            _nCurrentPage--;
        } else {
            _nCurrentPage = _nTotalPages - 1;
        }
        
        //最右边的图片移到最左边
        UIImageView *rightImg = (UIImageView *)[_backScrollView viewWithTag:IMAGE_TAG + 2];
        [rightImg setTag:IMAGE_TAG];
        [rightImg setFrame:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT)];
        
        //改变位置与tag
        for (UIImageView *theView in [_backScrollView subviews]) {
            if ((theView.tag > 0) && (theView != rightImg)) {
                CGRect rect = theView.frame;
                theView.tag += 1;
                theView.frame = CGRectMake(rect.origin.x + IMAGE_WIDTH, rect.origin.y, rect.size.width, rect.size.height);
            }
        }
        [self loadImage];
    }
    
    
    //始终将scrollview置为第1页
    [_backScrollView setContentOffset:CGPointMake(IMAGE_WIDTH, 0.0)];
    _pageControl.currentPage = _nCurrentPage;
    [_tipLab setText:[NSString stringWithFormat:@"%ld/%ld",(long)_nCurrentPage + 1,(long)_nTotalPages]];
    [self resetTimer];
    
    if (lastIndex != _nCurrentPage) {
        if (_delegate && [_delegate respondsToSelector:@selector(indexChanged:ScrollView:)]) {
            [_delegate indexChanged:_nCurrentPage ScrollView:self];
        }
    }
    
}

#pragma mark -  滚动开始
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self clearTimer];
}

#pragma mark -  滚动停止时，触发该函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setAlphaAndImages];
}

#pragma mark -  触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self setAlphaAndImages];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self setAlphaAndImages];
}

@end
