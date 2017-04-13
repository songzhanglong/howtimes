//
//  MyTimeRecord.m
//  TYSociety
//
//  Created by szl on 16/7/19.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyTimeRecord.h"

@implementation TagNameSize : NSObject

- (void)calculateTagnameRect
{
    CGSize lastSize = CGSizeZero;
    if (_name && [_name length] > 0) {
        UIFont *font = [UIFont systemFontOfSize:12];
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    _sizeWidth = MIN(lastSize.width + 10, SCREEN_WIDTH / 2 - 90 * SCREEN_WIDTH / 375 - 5);
}

@end

@implementation MyTimeRecord

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)calculateTagNameRect
{
    CGSize lastSize = CGSizeZero;
    if (_tag_name && [_tag_name length] > 0) {
        UIFont *font = [UIFont systemFontOfSize:12];
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [_tag_name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    _tagSize = CGSizeMake(MIN(lastSize.width + 10, SCREEN_WIDTH / 2 - 90 * SCREEN_WIDTH / 375 - 5), 20);
}

- (BOOL)isEqual:(id)object
{
    MyTimeRecord *otherRecord = (MyTimeRecord *)object;
    return  ([_template_image isEqualToString:otherRecord.template_image]) &&
            ([_nums integerValue] == [otherRecord.nums integerValue]) &&
            ([_template_name isEqualToString:otherRecord.template_name]) &&
            ([_create_time isEqualToString:otherRecord.create_time]) &&
            ([_finish_num integerValue] == [otherRecord.finish_num integerValue]) &&
            ([_is_print integerValue] == [otherRecord.is_print integerValue]) &&
            ([_create_user_id isEqualToString:otherRecord.create_user_id]) &&
            ([_user_id isEqualToString:otherRecord.user_id]) &&
            ([_batch_id isEqualToString:otherRecord.batch_id]) &&
            ([_is_public integerValue] == [otherRecord.is_public integerValue]) &&
            ([_tag_name isEqualToString:otherRecord.tag_name]);
}

@end
