//
//  GrowTemplateModel.h
//  TYSociety
//
//  Created by zhangxs on 16/7/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol Theme

@end
@interface Theme : JSONModel

@property (nonatomic,strong)NSString *theme_id; //主题
@property (nonatomic,strong)NSString *template_index;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *template_detail_id;
@property (nonatomic,strong)NSString *image_url;
@property (nonatomic,strong)NSString *image_thumb_url;
@property (nonatomic,strong)NSString *template_id;
@property (nonatomic,strong)NSString *detail_type; //模板分类 1封面 2内容模板，3封底
@property (nonatomic,strong)NSString *cover_group;
@property (nonatomic,strong)NSString *image_height;
@property (nonatomic,strong)NSString *image_width;
@property (nonatomic,strong)NSString *c_id;

@end

@interface GrowTemplateModel : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *sort;
@property (nonatomic,strong)NSString *theme_name;
@property (nonatomic,strong)NSMutableArray <Theme>*template;

- (GrowTemplateModel *)itemCopy;

@end
