//
//  YWCBottomScrollView.h
//  网易首页
//
//  Created by City--Online on 15/9/1.
//  Copyright (c) 2015年 City--Online. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void(^PageChangedBlock)(CGFloat offsetX);
typedef  void(^PageChangeIndexBlock)(NSInteger index);

@interface YWCBottomScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,copy) PageChangedBlock pageChangedBlock;
@property (nonatomic,copy) PageChangeIndexBlock pageChangeIndexBlock;

-(instancetype)initWithFrame:(CGRect)frame andItems:(NSArray*)viewControllorArray Index:(NSInteger)index;
-(void)setShowPageWithIndex:(NSInteger)index;

@end
