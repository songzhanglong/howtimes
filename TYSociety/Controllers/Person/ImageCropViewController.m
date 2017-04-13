//
//  ImageCropViewController.m
//  NewTeacher
//
//  Created by 张雪松 on 15/10/27.
//  Copyright © 2015年 songzhanglong. All rights reserved.
//

#import "ImageCropViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ImageCropViewController ()

@end

@implementation ImageCropViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    //self.showBack = YES;
    
    //[self createRightBarButton];
    
    previewV = [[UIImageView alloc] init];

    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.cropView = [[BJImageCropper alloc] initWithImage:self.originImage andMaxSize:size];
    [self.view addSubview:self.cropView];
//    self.cropView.imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.cropView.imageView.layer.shadowRadius = 3.0f;
//    self.cropView.imageView.layer.shadowOpacity = 0.8f;
//    self.cropView.imageView.layer.shadowOffset = CGSizeMake(1, 1);
//    self.cropView.proportion = 1.0;
//    [self.cropView addObserver:self forKeyPath:@"crop" options:NSKeyValueObservingOptionNew context:nil];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(SCREEN_WIDTH - 75, SCREEN_HEIGHT - 60, 60, 40)];
    [button setTitle:@"确 认" forState:UIControlStateNormal];
    [button setTag:1];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(15, SCREEN_HEIGHT - 60, 60, 40)];
    [button2 setTitle:@"取 消" forState:UIControlStateNormal];
    [button2 setTag:2];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [button2 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

- (void)buttonAction:(UIButton *)btn
{
    switch (btn.tag - 1) {
        case 0:
        {
            [self updateDisplay];
            CGSize newSize = CGSizeMake(previewV.bounds.size.width, previewV.bounds.size.height);
            UIGraphicsBeginImageContext(newSize);
            UIImage *image = previewV.image;
            [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
            UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(ImageCropVC:CroppedImage:)]) {
                [self.delegate ImageCropVC:self CroppedImage:newImage];
            }
        }
            break;
        case 1:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)createRightBarButton
{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveCrop:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}
-(void)saveCrop:(id)sender{
    
    [self updateDisplay];
    CGSize newSize = CGSizeMake(previewV.bounds.size.width, previewV.bounds.size.height);
    UIGraphicsBeginImageContext(newSize);
    UIImage *image = previewV.image;
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(ImageCropVC:CroppedImage:)]) {
        [self.delegate ImageCropVC:self CroppedImage:newImage];
    }
}
- (void)updateDisplay {
    
    previewV.image = [self.cropView getCroppedImage];
    previewV.frame = CGRectMake(10, 10, self.cropView.crop.size.width, self.cropView.crop.size.height);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self.cropView] && [keyPath isEqualToString:@"crop"]) {
        //[self updateDisplay];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
