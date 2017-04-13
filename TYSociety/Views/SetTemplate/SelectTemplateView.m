//
//  SelectTemplateView.m
//  TYSociety
//
//  Created by zhangxs on 16/7/21.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "SelectTemplateView.h"
#import "TemplateModel.h"

#define BUTTONTAGINDEX 2300

@interface SelectTemplateView ()
{
    UIView *_backView;
    NSInteger _indexTag;
    NSMutableArray *_allSource,*_otherSource;
}
@end
@implementation SelectTemplateView

- (id)initWithFrame:(CGRect)frame Datas:(NSMutableArray *)dataSource OtherDatas:(NSMutableArray *)otners
{
    self = [super initWithFrame:frame];
    if (self) {
        if (self = [super initWithFrame:frame]) {
            [self setBackgroundColor:[UIColor clearColor]];
            _allSource = dataSource;
            _otherSource = otners;
            
            _dataSource = _otherSource;
            
            _backView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height / 3 + 42)];
            [_backView setBackgroundColor:[UIColor clearColor]];
            [_backView setUserInteractionEnabled:YES];
            [self addSubview:_backView];
            
            [self setHeadView];
            
            UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
            layout.minimumLineSpacing = 5;
            layout.minimumInteritemSpacing = 5;
            layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
            _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 42, frame.size.width, frame.size.height / 3) collectionViewLayout:layout];
            _collectionView.backgroundColor = [UIColor clearColor];
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
            [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SelectTemplate"];
            [_collectionView setBackgroundColor:CreateColor(240, 239, 244)];
            [_backView addSubview:_collectionView];
            
            [self createTableHeaderView];
        }
        return self;
    }
    return self;
}

- (void)createTableHeaderView{
    if ([self.dataSource count] > 0) {
        UIView *headView = (UIView *)[_backView viewWithTag:23];
        if (headView) {
            [headView removeFromSuperview];
        }
    }
    else{
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 120)];
        [headView setTag:23];
        [headView setBackgroundColor:_collectionView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 65) / 2, 50, 65, 80)];
        imgView.image = CREATE_IMG(@"order_default");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 10, SCREEN_WIDTH - 80, 30)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(86, 86, 86)];
        [label setText:@"模板已经全部添加了哦"];
        [headView addSubview:label];
        
        [_backView addSubview:headView];
    }
}

- (void)setHeadView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 42)];
    [headView setBackgroundColor:CreateColor(240, 239, 244)];
    [headView setUserInteractionEnabled:YES];
    [_backView addSubview:headView];
    
    _indexTag = 10;
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(SCREEN_WIDTH / 2 * i, 0, SCREEN_WIDTH / 2, 40)];
        [button setTitle:(i == 0) ? @"未使用" : @"全部" forState:UIControlStateNormal];
        [button setTag:10 + i];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleColor:(i == 0) ? BASELINE_COLOR : CreateColor(101, 101, 101)forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:button];
        
        if (i == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 0.5, 8, 1, 24)];
            [label setBackgroundColor:[UIColor lightGrayColor]];
            [headView addSubview:label];
            
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH / 2 - 60) / 2, 40, 60, 2)];
            [lineLabel setBackgroundColor:BASELINE_COLOR];
            [lineLabel setTag:21];
            [headView addSubview:lineLabel];
        }
    }
}

- (void)buttonPressed:(UIButton *)sender
{
    [sender setTitleColor:BASELINE_COLOR forState:UIControlStateNormal];
    UIView *headView = [sender superview];
    UILabel *lineLabel = (UILabel *)[headView viewWithTag:21];
    lineLabel.frameX = sender.frameX + (SCREEN_WIDTH / 2 - 60) / 2;
    if (sender.tag == _indexTag) {
        return;
    }else {
        UIButton *lastBtn = (UIButton *)[headView viewWithTag:_indexTag];
        [lastBtn setTitleColor:CreateColor(101, 101, 101) forState:UIControlStateNormal];
    }
    _indexTag = sender.tag;
    
    _dataSource = (_indexTag == 10) ? _otherSource : _allSource;
    
    [_collectionView reloadData];
    [self createTableHeaderView];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - butRec.size.height, butRec.size.width, butRec.size.height)];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(cancelTemplateIndex)]) {
        [_delegate cancelTemplateIndex];
    }
    
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger num = _is_double ? 2 : 3;
    TemplateModel *item = [self.dataSource objectAtIndex:indexPath.item];
    CGFloat itemHei = [item.image_height floatValue];
    CGFloat scale = ((SCREEN_WIDTH - 10 * 2 - (num - 1) * 5) / num) / [item.image_width floatValue];
    itemHei = itemHei * scale;
    CGFloat itemWei = (SCREEN_WIDTH - 10 * 2 - (num - 1) * 5) / num;
    
    return CGSizeMake(itemWei, itemHei);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectTemplate" forIndexPath:indexPath];
    
    UIImageView *_imgView = (UIImageView *)[cell.contentView viewWithTag:2];
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frameWidth, cell.contentView.frameHeight)];
        [_imgView setTag:2];
        //_imgView.contentMode = UIViewContentModeScaleAspectFill;
        //_imgView.clipsToBounds = YES;
        [_imgView setBackgroundColor:CreateColor(240, 239, 244)];
        [cell.contentView addSubview:_imgView];
    }
    TemplateModel *model = [self.dataSource objectAtIndex:indexPath.item];
    NSString *url = model.image_thumb_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_imgView sd_setImageWithURL:[NSURL URLWithString:url]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateModel *model = [self.dataSource objectAtIndex:indexPath.item];
    if (_indexTag == 10) {
        [self.dataSource removeObject:model];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        [self createTableHeaderView];
    }else {
        if ([_otherSource containsObject:model]) {
            [_otherSource removeObject:model];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(addTemplateSource:Theme:)]) {
        [_delegate addTemplateSource:model Theme:_theme_name];
    }
}

@end
