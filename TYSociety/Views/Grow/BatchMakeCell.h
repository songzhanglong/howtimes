//
//  BatchMakeCell.h
//  TYSociety
//
//  Created by szl on 16/7/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RecordTemplate;

@protocol BatchMakeCellDelegate <NSObject>

@optional
- (BOOL)canCheckTemeplate:(UICollectionViewCell *)collectionViewCell;

- (void)checkCell:(UICollectionViewCell *)collectionViewCell At:(NSInteger)index;

@end

@interface BatchMakeCell : UICollectionViewCell

@property (nonatomic,assign)id<BatchMakeCellDelegate> delegate;
@property (nonatomic,strong)UIImageView *contentImg;
@property (nonatomic,assign)NSInteger nSelectIdx;
@property (nonatomic,strong)RecordTemplate *record;

- (void)resetBatchMakeModel:(id)object Arr:(NSArray *)array Size:(CGSize)itemSize fullSize:(CGSize)fullSize;

- (void)resetNewArr:(NSArray *)array;

- (CGRect)getRectBySelectIdx;

- (void)clearAllStatus;

- (void)selectButtonAt:(NSInteger)index;

@end
