//
//  ProgressView.m
//  NewTeacher
//
//  Created by szl on 16/6/1.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "ProgressCircleView.h"

@implementation ProgressCircleView


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        _loadingIndicator = [[UAProgressView alloc] initWithFrame:CGRectMake((frame.size.width - 40) / 2, (frame.size.height - 40 - 20) / 2, 40.0f, 40.0f)];
        _loadingIndicator.tintColor = [UIColor whiteColor];
        [self addSubview:_loadingIndicator];
        
        _progressLab = [[UILabel alloc] initWithFrame:CGRectMake(10, (frame.size.height - 60) / 2 + 40 + 4, frame.size.width - 20, 32)];
        [_progressLab setBackgroundColor:[UIColor clearColor]];
        [_progressLab setFont:[UIFont systemFontOfSize:12]];
        [_progressLab setNumberOfLines:2];
        [_progressLab setTextColor:[UIColor whiteColor]];
        [_progressLab setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_progressLab];
    }
    return self;
}

@end
