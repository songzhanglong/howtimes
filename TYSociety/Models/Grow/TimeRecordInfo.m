//
//  TimeRecordInfo.m
//  TYSociety
//
//  Created by szl on 16/7/19.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TimeRecordInfo.h"
#import "DataBaseOperation.h"

#define Record_ID           @"record_id"
#define Record_Grow_ID      @"grow_id"
#define Base_Param          @"baseParam"    //基本参数
#define Record_Imgpath      @"imgpath"      //封面
#define Record_Gallery      @"gallery"      //图集
#define Record_Txtinput     @"imginput"     //输入框文本
#define Record_Imgdeco      @"imgdeco"      //素材
#define Record_Decotxt      @"decoTxt"      //自定义文本

@implementation WordCoorInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation ImageCoorInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation ProductImagePath

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation ProductImageGallery

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation ProductImageInput

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation ProductImageDecotext

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation CustomParamter

- (BOOL)isEqual:(id)object
{
    CustomParamter *param = (CustomParamter *)object;
    
    BOOL isSame = ([param.gallery isEqualToString:_gallery] &&
                   [param.imginput isEqualToString:_imginput] &&
                   [param.imgdeco isEqualToString:_imgdeco]);
    if (isSame) {
        //封面
        NSArray *path1 = [NSJSONSerialization JSONObjectWithData:[_imgpath dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSArray *path2 = [NSJSONSerialization JSONObjectWithData:[param.imgpath dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        //数量不等，直接跳出
        if (path1.count != path2.count) {
            return NO;
        }
        NSInteger imgCount = [path2 count];
        for (NSInteger i = 0; i < imgCount; i++) {
            //先比较地址，后比较detail参数，有较小误差，故roundf
            NSDictionary *dic1 = [path1 objectAtIndex:i];
            NSDictionary *dic2 = [path2 objectAtIndex:i];
            if ([dic1 allKeys].count == 0 && [dic2 allKeys].count == 0) {
                continue;
            }
            
            NSString *url1 = [dic1 valueForKey:@"image_url"];
            NSString *url2 = [dic2 valueForKey:@"image_url"];
            if (![url1 isEqualToString:url2]) {
                return NO;
            }
            
            NSArray *detail1 = [[dic1 valueForKey:@"detail"] componentsSeparatedByString:@"_"];
            NSArray *detail2 = [[dic2 valueForKey:@"detail"] componentsSeparatedByString:@"_"];
            for (NSInteger m = 0; m < detail1.count; m++) {
                NSString *address1 = detail1[m];
                NSString *address2 = detail2[m];
                if (!(roundf(address1.floatValue) == roundf(address2.floatValue))) {
                    return NO;
                }
            }
        }
        
        
        //自定义文字，高度会变化
        NSArray *txts1 = [NSJSONSerialization JSONObjectWithData:[_decoTxt dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSArray *txts2 = [NSJSONSerialization JSONObjectWithData:[param.decoTxt dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        //数量不等，直接跳出
        if (txts1.count != txts1.count) {
            return NO;
        }
        NSInteger txtCount = [txts1 count];
        for (NSInteger i = 0; i < txtCount; i++) {
            //先比较内容，后比较detail参数，有较小误差，故roundf
            NSDictionary *dic1 = [txts1 objectAtIndex:i];
            NSDictionary *dic2 = [txts2 objectAtIndex:i];
            NSString *url1 = [dic1 valueForKey:@"txt"];
            NSString *url2 = [dic2 valueForKey:@"txt"];
            if (![url1 isEqualToString:url2]) {
                return NO;
            }
            
            //detail参数，第四个过滤，因高度自定义
            NSArray *detail1 = [[dic1 valueForKey:@"detail"] componentsSeparatedByString:@"_"];
            NSArray *detail2 = [[dic2 valueForKey:@"detail"] componentsSeparatedByString:@"_"];
            for (NSInteger m = 0; m < detail1.count; m++) {
                if (m == 3) {
                    continue;
                }
                NSString *address1 = detail1[m];
                NSString *address2 = detail2[m];
                if (!(roundf(address1.floatValue) == roundf(address2.floatValue))) {
                    return NO;
                }
            }
        }
    }
    return isSame;
}

@end

@implementation ProductionParameter

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation TemplateDetail

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation RecordTemplate

- (void)dealloc
{
    [self clearRequest];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)clearRequest
{
    if (_sessionTask && (_sessionTask.state == NSURLSessionTaskStateRunning)) {
        [_sessionTask cancel];
    }
    self.sessionTask = nil;
}

#pragma mark - 上传
- (void)startUploadChangeInfo
{
    if (_sessionTask) {
        [self clearRequest];
    }
    
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"growProduction"];
    [param setObject:_user_grow_id forKey:@"grow_id"];
    [param setObject:_template_id forKey:@"template_id"];
    [param setObject:_template_detail_id forKey:@"template_detail_id"];
    [param setObject:_id forKey:@"c_id"];
    [param setObject:_user_id forKey:@"user_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    [param setObject:_batch_id forKey:@"batch_id"];
    [param setObject:_customParam.imgpath forKey:@"src_image_list"];
    [param setObject:_customParam.gallery forKey:@"src_gallery_list"];
    [param setObject:_customParam.imgdeco forKey:@"src_deco_list"];
    [param setObject:_customParam.imginput forKey:@"src_txt_list"];
    [param setObject:_customParam.decoTxt forKey:@"deco_text"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"production"];
    __weak typeof(self)weakSelf = self;
    NSString *deleteSql = [weakSelf deleteTemplateSql]; //避免数据库清除的时候对象已不存在
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        weakSelf.sessionTask = nil;
        if (error) {
            weakSelf.uploadEnd = [NSNumber numberWithInteger:2];
        }
        else{
            weakSelf.uploadEnd = [NSNumber numberWithInteger:1];
            [[DataBaseOperation shareInstance] resetTemplateInfo:deleteSql];
        }
        if (weakSelf.uploadBlock) {
            weakSelf.uploadBlock(weakSelf);
        }
    }];
}

#pragma mark - CustomParamter对象生产，并重置paramter上传
- (void)resetCustomParam:(NSArray *)array
{
    if (!_production_parameter) {
        _production_parameter = [[ProductionParameter alloc] init];
    }
    
    NSString *record_Imgpath    =   [array objectAtIndex:3];
    NSString *record_Gallery    =   [array objectAtIndex:4];
    NSString *record_Txtinput   =   [array objectAtIndex:5];
    NSString *record_Imgdeco    =   [array objectAtIndex:6];
    NSString *record_Decotxt    =   [array objectAtIndex:7];
    
    CustomParamter *custom = [[CustomParamter alloc] init];
    custom.imgpath = record_Imgpath;
    custom.gallery = record_Gallery;
    custom.imginput = record_Txtinput;
    custom.decoTxt = record_Decotxt;
    custom.imgdeco = record_Imgdeco;
    self.customParam = custom;
    
    //封面
    NSArray *pathObject = [NSJSONSerialization JSONObjectWithData:[record_Imgpath dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *imgPaths = [ProductImagePath arrayOfModelsFromDictionaries:pathObject error:nil];
    [_production_parameter setImage_path:(NSMutableArray<ProductImagePath> *)imgPaths];
    //图集
    NSArray *galleryObject = [NSJSONSerialization JSONObjectWithData:[record_Gallery dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *imgGallerys = [NSMutableArray array];
    for (NSInteger i = 0; i < [galleryObject count]; i++) {
        NSArray *subArr = galleryObject[i];
        NSMutableArray *newGallery = [ProductImageGallery arrayOfModelsFromDictionaries:subArr error:nil];
        [imgGallerys addObject:newGallery];
    }
    [_production_parameter setSrc_gallery_list:imgGallerys];
    //素材
    NSArray *decoObject = [NSJSONSerialization JSONObjectWithData:[record_Imgdeco dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *imgDecos = [ProductImagePath arrayOfModelsFromDictionaries:decoObject error:nil];
    [_production_parameter setDeco_path:(NSMutableArray<ProductImagePath> *)imgDecos];
    //文字
    NSArray *inputObject = [NSJSONSerialization JSONObjectWithData:[record_Txtinput dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *inputs = [ProductImageInput arrayOfModelsFromDictionaries:inputObject error:nil];
    [_production_parameter setInput_text:(NSMutableArray<ProductImageInput> *)inputs];
    //自定义文字
    NSArray *txtObject = [NSJSONSerialization JSONObjectWithData:[record_Decotxt dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *txtPaths = [ProductImageDecotext arrayOfModelsFromDictionaries:txtObject error:nil];
    [_production_parameter setDeco_text:(NSMutableArray<ProductImageDecotext> *)txtPaths];
    
    [self startUploadChangeInfo];
}

#pragma mark - 判断是否编辑过或者提交过
- (BOOL)isFinishedCommit
{
    //空模版，一版是封面和尾页,算编辑过，可以发布
    if (_detail_content == nil) {
        return YES;
    }
    else if (([_detail_content.image_coor count] == 0) && ([_detail_content.word_coor count] == 0))
    {
        return YES;
    }
    
    //图集，封面判断可跳过
    NSArray *gallerys = [NSJSONSerialization JSONObjectWithData:[_customParam.gallery dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    for (NSArray *subArr in gallerys) {
        if ([subArr count] > 0) {
            return YES;
        }
    }
    
    //素材
    NSArray *decoList = [NSJSONSerialization JSONObjectWithData:[_customParam.imgdeco dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    for (NSDictionary *subDic in decoList) {
        if ([[subDic allKeys] count] > 0) {
            return YES;
        }
    }
    
    //文本
    NSArray *txtList = [NSJSONSerialization JSONObjectWithData:[_customParam.imginput dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    for (NSDictionary *subDic in txtList) {
        if ([[subDic allKeys] count] > 0) {
            return YES;
        }
    }
    
    //自定义文本
    NSArray *decoImgList = [NSJSONSerialization JSONObjectWithData:[_customParam.decoTxt dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    for (NSDictionary *subDic in decoImgList) {
        if ([[subDic allKeys] count] > 0) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - 数据库语句
+ (NSString *)templateCreateTable
{
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null,PRIMARY KEY (%@));",NSStringFromClass([TimeRecordInfo class]),Record_Grow_ID,Record_ID,Base_Param,Record_Imgpath,Record_Gallery,Record_Txtinput,Record_Imgdeco,Record_Decotxt,Record_ID];
    return createTableSql;
}

- (NSString *)saveTemplateParam
{
    GlobalManager *manager = [GlobalManager shareInstance];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:_user_grow_id forKey:@"grow_id"];
    [param setObject:_template_id forKey:@"template_id"];
    [param setObject:_template_detail_id forKey:@"template_detail_id"];
    [param setObject:_id forKey:@"c_id"];
    [param setObject:_user_id forKey:@"user_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    [param setObject:_batch_id forKey:@"batch_id"];
    NSString *baseParam = [NSString dictToJsonStr:param];
    
    NSString *insertStr = [NSString stringWithFormat:@"insert or replace into %@(%@,%@,%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@','%@','%@')",NSStringFromClass([TimeRecordInfo class]),Record_Grow_ID,Record_ID,Base_Param,Record_Imgpath,Record_Gallery,Record_Txtinput,Record_Imgdeco,Record_Decotxt,_user_grow_id,_id,baseParam,_customParam.imgpath,_customParam.gallery,_customParam.imginput,_customParam.imgdeco,_customParam.decoTxt];
    return insertStr;
}

- (NSString *)deleteTemplateSql
{
    return [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",NSStringFromClass([TimeRecordInfo class]),Record_ID,_id];
}

- (NSString *)selectOneTemplateSql
{
    NSString *selectStr = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@,%@ from %@ where %@ = '%@'",Record_Grow_ID,Record_ID,Base_Param,Record_Imgpath,Record_Gallery,Record_Txtinput,Record_Imgdeco,Record_Decotxt,NSStringFromClass([TimeRecordInfo class]),Record_ID,_id];
    return selectStr;
}

+ (NSString *)selectAllTemplateSql:(NSString *)growId
{
    NSString *selectStr = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@,%@ from %@ where %@ = '%@'",Record_Grow_ID,Record_ID,Base_Param,Record_Imgpath,Record_Gallery,Record_Txtinput,Record_Imgdeco,Record_Decotxt,NSStringFromClass([TimeRecordInfo class]),Record_Grow_ID,growId];
    return selectStr;
}

+ (NSString *)deleteTemplateSqlBy:(NSString *)recordId
{
    return [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",NSStringFromClass([TimeRecordInfo class]),Record_ID,recordId];
}

@end

@implementation RecordTheme

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation TimeRecordInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
