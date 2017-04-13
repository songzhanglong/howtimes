//
//  ProgressView.h
//  NewTeacher
//
//  Created by szl on 16/6/1.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"

@interface ProgressCircleView : UIView

@property (nonatomic,strong)UAProgressView *loadingIndicator;
@property (nonatomic,strong)UILabel *progressLab;

@end
