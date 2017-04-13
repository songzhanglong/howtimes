//
//  YWCBottomScrollView.m
//  网易首页
//
//  Created by City--Online on 15/9/1.
//  Copyright (c) 2015年 City--Online. All rights reserved.
//

#import "YWCBottomScrollView.h"

@interface YWCBottomScrollView ()
@property (nonatomic,strong) NSArray *viewControllorArray;

@end
@implementation YWCBottomScrollView
{
    NSInteger _curIdx;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andItems:(NSArray*)viewControllorArray Index:(NSInteger)index
{
    self = [self initWithFrame:frame];
    if (self) {
        _curIdx = index;
        _viewControllorArray = viewControllorArray;
        self.contentSize = CGSizeMake(frame.size.width * viewControllorArray.count, frame.size.height);
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.directionalLockEnabled = YES;
        //控制控件遇到边框是否反弹
        self.bounces=NO;
        //控制垂直方向遇到边框是否反弹
        self.alwaysBounceVertical = NO;
        //控制水平方向遇到边框是否反弹
        self.alwaysBounceHorizontal = NO;
        //控制控件是否整页翻动
        self.pagingEnabled=YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        for (NSInteger i = 0; i < viewControllorArray.count; i++) {
            if (i == _curIdx) {
                UIViewController *vc = [viewControllorArray objectAtIndex:i];
                vc.view.frame = CGRectMake(frame.size.width * i, 0, frame.size.width, frame.size.height);
                [self addSubview:vc.view];
            }
        }
        [self setContentOffset:CGPointMake(frame.size.width * _curIdx, 0)];
    }
    
    return self;
}

- (void)setShowPageWithIndex:(NSInteger)index
{
    [self scrollRectToVisible:CGRectMake(self.frame.size.width * index, 0, self.frame.size.width, self.frame.size.height) animated:NO];
    _curIdx = index;
    [self initScrollViewWithIndex:index];
}

- (void)initScrollViewWithIndex:(NSInteger)index
{
    for (NSInteger i = 0; i < _viewControllorArray.count; i++) {
        UIViewController *vc = [_viewControllorArray objectAtIndex:i];
        
        if (i == index && [vc.view superview] != self) {
            vc.view.frame = CGRectMake(self.frame.size.width*i, 0, self.frame.size.width, self.frame.size.height);
            [self addSubview:vc.view];
            break;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_pageChangedBlock) {
        CGFloat offsetx = scrollView.contentOffset.x;
        _pageChangedBlock(offsetx);
        
        CGFloat referX = _curIdx * SCREEN_WIDTH;
        CGFloat diff = fabs(offsetx - referX);
        if (diff >= 2) {
            //滑过1/4，立即加载
            NSInteger shouldIdx;
            if (offsetx > referX) {
                shouldIdx = _curIdx + 1;
            }
            else{
                shouldIdx = _curIdx - 1;
            }
            if (shouldIdx >= 0 && shouldIdx < _viewControllorArray.count) {
                [self initScrollViewWithIndex:shouldIdx];
            }
        }
    }
}

#pragma mark -  滚动停止时，触发该函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetx = scrollView.contentOffset.x;
    NSInteger index = offsetx / self.frame.size.width;
    _curIdx = index;
    _pageChangeIndexBlock(index);
}

#pragma mark -  触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        CGFloat offsetx = scrollView.contentOffset.x;
        NSInteger index = offsetx / self.frame.size.width;
        _curIdx = index;
        _pageChangeIndexBlock(index);
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    CGFloat offsetx = scrollView.contentOffset.x;
    NSInteger index = offsetx / self.frame.size.width;
    _curIdx = index;
    _pageChangeIndexBlock(index);
}

@end
