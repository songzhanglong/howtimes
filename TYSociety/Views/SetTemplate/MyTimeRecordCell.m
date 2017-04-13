//
//  MyTimeRecordCell.m
//  TYSociety
//
//  Created by szl on 16/7/19.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyTimeRecordCell.h"
#import "MyTimeRecord.h"

@implementation MyTimeRecordCell

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
        if (i < count) {
            imageView.hidden = NO;
            nameLabel.hidden = NO;
            pLabel.hidden = NO;
            timeLabel.hidden = NO;
            typeLabel.hidden = NO;
            
            MyTimeRecord *record = array[i];
            //封面
            NSString *cover = record.template_image;
            if (![cover hasPrefix:@"http"]) {
                cover = [G_IMAGE_ADDRESS stringByAppendingString:cover ?: @""];
            }
            cover = [NSString getPictureAddress:@"2" width:@"230" height:@"0" original:cover];
            [imageView sd_setImageWithURL:[NSURL URLWithString:cover]];
            
            //名称
            nameLabel.text = record.template_name;
            
            //页码
            NSInteger pNum = [record.nums integerValue];
            NSInteger pFinish = [record.finish_num integerValue];
            if (record.is_double.integerValue == 1) {
                pNum = [record.nums integerValue] * 2;
                pFinish = [record.finish_num integerValue] * 2;
            }
            pLabel.text = [NSString stringWithFormat:@"%ld/%ld页",(long)pFinish,(long)pNum];
            
            //时间
            NSString *create_time = record.create_time;
            NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:create_time.doubleValue];
            timeLabel.text = [NSString stringByDate:@"MM月dd日" Date:updateDate];
            
            //标签
            typeLabel.text = record.tag_name;
            
            //按钮
            btn.hidden = NO;
            BOOL enable = (([record.is_print integerValue] == 0) && [record.create_user_id isEqualToString:record.user_id]);
            btn.enabled = enable;
            btn.alpha = enable ? 1 : 0.4;
        }
        else{
            imageView.hidden = YES;
            nameLabel.hidden = YES;
            pLabel.hidden = YES;
            timeLabel.hidden = YES;
            typeLabel.hidden = YES;
            btn.hidden = YES;
        }
    }
}

- (void)setTemplate:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setTemplateTimeRecord:At:)]) {
        NSInteger index = [sender tag] - 500;
        [self.delegate setTemplateTimeRecord:self.timeRecords[index] At:self];
    }
}

@end
