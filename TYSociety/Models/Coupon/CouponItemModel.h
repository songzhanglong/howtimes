//
//  CouponItemModel.h
//  TYSociety
//
//  Created by szl on 16/7/1.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface OrderModel : JSONModel

@property (nonatomic,strong)NSString *amount;
//@property (nonatomic,strong)NSString *count;
@property (nonatomic,strong)NSString *coupon_amount;
@property (nonatomic,strong)NSString *craft_size;
@property (nonatomic,strong)NSString *freight;
@property (nonatomic,strong)NSString *image_url;
@property (nonatomic,strong)NSString *nums;
@property (nonatomic,strong)NSString *original_price;
@property (nonatomic,strong)NSString *sale_price;
@property (nonatomic,strong)NSString *template_name;

@end

@interface CouponItemModel : JSONModel

@property (nonatomic,strong)NSNumber *amount;       //金额
@property (nonatomic,strong)NSString *base_amount;  //优惠券使用限制 （如满100减30 ）
@property (nonatomic,strong)NSString *consume_time;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *digist;
@property (nonatomic,strong)NSString *end_time;
@property (nonatomic,strong)NSString *from;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *mobile;
@property (nonatomic,strong)NSString *order_id;
@property (nonatomic,strong)NSString *product_id;
@property (nonatomic,strong)NSString *start_time;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *store_id;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *coupon_url;
@property (nonatomic,strong)NSDictionary *order;

@end
