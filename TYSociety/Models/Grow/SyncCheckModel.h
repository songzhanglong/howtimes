//
//  SyncCheckModel.h
//  TYSociety
//
//  Created by szl on 16/7/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface SyncCheckModel : JSONModel

@property (nonatomic,strong)NSString *id;       //客户id
@property (nonatomic,strong)NSString *phone;    //客户电话
@property (nonatomic,strong)NSString *name;     //客户名称
@property (nonatomic,strong)NSString *head_img; //客户头像 （预留）
@property (nonatomic,strong)NSNumber *is_change;//0表示可以同步，1不可以同步
@property (nonatomic,strong)NSString *user_id;  //客户的用户id

@end
