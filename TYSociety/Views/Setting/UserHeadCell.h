//
//  UserHeadCell.h
//  TYSociety
//
//  Created by zhangxs on 16/6/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserHeadCell;
@protocol UserHeadCellDelegate <NSObject>
@optional
- (void)uploadFaceImageToIndex:(UserHeadCell *)cell;
- (void)upDataUserNameToIndex:(UserHeadCell *)cell;

@end

@interface UserHeadCell : UITableViewCell

@property (nonatomic, strong) UIImageView *faceImgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *changePsdBtn;
@property (nonatomic, assign) id<UserHeadCellDelegate> delegate;

- (void)resetDataSource:(id)data;

@end
