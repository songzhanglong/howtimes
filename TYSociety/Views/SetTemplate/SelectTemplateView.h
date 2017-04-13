//
//  SelectTemplateView.h
//  TYSociety
//
//  Created by zhangxs on 16/7/21.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateModel.h"

@class SelectTemplateView;
@protocol SelectTemplateViewDelegate <NSObject>
@optional
- (void)addTemplateSource:(TemplateModel *)item Theme:(NSString *)theme_name;
- (void)cancelTemplateIndex;
@end

@interface SelectTemplateView : UIView <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, assign) id <SelectTemplateViewDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *theme_name;
@property (nonatomic, assign) BOOL is_double;

- (id)initWithFrame:(CGRect)frame Datas:(NSMutableArray *)dataSource OtherDatas:(NSMutableArray *)otners;
- (void)showInView:(UIView *)view;

@end
