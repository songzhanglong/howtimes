//
//  EditTextView.h
//  NewTeacher
//
//  Created by zhangxs on 16/3/28.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class EditTextView;
@protocol EditTextViewDelegate <NSObject>
@optional
- (void)showKeyboardEditTextView:(CGFloat)keyboard Height:(CGFloat)height;
- (void)hideKeyboardEditTextView:(CGFloat)height;
- (void)showEditTextContent:(NSString *)content;
- (void)hiddenEditTextView:(EditTextView *)editTextView;
- (void)replyTeacher:(EditTextView *)editTextView;

@end
@interface EditTextView : UIView <UITextViewDelegate>

@property (nonatomic, assign) id <EditTextViewDelegate> delegate;
@property (nonatomic, strong) UIButton *recordingButton;
@property (nonatomic, strong) UIImageView *recordingImgView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSString *loactionPath;
@property (nonatomic, strong) NSString *voiceUrl;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) UILabel *limitLabel;
@property (nonatomic, strong) UILabel *placeholderLab;

- (id)initWithFrame:(CGRect)frame ToFrom:(int)from;
- (id)initWithFrame:(CGRect)frame Voice_flag:(int)flag Placeholder:(NSString *)placeholder;
- (void)showInView:(UIView *)view;
- (void)setLimitCount:(NSInteger)limitCount;
- (void)setInitData;
- (void)playVoice:(id)sender;
@end
