//
//  UserDetailInfo.h
//  TYSociety
//
//  Created by szl on 16/6/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface DealerInfo : JSONModel

@property (nonatomic,strong)NSString *credentials_img;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *area_code;
@property (nonatomic,strong)NSString *province_code;
@property (nonatomic,strong)NSString *tel;
@property (nonatomic,strong)NSString *city_code;
@property (nonatomic,strong)NSString *linkman;
@property (nonatomic,strong)NSString *dealer_name;

@end

@interface UserInfo : JSONModel

@property (nonatomic,strong)NSString *dealer_id;
@property (nonatomic,strong)NSString *device_no;
@property (nonatomic,strong)NSString *head_img;
@property (nonatomic,strong)NSString *id;           //用户id
@property (nonatomic,strong)NSString *login_name;
@property (nonatomic,strong)NSString *md5_pwd;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *open_id;
@property (nonatomic,strong)NSString *password;
@property (nonatomic,strong)NSString *phone;        //联系电话
@property (nonatomic,strong)NSNumber *sex;          //1-boy,2-girl
@property (nonatomic,strong)NSNumber *status;       //状态  0 未激活 1正常 2.无效
@property (nonatomic,strong)NSString *vaild_date;
@property (nonatomic,strong)NSString *create_time;

@end

@interface UserConfig : JSONModel

@property (nonatomic,strong)NSNumber *coop_type;        //协作类型
@property (nonatomic,strong)NSNumber *create_myself;    //为自己创建成长档案 1可以为自己创建 ，0不可以
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSNumber *individuation;    //制作个性化 1.团体，2个人(个性化)
@property (nonatomic,strong)NSNumber *is_share;         //分享电子档案 1可以分享 ，0不可以
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSNumber *print;            //是否提供打印 1可以打印，0不可以
@property (nonatomic,strong)NSNumber *is_addconsumer;   //是否可以创建客户 1可以，0不可以

@end

@interface UserDetailInfo : JSONModel

@property (nonatomic,strong)UserConfig *config;
@property (nonatomic,strong)UserInfo *user;
@property (nonatomic,strong)NSString *token;
@property (nonatomic,strong)NSNumber *isDealer;         //1机构 ，0个人
@property (nonatomic,strong)DealerInfo *dealer;
@property (nonatomic,strong)NSMutableArray<Ignore> *profiles;  //个人作品，机构忽略
@property (nonatomic,strong)NSDictionary<Ignore> *userInfo;

@end
