//
//  LoginViewController.h
//  TYSociety
//
//  Created by szl on 16/6/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic,strong)UIImageView *navBarHairlineImageView;
@property (nonatomic,strong)UITextField *phoneField;
@property (nonatomic,strong)UITextField *passField;
@property (nonatomic,assign)BOOL showPass;
@property (nonatomic,assign)BOOL agreementCooperate;

@end
