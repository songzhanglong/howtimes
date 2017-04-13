//
//  GrowDetailModel.h
//  TYSociety
//
//  Created by zhangxs on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol ImageCoor

@end
@interface ImageCoor : JSONModel

@property (nonatomic,strong)NSString *x;
@property (nonatomic,strong)NSString *y;
@property (nonatomic,strong)NSMutableArray *imgs;

@end

@protocol WordCoor

@end
@interface WordCoor : JSONModel

@property (nonatomic,strong)NSString *auto_flag;
@property (nonatomic,strong)NSString *color;
@property (nonatomic,strong)NSString *default_txt;
@property (nonatomic,strong)NSString *font;
@property (nonatomic,strong)NSString *label;
@property (nonatomic,strong)NSString *max_num;
@property (nonatomic,strong)NSString *size;
@property (nonatomic,strong)NSString *tip;
@property (nonatomic,strong)NSString *voice_flag;
@property (nonatomic,strong)NSString *x;
@property (nonatomic,strong)NSString *y;

@end

@protocol GrowContent

@end
@interface GrowContent : JSONModel

@property (nonatomic,strong)NSArray <ImageCoor>*image_coor;
@property (nonatomic,strong)NSArray <WordCoor>*word_coor;

@end


@interface GrowDetailModel : JSONModel

@property (nonatomic,strong)NSString *batch_id;
@property (nonatomic,strong)NSString *create_user;
@property (nonatomic,strong)GrowContent *detail_content;
@property (nonatomic,strong)NSString *detail_type;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *image_height;
@property (nonatomic,strong)NSString *image_thumb_url;
@property (nonatomic,strong)NSString *image_url;
@property (nonatomic,strong)NSString *image_width;
@property (nonatomic,strong)NSString *is_operate;
@property (nonatomic,strong)NSString *original_height;
@property (nonatomic,strong)NSString *original_width;
@property (nonatomic,strong)NSString *production_parameter;
@property (nonatomic,strong)NSString *template_detail_id;
@property (nonatomic,strong)NSString *template_id;
@property (nonatomic,strong)NSString *template_image_url;
@property (nonatomic,strong)NSString *template_index;
@property (nonatomic,strong)NSString *theme_id;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *user_grow_id;
@property (nonatomic,strong)NSString *user_id;

@end
