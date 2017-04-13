//
//  AddTextViewController.h
//  TYSociety
//
//  Created by szl on 16/7/27.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"

@class AddTextViewController;
@protocol AddTextViewControllerDelegate <NSObject>

@optional
- (void)addTextFinish:(AddTextViewController *)addTxt Arr:(NSArray *)rows;

@end

@interface AddTextViewController : BaseViewController

@property (nonatomic,assign)id<AddTextViewControllerDelegate> delegate;

@property (nonatomic,strong)NSString *textStr;
@property (nonatomic,strong)NSString *color;
@property (nonatomic,assign)CGFloat alpha;
@property (nonatomic,strong)NSString *font_key;
@property (nonatomic,assign)CGFloat maxWei;

@end
