//
//  BatchDetailGalleryService.m
//  TYSociety
//
//  Created by szl on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BatchDetailGalleryService.h"
#import "PhotoManagerModel.h"
#import "TimeRecordInfo.h"
#import "Masonry.h"
#import "UIImage+Caption.h"

@implementation BatchDetailGalleryService

#pragma mark - CheckCoverCellDelegate
- (void)deleteCoverCell:(UICollectionViewCell *)cell
{
    UICollectionView *collectionView = [GlobalManager findViewFrom:cell To:[UICollectionView class]];
    if (collectionView) {
        
        BOOL changeLstSec = ([_gallerys count] + [_photos count] == 9);
        //删除数据
        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
        if (indexPath.item < [_gallerys count]) {
            [_gallerys removeObjectAtIndex:indexPath.item];
        }
        else{
            NSInteger index = indexPath.item - [_gallerys count];
            [_photos removeObjectAtIndex:index];
        }
        
        //表格刷新
        if (indexPath.item > _coverIdx) {
            //不用处理
            if (changeLstSec) {
                [collectionView reloadData];
            }
            else{
                [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
        }
        else if (indexPath.item == _coverIdx)
        {
            //另找封面，取第一个不是视屏的作为封面
            NSInteger newIdx = -1;
            for (NSInteger i = 0; i < [_gallerys count]; i++) {
                ProductImageGallery *gallery = [_gallerys objectAtIndex:i];
                if (gallery.type.integerValue == 1) {
                    if (gallery.original_width.floatValue >= _minWei && gallery.original_height.floatValue >= _minHei) {
                        newIdx = i;
                        break;
                    }
                }
            }
            //本地查找
            if (newIdx == -1) {
                for (NSInteger i = 0; i < [_photos count]; i++) {
                    PhotoManagerModel *photo = [_photos objectAtIndex:i];
                    if (photo.file_type.integerValue == 1) {
                        if (photo.width.floatValue >= _minWei && photo.height.floatValue >= _minHei) {
                            newIdx = i + [_gallerys count];
                            break;
                        }
                    }
                }
            }
            
            _coverIdx = newIdx;
            if (newIdx == -1) {
                if (changeLstSec) {
                    [collectionView reloadData];
                }
                else{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }
                
                if (_delegate && [_delegate respondsToSelector:@selector(cancelCoverImg)]) {
                    [_delegate cancelCoverImg];
                }
            }
            else{
                [collectionView reloadData];
                if (_delegate && [_delegate respondsToSelector:@selector(didSelectGalleryAt:)]) {
                    [_delegate didSelectGalleryAt:[NSIndexPath indexPathForRow:newIdx inSection:0]];
                }
            }
        }
        else{
            _coverIdx--;
            if (changeLstSec) {
                [collectionView reloadData];
            }
            else{
                [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(resetGalleryCoverAt:)]) {
                [_delegate resetGalleryCoverAt:_coverIdx];
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [_gallerys count] + [_photos count];
    if (section == 0) {
        return count;
    }
    return (count >= 9) ? 0 : 1 ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UICollectionViewCell *twoCell = [collectionView dequeueReusableCellWithReuseIdentifier:GalleryAddCellId forIndexPath:indexPath];
        UIImageView *addImg = (UIImageView *)[twoCell.contentView viewWithTag:1];
        if (!addImg) {
            addImg = [[UIImageView alloc] init];
            [addImg setTranslatesAutoresizingMaskIntoConstraints:NO];
            [addImg setTag:1];
            [addImg setImage:CREATE_IMG(@"galleryAdd")];
            [twoCell.contentView addSubview:addImg];
            [addImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(twoCell.contentView.mas_centerX);
                make.centerY.equalTo(twoCell.contentView.mas_centerY);
                make.width.equalTo(@(36));
                make.height.equalTo(@(36));
            }];
        }
        return twoCell;
    }
    CheckCoverCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GalleryCellId forIndexPath:indexPath];
    cell.delegate = self;
    
    NSString *path = nil,*picture = nil;
    NSInteger fileType = 0;
    CGFloat itemWei,itemHei;
    cell.preImg.hidden = (indexPath.item != _coverIdx);
    if (indexPath.item < [_gallerys count]) {
        //网络获取
        ProductImageGallery *gallery = [_gallerys objectAtIndex:indexPath.item];
        fileType = gallery.type.integerValue;
        
        path = gallery.path;
        picture = gallery.picture;
        itemWei = gallery.original_width.floatValue;
        itemHei = gallery.original_height.floatValue;
        [self setImageBy:fileType Path:path Picture:picture Cell:cell];
    }
    else{
        //本地资源
        NSInteger index = indexPath.item - [_gallerys count];
        PhotoManagerModel *photo = [_photos objectAtIndex:index];
        fileType = photo.file_type.integerValue;
        itemWei = photo.width.floatValue;
        itemHei = photo.height.floatValue;

        NSString *md5Str = [NSString md5:photo.file_client_path];
        NSString *lastPath = [[NSString getCachePath:@"thumbnail"] stringByAppendingPathComponent:[md5Str stringByAppendingString:@".png"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:lastPath]) {
            [cell.coverImg setImage:[UIImage imageWithContentsOfFile:lastPath]];
        }
        else if (photo.path.length > 0){
            path = photo.path;
            picture = photo.picture;
            [self setImageBy:fileType Path:path Picture:picture Cell:cell];
        }
        else{
            [cell.coverImg setImage:nil];
        }
    }
    
    [self resetQualitnBtnShow:fileType Width:itemWei Height:itemHei Cell:cell];
    
    NSString * leftTip = (fileType == 1) ? @"fastImage" : @"fastVideo";
    [cell.leftImg setImage:CREATE_IMG(leftTip)];
    
    return cell;
}

- (void)resetQualitnBtnShow:(NSInteger)type Width:(CGFloat)width Height:(CGFloat)height Cell:(CheckCoverCell *)cell
{
    if (type == 1) {
        if (width < _minWei || height < _minHei) {
            cell.qualityBtn.hidden = YES;
        }
        else{
            cell.qualityBtn.hidden = NO;
            CGFloat unilateralRatio = sqrt(2);
            cell.qualityBtn.selected = ((width >= _minWei * unilateralRatio) && (height >= _minHei * unilateralRatio));
        }
    }
    else{
        cell.qualityBtn.hidden = YES;
    }
}

- (void)setImageBy:(NSInteger)type Path:(NSString *)pathStr Picture:(NSString *)picture Cell:(CheckCoverCell *)cell
{
    if (type == 1) {
        NSString *path = pathStr;
        if (![path hasPrefix:@"http"]) {
            path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
        }
        path = [NSString getPictureAddress:@"2" width:@"240" height:@"0" original:path];
        [cell.coverImg sd_setImageWithURL:[NSURL URLWithString:path]];
    }
    else{
        if (picture.length > 0) {
            //有封面
            NSString *path = picture;
            if (![path hasPrefix:@"http"]) {
                path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
            }
            [cell.coverImg sd_setImageWithURL:[NSURL URLWithString:path]];
        }
        else{
            //无封面
            NSString *path = pathStr;
            if (![path hasPrefix:@"http"]) {
                path = [G_IMAGE_ADDRESS stringByAppendingString:path];
            }
            __weak typeof(cell)weakSelf = cell;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:path] atTime:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.coverImg setImage:image];
                });
            });
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (_delegate && [_delegate respondsToSelector:@selector(addNewGallerySource)]) {
            [_delegate addNewGallerySource];
        }
        return;
    }
    
    if (_coverIdx == indexPath.item) {
        return;
    }
    CheckCoverCell *cell = (CheckCoverCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.coverImg.image) {
        BOOL isVideo = NO;
        if (indexPath.item < [_gallerys count]) {
            ProductImageGallery *gallery = [_gallerys objectAtIndex:indexPath.item];
            isVideo = (gallery.type.integerValue == 2);
            if (!isVideo) {
                if (gallery.original_width.floatValue < _minWei || gallery.original_height.floatValue < _minHei) {
                    [APPWindow makeToast:@"您选择的图片分辨率过低，不适合作为打印封面" duration:1.0 position:@"center"];
                    return;
                }
            }
        }
        else{
            NSInteger index = indexPath.item - [_gallerys count];
            PhotoManagerModel *photo = [_photos objectAtIndex:index];
            isVideo = (photo.file_type.integerValue == 2);
            if (!isVideo) {
                if (photo.width.floatValue < _minWei || photo.height.floatValue < _minHei) {
                    [APPWindow makeToast:@"您选择的图片分辨率过低，不适合作为打印封面" duration:1.0 position:@"center"];
                    return;
                }
            }
        }
        
        if (isVideo) {
            [APPWindow makeToast:@"视频不可以作为封面" duration:1.0 position:@"center"];
        }
        else{
            NSInteger preIdx = _coverIdx;
            _coverIdx = indexPath.item;
            NSMutableArray *array = [NSMutableArray arrayWithObject:indexPath];
            if (preIdx >= 0 && preIdx < [collectionView numberOfItemsInSection:0]) {
                [array addObject:[NSIndexPath indexPathForItem:preIdx inSection:indexPath.section]];
            }
            [collectionView reloadItemsAtIndexPaths:array];
            
            if (_delegate && [_delegate respondsToSelector:@selector(didSelectGalleryAt:)]) {
                [_delegate didSelectGalleryAt:indexPath];
            }
        }
        
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
}

- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 1;
}

@end
