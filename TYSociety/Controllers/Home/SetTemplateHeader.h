//
//  SetTemplateHeader.h
//  TYSociety
//
//  Created by zhangxs on 16/7/8.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SetTemplateHeader;
@protocol SetTemplateHeaderDelagate <NSObject>

@optional
- (void)didTemplateHeadItem:(NSInteger)idx;
- (void)lookPigTemplateHeadItem:(NSInteger)idx;
@end

@interface SetTemplateHeader : NSObject <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *resource;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) id <SetTemplateHeaderDelagate> delegate;
@property (nonatomic, strong) NSIndexPath *recordIndexPath;
@property (nonatomic, assign) BOOL is_double;

- (void)createCollectionViewTo:(UIView *)view;

@end
