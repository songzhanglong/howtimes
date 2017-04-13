//
//  AddressModel.h
//  TYSociety
//
//  Created by zhangxs on 16/7/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface AddressModel : JSONModel

@property (nonatomic,strong)NSString *postal;
@property (nonatomic,strong)NSString *area_code;
@property (nonatomic,strong)NSString *consignee;
@property (nonatomic,strong)NSString *is_default;
@property (nonatomic,strong)NSString *m_id;
@property (nonatomic,strong)NSString *city;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *update_time;
@property (nonatomic,strong)NSString *address;
@property (nonatomic,strong)NSString *phone_num;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *province;
@property (nonatomic,strong)NSString *is_del;
@property (nonatomic,strong)NSString *mobile_num;
@property (nonatomic,assign)BOOL is_select;

@end
