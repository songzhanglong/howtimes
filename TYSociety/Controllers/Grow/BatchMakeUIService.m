//
//  BatchMakeUIService.m
//  TYSociety
//
//  Created by szl on 16/7/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BatchMakeUIService.h"
#import "TimeRecordInfo.h"

@implementation BatchMakeUIService

#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = [self.dataSource count];
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *assets = [self.dataSource objectAtIndex:section];
    return assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = FastMakeCellID;
    
    FastMakeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = _delegate;
    NSArray *assets = [self.dataSource objectAtIndex:indexPath.section];
    PhotoManagerModel *model = assets[indexPath.item];
    [cell resetPhotoData:model];
    
    if (model.path.length == 0) {
        //未上传过的，无需判断
        cell.checkImg.hidden = YES;
    }
    else if ([_checkArr containsObject:model]) {
        cell.checkImg.hidden = NO;
    }
    else{
        BOOL hasFound = NO;
        for (ProductImageGallery *gallery in _gallerys) {
            if ([gallery.path rangeOfString:model.path].location != NSNotFound) {
                hasFound = YES;
                break;
            }
        }
        cell.checkImg.hidden = !hasFound;
    }
    
    return cell;
}

#pragma mark - 头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:FastMakeHeader forIndexPath:indexPath];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *timeLab = (UILabel *)[view viewWithTag:1];
    if (!timeLab) {
        timeLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 16)];
        [timeLab setBackgroundColor:view.backgroundColor];
        [timeLab setTag:1];
        [timeLab setFont:[UIFont systemFontOfSize:12]];
        [timeLab setTextColor:[UIColor darkGrayColor]];
        [view addSubview:timeLab];
        
        UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 160, 1, 150, 24)];
        [numLab setFont:[UIFont systemFontOfSize:10]];
        [numLab setTag:2];
        [numLab setNumberOfLines:2];
        [numLab setTextColor:[UIColor darkGrayColor]];
        [numLab setTextAlignment:NSTextAlignmentRight];
        [view addSubview:numLab];
    }
    NSArray *array = self.dataSource[indexPath.section];
    PhotoManagerModel *model = [array firstObject];
    double time = model.shooting_time.doubleValue;
    if (model.shooting_time.length > 0) {
        NSString *timeStr = [[model.shooting_time componentsSeparatedByString:@"."] firstObject];
        if (timeStr.length > 10) {
            time /= 1000;
        }
    }
    NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString* nsALAssetPropertyDate = [NSString stringByDate:@"yyyy年MM月dd日" Date:curDate];
    [timeLab setText:nsALAssetPropertyDate];
    
    UILabel *numLab = (UILabel *)[view viewWithTag:2];
    NSString *str = nil;
    NSInteger count = MIN(10, array.count);
    for (NSInteger i = 0; i < count; i++) {
        PhotoManagerModel *assetModel = array[i];
        if (assetModel.location_name.length > 0) {
            str = assetModel.location_name;
            break;
        }
    }
    [numLab setText:str];
    
    return view;
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
