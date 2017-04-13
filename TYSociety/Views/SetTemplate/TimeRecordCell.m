//
//  TimeRecordCell.m
//  TYSociety
//
//  Created by szl on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TimeRecordCell.h"
#import "TimeRecordModel.h"

@implementation TimeRecordCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //CGFloat numPerRow = 3, xOri = 30,yOri = 30,margin = 20,itemWei = (SCREEN_WIDTH - xOri * 2 - margin * 2) / 3,itemHei = itemWei * 4 / 3;
        
        CGFloat scale = SCREEN_WIDTH / 375.0;
        CGFloat numPerRow = 2, xOri = 15 * scale, yOri = 15 * scale, itemWei = 75 * scale,itemHei = itemWei * 4 / 3, margin = SCREEN_WIDTH / 2 - xOri - itemWei;
        
        for (NSInteger i = 0; i < numPerRow; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOri + (itemWei + margin) * i, yOri, itemWei, itemHei)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            //[imageView setBackgroundColor:CreateColor(220, 220, 221)];
            [imageView setTag:i + 1];
            [imageView setUserInteractionEnabled:YES];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkTimeRecord:)]];
            [self.contentView addSubview:imageView];
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frameRight + 5, imageView.frameY, margin - 5, 20 * scale)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:CreateColor(101, 101, 101)];
            [nameLabel setFont:[UIFont systemFontOfSize:12]];
            [nameLabel setTag:100 + i];
            [self.contentView addSubview:nameLabel];
            
            UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frameX, nameLabel.frameBottom, nameLabel.frameWidth, nameLabel.frameHeight - 5 * scale)];
            [pLabel setBackgroundColor:[UIColor clearColor]];
            [pLabel setTextColor:CreateColor(101, 101, 101)];
            [pLabel setFont:[UIFont systemFontOfSize:10]];
            [pLabel setTag:200 + i];
            [self.contentView addSubview:pLabel];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frameX, pLabel.frameBottom, nameLabel.frameWidth, pLabel.frameHeight)];
            [timeLabel setBackgroundColor:[UIColor clearColor]];
            [timeLabel setTextColor:CreateColor(101, 101, 101)];
            [timeLabel setFont:[UIFont systemFontOfSize:10]];
            [timeLabel setTag:300 + i];
            [self.contentView addSubview:timeLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frameX, timeLabel.frameBottom, nameLabel.frameWidth, 30 * scale)];
            [typeLabel setBackgroundColor:[UIColor clearColor]];
            [typeLabel setTextColor:CreateColor(101, 101, 101)];
            [typeLabel setFont:[UIFont systemFontOfSize:10]];
            [typeLabel setTag:400 + i];
            typeLabel.numberOfLines = 2;
            [self.contentView addSubview:typeLabel];
            
            UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [setBtn setFrame:CGRectMake(nameLabel.frameX, typeLabel.frameBottom, 60, 20 * scale)];
            [setBtn.layer setMasksToBounds:YES];
            [setBtn.layer setCornerRadius:3];
            [setBtn.layer setBorderWidth:1];
            [setBtn.layer setBorderColor:BASELINE_COLOR.CGColor];
            [setBtn setTag:500 + i];
            [setBtn setTitle:@"设置模板" forState:UIControlStateNormal];
            [setBtn setTitleColor:BASELINE_COLOR forState:UIControlStateNormal];
            [setBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [setBtn addTarget:self action:@selector(setTemplate:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:setBtn];
        }
        
        //底部阴影
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height - 4, SCREEN_WIDTH, 4)];
        [bottomView setBackgroundColor:[UIColor whiteColor]];
        bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
        bottomView.layer.shadowOffset = CGSizeMake(0, 4);
        bottomView.layer.shadowOpacity = 0.1;
        bottomView.layer.shadowRadius = 2;
        [bottomView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [self.contentView addSubview:bottomView];
    }
    return self;
}

- (void)setTemplate:(UIButton *)sender
{

}

- (void)checkTimeRecord:(UITapGestureRecognizer *)recognizer
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectTimeRecord:At:)]) {
        UIView *tapView = [recognizer view];
        NSInteger index = [tapView tag] - 1;
        [_delegate selectTimeRecord:_timeRecords[index] At:self];
    }
}

- (void)resetTimeRecords:(NSArray *)array
{
    self.timeRecords = array;
    NSInteger count = [array count];
    for (NSInteger i = 0; i < 2; i++) {
        UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:i + 1];
        UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag:i + 100];
        UILabel *pLabel = (UILabel *)[self.contentView viewWithTag:i + 200];
        UILabel *timeLabel = (UILabel *)[self.contentView viewWithTag:i + 300];
        UILabel *typeLabel = (UILabel *)[self.contentView viewWithTag:i + 400];
        UIButton *btn = (UIButton *)[self.contentView viewWithTag:i + 500];
        typeLabel.hidden = YES;
        btn.hidden = YES;
        if (i < count) {
            imageView.hidden = NO;
            nameLabel.hidden = NO;
            pLabel.hidden = NO;
            timeLabel.hidden = NO;
            
            TimeRecordModel *record = array[i];
            
            NSString *cover = record.cover_image;
            if (![cover hasPrefix:@"http"]) {
                cover = [G_IMAGE_ADDRESS stringByAppendingString:cover ?: @""];
            }
            [imageView sd_setImageWithURL:[NSURL URLWithString:cover]];
            
            //名称
            nameLabel.text = record.name;
            //页码
            NSInteger pNum = [record.detail_num integerValue];
            if (record.is_double.integerValue == 1) {
                pNum = [record.detail_num integerValue] * 2;
            }
            pLabel.text = [NSString stringWithFormat:@"%ld页",(long)pNum];
            //日期
            NSString *create_time = record.create_time;
            NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:create_time.doubleValue];
            timeLabel.text = [NSString stringByDate:@"MM月dd日" Date:updateDate];

        }
        else{
            imageView.hidden = YES;
            nameLabel.hidden = YES;
            pLabel.hidden = YES;
            timeLabel.hidden = YES;
        }
    }
}

@end
