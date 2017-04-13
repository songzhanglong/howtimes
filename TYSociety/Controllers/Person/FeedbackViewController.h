//
//  FeedbackViewController.h
//  TYSociety
//
//  Created by zhangxs on 16/7/15.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"

@interface FeedbackViewController : BaseViewController <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLab;

@end
