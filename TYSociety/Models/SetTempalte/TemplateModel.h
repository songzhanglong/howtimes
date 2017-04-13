//
//  TemplateModel.h
//  TYSociety
//
//  Created by zhangxs on 16/7/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface TemplateModel : JSONModel

@property (nonatomic,strong)NSString *cover_group;
@property (nonatomic,strong)NSString *detail_type;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *image_height;
@property (nonatomic,strong)NSString *image_thumb_url;
@property (nonatomic,strong)NSString *image_url;
@property (nonatomic,strong)NSString *image_width;
@property (nonatomic,strong)NSString *template_id;
@property (nonatomic,strong)NSString *title;

@end
