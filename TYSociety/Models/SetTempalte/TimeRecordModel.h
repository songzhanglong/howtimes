//
//  TimeRecordModel.h
//  TYSociety
//
//  Created by szl on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface TimeRecordModel : JSONModel

@property (nonatomic,strong)NSString *batch_id;         //批次id
@property (nonatomic,strong)NSString *cover_image;      //时光档案封面
@property (nonatomic,strong)NSString *username;         //用户昵称
@property (nonatomic,strong)NSNumber *detail_num;       //档案模板数
@property (nonatomic,strong)NSNumber *finish_num;       //档案模板数
@property (nonatomic,strong)NSString *image_url;        //模板封面
@property (nonatomic,strong)NSString *name;             //模板名称
@property (nonatomic,strong)NSString *head_img;         //用户头像
@property (nonatomic,strong)NSString *template_id;      //模板id
@property (nonatomic,strong)NSString *user_id;          //用户id
@property (nonatomic,strong)NSString *grow_id;          //时光档案id
@property (nonatomic,strong)NSString *is_double;        //是否跨页,1-跨页
@property (nonatomic,strong)NSString *craft_size;       
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *is_print;
@property (nonatomic,strong)NSString *sys_order_num;

@end
