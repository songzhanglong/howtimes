//
//  MyTimeRecord.h
//  TYSociety
//
//  Created by szl on 16/7/19.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface TagNameSize : NSObject

@property (nonatomic,assign)CGFloat sizeWidth;
@property (nonatomic,assign)CGFloat sizeHeight;
@property (nonatomic,strong)NSString *name;

- (void)calculateTagnameRect;

@end

@interface MyTimeRecord : JSONModel

@property (nonatomic,strong)NSString *batch_id;         //批次id
@property (nonatomic,strong)NSString *template_name;    //成长档案主题
@property (nonatomic,strong)NSString *template_id;      //模板id
@property (nonatomic,strong)NSString *update_time;      //修改时间
@property (nonatomic,strong)NSNumber *nums;             //模板数
@property (nonatomic,strong)NSString *finish_num;       //已制作模板数
@property (nonatomic,strong)NSString *template_image;   //模板封面
@property (nonatomic,strong)NSString *grow_name;        //成长档案名称
@property (nonatomic,strong)NSNumber *show_type;        //家长
@property (nonatomic,strong)NSString *print_url;        //打印url
@property (nonatomic,strong)NSNumber *print_flag;       //1可以打印 0不能打印
@property (nonatomic,strong)NSString *grow_id;
@property (nonatomic,strong)NSString *user_id;
@property (nonatomic,strong)NSString *is_double;        //是否跨页,1-跨页
@property (nonatomic,strong)NSString *craft_size;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *tag_name;
@property (nonatomic,strong)NSNumber *is_public;        //是否已经发布 0没有 1已发布图片未生成，2已发布图片已生成
@property (nonatomic,strong)NSString *is_print;         //是否提交打印 0没有提交，1已提交打印
@property (nonatomic,strong)NSString *create_user_id;   //档案创建人用户id   如果 user_id=create_user_id 表示档案就是用户自己创建的可以修改模板


@property (nonatomic,strong)NSMutableArray<Ignore> *nameSizeArray;
@property (nonatomic,assign)CGSize tagSize;
- (void)calculateTagNameRect;

@end
