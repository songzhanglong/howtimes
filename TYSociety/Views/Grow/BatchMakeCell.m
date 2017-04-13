//
//  BatchMakeCell.m
//  TYSociety
//
//  Created by szl on 16/7/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BatchMakeCell.h"
#import "Masonry.h"
#import "TimeRecordInfo.h"
#import "JSCarouselLayout.h"
#import "PhotoManagerModel.h"
#import "UIButton+WebCache.h"
#import "UIColor+Hex.h"
#import "DecoTextView.h"

#define Count_Item      10
#define CoverImg_Tag    100
#define Preview_Tag     20
#define Number_Tag      200

@implementation BatchMakeCell
{
    CGSize _initSize,_fullSize;
    UIView *_coverView;
    NSMutableArray *_coverStrArr;   //封面数据，避免删减图集时的重复加载操作
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = rgba(239, 239, 244, 1);
        self.clipsToBounds = YES;
        //模版封面
        _contentImg = [[UIImageView alloc] init];
        [_contentImg setBackgroundColor:[UIColor clearColor]];
        [_contentImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_contentImg setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:_contentImg];
        [_contentImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        //覆盖表面
        _coverView = [[UIView alloc] init];
        [_coverView setBackgroundColor:[UIColor clearColor]];
        [_coverView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_coverView setClipsToBounds:YES];
        [_coverView setUserInteractionEnabled:NO];
        [self.contentView addSubview:_coverView];
        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        //
        for (NSInteger i = 0; i < Count_Item; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTag:i + 1];
            [btn setBackgroundColor:[UIColor clearColor]];
            btn.clipsToBounds = YES;
            [btn setContentMode:UIViewContentModeScaleToFill];
            [btn addTarget:self action:@selector(checkButtonAt:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btn];
            
            UIImageView *imgView = [[UIImageView alloc] init];
            [imgView setTag:CoverImg_Tag];
            [imgView setContentMode:UIViewContentModeScaleAspectFill];
            imgView.clipsToBounds = YES;
            [btn addSubview:imgView];
            [self.contentView sendSubviewToBack:btn];
            
            UIView *preView = [[UIView alloc] init];
            [preView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [preView setUserInteractionEnabled:NO];
            preView.layer.masksToBounds = YES;
            preView.layer.borderWidth = 1.0;
            [preView setTag:i + Preview_Tag];
            preView.layer.borderColor = [UIColor redColor].CGColor;
            [self.contentView addSubview:preView];
            
            [preView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(btn.mas_left);
                make.top.equalTo(btn.mas_top);
                make.width.equalTo(btn.mas_width);
                make.height.equalTo(btn.mas_height);
            }];
            
            UILabel *numLab = [[UILabel alloc] init];
            [numLab setTextAlignment:NSTextAlignmentCenter];
            [numLab setBackgroundColor:[UIColor redColor]];
            [numLab setTextColor:[UIColor whiteColor]];
            [numLab setFont:[UIFont systemFontOfSize:10]];
            [numLab setTag:i + Number_Tag];
            [numLab setText:@"0"];
            numLab.layer.masksToBounds = YES;
            numLab.layer.cornerRadius = 8;
            [numLab setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.contentView addSubview:numLab];
            [numLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(preView.mas_right).with.offset(-8).with.priorityLow();
                make.right.lessThanOrEqualTo(self.contentView.mas_right);
                make.bottom.equalTo(preView.mas_top).with.offset(8).with.priorityLow();
                make.top.greaterThanOrEqualTo(self.contentView.mas_top);
                make.width.equalTo(@(16));
                make.height.equalTo(@(16));
            }];
        }
    }
    
    return self;
}

- (void)checkButtonAt:(UIButton *)sender
{
    BOOL canCheck = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(canCheckTemeplate:)]) {
        canCheck = [_delegate canCheckTemeplate:self];
    }
    
    if (!canCheck) {
        return;
    }
    
    NSInteger index = [sender tag] - 1;
    UIView *preView = [self.contentView viewWithTag:_nSelectIdx + Preview_Tag];
    UILabel *preLab = [self.contentView viewWithTag:Number_Tag + _nSelectIdx];
    
    if (index == _nSelectIdx) {
//        _nSelectIdx = -1;
//        preView.hidden = YES;
    }
    else{
        _nSelectIdx = index;
        preView.hidden = YES;
        preLab.hidden = YES;
        UIView *curView = [self.contentView viewWithTag:index + Preview_Tag];
        curView.hidden = NO;
        UILabel *numLab = [self.contentView viewWithTag:Number_Tag + index];
        numLab.hidden = NO;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(checkCell:At:)]) {
        [_delegate checkCell:self At:_nSelectIdx];
    }
}

- (void)selectButtonAt:(NSInteger)index
{
    if (_nSelectIdx >= 0) {
        UIView *lastView = [self.contentView viewWithTag:_nSelectIdx + Preview_Tag];
        UIView *numView = [self.contentView viewWithTag:_nSelectIdx + Number_Tag];
        [lastView setHidden:YES];
        [numView setHidden:YES];
    }
    _nSelectIdx = index;
    UIView *preView = [self.contentView viewWithTag:_nSelectIdx + Preview_Tag];
    preView.hidden = NO;
    UILabel *numLab = [self.contentView viewWithTag:Number_Tag + index];
    numLab.hidden = NO;
}

#pragma mark - 外部调用
- (void)resetBatchMakeModel:(id)object Arr:(NSArray *)array Size:(CGSize)itemSize fullSize:(CGSize)fullSize
{
    _initSize = itemSize,_fullSize = fullSize;
    _nSelectIdx = -1;
    RecordTemplate *record = (RecordTemplate *)object;
    self.record = record;
    NSString *url = record.template_image_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    url = [NSString getPictureAddress:@"2" width:@"640" height:@"0" original:url];
    
    [_contentImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed];
    
    CGSize imgSize = CGSizeMake(record.image_width.floatValue, record.image_height.floatValue);
    CGFloat scale = itemSize.height / imgSize.height;   //缩放尺寸
    NSInteger count = [record.detail_content.image_coor count];
    NSInteger coverCount = [record.production_parameter.image_path count];
    NSMutableArray *coverStrArr = [NSMutableArray array];
    for (NSInteger i = 0; i < Count_Item; i++) {
        UIButton *btn = (UIButton *)[self.contentView viewWithTag:i + 1];
        UIView *lineImg = [self.contentView viewWithTag:i + Preview_Tag];
        lineImg.hidden = YES;
        UILabel *numLab = [self.contentView viewWithTag:Number_Tag + i];
        numLab.hidden = YES;
        
        if (i < count) {
            btn.hidden = NO;
            ImageCoorInfo *coorInfo = [record.detail_content.image_coor objectAtIndex:i];
            NSArray *x = [coorInfo.x componentsSeparatedByString:@","];
            NSArray *y = [coorInfo.y componentsSeparatedByString:@","];
            //边框应具备的尺寸
            CGRect rect = CGRectMake([x[0] floatValue] * scale, [x[1] floatValue] * scale, ([y[0] floatValue] - [x[0] floatValue]) * scale, ([y[1] floatValue] - [x[1] floatValue]) * scale);
            [btn setFrame:rect];
            
            UIImageView *imgView = (UIImageView *)[btn viewWithTag:CoverImg_Tag];
            [imgView setImage:nil];
            
            NSArray *galleryArr = nil;
            if ([record.production_parameter.src_gallery_list count] > i) {
                galleryArr = record.production_parameter.src_gallery_list[i];
            }
            NSArray *subArr = [array objectAtIndex:i];
            NSInteger numCount = [subArr count];
            numCount += [galleryArr count];
            [numLab setText:[NSNumber numberWithInteger:numCount].stringValue];
            //判断该区域是否有封面图片
            if (coverCount > i) {
                ProductImagePath *tmpPath = record.production_parameter.image_path[i];
                if (tmpPath && tmpPath.image_url.length > 0) {
                    NSString *path = tmpPath.image_url;
                    if (![path hasPrefix:@"http"]) {
                        path = [G_IMAGE_ADDRESS stringByAppendingString:path];
                    }
                    path = [self getResizeImgStrBy:path Width:btn.frameWidth];
                    [imgView sd_setImageWithURL:[NSURL URLWithString:path]];
                    [self resetMakeCoverAt:tmpPath MakeView:imgView Scale:scale];
                    [coverStrArr addObject:tmpPath.image_url];
                    
                    continue;
                }
            }

            //未被占用，添加本地图片
            /*
            BOOL hasFound = NO;
            
            //图片最低要求大小
            CGFloat temOri = record.original_width.floatValue / imgSize.width;
            CGFloat unilateralRatio = sqrt(2);
            CGSize oriSize = CGSizeMake(([y[0] floatValue] - [x[0] floatValue]) * temOri / unilateralRatio, ([y[1] floatValue] - [x[1] floatValue]) * temOri / unilateralRatio);
            
            for (NSInteger m = 0; m < subArr.count; m++) {
                PhotoManagerModel *photo = subArr[m];
                if (photo.file_type.integerValue != 1) {
                    continue;
                }
                
                if (photo.width.floatValue < oriSize.width || photo.height.floatValue < oriSize.height) {
                    continue;
                }
                
                if (photo.path.length > 0){
                    NSString *path = photo.path;
                    if (![path hasPrefix:@"http"]) {
                        path = [G_IMAGE_ADDRESS stringByAppendingString:path];
                    }
                    path = [self getResizeImgStrBy:path Width:btn.frameWidth];
                    [imgView sd_setImageWithURL:[NSURL URLWithString:path]];
                    CGFloat maxScale = scale / temOri;
                    [self resetMakeContentSize:photo To:imgView Scale:maxScale];
                    hasFound = YES;
                    break;
                }
                else{
                    NSString *md5Str = [NSString md5:photo.file_client_path];
                    NSString *lastPath = [[NSString getCachePath:@"thumbnail"] stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
                    if ([fileManager fileExistsAtPath:lastPath]) {
                        [imgView setImage:[UIImage imageWithContentsOfFile:lastPath]];
                        CGFloat maxScale = scale / temOri;
                        [self resetMakeContentSize:photo To:imgView Scale:maxScale];
                        hasFound = YES;
                        break;
                    }
                }
            }
            
            if (!hasFound) {
                [imgView setImage:nil];
            }
             */
            //图片最低要求大小
            CGFloat temOri = record.original_width.floatValue / imgSize.width;
            CGFloat unilateralRatio = sqrt(2);
            CGSize oriSize = CGSizeMake(([y[0] floatValue] - [x[0] floatValue]) * temOri / unilateralRatio, ([y[1] floatValue] - [x[1] floatValue]) * temOri / unilateralRatio);
            PhotoManagerModel *photoLst = [self resetCoverContent:oriSize Local:subArr Img:imgView Scale:scale / temOri];
            [coverStrArr addObject:photoLst.path ?: @""];
        }
        else{
            btn.hidden = YES;
        }
    }
    //封面地址数组
    _coverStrArr = coverStrArr;
    
    //素材，图片，文字
    [_coverView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //文本区域
    [self dealWithTxt:scale];
    
    //素材
    [self dealWithDecoImg:scale];
    
    //自动文本，非模版中自带
    [self dealWithDecoTxt:scale];
}

- (PhotoManagerModel *)resetCoverByGallerys:(CGSize)oriSize Local:(NSArray *)gallerys Img:(UIImageView *)imgView Scale:(CGFloat)maxScale
{
    //未被占用，添加本地图片
    BOOL hasFound = NO;
    PhotoManagerModel *photoLst = nil;
    for (NSInteger m = 0; m < gallerys.count; m++) {
        ProductImageGallery *gal = gallerys[m];
        if (gal.type.integerValue != 1) {
            continue;
        }
        
        if (gal.original_width.floatValue < oriSize.width || gal.original_height.floatValue < oriSize.height) {
            continue;
        }
        
        NSString *path = gal.path;
        if (![path hasPrefix:@"http"]) {
            path = [G_IMAGE_ADDRESS stringByAppendingString:path];
        }
        path = [self getResizeImgStrBy:path Width:[imgView superview].frameWidth];
        [imgView sd_setImageWithURL:[NSURL URLWithString:path]];
        
        photoLst = [[PhotoManagerModel alloc] init];
        photoLst.path = gal.path;
        photoLst.width = [gal.original_width stringValue];
        photoLst.height = [gal.original_height stringValue];
        [self resetMakeContentSize:photoLst To:imgView Scale:maxScale];
        hasFound = YES;
    }
    
    if (!hasFound) {
        [imgView setImage:nil];
    }
    
    return photoLst;
}

- (PhotoManagerModel *)resetCoverContent:(CGSize)oriSize Local:(NSArray *)subArr Img:(UIImageView *)imgView Scale:(CGFloat)maxScale
{
    //未被占用，添加本地图片
    BOOL hasFound = NO;
    PhotoManagerModel *photoLst = nil;
    for (NSInteger m = 0; m < subArr.count; m++) {
        PhotoManagerModel *photo = subArr[m];
        if (photo.file_type.integerValue != 1) {
            continue;
        }
        
        if (photo.width.floatValue < oriSize.width || photo.height.floatValue < oriSize.height) {
            continue;
        }
        
        if (photo.path.length > 0){
            NSString *path = photo.path;
            if (![path hasPrefix:@"http"]) {
                path = [G_IMAGE_ADDRESS stringByAppendingString:path];
            }
            path = [self getResizeImgStrBy:path Width:[imgView superview].frameWidth];
            [imgView sd_setImageWithURL:[NSURL URLWithString:path]];
            [self resetMakeContentSize:photo To:imgView Scale:maxScale];
            hasFound = YES;
            photoLst = photo;
            break;
        }
        else{
            NSString *md5Str = [NSString md5:photo.file_client_path];
            NSString *lastPath = [[NSString getCachePath:@"thumbnail"] stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:lastPath]) {
                [imgView setImage:[UIImage imageWithContentsOfFile:lastPath]];
                [self resetMakeContentSize:photo To:imgView Scale:maxScale];
                hasFound = YES;
                break;
            }
        }
    }
    
    if (!hasFound) {
        [imgView setImage:nil];
    }
    
    return photoLst;
}

- (NSString *)getResizeImgStrBy:(NSString *)path Width:(CGFloat)wei
{
    //160,240,320,400,500,640
    CGFloat newWei = wei / (_fullSize.width / _initSize.width);
    NSString *lastWei = nil;
    if (newWei < 80) {
        lastWei = @"160";
    }
    else if (newWei < 120){
        lastWei = @"240";
    }
    else if (newWei < 160)
    {
        lastWei = @"320";
    }
    else if(newWei < 200)
    {
        lastWei = @"400";
    }
    else if (newWei < 250)
    {
        lastWei = @"500";
    }
    else
    {
        lastWei = @"640";
    }
    return [NSString getPictureAddress:@"2" width:lastWei height:@"0" original:path];
}

#pragma mark - 封面元素
- (void)dealWithTxt:(CGFloat)scale
{
    NSArray *word_coor = _record.detail_content.word_coor;
    if (word_coor && [word_coor count] > 0) {
        for (NSInteger i = 0;i < [word_coor count];i++) {
            WordCoorInfo *wordInfo = word_coor[i];
            if ((!wordInfo.x || (wordInfo.x.length <= 0)) || (!wordInfo.y || (wordInfo.y.length <= 0))) {
                continue;
            }
            if ([_record.production_parameter.input_text count] == [word_coor count]) {
                ProductImageInput *input = [_record.production_parameter.input_text objectAtIndex:i];
                NSArray *x = [wordInfo.x componentsSeparatedByString:@","];
                NSArray *y = [wordInfo.y componentsSeparatedByString:@","];
                CGRect rect = CGRectMake([x[0] floatValue] * scale, [x[1] floatValue] * scale, ([y[0] floatValue] - [x[0] floatValue]) * scale, ([y[1] floatValue] - [x[1] floatValue]) * scale);
                
                NSString *color = wordInfo.color;
                CGFloat fontSize = wordInfo.size.floatValue;
                if (fontSize == 0) {
                    fontSize = 12 / scale;
                }
                NSInteger lastSize = fontSize * scale;
                
                UILabel *label = [[UILabel alloc] initWithFrame:rect];
                [label setBackgroundColor:[UIColor clearColor]];
                [label setFont:[UIFont systemFontOfSize:lastSize]];
                [label setTextColor:[UIColor colorWithHexString:color]];
                [label setNumberOfLines:0];
                [_coverView addSubview:label];
                [label setText:input.txt];
            }
        }
    }
}

- (void)dealWithDecoTxt:(CGFloat)scale
{
    NSInteger txtCount = [_record.production_parameter.deco_text count];
    for (NSInteger i = 0; i < txtCount; i++) {
        ProductImageDecotext *dexoTxt = [_record.production_parameter.deco_text objectAtIndex:i];
        if (dexoTxt.txt.length > 0) {
            NSArray *decoArr = [dexoTxt.detail componentsSeparatedByString:@"_"];
            if ([decoArr count] == 5) {
                CGFloat alphaColor = (dexoTxt.alpha == nil) ? 1 : [dexoTxt.alpha floatValue];
                UIFont *font = (dexoTxt.font.length > 0) ? [NSString customFontWithPath:[APPDocumentsDirectory stringByAppendingPathComponent:[dexoTxt.font stringByAppendingString:@".ttf"]] size:12] : [UIFont systemFontOfSize:12];
                UIImage *tmpImg = [self imageFromText:[dexoTxt.txt componentsSeparatedByString:Seperate_RowStr] withFont:font Color:dexoTxt.color Alpha:alphaColor];
                CGFloat wei = [decoArr[2] floatValue] * scale,hei = tmpImg.size.height * wei / tmpImg.size.width;
                CGRect rect = CGRectMake([decoArr[0] floatValue] * scale, [decoArr[1] floatValue] * scale, wei, hei);
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect];
                [imgView setImage:tmpImg];
                [_coverView addSubview:imgView];
                imgView.transform = CGAffineTransformRotate(imgView.transform, [decoArr[4] floatValue] * M_PI / 180);
            }
        }
    }
}

- (void)dealWithDecoImg:(CGFloat)scale
{
    NSInteger decoCount = [_record.production_parameter.deco_path count];
    for (NSInteger i = 0; i < decoCount; i++) {
        ProductImagePath *decoPath = _record.production_parameter.deco_path[i];
        NSArray *decoArr = [decoPath.detail componentsSeparatedByString:@"_"];
        if ([decoArr count] == 5) {
            NSString *url = decoPath.image_url;
            if (![url hasPrefix:@"http"]) {
                url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
            }
            
            CGRect rect = CGRectMake([decoArr[0] floatValue] * scale, [decoArr[1] floatValue] * scale, [decoArr[2] floatValue] * scale, [decoArr[3] floatValue] * scale);
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect];
            [imgView sd_setImageWithURL:[NSURL URLWithString:url]];
            [_coverView addSubview:imgView];
            imgView.transform = CGAffineTransformRotate(imgView.transform, [decoArr[4] floatValue] * M_PI / 180);
        }
    }
}

#pragma mark - 文本绘制
- (UIImage *)imageFromText:(NSArray *)arrContent withFont:(UIFont *)font Color:(NSString *)colorStr Alpha:(CGFloat)alpha
{
    NSMutableArray *arrHeight = [[NSMutableArray alloc] initWithCapacity:arrContent.count];
    
    CGFloat fHeight = 0.0f,newWei = 0;
    CGFloat maxWei = SCREEN_WIDTH * 2;
    NSDictionary *attribute = @{NSFontAttributeName:font};
    for (NSString *sContent in arrContent) {
        CGSize stringSize = [sContent boundingRectWithSize:CGSizeMake(maxWei, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        [arrHeight addObject:[NSNumber numberWithFloat:stringSize.height]];
        
        fHeight += stringSize.height;
        newWei = MAX(newWei, stringSize.width);
    }
    
    CGSize newSize = CGSizeMake(newWei + 20, fHeight + 20);
    NSString *textStr = [arrContent componentsJoinedByString:@"\n"];
    DecoTextView *decoView = [[DecoTextView alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height) Text:textStr TextColor:[UIColor colorWithHexString:colorStr] Alpha:alpha Font:font];
    decoView.userInteractionEnabled = NO;
    return [DecoTextView convertSelfToImage:decoView];
}

#pragma mark - 封面重定义
- (void)resetNewArr:(NSArray *)array
{
    if (_nSelectIdx < 0 || _nSelectIdx >= array.count) {
        return;
    }
    
    CGSize imgSize = CGSizeMake(_record.image_width.floatValue, _record.image_height.floatValue);
    CGFloat scale = _initSize.height / imgSize.height;
    NSInteger coverCount = [_record.production_parameter.image_path count];
    NSArray *galleryArr = nil;
    if ([_record.production_parameter.src_gallery_list count] > _nSelectIdx) {
        galleryArr = _record.production_parameter.src_gallery_list[_nSelectIdx];
    }
    
    //图集数量
    NSArray *subArr = array[_nSelectIdx];
    UILabel *numLab = [self.contentView viewWithTag:_nSelectIdx + Number_Tag];
    NSInteger numCount = [subArr count];
    numCount += [galleryArr count];
    [numLab setText:[NSNumber numberWithInteger:numCount].stringValue];
    
    //判断封面是否需要清空,不为空直接使用
    BOOL isChanged = [self checkCoverChange:galleryArr Local:subArr Scale:scale];
    if (!isChanged) {
        return;
    }
    
    //图片最低要求大小
    ImageCoorInfo *coorInfo = [_record.detail_content.image_coor objectAtIndex:_nSelectIdx];
    NSArray *x = [coorInfo.x componentsSeparatedByString:@","];
    NSArray *y = [coorInfo.y componentsSeparatedByString:@","];
    CGFloat temOri = _record.original_width.floatValue / imgSize.width;
    CGFloat unilateralRatio = sqrt(2);
    CGSize oriSize = CGSizeMake(([y[0] floatValue] - [x[0] floatValue]) * temOri / unilateralRatio, ([y[1] floatValue] - [x[1] floatValue]) * temOri / unilateralRatio);
    CGFloat maxScale = _record.image_width.floatValue / _record.original_width.floatValue * scale;
    //封面只可能在本地中查找，因为网络返回的没做删除处理
    UIButton *btn = (UIButton *)[self.contentView viewWithTag:_nSelectIdx + 1];
    UIImageView *imgView = (UIImageView *)[btn viewWithTag:CoverImg_Tag];
    //图集中查找是否存在适合作为封面的图片
    PhotoManagerModel *photoLst = [self resetCoverByGallerys:oriSize Local:galleryArr Img:imgView Scale:maxScale];
    if (!photoLst) {
        //相册中查找是否存在适合的数据源
        photoLst = [self resetCoverContent:oriSize Local:subArr Img:imgView Scale:maxScale];
    }

    [_coverStrArr replaceObjectAtIndex:_nSelectIdx withObject:photoLst.path ?: @""];

    //封面重定义
    ProductImagePath *coverPath = nil;
    if (_nSelectIdx < coverCount) {
        coverPath = _record.production_parameter.image_path[_nSelectIdx];
        [self resetProductImagePath:coverPath Img:imgView Scale:scale Photo:photoLst];
    }
}

#pragma mark - 封面是否改变，未改变，不需进行下一步处理
- (BOOL)checkCoverChange:(NSArray *)galleryArr Local:(NSArray *)subArr Scale:(CGFloat)scale
{
    //判断封面是否需要清空,不为空直接使用
    NSString *coverStr = _coverStrArr[_nSelectIdx];
    BOOL tmpFound = NO;
    //封面数组中查找
    for (ProductImageGallery *gal in galleryArr) {
        if ([gal.path rangeOfString:coverStr].location != NSNotFound) {
            tmpFound = YES;
            break;
        }
    }
    //本地新增中查找
    if (!tmpFound) {
        for (PhotoManagerModel *photo in subArr) {
            if ([photo.path rangeOfString:coverStr].location != NSNotFound) {
                tmpFound = YES;
                break;
            }
        }
    }
    
    return !tmpFound;
}

#pragma mark - 外部调用
- (CGRect)getRectBySelectIdx
{
    if (_nSelectIdx == -1) {
        return CGRectZero;
    }
    
    UIButton *btn = [self.contentView viewWithTag:_nSelectIdx + 1];
    if (btn) {
        return btn.frame;
    }
    
    return CGRectZero;
}

- (void)clearAllStatus
{
    _nSelectIdx = -1;
    for (NSInteger i = 0; i < Count_Item; i++) {
        UIView *lineImg = [self.contentView viewWithTag:i + Preview_Tag];
        lineImg.hidden = YES;
        UILabel *numLab = [self.contentView viewWithTag:Number_Tag + i];
        numLab.hidden = YES;
    }
}

#pragma mark - 重设封面
- (void)resetProductImagePath:(ProductImagePath *)covetImg Img:(UIImageView *)imgView Scale:(CGFloat)scale Photo:(PhotoManagerModel *)photo
{
    if (photo) {
        UIView *supView = [imgView superview];
        NSString *detail =  [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_0.0000",(supView.center.x - supView.bounds.size.width / 2 + imgView.center.x - imgView.bounds.size.width / 2) / scale, (supView.center.y - supView.bounds.size.height / 2 + imgView.center.y - imgView.bounds.size.height / 2) / scale, imgView.bounds.size.width / scale, imgView.bounds.size.height / scale];
        covetImg.image_url = photo.path;
        covetImg.detail = detail;
        covetImg.original_width = [NSNumber numberWithFloat:[photo.width floatValue]];
        covetImg.original_height = [NSNumber numberWithFloat:[photo.height floatValue]];
    }
    else{
        covetImg.detail = nil;
        covetImg.image_url = nil;
        covetImg.original_width = nil;
        covetImg.original_height = nil;
    }
}

#pragma mark - 区域设置，针对打印尺寸
- (void)resetMakeContentSize:(PhotoManagerModel *)photo To:(UIImageView *)imgView Scale:(CGFloat)maxScale
{
    CGSize fatherSize = [imgView superview].frame.size;
    CGSize imgSize = CGSizeMake(photo.width.floatValue * maxScale, photo.height.floatValue * maxScale);
    //超过2边，保证一边充满，另一边超出
    CGFloat tmpScale = MAX(fatherSize.width / imgSize.width, fatherSize.height / imgSize.height);
    imgSize = CGSizeMake(imgSize.width * tmpScale, imgSize.height * tmpScale);
    imgView.transform = CGAffineTransformIdentity;
    [imgView setFrame:CGRectMake((fatherSize.width - imgSize.width) / 2, (fatherSize.height - imgSize.height) / 2, imgSize.width, imgSize.height)];
    imgView.transform = CGAffineTransformRotate(imgView.transform,0);
}

- (void)resetMakeCoverAt:(ProductImagePath *)tmpPath MakeView:(UIImageView *)imgView Scale:(CGFloat)scale
{
    UIView *father = [imgView superview];
    NSArray *frames = [tmpPath.detail componentsSeparatedByString:@"_"];
    if (frames.count == 5) {
        CGFloat wei = [frames[2] floatValue] * scale;
        CGFloat hei = [frames[3] floatValue] * scale;
        imgView.transform = CGAffineTransformIdentity;
        [imgView setFrame:CGRectMake([frames[0] floatValue] * scale - father.frameX, [frames[1] floatValue] * scale - father.frameY, wei, hei)];
        imgView.transform = CGAffineTransformRotate(imgView.transform, [frames[4] floatValue] * M_PI / 180);
    }
}

@end
