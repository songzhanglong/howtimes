//
//  CheckCoverCell.h
//  TYSociety
//
//  Created by szl on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckCoverCellDelegate <NSObject>

@optional
- (void)deleteCoverCell:(UICollectionViewCell *)cell;

@end

@interface CheckCoverCell : UICollectionViewCell

@property (nonatomic,strong)UIImageView *coverImg;
@property (nonatomic,strong)UIImageView *preImg;
@property (nonatomic,strong)UIImageView *leftImg;
@property (nonatomic,strong)UIButton *qualityBtn;
@property (nonatomic,assign)id<CheckCoverCellDelegate> delegate;

@end
