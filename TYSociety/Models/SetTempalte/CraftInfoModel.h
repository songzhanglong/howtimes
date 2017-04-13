//
//  CraftInfoModel.h
//  TYSociety
//
//  Created by zhangxs on 16/8/17.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CraftInfoModel : JSONModel

@property (nonatomic,strong)NSString *page_size;
@property (nonatomic,strong)NSString *share_name;
@property (nonatomic,strong)NSString *cover;
@property (nonatomic,strong)NSString *craft_name;

@end
