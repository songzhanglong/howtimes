//
//  CustomTextView.h
//  TYSociety
//
//  Created by szl on 16/7/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MIN_CUSTOMWEIGHT  71.0
#define MIN_CUSTOMHEIGHT  71.0

@class CustomTextView;
@protocol CustomTextViewDelegate <NSObject>

@optional
- (void)deleteCustomText:(CustomTextView *)textView;
- (void)beginEditCustomText:(CustomTextView *)textView;

@end

@interface CustomTextView : UIView
{
    BOOL _isHidden;
    UIButton *_deleteBut,*_editBut;
    UIImageView *_dragImgView;
    CGPoint prevPoint;
    CGFloat deltaAngle;
}

//@property (nonatomic,strong)UILabel *textView;
@property (nonatomic,assign)CGFloat nRotation;
@property (nonatomic,assign)CGFloat fontSize;
@property (nonatomic,assign)id<CustomTextViewDelegate> delegate;
@property (nonatomic,strong)NSString *colorStr;
@property (nonatomic,assign)CGFloat alphaColor;
@property (nonatomic,strong)NSString *textStr;
@property (nonatomic,strong)UIImageView *borderImg;

- (id)initWithFrame:(CGRect)frame Str:(NSString *)str Color:(NSString *)color Alpha:(CGFloat)alpha;

/**
 *	@brief	控制显示与隐藏
 */
- (void)controlHiddenOrShow;

- (void)hiddenButton;

- (void)resetBoundSize:(CGSize)size;

@end
