//
//  TimeRecordInfo.h
//  TYSociety
//
//  Created by szl on 16/7/19.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol WordCoorInfo
@end
@interface WordCoorInfo : JSONModel

@property (nonatomic,strong)NSString *x;
@property (nonatomic,strong)NSString *y;
@property (nonatomic,strong)NSNumber *size;
@property (nonatomic,strong)NSNumber *max_num;
@property (nonatomic,strong)NSString *tip;
@property (nonatomic,strong)NSString *default_txt;
@property (nonatomic,strong)NSString *color;
@property (nonatomic,strong)NSString *font;
@property (nonatomic,strong)NSNumber *auto_flag;
@property (nonatomic,strong)NSNumber *voice_flag;
@property (nonatomic,strong)NSString *label;        //表单提交 lable

@end

@protocol ImageCoorInfo
@end
@interface ImageCoorInfo : JSONModel

@property (nonatomic,strong)NSString *x;
@property (nonatomic,strong)NSString *y;

@end

//deco_path一致
@protocol ProductImagePath
@end
@interface ProductImagePath : JSONModel

@property (nonatomic,strong)NSString *image_url;
@property (nonatomic,strong)NSString *detail;       //位置X_位置Y_宽度_高度_旋转度
@property (nonatomic,strong)NSNumber *original_height;  //图片实际高度
@property (nonatomic,strong)NSNumber *original_width;   //图片实际宽度

@end

@protocol ProductImageGallery
@end
@interface ProductImageGallery : JSONModel

@property (nonatomic,strong)NSNumber *type;     //1-picture,2-video,3-voice
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSNumber *is_cover;
@property (nonatomic,strong)NSString *picture;  //视频封面，图片则为空
@property (nonatomic,strong)NSNumber *original_height;  //图片实际高度
@property (nonatomic,strong)NSNumber *original_width;   //图片实际宽度

@end

@protocol ProductImageInput
@end
@interface ProductImageInput : JSONModel

@property (nonatomic,strong)NSString *txt;
@property (nonatomic,strong)NSString *voice;

@end

@protocol ProductImageDecotext
@end
@interface ProductImageDecotext : JSONModel

@property (nonatomic,strong)NSString *txt;
@property (nonatomic,strong)NSString *color;
@property (nonatomic,strong)NSString *font;
@property (nonatomic,strong)NSString *detail;       //位置X_位置Y_宽度_高度_旋转度
@property (nonatomic,strong)NSNumber *alpha;        //透明度

@end

@interface CustomParamter : NSObject

@property (nonatomic,strong)NSString *imgpath;
@property (nonatomic,strong)NSString *gallery;
@property (nonatomic,strong)NSString *imginput;
@property (nonatomic,strong)NSString *imgdeco;
@property (nonatomic,strong)NSString *decoTxt;

@end

@interface ProductionParameter : JSONModel

@property (nonatomic,strong)NSMutableArray<ProductImagePath> *image_path;   //封面数组
@property (nonatomic,strong)NSMutableArray *src_gallery_list;   //图集数组
@property (nonatomic,strong)NSMutableArray<ProductImagePath> *deco_path;    //素材数组
@property (nonatomic,strong)NSMutableArray<ProductImageInput> *input_text;  //文本数组
@property (nonatomic,strong)NSMutableArray<ProductImageDecotext> *deco_text;    //自定义文本数组

@end

@interface TemplateDetail : JSONModel

@property (nonatomic,strong)NSMutableArray<WordCoorInfo> *word_coor;
@property (nonatomic,strong)NSMutableArray<ImageCoorInfo> *image_coor;

@end

@class RecordTemplate;
typedef void(^RecordUploadBlock)(RecordTemplate *recordPlate);

@protocol RecordTemplate
@end
@interface RecordTemplate : JSONModel

@property (nonatomic,strong)NSNumber *template_index;   //排序
@property (nonatomic,strong)NSString *template_detail_id;
@property (nonatomic,strong)NSString *c_id;             //用户模板id ，用于区分同一个子模板 在同一个主题或者不同住 顺序以及制作信息
@property (nonatomic,strong)NSNumber *template_id;      //模板id
@property (nonatomic,strong)NSNumber *is_operate;       //是否可以编辑  0不可编辑 1可以编辑
@property (nonatomic,strong)TemplateDetail *detail_content;//模板制作制作参数
@property (nonatomic,strong)NSNumber *image_height;
@property (nonatomic,strong)NSNumber *image_width;
@property (nonatomic,strong)NSNumber *original_height;  //模板的实际高度 （打印模板）
@property (nonatomic,strong)NSNumber *original_width;   //模板实际宽度
@property (nonatomic,strong)NSString *user_grow_id;     //成长档案id
@property (nonatomic,strong)NSNumber *detail_type;      //模板类型  1封面 ，2内容模板 3.封底
@property (nonatomic,strong)NSString *theme_id;         //自建主题id  如果自建主题id 为空 或者为0 表示没有自建主题
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *batch_id;         //批次id
@property (nonatomic,strong)NSString *title;            //模板标题
@property (nonatomic,strong)NSString *image_url;        //模板图片（如果已制作显示制作图片）
@property (nonatomic,strong)NSString *image_thumb_url;  //模板缩略图（如果已制作显示制作缩略图片）
@property (nonatomic,strong)NSString *user_id;          //用户id
@property (nonatomic,strong)NSString *create_user;      //创建用户id
@property (nonatomic,strong)ProductionParameter *production_parameter;//制作参数
@property (nonatomic,strong)NSString *template_image_url;//模板

#pragma mark - 新增字段，管理上传
@property (nonatomic,strong)CustomParamter<Ignore> *customParam;
@property (nonatomic,strong)NSURLSessionTask<Ignore> *sessionTask;
@property (nonatomic,strong)NSNumber<Ignore> *uploadEnd;        //1-成功，2-失败
@property (nonatomic,copy)RecordUploadBlock uploadBlock;

- (void)startUploadChangeInfo;
- (BOOL)isFinishedCommit;

#pragma mark - CustomParamter对象生产，并重置paramter上传
- (void)resetCustomParam:(NSArray *)array;

#pragma mark - 数据库语句
+ (NSString *)templateCreateTable;
- (NSString *)saveTemplateParam;
- (NSString *)deleteTemplateSql;
- (NSString *)selectOneTemplateSql;
+ (NSString *)selectAllTemplateSql:(NSString *)growId;
+ (NSString *)deleteTemplateSqlBy:(NSString *)recordId;

@end

//自建主题
@protocol RecordTheme
@end
@interface RecordTheme : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSNumber *sort;
@property (nonatomic,strong)NSString *theme_name;

@end

@interface TimeRecordInfo : JSONModel

@property (nonatomic,strong)NSMutableArray<RecordTheme> *theme;
@property (nonatomic,strong)NSMutableArray<RecordTemplate> *template;
@property (nonatomic,strong)NSNumber *is_double;    // 是否跨页 0不跨页 1跨页
@property (nonatomic,strong)NSNumber *craft_size;   //模板尺寸 1八寸 2 =12寸
@property (nonatomic,strong)NSNumber *is_public;    //是否已经发布 0没有 1已发布图片未生成，2已发布图片已生成

@end
