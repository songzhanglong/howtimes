//
//  HomeRecommond.h
//  TYSociety
//
//  Created by szl on 16/6/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol AdTags
@end

@interface AdTags : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *logo;
@property (nonatomic,strong)NSString *desc;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSNumber *status;   //0-表示未启用，1-表示已启用

@end

@protocol ADItemCoupon
@end

@interface ADItemCoupon : JSONModel

@property (nonatomic,strong)NSString *batch_id;
@property (nonatomic,strong)NSString *grow_id;
@property (nonatomic,strong)NSString *is_double;    //是否跨页,1-跨页
@property (nonatomic,strong)NSNumber *type;         //1-成长档案，2-活动
@property (nonatomic,strong)NSString *user_id;
@property (nonatomic,strong)NSNumber *is_login;     //0不需要 ，1需要

@end

@protocol ADItem

@end
@interface ADItem : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *picture;
@property (nonatomic,strong)NSNumber *sort;
@property (nonatomic,strong)ADItemCoupon *param;
@property (nonatomic,strong)NSString *ad_name;
@property (nonatomic,strong)NSString *postion;
@property (nonatomic,strong)NSNumber *type;     // 1. h5  2.程序跳转
@property (nonatomic,strong)NSString *key;      // 这里类似 童印菜单里的模式
@property (nonatomic,strong)NSString *url;      //h5地址

@end

@protocol RecommondItem

@end
@interface RecommondItem : JSONModel

@property (nonatomic,strong)NSString *id;           //广告位id
@property (nonatomic,strong)NSString *picture;      //图片
@property (nonatomic,strong)NSNumber *sort;         //排序
@property (nonatomic,strong)NSNumber *tag_id;       //类型id

@end

@interface AdModel : JSONModel

@property (nonatomic,strong)NSMutableArray<ADItem> *ad_1;
@property (nonatomic,strong)NSMutableArray<ADItem> *ad_2;

@end

@interface HomeRecommond : JSONModel

@property (nonatomic,strong)AdModel *ad;
@property (nonatomic,strong)NSMutableArray<RecommondItem> *tmplate_tag;
@property (nonatomic,strong)NSMutableArray<AdTags> *tags;

@end
