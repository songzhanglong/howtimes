//
//  FindPass2ViewController.h
//  TYSociety
//
//  Created by szl on 16/7/18.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@interface FindPass2ViewController : TableViewController<UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)NSMutableArray *params;
@property (nonatomic,strong)NSString *phoneNumber;
@property (nonatomic,strong)NSString *verificationCode;

@end
