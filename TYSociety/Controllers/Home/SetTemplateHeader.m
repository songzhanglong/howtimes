//
//  SetTemplateHeader.m
//  TYSociety
//
//  Created by zhangxs on 16/7/8.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SetTemplateHeader.h"
#import "GrowTemplateModel.h"

@implementation SetTemplateHeader

- (id)init
{
    self = [super init];
    if (self) {
        _recordIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    return self;
}

- (void)createCollectionViewTo:(UIView *)view{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //layout.itemSize = CGSizeMake(135, 95);
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(7.5, 10, 7.5, 0);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 137) collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SetHeaderCell"];
    [_collectionView setBackgroundColor:CreateColor(235, 233, 247)];
    [view addSubview:_collectionView];
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Theme *item;
    if (_is_double) {
        item = [_resource objectAtIndex:indexPath.item];
    }else {
        NSArray *array = [_resource objectAtIndex:indexPath.item];
        item = [array objectAtIndex:0];
    }
    
    CGFloat itemHei = [item.image_height floatValue];
    CGFloat scale = (_is_double ? 175.0 : 175.0 / 2) / [item.image_width floatValue];
    itemHei = itemHei * scale;
    CGFloat itemWei = 175.0;
    return CGSizeMake(itemWei, itemHei);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_resource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SetHeaderCell" forIndexPath:indexPath];
    if (_is_double) {
        UIImageView *_fmimgView = (UIImageView *)[cell.contentView viewWithTag:1];
        if (!_fmimgView) {
            _fmimgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frameWidth, cell.contentView.frameHeight)];
            [_fmimgView setTag:1];
            [_fmimgView setBackgroundColor:CreateColor(240, 239, 244)];
            [cell.contentView addSubview:_fmimgView];
        }
        Theme *fm_model = [_resource objectAtIndex:indexPath.item];
        NSString *fm_url = fm_model.image_thumb_url;
        if (![fm_url hasPrefix:@"http"]) {
            fm_url = [G_IMAGE_ADDRESS stringByAppendingString:fm_url ?: @""];
        }
        //NSString *width = [NSString stringWithFormat:@"%.0f",_fmimgView.frameWidth];
        //fm_url = [NSString getPictureAddress:@"2" width:width height:@"0" original:fm_url];
        //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fm_url]]];
        //_fmimgView.image = image;
        [_fmimgView sd_setImageWithURL:[NSURL URLWithString:fm_url]];
    }else {
        UIImageView *_fmimgView = (UIImageView *)[cell.contentView viewWithTag:1];
        if (!_fmimgView) {
            _fmimgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frameWidth / 2, cell.contentView.frameHeight)];
            [_fmimgView setTag:1];
            //_fmimgView.contentMode = UIViewContentModeScaleAspectFill;
            //_fmimgView.clipsToBounds = YES;
            [_fmimgView setBackgroundColor:[UIColor whiteColor]];
            [cell.contentView addSubview:_fmimgView];
        }
        NSArray *array = [_resource objectAtIndex:indexPath.item];
        Theme *fm_model = [array objectAtIndex:0];
        NSString *fm_url = fm_model.image_thumb_url;
        if (![fm_url hasPrefix:@"http"]) {
            fm_url = [G_IMAGE_ADDRESS stringByAppendingString:fm_url ?: @""];
        }
        [_fmimgView sd_setImageWithURL:[NSURL URLWithString:fm_url]];
        
        UIImageView *_fdimgView = (UIImageView *)[cell.contentView viewWithTag:2];
        if (!_fdimgView) {
            _fdimgView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frameWidth / 2, 0, cell.contentView.frameWidth / 2, cell.contentView.frameHeight)];
            [_fdimgView setTag:2];
            //_fdimgView.contentMode = UIViewContentModeScaleAspectFill;
            //_fdimgView.clipsToBounds = YES;
            [_fdimgView setBackgroundColor:[UIColor whiteColor]];
            [cell.contentView addSubview:_fdimgView];
        }
        Theme *fd_model = [array objectAtIndex:1];
        NSString *fd_url = fd_model.image_thumb_url;
        if (![fd_url hasPrefix:@"http"]) {
            fd_url = [G_IMAGE_ADDRESS stringByAppendingString:fd_url ?: @""];
        }
        [_fdimgView sd_setImageWithURL:[NSURL URLWithString:fd_url]];
    }
    
    UIView *view = (UIView *)[cell.contentView viewWithTag:3];
    if (!view) {
        view = [[UIView alloc] initWithFrame:cell.contentView.bounds];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.3;
        [view setTag:3];
        [cell.contentView addSubview:view];
    }
    if (_recordIndexPath && (_recordIndexPath.item == indexPath.item)) {
        view.hidden = YES;
    }else{
        view.hidden = NO;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item != _recordIndexPath.item) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:_recordIndexPath];
        UIView *view = (UIView *)[cell.contentView viewWithTag:3];
        if (view) {
            view.hidden = NO;
        }
    }else {
        if (_delegate && [_delegate respondsToSelector:@selector(lookPigTemplateHeadItem:)]) {
            [_delegate lookPigTemplateHeadItem:indexPath.item];
        }
        
        return;
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView *view = (UIView *)[cell.contentView viewWithTag:3];
    if (view) {
        view.hidden = YES;
    }
    _recordIndexPath = indexPath;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didTemplateHeadItem:)]) {
        [_delegate didTemplateHeadItem:indexPath.item];
    }
}

@end
