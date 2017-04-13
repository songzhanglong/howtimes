//
//  GuideScrollView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/3/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuideScrollView;

@protocol GuideScrollViewDelegate <NSObject>

- (void)startLaunchApp:(GuideScrollView *)guideView;

@end

@interface GuideScrollView : UIView<UIScrollViewDelegate>

@property (nonatomic,assign)id<GuideScrollViewDelegate> delegate;

@end
