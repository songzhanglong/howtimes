//
//  CoopModel.h
//  TYSociety
//
//  Created by zhangxs on 16/8/24.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CoopModel : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *image_url;
@property (nonatomic,strong)NSString *image_width;
@property (nonatomic,strong)NSString *image_thumb_url;
@property (nonatomic,strong)NSString *image_height;
@property (nonatomic,strong)NSString *template_id;
@property (nonatomic,strong)NSString *c_id;
@property (nonatomic,strong)NSString *coop_flag;

@end
