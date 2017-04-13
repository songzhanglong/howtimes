//
//  BatchDetailViewController.m
//  TYSociety
//
//  Created by szl on 16/7/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BatchDetailViewController.h"
#import "TimeRecordInfo.h"
#import "MakeView.h"
#import "UIColor+Hex.h"
#import "PhotoManagerModel.h"
#import "CanCancelImageView.h"
#import "VerticalButton.h"
#import "BatchDetailMatterService.h"
#import "BatchDetailGalleryService.h"
#import "MyCustomTextView.h"
#import "AddTextViewController.h"
#import "Masonry.h"
#import "SyncViewController.h"
#import "EditTextView.h"
#import "RMPZoomTransitionAnimator.h"
#import "DecoTextView.h"

#define LABEL_TIP   @"请输入文字"
#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)

@interface BatchDetailViewController ()<MakeViewDelegate,CanCancelImageViewDelegate,BatchDetailMatterServiceDelegate,BatchDetailGalleryServiceDelegate,AddTextViewControllerDelegate,EditTextViewDelegate,RMPZoomTransitionAnimating>

@property (nonatomic,strong)UIImageView *targetImg;
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)NSMutableArray *allMakeViews;
@property (nonatomic,strong)NSMutableArray *allFields;
@property (nonatomic,strong)NSMutableArray *customTextViews;
@property (nonatomic,strong)NSMutableArray *voiceUrlArray;
@property (nonatomic,strong)NSMutableArray *loactionPathArray;
@property (nonatomic,strong)NSMutableArray *allImages;
@property (nonatomic,assign)NSInteger switchIdx;
@property (nonatomic,strong)BatchDetailMatterService *matterService;
@property (nonatomic,strong)BatchDetailGalleryService *galleryService;
@property (nonatomic,strong)UICollectionView *galleryCollectionView;
@property (nonatomic,strong)UICollectionView *matteryCollectionView;
@property (nonatomic,strong)MakeView *touchView;
@property (nonatomic,strong)UILabel *responderLabel;
@property (nonatomic,strong)AddTextViewController *addTextController;
@property (nonatomic,strong)EditTextView *editView;
@property (nonatomic,assign)CGFloat indexOffset;

@end

@implementation BatchDetailViewController
{
    MyCustomTextView *_cusEditView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.translucent = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.view.backgroundColor = rgba(239, 239, 244, 1);
    [self createNavButtons];
    
    _switchIdx = -1;
    self.allMakeViews = [NSMutableArray array];
    self.allFields = [NSMutableArray array];
    self.customTextViews = [NSMutableArray array];
    self.voiceUrlArray = [NSMutableArray array];
    self.loactionPathArray = [NSMutableArray array];
    self.allImages = [NSMutableArray array];
    [self targetViewCreate];
    [self.view addSubview:self.bottomView];
    
    [self getAllDecos];
}

#pragma mark - UI
- (void)createNavButtons
{
    UIButton *leftBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBut setImage:CREATE_IMG(@"makeBack") forState:UIControlStateNormal];
    [leftBut setFrame:CGRectMake(0, 0, 27, 20)];
    [leftBut setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 7)];
    [leftBut addTarget:self action:@selector(backToMakeList:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setImage:CREATE_IMG(@"makeFinish") forState:UIControlStateNormal];
    [rightBut setFrame:CGRectMake(0, 0, 27, 18)];
    [rightBut addTarget:self action:@selector(makeFinish:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBut];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftItem];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
}

- (void)targetViewCreate
{
    [self.view addSubview:self.targetImg];
    
    //模版内容
    UIImageView *preImgView = [[UIImageView alloc] initWithFrame:self.targetImg.bounds];
    [preImgView setImage:_templateImg];
    [_targetImg addSubview:preImgView];
    
    //数据解析
    if (_recordTemplate.detail_content) {
        [self dealWithHomePageImg];
        [self dealWithPlacText];
    }
    
    [self dealWithDecoList];
    [self dealWithDecoText];
}

//图片处理
- (void)dealWithHomePageImg
{
    //图片区域
    NSArray *image_coor = _recordTemplate.detail_content.image_coor;
    if (image_coor && [image_coor count] > 0) {
        for (NSInteger i = 0; i < [image_coor count]; i++) {
            ImageCoorInfo *imgInfo = [image_coor objectAtIndex:i];
            if ((!imgInfo.x || (imgInfo.x.length <= 0)) || (!imgInfo.y || (imgInfo.y.length <= 0))) {
                continue;
            }
            NSArray *x = [imgInfo.x componentsSeparatedByString:@","];
            NSArray *y = [imgInfo.y componentsSeparatedByString:@","];
            
            CGRect rect = CGRectMake([x[0] floatValue] * _fRate, [x[1] floatValue] * _fRate, ([y[0] floatValue] - [x[0] floatValue]) * _fRate, ([y[1] floatValue] - [x[1] floatValue]) * _fRate);
            MakeView *makeView = [[MakeView alloc] initWithFrame:rect];
            makeView.delegate = self;
            makeView.tag = 10 + i;
            [_targetImg addSubview:makeView];
            [_targetImg sendSubviewToBack:makeView];
            [_allMakeViews addObject:makeView];
            
            //数组获取
            NSArray *gallerys = nil,*photosArr = nil;
            if ([_recordTemplate.production_parameter.src_gallery_list count] > i) {
                gallerys = [_recordTemplate.production_parameter.src_gallery_list objectAtIndex:i];
            }
            if ([_localArr count] > i) {
                photosArr = [_localArr objectAtIndex:i];
            }
            
            //默认填充资源
            if ([_recordTemplate.production_parameter.image_path count] > i) {
                ProductImagePath *tmpPath = _recordTemplate.production_parameter.image_path[i];
                //该区域又可能未添加
                if (tmpPath && tmpPath.image_url.length > 0) {
                    BOOL hasFound = NO;
                    //网络检索
                    for (ProductImageGallery *gallery in gallerys) {
                        if ([gallery.path rangeOfString:tmpPath.image_url].location != NSNotFound) {
                            hasFound = YES;
                            makeView.checkIdx = [gallerys indexOfObject:gallery];
                            [self downLoadWithGallery:gallery Make:makeView First:YES];
                            break;
                        }
                    }
                    //本地检索
                    if (!hasFound) {
                        for (PhotoManagerModel *subPhoto in photosArr) {
                            if ([subPhoto.path rangeOfString:tmpPath.image_url].location != NSNotFound) {
                                makeView.checkIdx = [photosArr indexOfObject:subPhoto] + [gallerys count];
                                [self downLoadWithPhoto:subPhoto Make:makeView First:YES];
                                break;
                            }
                        }
                    }
                    
                    continue;
                }
            }
            //本地资源填充
            if ([photosArr count] > 0) {
                //图片最低要求大小
                CGFloat temOri = _recordTemplate.original_width.floatValue /_recordTemplate.image_width.floatValue;
                CGFloat unilateralRatio = sqrt(2);
                CGSize oriSize = CGSizeMake((rect.size.width / _fRate) * temOri / unilateralRatio, (rect.size.height / _fRate) * temOri / unilateralRatio);
                
                for (NSInteger m = 0; m < [photosArr count]; m++) {
                    PhotoManagerModel *subPhoto = photosArr[m];
                    if (subPhoto.file_type.integerValue == 1) {
                        if (subPhoto.width.floatValue >= oriSize.width && subPhoto.height.floatValue >= oriSize.height) {
                            makeView.checkIdx = m + [gallerys count];
                            [self downLoadWithPhoto:subPhoto Make:makeView First:YES];
                            break;
                        }
                    }
                }
            }
        }
    }
}

//文本处理
- (void)dealWithPlacText
{
    //文本区域
    NSArray *word_coor = _recordTemplate.detail_content.word_coor;
    if (word_coor && [word_coor count] > 0) {
        for (NSInteger i = 0;i < [word_coor count];i++) {
            WordCoorInfo *wordInfo = word_coor[i];
            if ((!wordInfo.x || (wordInfo.x.length <= 0)) || (!wordInfo.y || (wordInfo.y.length <= 0))) {
                continue;
            }
            NSArray *x = [wordInfo.x componentsSeparatedByString:@","];
            NSArray *y = [wordInfo.y componentsSeparatedByString:@","];
            CGRect rect = CGRectMake([x[0] floatValue] * _fRate, [x[1] floatValue] * _fRate, ([y[0] floatValue] - [x[0] floatValue]) * _fRate, ([y[1] floatValue] - [x[1] floatValue]) * _fRate);
            
            UILabel *label = [[UILabel alloc] initWithFrame:rect];
            [label setBackgroundColor:[UIColor clearColor]];
            
            NSString *default_txt = wordInfo.default_txt;
            label.text = (default_txt && [default_txt isKindOfClass:[NSString class]] && ([default_txt length] > 0)) ? default_txt : LABEL_TIP;
            NSString *color = wordInfo.color;
            CGFloat fontSize = wordInfo.size.floatValue;
            if (fontSize == 0) {
                fontSize = 12 / _fRate;
            }
            NSInteger lastSize = fontSize * _fRate;
            [label setFont:[UIFont systemFontOfSize:lastSize]];
            [label setTextColor:[UIColor colorWithHexString:color]];
            [label setUserInteractionEnabled:YES];
            [label setTag:i + 1];
            [label setNumberOfLines:0];
            label.layer.masksToBounds = YES;
            label.layer.borderWidth = 1.0;
            label.layer.borderColor = [UIColor clearColor].CGColor;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabelView:)];
            [label addGestureRecognizer:tapGestureRecognizer];
            [_allFields addObject:label];
            [_targetImg addSubview:label];
            
            //语音
            [_voiceUrlArray addObject:@""];
            [_loactionPathArray addObject:@""];
            if ([_recordTemplate.production_parameter.input_text count] == [word_coor count]) {
                ProductImageInput *input = [_recordTemplate.production_parameter.input_text objectAtIndex:i];
                [label setText:input.txt];
                if ([input.voice isKindOfClass:[NSString class]] && input.voice.length > 0) {
                    NSString * url = input.voice;
                    if (![url hasPrefix:@"http"]) {
                        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                    }
                    [_voiceUrlArray replaceObjectAtIndex:i withObject:url];
                    
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setFrame:CGRectMake(label.frame.origin.x - 50, label.frame.origin.y, 44, 17.5)];
                    [btn setTag:i + 1];
                    [btn setImage:CREATE_IMG(@"voice42") forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
                    [_targetImg addSubview:btn];
                }
            }
        }
    }
}

//素材处理
- (void)dealWithDecoList
{
    //素材
    NSInteger decoCount = [_recordTemplate.production_parameter.deco_path count];
    for (NSInteger i = 0; i < decoCount; i++) {
        ProductImagePath *decoPath = _recordTemplate.production_parameter.deco_path[i];
        NSArray *decoArr = [decoPath.detail componentsSeparatedByString:@"_"];
        if ([decoArr count] == 5) {
            NSString *url = decoPath.image_url;
            if (![url hasPrefix:@"http"]) {
                url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
            }
            
            CGRect rect = CGRectMake([decoArr[0] floatValue] * _fRate - 12.5, [decoArr[1] floatValue] * _fRate - 12.5, [decoArr[2] floatValue] * _fRate + 25, [decoArr[3] floatValue] * _fRate + 25);
            CanCancelImageView *imageView = [[CanCancelImageView alloc] initWithFrame:rect];
            imageView.delegate = self;
            [imageView.contentImg sd_setImageWithURL:[NSURL URLWithString:url]];
            [imageView setBackgroundColor:[UIColor clearColor]];
            imageView.imgPath = decoPath.image_url;
            [_targetImg addSubview:imageView];
            
            [_allImages addObject:imageView];
            imageView.transform = CGAffineTransformRotate(imageView.transform, [decoArr[4] floatValue] * M_PI / 180);
            imageView.nRotation = [decoArr[4] floatValue];
            [imageView hiddenButton];
        }
    }
}

//素材文本处理
- (void)dealWithDecoText
{
    //自动文本，非模版中自带
    NSInteger txtCount = [_recordTemplate.production_parameter.deco_text count];
    for (NSInteger i = 0; i < txtCount; i++) {
        ProductImageDecotext *dexoTxt = [_recordTemplate.production_parameter.deco_text objectAtIndex:i];
        if (dexoTxt.txt.length > 0) {
            NSArray *decoArr = [dexoTxt.detail componentsSeparatedByString:@"_"];
            if ([decoArr count] == 5) {
                CGFloat alphaColor = (dexoTxt.alpha == nil) ? 1 : [dexoTxt.alpha floatValue];
                NSString *font_key = (dexoTxt.font.length > 0) ? dexoTxt.font : @"";
                UIFont *font = [NSString customFontWithPath:[APPDocumentsDirectory stringByAppendingPathComponent:[font_key stringByAppendingString:@".ttf"]] size:12];
                UIImage *tmpImg = [self imageFromText:[dexoTxt.txt componentsSeparatedByString:Seperate_RowStr] withFont:font Color:dexoTxt.color Alpha:alphaColor];
                CGFloat wei = [decoArr[2] floatValue] * _fRate,hei = tmpImg.size.height * wei / tmpImg.size.width;
                CGRect rect = CGRectMake([decoArr[0] floatValue] * _fRate - 12.5, [decoArr[1] floatValue] * _fRate - 12.5, wei + 25, hei + 25);
                MyCustomTextView *imageView = [[MyCustomTextView alloc] initWithFrame:rect];
                imageView.delegate = self;
                imageView.colorStr = dexoTxt.color;
                imageView.alphaColor = alphaColor;
                imageView.textStr = dexoTxt.txt;
                imageView.font_key = font_key;
                [imageView.contentImg setImage:tmpImg];
                [_targetImg addSubview:imageView];
                
                [_customTextViews addObject:imageView];
                imageView.transform = CGAffineTransformRotate(imageView.transform, [decoArr[4] floatValue] * M_PI / 180);
                imageView.nRotation = [decoArr[4] floatValue];
                [imageView hiddenButton];
            }
        }
    }
}

- (void)hideAllCancelButs
{
    //隐藏所有删除按钮项
    for (CanCancelImageView *subView in _allImages) {
        [subView hiddenButton];
    }
    
    for (MyCustomTextView *textView in _customTextViews) {
        [textView hiddenButton];
    }
}

- (void)hideOtherCancelButsOff:(CanCancelImageView *)imgView
{
    //隐藏除imgView外的所有删除按钮项
    for (CanCancelImageView *subView in _allImages) {
        if (subView == imgView) {
            continue;
        }
        [subView hiddenButton];
    }
    
    for (MyCustomTextView *textView in _customTextViews) {
        if (textView == imgView) {
            continue;
        }
        [textView hiddenButton];
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
    return [DecoTextView convertSelfToImage:decoView];
    /*
    UIGraphicsBeginImageContextWithOptions(newSize,NO,0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetCharacterSpacing(ctx, 10);
    CGContextSetTextDrawingMode (ctx, kCGTextFillStroke);
    //CGContextSetRGBFillColor (ctx, 0.1, 0.2, 0.3, 1); // 6
    CGContextSetLineWidth(ctx, SINGLE_LINE_WIDTH);
    //CGContextSetShouldAntialias(ctx, NO );
    
    unsigned int r,g,b;
    [UIColor colorRGBWithHexString:&r G:&g B:&b Color:colorStr];
    CGContextSetRGBStrokeColor (ctx, r / 255.0, g / 255.0, b / 255.0, alpha);
    
    CGFloat fPosY = 10;
    NSInteger nIndex = 0;
    CGFloat pixelAdjustOffset = 0;
    if (((int)([UIScreen mainScreen].scale) + 1) % 2 == 0) {
        pixelAdjustOffset = SINGLE_LINE_ADJUST_OFFSET;
    }
    for (NSString *sContent in arrContent) {
        NSNumber *numHeight = [arrHeight objectAtIndex:nIndex];
        CGFloat xPos = 10 - pixelAdjustOffset;
        CGFloat yPos = fPosY - pixelAdjustOffset;
        CGRect rect = CGRectMake(xPos, yPos, newWei, numHeight.floatValue);
        [sContent drawWithRect:rect options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
        
        fPosY += [numHeight floatValue];
        nIndex++;
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
     */
}

#pragma mark - 全新下载管理
- (void)downloagImgWithURL:(NSString *)url complate:(void (^)(UIImage *image))complateBlock{
    NSString *downStr = url;
    if (![downStr hasPrefix:@"http"]) {
        downStr = [G_IMAGE_ADDRESS stringByAppendingString:downStr ?: @""];
    }
    NSURL *downUrl = [NSURL URLWithString:downStr];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //下载
    @try {
        [manager downloadImageWithURL:downUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    complateBlock(image);
                }
                else
                {
                    NSLog(@"%@",error.description);
                }
            });
        }];
        
    } @catch (NSException *e) {
        NSLog(@"%@",e.description);
    }
}

- (void)downLoadWithGallery:(ProductImageGallery *)gallery Make:(MakeView *)makeView First:(BOOL)first
{
    __weak typeof(self)weakSelf = self;
    NSInteger index = [_allMakeViews indexOfObject:makeView];
    NSString *path = gallery.path;
    path = [NSString getPictureAddress:@"2" width:@"640" height:@"0" original:path];
    [self downloagImgWithURL:path complate:^(UIImage *image) {
        NSArray *localArr = weakSelf.recordTemplate.production_parameter.src_gallery_list[index];
        NSInteger shouldIdx = [localArr indexOfObject:gallery];
        if (shouldIdx == NSNotFound) {
            return ;
        }
        
        if (makeView.checkIdx != shouldIdx) {
            return;
        }
        
        CGFloat maxScale = _recordTemplate.image_width.floatValue / _recordTemplate.original_width.floatValue * _fRate;
        if (first) {
            //封面索引,第一次加载上次提交过的封面
            if ([weakSelf.recordTemplate.production_parameter.image_path count] > index) {
                ProductImagePath *tmpPath = weakSelf.recordTemplate.production_parameter.image_path[index];
                if ((tmpPath.image_url.length > 0) && [gallery.path rangeOfString:tmpPath.image_url].location != NSNotFound) {
                    
                    [makeView resetImageView:image];
                    //第一次加载调整为上一次制作样子，保证还原度
                    makeView.oriImgSize = CGSizeMake(tmpPath.original_width.floatValue * maxScale, tmpPath.original_height.floatValue * maxScale);
                    NSArray *frames = [tmpPath.detail componentsSeparatedByString:@"_"];
                    if (frames.count == 5) {
                        CGFloat wei = [frames[2] floatValue] * _fRate;
                        CGSize imgSize = image.size;
                        CGFloat hei = wei * imgSize.height / imgSize.width;
                        [makeView.curImg setFrame:CGRectMake([frames[0] floatValue] * _fRate - makeView.frameX, [frames[1] floatValue] * _fRate - makeView.frameY, wei, hei)];
                        makeView.curImg.transform = CGAffineTransformRotate(makeView.curImg.transform, [frames[4] floatValue] * M_PI / 180);
                        makeView.nRotation = [frames[4] floatValue];
                    }
                    return;
                }
            }
        }
        
        [makeView resetImageView:image];
        CGSize imgSize = CGSizeMake(gallery.original_width.floatValue * maxScale, gallery.original_height.floatValue * maxScale);
        makeView.oriImgSize = imgSize;
        
        //填充框
        CGFloat fullScale = MAX(makeView.bounds.size.width / imgSize.width, makeView.bounds.size.height / imgSize.height);
        CGSize fullSize = CGSizeMake(imgSize.width * fullScale, imgSize.height * fullScale);
        [makeView.curImg setFrame:CGRectMake((makeView.frameWidth - fullSize.width) / 2, (makeView.frameHeight - fullSize.height) / 2, fullSize.width, fullSize.height)];
    }];
}

- (void)downLoadWithPhoto:(PhotoManagerModel *)photo Make:(MakeView *)makeView First:(BOOL)first
{
    if (photo.asset) {
        [self resetImage:[UIImage imageWithCGImage:photo.asset.defaultRepresentation.fullScreenImage] data:photo To:makeView First:first];
    }
    else if (photo.path.length > 0){
        NSString *path = photo.path;
        path = [NSString getPictureAddress:@"2" width:@"640" height:@"0" original:path];
        __weak typeof(self)weakSelf = self;
        [self downloagImgWithURL:path complate:^(UIImage *image) {
            [weakSelf resetImage:image data:photo To:makeView First:first];
        }];
    }
    else{
        __weak typeof(self)weakSelf = self;
        [[GlobalManager defaultAssetsLibrary] assetForURL:[NSURL URLWithString:photo.file_client_path] resultBlock:^(ALAsset *asset) {
            photo.asset = asset;
            [weakSelf resetImage:[UIImage imageWithCGImage:photo.asset.defaultRepresentation.fullScreenImage] data:photo To:makeView First:first];
        } failureBlock:^(NSError *error) {
            
        }];;
    }
}

- (void)resetImage:(UIImage *)image data:(PhotoManagerModel *)photo To:(MakeView *)makeView First:(BOOL)first
{
    NSInteger index = [_allMakeViews indexOfObject:makeView];
    NSArray *localArr = _localArr[index];
    NSInteger shouldIdx = [localArr indexOfObject:photo];
    if (shouldIdx == NSNotFound) {
        return ;
    }
    
    NSInteger lstIdx = shouldIdx;
    if ([_recordTemplate.production_parameter.src_gallery_list count] > index) {
        NSArray *galleryArr = _recordTemplate.production_parameter.src_gallery_list[index];
        lstIdx += galleryArr.count;
    }
    
    if (makeView.checkIdx != lstIdx) {
        return;
    }
    
    CGFloat maxScale = _recordTemplate.image_width.floatValue / _recordTemplate.original_width.floatValue * _fRate;
    if (first) {
        //封面索引,第一次加载上次提交过的封面
        if ([_recordTemplate.production_parameter.image_path count] > index) {
            ProductImagePath *tmpPath = _recordTemplate.production_parameter.image_path[index];
            if ((tmpPath.image_url.length > 0) && (photo.path.length > 0) && [photo.path rangeOfString:tmpPath.image_url].location != NSNotFound) {
                
                [makeView resetImageView:image];
                //第一次加载调整为上一次制作样子，保证还原度
                makeView.oriImgSize = CGSizeMake(tmpPath.original_width.floatValue * maxScale, tmpPath.original_height.floatValue * maxScale);
                NSArray *frames = [tmpPath.detail componentsSeparatedByString:@"_"];
                if (frames.count == 5) {
                    CGFloat wei = [frames[2] floatValue] * _fRate;
                    CGSize imgSize = image.size;
                    CGFloat hei = wei * imgSize.height / imgSize.width;
                    [makeView.curImg setFrame:CGRectMake([frames[0] floatValue] * _fRate - makeView.frameX, [frames[1] floatValue] * _fRate - makeView.frameY, wei, hei)];
                    makeView.curImg.transform = CGAffineTransformRotate(makeView.curImg.transform, [frames[4] floatValue] * M_PI / 180);
                    makeView.nRotation = [frames[4] floatValue];
                }
                return;
            }
        }
    }
    
    [makeView resetImageView:image];
    CGSize imgSize = CGSizeMake(photo.width.floatValue * maxScale, photo.height.floatValue * maxScale);
    makeView.oriImgSize = imgSize;
    
    //填充框
    CGFloat fullScale = MAX(makeView.bounds.size.width / imgSize.width, makeView.bounds.size.height / imgSize.height);
    CGSize fullSize = CGSizeMake(imgSize.width * fullScale, imgSize.height * fullScale);
    [makeView.curImg setFrame:CGRectMake((makeView.frameWidth - fullSize.width) / 2, (makeView.frameHeight - fullSize.height) / 2, fullSize.width, fullSize.height)];
}

#pragma mark - 素材
- (void)getAllDecos
{
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.decorationArr) {
        return;
    }
    
    if (manager.networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        return;
    }

    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMaterial"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"material"];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        [weakSelf getAllDecosFinish:error Data:data];
    }];
}

- (void)getAllDecosFinish:(NSError *)error Data:(id)data
{
    if (error == nil) {
        NSArray *ret_data = [data valueForKey:@"ret_data"];
        NSMutableArray *array = [DecorateModel arrayOfModelsFromDictionaries:ret_data error:nil];
        [[GlobalManager shareInstance] setDecorationArr:array];
    }
}

#pragma mark - actions
- (void)scaleToFatherType:(kBackMakeType)backType At:(NSInteger)index
{
    ProductionParameter *param = _recordTemplate.production_parameter;
    if (!param) {
        param = [[ProductionParameter alloc] init];
        [_recordTemplate setProduction_parameter:param];
    }
    
    NSMutableArray *src_image_list  = [self getSrcImageList];
    NSMutableArray *src_txt_list    = [self getSrcTxtLists];
    NSMutableArray *deco_text       = [self getDecoTxtListArr];
    NSMutableArray *src_deco_list   = [self getSrcDecoListArr];
    [param setImage_path:(NSMutableArray<ProductImagePath> *)src_image_list];
    [param setDeco_path:(NSMutableArray<ProductImagePath> *)src_deco_list];
    [param setInput_text:(NSMutableArray<ProductImageInput> *)src_txt_list];
    [param setDeco_text:(NSMutableArray<ProductImageDecotext> *)deco_text];
    
    if (_delegate && [_delegate respondsToSelector:@selector(changeDetailFinishAt:Type:)]) {
        [_delegate changeDetailFinishAt:index Type:backType];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)backToMakeList:(id)sender
{
    [self scaleToFatherType:kBackMakeReturnKey At:NSNotFound];
}

- (void)makeFinish:(id)sender
{
    [self startCommitInfo:NO];
}

- (void)tapLabelView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UILabel *label = (UILabel *)[tapGestureRecognizer view];
    if (_responderLabel == label) {
        return;
    }
    [self hideAllCancelButs];
    [self dismissPopUpView];
    
    _targetImg.userInteractionEnabled = NO;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
    
    if (_responderLabel) {
        _responderLabel.layer.borderColor = [UIColor clearColor].CGColor;
        if (_responderLabel.text.length == 0) {
            [_responderLabel setText:LABEL_TIP];
        }
    }
    _responderLabel = label;
    _responderLabel.layer.borderColor = CreateColor(244, 174, 97).CGColor;
    if (label.text && [label.text isEqualToString:LABEL_TIP]) {
        [label setText:@""];
    }
    NSArray *word_coor = _recordTemplate.detail_content.word_coor;
    WordCoorInfo *info = word_coor[_responderLabel.tag - 1];
    NSInteger max_num = info.max_num.integerValue;
    if (max_num == 0) {
        max_num = 12;
    }
    int voice_flag = (int)info.voice_flag.integerValue;
    
    _indexOffset = _targetImg.frame.origin.y + label.frame.origin.y + label.frame.size.height;
    EditTextView *editView = [[EditTextView alloc] initWithFrame:[UIScreen mainScreen].bounds Voice_flag:voice_flag Placeholder:[label text]];
    [editView setTag:[label tag]];
    _editView = editView;
    [editView setLoactionPath:[_loactionPathArray objectAtIndex:[label tag] - 1]];
    [editView setVoiceUrl:[_voiceUrlArray objectAtIndex:[label tag] - 1]];
    [editView setDelegate:self];
    [editView showInView:[self.view window]];
    [editView setLimitCount:max_num];
    
    NSString *voiceUrl = [_voiceUrlArray objectAtIndex:[label tag] - 1];
    if ([voiceUrl length] > 0) {
        [editView setInitData];
    }
    
    if (_indexOffset > SCREEN_HEIGHT - ((voice_flag == 1) ? 160 : 90)) {
        //上移
        CGRect butRec = self.view.frame;
        [UIView animateWithDuration:0.35 animations:^{
            [self.view setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - (_indexOffset - (SCREEN_HEIGHT - ((voice_flag == 1) ? 160 : 90))), butRec.size.width, butRec.size.height)];
        }];
    }
    
}

#pragma mark - RMPZoomTransitionAnimating
- (UIImageView *)transitionSourceImageView
{
    UIImageView *tempImg = [[UIImageView alloc] initWithFrame:_targetImg.frame];
    [tempImg setImage:_templateImg];
    //[tempImg setImage:[DecoTextView convertSelfToImage:_targetImg]];
    [tempImg setBackgroundColor:_targetImg.backgroundColor];
    
    return tempImg;
}

- (UIColor *)transitionSourceBackgroundColor
{
    return _targetImg.backgroundColor;
}

- (CGRect)transitionDestinationImageViewFrame
{
    return _targetImg.frame;
}

#pragma mark - EditTextViewDelegate
- (void)hiddenEditTextView:(EditTextView *)editTextView
{
    if (_responderLabel) {
        _responderLabel.layer.borderColor = [UIColor clearColor].CGColor;
        if (_responderLabel.text.length == 0) {
            _responderLabel.text = LABEL_TIP;
        }
        _responderLabel = nil;
        _targetImg.userInteractionEnabled = YES;
        ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    }
    
    [_loactionPathArray replaceObjectAtIndex:[editTextView tag] - 1 withObject:editTextView.loactionPath];
    [_voiceUrlArray replaceObjectAtIndex:[editTextView tag] - 1 withObject:editTextView.voiceUrl];
    
    CGRect butRec = self.view.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [self.view setFrame:CGRectMake(butRec.origin.x, 0, butRec.size.width, butRec.size.height)];
    }];
}

- (void)showKeyboardEditTextView:(CGFloat)keyboard Height:(CGFloat)height
{
    if (_indexOffset > SCREEN_HEIGHT - height - keyboard) {
        //上移
        UIView *father = [self.view superview];
        CGRect newRect = CGRectMake(self.view.frame.origin.x, father.frame.size.height - (_indexOffset - (SCREEN_HEIGHT - height - keyboard)) - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        [UIView animateWithDuration:0.35 animations:^{
            [self.view setFrame:newRect];
        }];
    }
}

- (void)hideKeyboardEditTextView:(CGFloat)height
{
    //下移
    CGFloat _offSet = 0.0;
    if (_indexOffset > (SCREEN_HEIGHT - height)) {
        _offSet = _indexOffset - (SCREEN_HEIGHT - height);
    }
    UIView *father = [self.view superview];
    CGRect newRect = CGRectMake(self.view.frame.origin.x, father.frame.size.height - _offSet - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.35 animations:^{
        [self.view setFrame:newRect];
    }];
}

- (void)showEditTextContent:(NSString *)content
{
    if (![_responderLabel.text isEqualToString:content]) {
        [_responderLabel setText:content];
    }
}

#pragma mark - play Voice
- (void)playVoice:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (!_editView) {
        _editView = [[EditTextView alloc] init];
        [_editView setLoactionPath:[_loactionPathArray objectAtIndex:[btn tag] - 1]];
        [_editView setVoiceUrl:[_voiceUrlArray objectAtIndex:[btn tag] - 1]];
    }
    [_editView playVoice:sender];
}

- (void)switchItem:(id)sender
{
    NSInteger index = [sender tag] - 1;
    if (_switchIdx == index) {
        return;
    }
    if (_switchIdx >= 0) {
        UIButton *preBut = (UIButton *)[_bottomView viewWithTag:_switchIdx + 1];
        preBut.selected = NO;
    }
    
    [self hideAllCancelButs];
    
    _switchIdx = index;
    switch (index) {
        case 0:
        {
            if ([GlobalManager shareInstance].decorationArr) {
                [(UIButton *)sender setSelected:YES];
                _targetImg.userInteractionEnabled = NO;
                //animation
                if (![self.matteryCollectionView isDescendantOfView:self.view]) {
                    [self.view addSubview:self.matteryCollectionView];
                    [self.view sendSubviewToBack:self.matteryCollectionView];
                }
                
                self.view.window.userInteractionEnabled = NO;
                [_matteryCollectionView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 140 - 49)];
                [_matteryCollectionView reloadData];
                __weak typeof(self)weakSelf = self;
                CGFloat scale = _newRate / _fRate;
                [UIView animateWithDuration:0.3 animations:^{
                    [weakSelf.matteryCollectionView setFrameY:SCREEN_HEIGHT - 140];
                    weakSelf.targetImg.transform = CGAffineTransformMakeScale(scale,scale);
                    [weakSelf.targetImg setCenter:CGPointMake(weakSelf.view.center.x, 44 + (SCREEN_HEIGHT - 140 - 44) / 2)];
                } completion:^(BOOL finished) {
                    weakSelf.view.window.userInteractionEnabled = YES;
                }];
            }
            else{
                _switchIdx = -1;
                [self.view.window makeToast:@"暂无相应素材，请稍后再试" duration:1.0 position:@"center"];
            }
        }
            break;
        case 1:
        {
            [(UIButton *)sender setSelected:YES];
            [self dismissPopUpView];
            
            self.addTextController.delegate = self;
            self.navigationController.navigationBarHidden = YES;
            [self.view addSubview:_addTextController.view];
            [self addChildViewController:_addTextController];
        }
            break;
        case 2:
        {
            [self dismissPopUpView];
            [self startCommitInfo:YES];
        }
            break;
        default:
            break;
    }
    
    
    
    if (index != 2) {
        [(UIButton *)sender setSelected:YES];
    }
}

#pragma mark - 提交数据
- (void)startCommitInfo:(BOOL)isSync
{
    GlobalManager *manager = [GlobalManager shareInstance];
    if (manager.networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSMutableDictionary *param = [manager requestinitParamsWith:@"growProduction"];
    [param setObject:_recordTemplate.user_grow_id forKey:@"grow_id"];
    [param setObject:_recordTemplate.template_id forKey:@"template_id"];
    [param setObject:_recordTemplate.template_detail_id forKey:@"template_detail_id"];
    [param setObject:_recordTemplate.id forKey:@"c_id"];
    [param setObject:_recordTemplate.user_id forKey:@"user_id"];
    [param setObject:manager.detailInfo.token forKey:@"token"];
    [param setObject:_recordTemplate.batch_id forKey:@"batch_id"];
    NSString *src_image_list    = [self getSrcImgList];
    NSString *src_gallery_list  = [self getSrcGalleryList];
    NSString *src_deco_list     = [self getSrcDecoList];
    NSString *src_txt_list      = [self getSrcTxtList];
    NSString *deco_text         = [self getDecoTxtList];
    [param setObject:src_image_list forKey:@"src_image_list"];
    [param setObject:src_gallery_list forKey:@"src_gallery_list"];
    [param setObject:src_deco_list forKey:@"src_deco_list"];
    [param setObject:src_txt_list forKey:@"src_txt_list"];
    [param setObject:deco_text forKey:@"deco_text"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"production"];
    __weak typeof(self)weakSelf = self;
    [self.view.window makeToastActivity];
    self.navigationController.view.userInteractionEnabled = NO;
    self.sessionTask = [HttpClient asynchronousRequest:url parameters:param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf commitFinish:error Data:data Sync:isSync];
        });
    }];
}

- (void)commitFinish:(NSError *)error Data:(id)data Sync:(BOOL)isSync
{
    self.sessionTask = nil;
    [self.view.window hideToastActivity];
    self.navigationController.view.userInteractionEnabled = YES;
    if (error) {
        [self.view.window makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        /*
        id ret_data = [data valueForKey:@"ret_data"];
        NSString *image_thumb_url = [ret_data valueForKey:@"image_thumb_url"];
        NSString *image_url = [ret_data valueForKey:@"image_url"];
        [_recordTemplate setImage_url:image_url];
        [_recordTemplate setImage_thumb_url:image_thumb_url];
        */
        if (isSync) {
            ProductionParameter *param = _recordTemplate.production_parameter;
            if (!param) {
                param = [[ProductionParameter alloc] init];
                [_recordTemplate setProduction_parameter:param];
            }
            
            NSMutableArray *src_image_list  = [self getSrcImageList];
            NSMutableArray *src_txt_list    = [self getSrcTxtLists];
            NSMutableArray *deco_text       = [self getDecoTxtListArr];
            NSMutableArray *src_deco_list   = [self getSrcDecoListArr];
            [param setImage_path:(NSMutableArray<ProductImagePath> *)src_image_list];
            [param setDeco_path:(NSMutableArray<ProductImagePath> *)src_deco_list];
            [param setInput_text:(NSMutableArray<ProductImageInput> *)src_txt_list];
            [param setDeco_text:(NSMutableArray<ProductImageDecotext> *)deco_text];
            
            if (_delegate && [_delegate respondsToSelector:@selector(changeDetailFinishAt:Type:)]) {
                [_delegate changeDetailFinishAt:NSNotFound Type:kBackMakeFinish];
            }
            
            SyncViewController *sync = [[SyncViewController alloc] init];
            sync.recordTemplate = _recordTemplate;
            [self.navigationController pushViewController:sync animated:YES];
        }
        else{
            [self scaleToFatherType:kBackMakeFinish At:NSNotFound];
        }
        
    }
}

#pragma mark - 接口参数
//封面
- (NSString *)getSrcImgList
{
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = [_recordTemplate.production_parameter.src_gallery_list count];
    for (NSInteger i = 0; i < _allMakeViews.count; i++) {
        MakeView *makeView = _allMakeViews[i];
        NSString *url = nil,*width = nil, *height = nil;
        if (makeView.checkIdx >= 0 && makeView.curImg) {
            NSArray *gallerys = nil,*localArr = nil;
            //找图集数组，分网络和本地
            if (count > i) {
                gallerys = [_recordTemplate.production_parameter.src_gallery_list objectAtIndex:i];
            }

            if ([_localArr count] > i) {
                localArr = [_localArr objectAtIndex:i];
            }
            
            if ([gallerys count] > makeView.checkIdx) {
                ProductImageGallery *gallery = [gallerys objectAtIndex:makeView.checkIdx];
                url = gallery.path;
                width = gallery.original_width.stringValue;
                height = gallery.original_height.stringValue;
            }
            else{
                NSInteger index = makeView.checkIdx - [gallerys count];
                PhotoManagerModel *photo = [localArr objectAtIndex:index];
                url = photo.path;
                width = photo.width;
                height = photo.height;
            }
           
            NSString *detail =  [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(makeView.center.x - makeView.bounds.size.width / 2 + makeView.curImg.center.x - makeView.curImg.bounds.size.width / 2) / _fRate, (makeView.center.y - makeView.bounds.size.height / 2 + makeView.curImg.center.y - makeView.curImg.bounds.size.height / 2) / _fRate, (makeView.curImg.bounds.size.width) / _fRate, (makeView.curImg.bounds.size.height) / _fRate, makeView.nRotation];
            NSDictionary *dic = @{@"image_url":url,@"detail":detail,@"original_width":width,@"original_height":height};
            NSString *jsonString = [NSString dictToJsonStr:dic];
            [array addObject:jsonString];
        }
        else{
            [array addObject:@"{}"];
        }
    }
    
    return [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
}

//图集
- (NSString *)getSrcGalleryList
{
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = [_recordTemplate.production_parameter.src_gallery_list count];
    for (NSInteger i = 0; i < _allMakeViews.count; i++) {
        
        MakeView *makeView = _allMakeViews[i];
        NSMutableArray *tmpArr = [NSMutableArray array];
        NSArray *gallerys = nil,*localArr = nil;
        //找图集数组，分网络和本地
        if (count > i) {
            gallerys = [_recordTemplate.production_parameter.src_gallery_list objectAtIndex:i];
            for (NSInteger m = 0; m < gallerys.count; m++) {
                ProductImageGallery *gallery = [gallerys objectAtIndex:m];
                NSString *type = gallery.type.stringValue;
                NSString *is_cover = (m == makeView.checkIdx) ? @"1" : @"0";
                NSDictionary *dic = @{@"type":type,@"path":gallery.path,@"is_cover":is_cover,@"picture":gallery.picture ?: @"",@"original_width":gallery.original_width.stringValue,@"original_height":gallery.original_height.stringValue};
                    NSString *jsonString = [NSString dictToJsonStr:dic];
                    [tmpArr addObject:jsonString];
            }
        }
            
        if ([_localArr count] > i) {
            localArr = [_localArr objectAtIndex:i];
            for (NSInteger m = 0; m < localArr.count; m++) {
                PhotoManagerModel *photo = [localArr objectAtIndex:m];
                NSString *type = photo.file_type;
                NSString *is_cover = ((makeView.checkIdx >= [gallerys count]) && (m == makeView.checkIdx - [gallerys count])) ? @"1" : @"0";
                NSDictionary *dic = @{@"type":type,@"path":photo.path,@"is_cover":is_cover,@"picture":@"",@"original_width":photo.width,@"original_height":photo.height};
                    NSString *jsonString = [NSString dictToJsonStr:dic];
                    [tmpArr addObject:jsonString];
            }
        }
            
        [array addObject:[NSString stringWithFormat:@"[%@]",[tmpArr componentsJoinedByString:@","]]];
    }
    
    return [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
}

//素材地址
- (NSString *)getSrcDecoList
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < _allImages.count; i++) {
        CanCancelImageView *cancel = _allImages[i];
        NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(cancel.center.x - cancel.bounds.size.width / 2 + cancel.contentImg.center.x - cancel.contentImg.bounds.size.width / 2) / _fRate, (cancel.center.y - cancel.bounds.size.height / 2 + cancel.contentImg.center.y - cancel.contentImg.bounds.size.height / 2) / _fRate, (cancel.contentImg.bounds.size.width) / _fRate, (cancel.contentImg.bounds.size.height) / _fRate, cancel.nRotation];
        NSDictionary *dic = @{@"image_url":cancel.imgPath,@"detail":str};
        NSString *jsonString = [NSString dictToJsonStr:dic];
        [array addObject:jsonString];
    }
    
    return [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
}

//输入文字
- (NSString *)getSrcTxtList
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < _allFields.count; i++) {
        UILabel *label = _allFields[i];
        NSArray *word_coor = _recordTemplate.detail_content.word_coor;
        WordCoorInfo *coorInfo = word_coor[label.tag - 1];
        NSString *voice_flag = coorInfo.voice_flag.stringValue;
        NSString *voiceUrl = @"";
        if ([voice_flag integerValue] == 1) {
            voiceUrl = [_voiceUrlArray objectAtIndex:[label tag] - 1];
        }
        NSString *tip = (([label.text length] > 0) && ![label.text isEqualToString:LABEL_TIP]) ? label.text : @"";
        NSDictionary *dic = @{@"txt":tip,@"voice":voiceUrl};
        NSString *jsonString = [NSString dictToJsonStr:dic];
        [array addObject:jsonString];
    }
    
    return [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
}

//自定义文本
- (NSString *)getDecoTxtList
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < _customTextViews.count; i++) {
        MyCustomTextView *cancel = _customTextViews[i];
        NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(cancel.center.x - cancel.bounds.size.width / 2 + cancel.contentImg.center.x - cancel.contentImg.bounds.size.width / 2) / _fRate, (cancel.center.y - cancel.bounds.size.height / 2 + cancel.contentImg.center.y - cancel.contentImg.bounds.size.height / 2) / _fRate, (cancel.contentImg.bounds.size.width) / _fRate, (cancel.contentImg.bounds.size.height) / _fRate, cancel.nRotation];
        NSDictionary *dic = @{@"txt":cancel.textStr ?: @"",@"size":@"12",@"detail":str,@"color":cancel.colorStr,@"font":cancel.font_key ?: @"",@"alpha":[[NSNumber numberWithFloat:cancel.alphaColor] stringValue]};
        NSString *jsonString = [NSString dictToJsonStr:dic];
        [array addObject:jsonString];
    }
    
    return [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
}

#pragma mark - 结果数据调整
//封面
- (NSMutableArray *)getSrcImageList
{
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = [_recordTemplate.production_parameter.src_gallery_list count];
    for (NSInteger i = 0; i < _allMakeViews.count; i++) {
        ProductImagePath *product = [[ProductImagePath alloc] init];
        MakeView *makeView = _allMakeViews[i];
        NSString *url = nil;
        CGFloat width,height;
        if (makeView.checkIdx >= 0 && makeView.curImg) {
            NSArray *gallerys = nil,*localArr = nil;
            //找图集数组，分网络和本地
            if (count > i) {
                gallerys = [_recordTemplate.production_parameter.src_gallery_list objectAtIndex:i];
            }
            
            if ([_localArr count] > i) {
                localArr = [_localArr objectAtIndex:i];
            }
            
            if ([gallerys count] > makeView.checkIdx) {
                ProductImageGallery *gallery = [gallerys objectAtIndex:makeView.checkIdx];
                url = gallery.path;
                width = gallery.original_width.floatValue;
                height = gallery.original_height.floatValue;
            }
            else{
                NSInteger index = makeView.checkIdx - [gallerys count];
                PhotoManagerModel *photo = [localArr objectAtIndex:index];
                url = photo.path;
                width = photo.width.floatValue;
                height = photo.height.floatValue;
            }
            
            NSString *detail =  [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(makeView.center.x - makeView.bounds.size.width / 2 + makeView.curImg.center.x - makeView.curImg.bounds.size.width / 2) / _fRate, (makeView.center.y - makeView.bounds.size.height / 2 + makeView.curImg.center.y - makeView.curImg.bounds.size.height / 2) / _fRate, (makeView.curImg.bounds.size.width) / _fRate, (makeView.curImg.bounds.size.height) / _fRate, makeView.nRotation];
            product.image_url = url;
            product.detail = detail;
            product.original_width = [NSNumber numberWithFloat:width];
            product.original_height = [NSNumber numberWithFloat:height];
        }
        [array addObject:product];
    }
    
    return array;
}

//素材地址
- (NSMutableArray *)getSrcDecoListArr
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < _allImages.count; i++) {
        CanCancelImageView *cancel = _allImages[i];
        NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(cancel.center.x - cancel.bounds.size.width / 2 + cancel.contentImg.center.x - cancel.contentImg.bounds.size.width / 2) / _fRate, (cancel.center.y - cancel.bounds.size.height / 2 + cancel.contentImg.center.y - cancel.contentImg.bounds.size.height / 2) / _fRate, (cancel.contentImg.bounds.size.width) / _fRate, (cancel.contentImg.bounds.size.height) / _fRate, cancel.nRotation];
        ProductImagePath *product = [[ProductImagePath alloc] init];
        product.image_url = cancel.imgPath;
        product.detail = str;
        [array addObject:product];
    }
    
    return array;
}

//输入文本
- (NSMutableArray *)getSrcTxtLists
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < _allFields.count; i++) {
        UILabel *label = _allFields[i];
        NSArray *word_coor = _recordTemplate.detail_content.word_coor;
        WordCoorInfo *coorInfo = word_coor[label.tag - 1];
        NSString *voice_flag = coorInfo.voice_flag.stringValue;
        NSString *voiceUrl = @"";
        if ([voice_flag integerValue] == 1) {
            voiceUrl = [_voiceUrlArray objectAtIndex:[label tag] - 1];
        }
        NSString *tip = (([label.text length] > 0) && ![label.text isEqualToString:LABEL_TIP]) ? label.text : @"";
        
        ProductImageInput *input = [[ProductImageInput alloc] init];
        input.txt = tip;
        input.voice = voiceUrl;
        [array addObject:input];
    }
    
    return array;
}

//自定义文本
- (NSMutableArray *)getDecoTxtListArr
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < _customTextViews.count; i++) {
        MyCustomTextView *cancel = _customTextViews[i];
        NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(cancel.center.x - cancel.bounds.size.width / 2 + cancel.contentImg.center.x - cancel.contentImg.bounds.size.width / 2) / _fRate, (cancel.center.y - cancel.bounds.size.height / 2 + cancel.contentImg.center.y - cancel.contentImg.bounds.size.height / 2) / _fRate, (cancel.contentImg.bounds.size.width) / _fRate, (cancel.contentImg.bounds.size.height) / _fRate, cancel.nRotation];
        ProductImageDecotext *decoTxt = [[ProductImageDecotext alloc] init];
        decoTxt.txt = cancel.textStr ?: @"";
        decoTxt.detail = str;
        decoTxt.color = cancel.colorStr;
        decoTxt.font = cancel.font_key;
        decoTxt.alpha = [NSNumber numberWithFloat:cancel.alphaColor];;
        [array addObject:decoTxt];
    }
    
    return array;
}

#pragma mark - MakeViewDelegate
- (void)touchMakeView:(MakeView *)makeView
{
    if (_touchView == makeView) {
        return;
    }
    
    NSInteger index = [_allMakeViews indexOfObject:makeView];
    //数据源
    if ([_recordTemplate.production_parameter.src_gallery_list count] > index) {
        NSMutableArray *subArr = [_recordTemplate.production_parameter.src_gallery_list objectAtIndex:index];
        self.galleryService.gallerys = subArr;
    }
    else{
        self.galleryService.gallerys = nil;
    }
    if ([_localArr count] > index) {
        NSMutableArray *subArr = [_localArr objectAtIndex:index];
        self.galleryService.photos = subArr;
    }
    else{
        self.galleryService.photos = nil;
    }
    
    if ([self.galleryService.gallerys count] == 0 && [self.galleryService.photos count] == 0) {
        [self scaleToFatherType:kBackMakeBlank At:index];
        return;
    }
    
    CGFloat temOri = _recordTemplate.original_width.floatValue /_recordTemplate.image_width.floatValue;
    CGFloat unilateralRatio = sqrt(2);
    self.galleryService.minWei = (makeView.bounds.size.width / _fRate) * temOri / unilateralRatio;
    self.galleryService.minHei = (makeView.bounds.size.height / _fRate) * temOri / unilateralRatio;
    
    [self hideAllCancelButs];
    
    //前置边框
    CGRect newRect = CGRectMake(makeView.frame.origin.x - 10, makeView.frame.origin.y - 10, makeView.frame.size.width + 20, makeView.frame.size.height + 20);
    CGPoint offset = CGPointZero;
    CGFloat rightOff = newRect.origin.x + newRect.size.width - _targetImg.bounds.size.width;
    CGFloat bottomOff = newRect.origin.y + newRect.size.height - _targetImg.bounds.size.height;
    if (rightOff > 0) {
        offset.x -= rightOff;
    }
    if (bottomOff > 0) {
        offset.y -= bottomOff;
    }
    DragMakeView *preView = [[DragMakeView alloc] initWithFrame:newRect Off:offset];
    preView.delegate = makeView;
    preView.tag = makeView.tag + 90;
    [_targetImg addSubview:preView];
    
    self.galleryService.coverIdx = makeView.checkIdx;
    if (_touchView) {
        //前面有选中
        DragMakeView *preView = [_targetImg viewWithTag:_touchView.tag + 90];
        [preView removeFromSuperview];

        _touchView = makeView;
        [_galleryCollectionView reloadData];
    }
    else{
        _touchView = makeView;

        //禁止触摸
        for (CanCancelImageView *cancelImg in _allImages) {
            cancelImg.userInteractionEnabled = NO;
        }
        for (UILabel *label in _allFields) {
            label.userInteractionEnabled = NO;
        }
        
        //animation
        if (![self.galleryCollectionView isDescendantOfView:self.view]) {
            [self.view addSubview:self.galleryCollectionView];
        }
        
        self.view.window.userInteractionEnabled = NO;
        [_galleryCollectionView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 140)];
        [_galleryCollectionView reloadData];
        __weak typeof(self)weakSelf = self;
        CGFloat scale = _newRate / _fRate;
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf.bottomView setFrameY:SCREEN_HEIGHT];
            [weakSelf.galleryCollectionView setFrameY:SCREEN_HEIGHT - 140];
            weakSelf.targetImg.transform = CGAffineTransformMakeScale(scale,scale);
            [weakSelf.targetImg setCenter:CGPointMake(weakSelf.view.center.x, 44 + (SCREEN_HEIGHT - 140 - 44) / 2)];
        } completion:^(BOOL finished) {
            weakSelf.view.window.userInteractionEnabled = YES;
        }];
    }
}

- (void)hiddPreView:(UIView *)preView Make:(MakeView *)makeView
{
    [self dismissPopUpView];
}

#pragma mark - CanCancelImageViewDelegate
- (void)CancelImageView:(CanCancelImageView *)imageView
{
    [imageView removeFromSuperview];
    if ([imageView isKindOfClass:[MyCustomTextView class]]) {
        [_customTextViews removeObject:imageView];
    }
    else{
        [_allImages removeObject:imageView];
    }
    
}

- (void)checkCancelImgView:(CanCancelImageView *)imageView
{
    [self hideAllCancelButs];
}

- (void)touchUpinsideImgView:(CanCancelImageView *)imageView
{
    [[imageView superview] bringSubviewToFront:imageView];
    [self hideOtherCancelButsOff:imageView];
}

- (void)editDecoTxtContent:(CanCancelImageView *)imageView
{
    _cusEditView = (MyCustomTextView *)imageView;
    self.navigationController.navigationBarHidden = YES;
    self.addTextController.delegate = self;
    _addTextController.textStr = [_cusEditView.textStr stringByReplacingOccurrencesOfString:Seperate_RowStr withString:@""];
    _addTextController.alpha = _cusEditView.alphaColor;
    _addTextController.color = _cusEditView.colorStr;
    _addTextController.font_key = _cusEditView.font_key;
    [self.view addSubview:_addTextController.view];
    [self addChildViewController:_addTextController];
}

#pragma mark - BatchDetailGalleryServiceDelegate
- (void)didSelectGalleryAt:(NSIndexPath *)indexPath
{
    _touchView.checkIdx = indexPath.item;
    [_touchView resetImageView:nil];
    if (indexPath.item < [self.galleryService.gallerys count]) {
        ProductImageGallery *gallery = [self.galleryService.gallerys objectAtIndex:indexPath.item];
        [self downLoadWithGallery:gallery Make:_touchView First:NO];
    }
    else{
        NSInteger index = indexPath.item - [self.galleryService.gallerys count];
        PhotoManagerModel *photo = [self.galleryService.photos objectAtIndex:index];
        [self downLoadWithPhoto:photo Make:_touchView First:NO];
    }
}

- (void)cancelCoverImg
{
    [_touchView resetImageView:nil];
    _touchView.checkIdx = -1;
}

- (void)resetGalleryCoverAt:(NSInteger)idx
{
    _touchView.checkIdx = idx;
}

- (void)addNewGallerySource
{
    NSInteger index = [_allMakeViews indexOfObject:_touchView];
    [self scaleToFatherType:kBackMakeAddPicture At:index];
}

#pragma mark - BatchDetailMatterServiceDelegate
- (void)didSelectItem:(NSIndexPath *)indexPath Img:(UIImage *)img Deco:(DecorateModel *)deco
{
    [self hideAllCancelButs];
    
    CGFloat maxScale = _recordTemplate.image_width.floatValue / _recordTemplate.original_width.floatValue * _fRate;
    CGSize imgSize = img.size;
    imgSize = CGSizeMake(imgSize.width * maxScale, imgSize.height * maxScale);
    CGFloat wei = MAX(imgSize.width, MIN_WEIGHT + 20);
    CGFloat hei = wei * imgSize.height / imgSize.width;
    if (hei < MIN_HEIGHT + 20) {
        hei = MIN_HEIGHT + 20;
        wei = hei * imgSize.width / imgSize.height;
    }
    NSString *url = deco.image_url;
    
    CanCancelImageView *imageView = [[CanCancelImageView alloc] initWithFrame:CGRectMake((_targetImg.bounds.size.width - wei) / 2, (_targetImg.bounds.size.height - hei) / 2, wei, hei)];
    imageView.delegate = self;
    NSLog(@"------%@",NSStringFromCGRect(_targetImg.bounds));
    [imageView.contentImg setImage:img];
    [imageView setBackgroundColor:[UIColor clearColor]];
    imageView.imgPath = url;
    [_targetImg addSubview:imageView];
    [_allImages addObject:imageView];
}

#pragma mark - AddTextViewControllerDelegate
- (void)addTextFinish:(AddTextViewController *)add Arr:(NSArray *)rows
{
    if (_addTextController.textStr.length > 0) {
        NSString *font_key = _addTextController.font_key ?: @"";
        UIFont *font = [NSString customFontWithPath:[APPDocumentsDirectory stringByAppendingPathComponent:[font_key stringByAppendingString:@".ttf"]] size:12];
        UIImage *tmpImg = [self imageFromText:rows withFont:font Color:_addTextController.color Alpha:_addTextController.alpha];
        CGFloat wei = tmpImg.size.width + 25,hei = tmpImg.size.height + 25;
        CGRect rect = CGRectMake((_targetImg.bounds.size.width - wei) / 2, 40, wei, hei);
        MyCustomTextView *imageView = [[MyCustomTextView alloc] initWithFrame:rect];
        imageView.delegate = self;
        imageView.colorStr = _addTextController.color;
        imageView.alphaColor = _addTextController.alpha;
        imageView.font_key = font_key;
        NSString *textStr = [rows componentsJoinedByString:Seperate_RowStr];;
        imageView.textStr = textStr;
        
        [imageView.contentImg setImage:tmpImg];
        [_targetImg addSubview:imageView];
        [_customTextViews addObject:imageView];

    }
    if (_cusEditView) {
        [_cusEditView removeFromSuperview];
        [_customTextViews removeObject:_cusEditView];
        _cusEditView = nil;
    }
    
    self.navigationController.navigationBarHidden = NO;
    [_addTextController.view removeFromSuperview];
    [_addTextController removeFromParentViewController];
    _addTextController = nil;
    
    UIButton *preBut = (UIButton *)[_bottomView viewWithTag:2];
    preBut.selected = NO;
    _switchIdx = -1;
}

#pragma mark - 状态栏隐藏与样式
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar cnSetBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_initIdx >= 0 && _initIdx < [_allMakeViews count]) {
        [self touchMakeView:_allMakeViews[_initIdx]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _initIdx = NSNotFound;
    [self.navigationController.navigationBar cnReset];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //屏蔽触摸
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_targetImg];
    if (_targetImg.userInteractionEnabled) {
        if (_touchView) {
            DragMakeView *preView = [_targetImg viewWithTag:_touchView.tag + 90];
            if (preView && CGRectContainsPoint(preView.frame, point)) {
                return;
            }
        }
        
        for (MakeView *subMake in _allMakeViews) {
            if (CGRectContainsPoint(subMake.frame, point)) {
                return;
            }
        }
    }
    
    if (_switchIdx >= 0) {
        UIButton *preBut = (UIButton *)[_bottomView viewWithTag:_switchIdx + 1];
        preBut.selected = NO;
        _switchIdx = -1;
    }
    
    //触摸在素材之上
    BOOL hasFoundImg = NO;
    for (CanCancelImageView *subView in _allImages) {
        if (CGRectContainsPoint(subView.frame, point)) {
            hasFoundImg = YES;
            break;
        }
    }
    if (!hasFoundImg) {
        for (MyCustomTextView *textView in _customTextViews) {
            if (CGRectContainsPoint(textView.frame, point)) {
                hasFoundImg = YES;
                break;
            }
        }
    }
    if (!hasFoundImg) {
        [self hideAllCancelButs];
    }
    
    [self dismissPopUpView];
}

- (void)dismissPopUpView
{
    BOOL gallery = (_galleryCollectionView && [_galleryCollectionView isDescendantOfView:self.view]);
    BOOL mattery = (_matteryCollectionView && [_matteryCollectionView isDescendantOfView:self.view]);
    if (gallery || mattery) {
        __weak typeof(self)weakSelf = self;
        weakSelf.view.window.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            if (gallery) {
                [weakSelf.galleryCollectionView setFrameY:SCREEN_HEIGHT];
            }
            if (mattery) {
                [weakSelf.matteryCollectionView setFrameY:SCREEN_HEIGHT];
            }
            [weakSelf.bottomView setFrameY:SCREEN_HEIGHT - weakSelf.bottomView.frameHeight];
            weakSelf.targetImg.transform = CGAffineTransformMakeScale(1,1);
            [weakSelf.targetImg setCenter:CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y)];
        } completion:^(BOOL finished) {
            if (gallery) {
                [weakSelf.galleryCollectionView removeFromSuperview];
            }
            if (mattery) {
                [weakSelf.matteryCollectionView removeFromSuperview];
            }
            if (weakSelf.touchView) {
                UIView *preView = [weakSelf.targetImg viewWithTag:weakSelf.touchView.tag + 90];
                [preView removeFromSuperview];
                weakSelf.touchView = nil;
            }

            weakSelf.view.window.userInteractionEnabled = YES;
            weakSelf.targetImg.userInteractionEnabled = YES;
            //可以触摸
            for (CanCancelImageView *cancelImg in weakSelf.allImages) {
                cancelImg.userInteractionEnabled = YES;
            }
            for (UILabel *label in weakSelf.allFields) {
                label.userInteractionEnabled = YES;
            }
        }];
    }
}

#pragma mark - lazy load
- (UIImageView *)targetImg
{
    if (!_targetImg) {
        _targetImg = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - _templateSize.width) / 2, (SCREEN_HEIGHT - _templateSize.height) / 2, _templateSize.width, _templateSize.height)];
        _targetImg.clipsToBounds = YES;
        [_targetImg setUserInteractionEnabled:YES];
        [_targetImg setBackgroundColor:self.view.backgroundColor];
    }
    
    return _targetImg;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 49.0, SCREEN_WIDTH, 49.0)];
        [_bottomView setBackgroundColor:[UIColor whiteColor]];
        
        //line
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.frameWidth, 1)];
        [lineView setBackgroundColor:self.view.backgroundColor];
        [_bottomView addSubview:lineView];
        
        //buttons
        UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
        NSInteger numsPerRow = ([detailInfo.isDealer integerValue] == 1) ? 3 : 2;
        CGFloat itemWei = 30.0, margin = (_bottomView.frameWidth - itemWei * numsPerRow) / numsPerRow;
        NSArray *imgsN = @[@"makeMaterialN",@"makeFontN",@"makeSyncN"],*imgsH = @[@"makeMaterialH",@"makeFontH",@"makeSyncH"],*txts = @[@"素材",@"文字",@"同步"];;
        for (NSInteger i = 0; i < numsPerRow; i++) {
            VerticalButton *vertical = [VerticalButton buttonWithType:UIButtonTypeCustom];
            vertical.imgSize = CGSizeMake(20, 20);
            vertical.textSize = CGSizeMake(30, 15);
            vertical.margin = 2;
            [vertical setFrame:CGRectMake(margin / 2 + (itemWei + margin) * i, 6, itemWei, 37)];
            [vertical setBackgroundColor:_bottomView.backgroundColor];
            [vertical setImage:CREATE_IMG(imgsN[i]) forState:UIControlStateNormal];
            [vertical setTitle:txts[i] forState:UIControlStateNormal];
            if (i == 2) {
                [vertical setTitleColor:BASELINE_COLOR forState:UIControlStateHighlighted];
                [vertical setImage:CREATE_IMG(imgsH[i]) forState:UIControlStateHighlighted];
            }
            else{
                [vertical setTitleColor:BASELINE_COLOR forState:UIControlStateSelected];
                [vertical setImage:CREATE_IMG(imgsH[i]) forState:UIControlStateSelected];
            }
            
            [vertical setTitleColor:rgba(153, 153, 153, 1) forState:UIControlStateNormal];
            [vertical setTag:i + 1];
            vertical.selected = (i == _switchIdx);
            [vertical.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [vertical.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [vertical addTarget:self action:@selector(switchItem:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:vertical];
        }
    }
    return _bottomView;
}

- (BatchDetailMatterService *)matterService
{
    if (!_matterService) {
        _matterService = [[BatchDetailMatterService alloc] init];
        _matterService.delegate = self;
    }
    return _matterService;
}

- (BatchDetailGalleryService *)galleryService
{
    if (!_galleryService) {
        _galleryService = [[BatchDetailGalleryService alloc] init];
        _galleryService.delegate = self;
    }
    return _galleryService;
}

- (UICollectionView *)galleryCollectionView
{
    if (!_galleryCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(70, 90);
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 15;
        _galleryCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [_galleryCollectionView setContentInset:UIEdgeInsetsMake(25, 15, 25, 15)];
        [_galleryCollectionView setBackgroundColor:[UIColor whiteColor]];
        _galleryCollectionView.showsHorizontalScrollIndicator = YES;
        _galleryCollectionView.showsVerticalScrollIndicator = NO;
        _galleryCollectionView.dataSource = self.galleryService;
        _galleryCollectionView.delegate = self.galleryService;
        [_galleryCollectionView registerClass:[CheckCoverCell class] forCellWithReuseIdentifier:GalleryCellId];
        [_galleryCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:GalleryAddCellId];
    }
    return _galleryCollectionView;
}

- (UICollectionView *)matteryCollectionView
{
    if (!_matteryCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(31, 31);
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 15;
        layout.sectionInset = UIEdgeInsetsMake(30, 15, 30, 15);
        _matteryCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _matteryCollectionView.showsHorizontalScrollIndicator = YES;
        _matteryCollectionView.showsVerticalScrollIndicator = NO;
        [_matteryCollectionView setBackgroundColor:[UIColor whiteColor]];
        _matteryCollectionView.dataSource = self.matterService;
        _matteryCollectionView.delegate = self.matterService;
        [_matteryCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:MatterCellId];
    }
    
    return _matteryCollectionView;
}

- (AddTextViewController *)addTextController
{
    if (!_addTextController) {
        _addTextController = [[AddTextViewController alloc] init];
        _addTextController.maxWei = _targetImg.bounds.size.width * 0.9;
    }
    return _addTextController;
}

@end
