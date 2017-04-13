//
//  BatchDetailMatterService.m
//  TYSociety
//
//  Created by szl on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BatchDetailMatterService.h"

@implementation BatchDetailMatterService

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = [GlobalManager shareInstance].decorationArr;
    
    return [array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MatterCellId forIndexPath:indexPath];
    
    UIImageView *curImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!curImg) {
        curImg = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [curImg setContentMode:UIViewContentModeScaleAspectFit];
        [curImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [curImg setTag:1];
        [cell.contentView addSubview:curImg];
    }
    
    NSArray *array = [GlobalManager shareInstance].decorationArr;
    DecorateModel *deco = array[indexPath.item];
    NSString *url = deco.image_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [curImg sd_setImageWithURL:[NSURL URLWithString:url]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *curImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (curImg.image) {
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectItem:Img:Deco:)]) {
            NSArray *array = [GlobalManager shareInstance].decorationArr;
            DecorateModel *deco = array[indexPath.item];
            [_delegate didSelectItem:indexPath Img:curImg.image Deco:deco];
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
