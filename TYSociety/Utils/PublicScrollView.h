//
//  PublicScrollView.h
//  ChildrenKing
//
//  Created by songzhanglong on 15/2/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PublicScrollView;

@protocol PublicScrollViewDelegate <NSObject>

@optional
- (void)indexChanged:(NSInteger)index ScrollView:(PublicScrollView *)pubSro;
- (void)touchImageAtIndex:(NSInteger)index ScrollView:(PublicScrollView *)pubSro;
- (void)playVideoAtIndex:(NSInteger)index ScrollView:(PublicScrollView *)pubSro;

@end

@interface PublicScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_backScrollView;
    NSArray *_imageUrlArray;
    NSInteger _nTotalPages;
    UIPageControl *_pageControl;
    
    UILabel *_tipLab;
}

@property (nonatomic,assign)NSInteger nCurrentPage;
@property (nonatomic,assign)id<PublicScrollViewDelegate> delegate;
@property (nonatomic,assign)BOOL autoScroll;
@property (nonatomic,assign)BOOL tipShow;
@property (nonatomic,strong)NSArray *checkArr;

- (void)setImagesArrayFromModel:(NSArray *)imageUrlArray;

- (void)reloadArr:(NSArray *)imgArr;

- (void)clearTimer;
- (void)resetTimer;

@end
