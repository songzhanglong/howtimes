//
//  UserHeadCell.h
//  TYSociety
//
//  Created by zhangxs on 16/6/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface PerInforModel : JSONModel

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *head_img;
@property (nonatomic,strong) UIImage *faceImg;
@property (nonatomic,strong) NSString *user_id;
@property (nonatomic,assign) NSInteger recordID;
@property (nonatomic,assign) BOOL isDelete;

@end
