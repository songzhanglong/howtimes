//
//  FastMakeCell.h
//  TYSociety
//
//  Created by szl on 16/7/14.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoManagerModel;

@protocol FastMakeCellDelegate <NSObject>

@optional
- (BOOL)checkItemOf:(UICollectionViewCell *)cell Check:(BOOL)check;
- (CGSize)minImageSizeByMakeView;

@end

@interface FastMakeCell : UICollectionViewCell

@property (nonatomic,strong)PhotoManagerModel *managerPhoto;
@property (nonatomic,assign)id<FastMakeCellDelegate> delegate;
@property (nonatomic,strong)UIImageView *checkImg;
@property (nonatomic,strong)UIImageView *contentImg;
@property (nonatomic,strong)UIImageView *waitImg;
@property (nonatomic,strong)UIView *coverView;
@property (nonatomic,strong)UIButton *qualityBtn;

- (void)resetPhotoData:(PhotoManagerModel *)data;
- (void)resetImgShowQuality:(CGSize)size;

#pragma mark - state
- (void)changeUploadState;

- (void)photoUplodFinish;

@end
