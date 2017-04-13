//
//  SysConfigModel.h
//  TYSociety
//
//  Created by zhangxs on 16/8/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface SysConfigModel : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *remark;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *data;
@property (nonatomic,strong)NSString *type;

@end
