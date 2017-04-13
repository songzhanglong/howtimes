//
//  BaseViewController.h
//  TYSociety
//
//  Created by szl on 16/6/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpClient.h"
#import "UINavigationBar+Background.h"

@interface BaseViewController : UIViewController

@property (nonatomic,assign)BOOL showBack;  //初始化时指明
@property (nonatomic,strong)UILabel *titleLable;    //标题拦
@property (nonatomic,strong)UIButton *titleButton;
@property (nonatomic,strong)NSURLSessionTask *sessionTask;

@end
