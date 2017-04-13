//
//  GoodsInfoView.m
//  TYSociety
//
//  Created by zhangxs on 16/8/2.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "GoodsInfoView.h"
#import "PublicScrollView.h"
#import "CraftInfoModel.h"

@interface GoodsInfoView ()<PublicScrollViewDelegate>
{
    UIImageView *_imgView;
    UILabel *_nameLabel;
    PublicScrollView *_publicView;
    NSMutableArray *_dataSource;
}
@end

@implementation GoodsInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _dataSource = [NSMutableArray array];
        UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
        backView.backgroundColor = [UIColor blackColor];
        backView.alpha = 0.8;
        backView.userInteractionEnabled = YES;
        [self addSubview:backView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapGestureRecognizer:)];
        [backView addGestureRecognizer:tapGesture];
        
//        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 165) / 2, (SCREEN_HEIGHT - 294.5) / 2, 165, 294.5)];
//        _imgView = imgView;
//        imgView.contentMode = UIViewContentModeScaleAspectFill;
//        imgView.clipsToBounds = YES;
//        [self addSubview:imgView];
        
        PublicScrollView *public = [[PublicScrollView alloc] initWithFrame:CGRectMake(10, (SCREEN_HEIGHT - 294.5) / 2, SCREEN_WIDTH - 20, 294.5)];
        _publicView = public;
        public.autoScroll = NO;
        public.tipShow = YES;
        public.delegate = self;
        [self addSubview:public];
        
       
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 125, SCREEN_WIDTH - 20, 40)];
        _nameLabel = nameLabel;
        [nameLabel setBackgroundColor:CreateColor(155, 124, 251)];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:nameLabel];
    }
    return self;
}

- (void)restDatas:(NSMutableArray *)dataSource
{
    _dataSource = dataSource;

    CraftInfoModel *item = [dataSource objectAtIndex:0];
    [_nameLabel setText:[NSString stringWithFormat:@"%@ %@页  %@",item.share_name,item.page_size,item.craft_name]];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0;i < [dataSource count];i++) {
        CraftInfoModel *item = [dataSource objectAtIndex:i];
        [array addObject:item.cover];
    }
    [_publicView setImagesArrayFromModel:array];
}

-(void)tapGestureRecognizer:(id)sender
{
    [self removeFromSuperview];
    [_publicView clearTimer];
//    if (_delegate && [_delegate respondsToSelector:@selector(cancelGoodsInfoView)]) {
//        [_delegate cancelGoodsInfoView];
//    }
}

#pragma mark - PublicScrollViewDelegate
- (void)indexChanged:(NSInteger)index ScrollView:(PublicScrollView *)pubSro
{
    CraftInfoModel *item = [_dataSource objectAtIndex:index];
    [_nameLabel setText:[NSString stringWithFormat:@"%@ %@页  %@",item.share_name,item.page_size,item.craft_name]];
}

@end
