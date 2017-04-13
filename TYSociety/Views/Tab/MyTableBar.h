//
//  MyTableBar.h
//  TYSociety
//
//  Created by szl on 16/7/6.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyTableBarDelegate <NSObject>

@optional
- (void)selectTableIndex:(NSInteger)index;

@end

@interface MyTableBar : UIView

@property (nonatomic,assign)id<MyTableBarDelegate> delegate;
@property (nonatomic,assign)NSInteger nSelectedIndex;

@end
