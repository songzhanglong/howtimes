//
//  FastMakeCell.m
//  TYSociety
//
//  Created by szl on 16/7/14.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "FastMakeCell.h"
#import "PhotoManagerModel.h"
#import "Masonry.h"
#import "UIImage+FixOrientation.h"
#import "Toast+UIView.h"
#import "UIImage+Caption.h"
#import "UAProgressView.h"
#import "UIImage+Caption.h"

@implementation FastMakeCell
{
    UIButton *_leftBtn;
    UILabel *_progressLab;
    UAProgressView *_loadingIndicator;
}

- (void)dealloc
{
    if (_managerPhoto) {
        [_managerPhoto removeObserver:self forKeyPath:@"progress"];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentImg = [[UIImageView alloc] init];
        [_contentImg setContentMode:UIViewContentModeScaleAspectFill];
        _contentImg.clipsToBounds = YES;
        [_contentImg setUserInteractionEnabled:YES];
        [_contentImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentImg:)]];
        [_contentImg setBackgroundColor:rgba(220, 220, 221, 1)];
        [_contentImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_contentImg];
        [_contentImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setUserInteractionEnabled:NO];
        [_leftBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_leftBtn setImage:CREATE_IMG(@"fastImage") forState:UIControlStateNormal];
        [_leftBtn setImage:CREATE_IMG(@"fastVideo") forState:UIControlStateSelected];
        [self.contentView addSubview:_leftBtn];
        [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.bottom.equalTo(@(-2));
            make.width.equalTo(@(12));
            make.height.equalTo(@(10));
        }];
        
        _coverView = [[UIView alloc] init];
        [_coverView setUserInteractionEnabled:NO];
        [_coverView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_coverView setBackgroundColor:rgba(0, 0, 0, 0.3)];
        [self.contentView addSubview:_coverView];
        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        _checkImg = [[UIImageView alloc] init];
        [_checkImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_checkImg setImage:CREATE_IMG(@"fastChecked")];
        [_checkImg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_checkImg];
        [_checkImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.equalTo(@(24));
            make.height.equalTo(@(24));
        }];
        
        _waitImg = [[UIImageView alloc] init];
        [_waitImg setBackgroundColor:[UIColor clearColor]];
        [_waitImg setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_waitImg setImage:CREATE_IMG(@"waitForUpload")];
        [_coverView addSubview:_waitImg];
        [_waitImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_coverView.mas_centerX);
            make.centerY.equalTo(_coverView.mas_centerY);
            make.width.equalTo(@(24));
            make.height.equalTo(@(24));
        }];
        
        _qualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_qualityBtn setUserInteractionEnabled:NO];
        [_qualityBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_qualityBtn setImage:CREATE_IMG(@"normalQuality") forState:UIControlStateNormal];
        [_qualityBtn setImage:CREATE_IMG(@"hignQuality") forState:UIControlStateSelected];
        [self.contentView addSubview:_qualityBtn];
        [_qualityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.top.equalTo(@(0));
            make.width.equalTo(@(16));
            make.height.equalTo(@(27));
        }];
        
        _loadingIndicator = [[UAProgressView alloc] init];
        _loadingIndicator.tintColor = [UIColor whiteColor];
        [_loadingIndicator setBackgroundColor:[UIColor clearColor]];
        [_loadingIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_coverView addSubview:_loadingIndicator];
        [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_coverView.mas_centerX);
            make.centerY.equalTo(_coverView.mas_centerY);
            make.width.equalTo(@(24));
            make.height.equalTo(@(24));
        }];
        
        _progressLab = [[UILabel alloc] init];
        [_progressLab setBackgroundColor:[UIColor clearColor]];
        [_progressLab setFont:[UIFont systemFontOfSize:7]];
        [_progressLab setTextAlignment:NSTextAlignmentCenter];
        [_progressLab setTextColor:[UIColor whiteColor]];
        [_progressLab setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_coverView addSubview:_progressLab];
        [_progressLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_coverView.mas_centerX);
            make.centerY.equalTo(_coverView.mas_centerY);
            make.height.equalTo(@(11));
            make.width.equalTo(@(24));
        }];
    }
    return self;
}

#pragma mark - actions
- (void)tapContentImg:(UITapGestureRecognizer *)tapGestureRecognizer
{
    BOOL canCheck = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(checkItemOf:Check:)]) {
        canCheck = [_delegate checkItemOf:self Check:!_checkImg.hidden];
    }
    if (canCheck) {
        _checkImg.hidden = !_checkImg.hidden;
        //界面调整
    }
}

#pragma mark - reset
- (void)resetPhotoData:(PhotoManagerModel *)data
{
    if (_managerPhoto) {
        [_managerPhoto removeObserver:self forKeyPath:@"progress"];
    }
    self.managerPhoto = data;
    [data addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    _leftBtn.selected = (data.file_type.integerValue != 1);
    [_contentImg setImage:nil];
    
    NSString *md5Str = [NSString md5:data.file_client_path];
    NSString *lastPath = [[NSString getCachePath:@"thumbnail"] stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:lastPath]) {
        [_contentImg setImage:[UIImage imageWithContentsOfFile:lastPath]];
    }
    else if (data.path.length > 0){
        BOOL isVideo = (data.file_type.integerValue == 2);
        if (isVideo) {
            if ([data.picture length] > 0) {
                //有封面
                NSString *path = data.picture;
                if (![path hasPrefix:@"http"]) {
                    path = [G_IMAGE_ADDRESS stringByAppendingString:path];
                }
                [_contentImg sd_setImageWithURL:[NSURL URLWithString:path]];
            }
            else{
                //无封面
                NSString *path = data.path;
                if (![path hasPrefix:@"http"]) {
                    path = [G_IMAGE_ADDRESS stringByAppendingString:path];
                }
                __weak typeof(self)weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:path] atTime:1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.contentImg setImage:image];
                    });
                });
            }
        }
        else{
            NSString *path = data.path;
            if (![path hasPrefix:@"http"]) {
                path = [G_IMAGE_ADDRESS stringByAppendingString:path];
            }
            path = [NSString getPictureAddress:@"2" width:@"160" height:@"0" original:path];
            [_contentImg sd_setImageWithURL:[NSURL URLWithString:path]];
        }
        
    }
    
    if (data.path.length > 0) {
        _coverView.hidden = YES;
    }
    else{
        _coverView.hidden = NO;
        
        _waitImg.hidden = (data.uploadState != kPhotoUploadWait);
        _progressLab.hidden = (data.uploadState != kPhotoUploading);
        _loadingIndicator.hidden = _progressLab.hidden;
        if (!_progressLab.hidden) {
            [_loadingIndicator setProgress:data.progress];
            [_progressLab setText:[NSString stringWithFormat:@"%.0f%%",data.progress * 100]];
        }
    }
    
    //标志
    if (_managerPhoto.file_type.integerValue == 1)
    {
        CGSize size = CGSizeZero;
        if (_delegate && [_delegate respondsToSelector:@selector(minImageSizeByMakeView)]) {
            size = [_delegate minImageSizeByMakeView];
        }
        [self resetImgShowQuality:size];
    }
    else{
        _qualityBtn.hidden = YES;
    }
     
}

- (void)resetImgShowQuality:(CGSize)size
{
    if (_managerPhoto.file_type.integerValue == 1) {
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            _qualityBtn.hidden = YES;
        }
        else{
            if ((_managerPhoto.width.floatValue >= size.width) && (_managerPhoto.height.floatValue >= size.height)) {
                _qualityBtn.hidden = NO;
                CGFloat unilateralRatio = sqrt(2);
                _qualityBtn.selected = ((_managerPhoto.width.floatValue >= size.width * unilateralRatio) && (_managerPhoto.height.floatValue >= size.height * unilateralRatio));
            }
            else{
                _qualityBtn.hidden = YES;
            }
        }
    }
    else{
        _qualityBtn.hidden = YES;
    }
}

#pragma mark - 观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:@"progress"]) {
        NSLog(@"%f",_managerPhoto.progress);
        _waitImg.hidden = YES;
        _loadingIndicator.hidden = NO;
        _progressLab.hidden = NO;
        [_loadingIndicator setProgress:_managerPhoto.progress];
        [_progressLab setText:[NSString stringWithFormat:@"%.0f%%",_managerPhoto.progress * 100]];
//        [_progressLab setHidden:(_managerPhoto.progress == 1)];
//        _loadingIndicator.hidden = _progressLab.hidden;
    }
}

#pragma mark - state
- (void)changeUploadState
{
    if (_managerPhoto.uploadState == kPhotoUploadWait) {
        _coverView.hidden = NO;
        _waitImg.hidden = NO;
        _loadingIndicator.hidden = YES;
        _progressLab.hidden = YES;
    }
    else if (_managerPhoto.uploadState == kPhotoUploading) {
        _coverView.hidden = NO;
        _waitImg.hidden = YES;
        _loadingIndicator.hidden = NO;
        _progressLab.hidden = NO;
        [_loadingIndicator setProgress:_managerPhoto.progress];
        [_progressLab setText:[NSString stringWithFormat:@"%.0f%%",_managerPhoto.progress * 100]];
    }
    else{
        _waitImg.hidden = YES;
        _loadingIndicator.hidden = YES;
        _progressLab.hidden = YES;
        _coverView.hidden = (_managerPhoto.uploadState == kPhotoUploadSuc);
    }
}

- (void)photoUplodFinish
{
    _waitImg.hidden = YES;
    _loadingIndicator.hidden = YES;
    _progressLab.hidden = YES;
    _coverView.hidden = (_managerPhoto.uploadState == kPhotoUploadSuc);
}

@end
