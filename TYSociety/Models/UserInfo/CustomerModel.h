//
//  CustomerModel.h
//  TYSociety
//
//  Created by zhangxs on 16/7/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol CustomerModel
@end
@interface CustomerModel : JSONModel

@property (nonatomic,strong)NSString *batch_id;         //批次id
@property (nonatomic,strong)NSString *finish_num;       //制作数
@property (nonatomic,strong)NSString *name;             //客户名称
@property (nonatomic,strong)NSString *nums;             //模板数
@property (nonatomic,strong)NSString *phone;            //客户名称
@property (nonatomic,strong)NSString *template_id;
@property (nonatomic,strong)NSString *template_name;    //模板名称
@property (nonatomic,strong)NSString *user_id;          //客户用户id
@property (nonatomic,strong)NSString *grow_id;          //用户档案id
@property (nonatomic,strong)NSString *craft_size;
@property (nonatomic,strong)NSString *is_public;        //是否已经发布 0没有 1已发布图片未生成，2已发布图片已生成
@property (nonatomic,strong)NSString *is_double;        //是否跨页,1-跨页
@property (nonatomic,strong)NSString *is_print;

//CustomerInfo  合并
@property (nonatomic,strong)NSString *address;
@property (nonatomic,strong)NSString *address_id;
@property (nonatomic,strong)NSString *print_flag;
@property (nonatomic,strong)NSString *print_url;
@property (nonatomic,strong)NSString *sys_order_num;
@property (nonatomic,strong)NSString *template_image;
@property (nonatomic,strong)NSString *user_name;
@property (nonatomic,strong)NSString *grow_name;
@property (nonatomic,assign)BOOL isSelected;
@property (nonatomic,assign)NSInteger print_num;
@property (nonatomic,strong)NSString *sale_price;
@property (nonatomic,strong)NSString *mobile_num;
@property (nonatomic,strong)NSString *consignee;

@end

@interface BatchCustomers : JSONModel

@property (nonatomic,strong)NSNumber *is_create_grow;   //是否选择模板
@property (nonatomic,strong)NSNumber *is_choose_craft;  //是否选择工艺  0=未选择 1=已选择  当is_create_grow=0 是这个参数有效
@property (nonatomic,strong)NSString *batch_id;         //批次id
@property (nonatomic,strong)NSString *size;             //模板尺寸
@property (nonatomic,strong)NSString *grow_name;        //批次名称
@property (nonatomic,strong)NSString *grow_id;
@property (nonatomic,strong)NSMutableArray<CustomerModel> *consumers;   //客户集合

@end
