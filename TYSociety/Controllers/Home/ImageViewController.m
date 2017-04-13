//
//  ImageViewController.m
//  TYSociety
//
//  Created by szl on 16/7/21.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "ImageViewController.h"
#import "Masonry.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = CreateColor(220, 220, 221);
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"preCover")];
    [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //[imgView setClipsToBounds:YES];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    if (![_url hasPrefix:@"http"]) {
        _url = [G_IMAGE_ADDRESS stringByAppendingString:_url ?: @""];
    }
    [imgView sd_setImageWithURL:[NSURL URLWithString:_url]];
    [self.view addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
}

@end
