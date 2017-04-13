//
//  EditTextView.m
//  NewTeacher
//
//  Created by zhangxs on 16/3/28.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EditTextView.h"
#import "NSString+Common.h"
#import "lame.h"
#import "Toast+UIView.h"
#import "HttpClient.h"
#import "GlobalManager.h"

#define PLACE_BABY_MSG   @"可爱亲爱的好宝宝"

@interface EditTextView ()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>

@end

@implementation EditTextView
{
    UIView *_butFather;
    NSInteger _limitCount;
    
    AVAudioRecorder *_recorder;
    NSString *_tempFilePath;
    NSTimeInterval _curTimeInterval;
    NSTimer *_timer;
    int _count;
    BOOL _isRecorder;
    int _toFrom;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame ToFrom:(int)from
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        _toFrom = from;
        
        UIView *butFather = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, frame.size.height)];
        [butFather setBackgroundColor:CreateColor(238, 242, 247)];
        [butFather setTag:1000];
        _butFather = butFather;
        [self addSubview:butFather];
        
        //监视键盘高度变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginChange:) name:UITextViewTextDidChangeNotification object:nil];
        
        [self setContentView:@""];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame Voice_flag:(int)flag Placeholder:(NSString *)placeholder
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height)];
        [bgView setBackgroundColor:[UIColor blackColor]];
        [bgView setAlpha:0.3];
        [self addSubview:bgView];
        
        UIView *butFather = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, (flag == 1) ? 160 : 90)];
        [butFather setBackgroundColor:CreateColor(238, 242, 247)];
        [butFather setTag:1000];
        _butFather = butFather;
        [self addSubview:butFather];
        
        UIButton *butNil = [UIButton buttonWithType:UIButtonTypeCustom];
        [butNil setFrame:CGRectMake(0, 0, bgView.frameWidth, bgView.frameHeight - butFather.frameHeight)];
        [butNil setBackgroundColor:[UIColor clearColor]];
        [butNil addTarget:self action:@selector(selectNilBut:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:butNil];
        
        //监视键盘高度变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginChange:) name:UITextViewTextDidChangeNotification object:nil];
        
        [self setContentView:placeholder];
    }
    
    return self;
}

- (void)selectNilBut:(id)sender
{
    [self hidenTextView];
}

- (void)setContentView:(NSString *)placeholder
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20 - 50, 20)];
    _limitLabel = label;
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:12]];
    [_butFather addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:CreateColor(57, 104, 238)];
    [[button layer] setCornerRadius:2];
    [[button layer] setMasksToBounds:YES];
    if (_toFrom != 1) {
        [button setFrame:CGRectMake(SCREEN_WIDTH - 50, 5, 40, 25)];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [button setFrame:CGRectMake(SCREEN_WIDTH - 60, 5, 50, 25)];
        [button setTitle:@"评语库" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_butFather addSubview:button];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 35, SCREEN_WIDTH - 20, 45)];
    [_textView setBackgroundColor:[UIColor whiteColor]];
    _textView.delegate = self;
    //_textView.returnKeyType = UIReturnKeyDone;
    [[_textView layer] setCornerRadius:2];
    [[_textView layer] setMasksToBounds:YES];
    [[_textView layer] setBorderWidth:0.5];
    [[_textView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    _textView.text = placeholder ?: PLACE_BABY_MSG;
    [_butFather addSubview:_textView];
    
    if (_toFrom != 2) {
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(10, _textView.frame.origin.y + _textView.frame.size.height + 10, SCREEN_WIDTH - 20 - 60, 20)];
        [tip setBackgroundColor:[UIColor clearColor]];
        [tip setText:@"录入您对宝宝的语言："];
        [tip setTextColor:[UIColor lightGrayColor]];
        [tip setFont:[UIFont systemFontOfSize:12]];
        [_butFather addSubview:tip];
        
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeButton setFrame:CGRectMake(SCREEN_WIDTH - 10 - 60, _textView.frame.origin.y + _textView.frame.size.height + 5, 60, 30)];
        [_changeButton setBackgroundColor:[UIColor clearColor]];
        [_changeButton setTitle:@"重新录音" forState:UIControlStateNormal];
        [_changeButton setTitleColor:CreateColor(57, 105, 237) forState:UIControlStateNormal];
        [_changeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_changeButton addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_changeButton setHidden:YES];
        [_butFather addSubview:_changeButton];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, _changeButton.frame.size.height - 6, 54, 1)];
        [lineLabel setBackgroundColor:CreateColor(57, 105, 237)];
        [_changeButton addSubview:lineLabel];
        
        _recordingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, tip.frame.size.height + tip.frame.origin.y + 10, 30, 30)];
        [_recordingImgView setImage:CREATE_IMG(@"tv35")];
        [_butFather addSubview:_recordingImgView];
        
        _recordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordingButton setFrame:CGRectMake(_recordingImgView.frame.origin.x + _recordingImgView.frame.size.width + 5, _recordingImgView.frame.origin.y, SCREEN_WIDTH - _recordingImgView.frame.origin.x - _recordingImgView.frame.size.width - 5 - 10, 30)];
        [_recordingButton setBackgroundColor:CreateColor(57, 105, 237)];
        [[_recordingButton layer] setCornerRadius:15];
        [[_recordingButton layer] setMasksToBounds:YES];
        [_recordingButton setTitle:@"按住录音" forState:UIControlStateNormal];
        [_recordingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_recordingButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_recordingButton addTarget:self action:@selector(recordingAction:) forControlEvents:UIControlEventTouchDown];
        [_recordingButton addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];
        [_recordingButton addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpOutside];
        [_butFather addSubview:_recordingButton];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setFrame:CGRectMake(_recordingImgView.frame.origin.x + _recordingImgView.frame.size.width + 5, _recordingImgView.frame.origin.y, SCREEN_WIDTH - _recordingImgView.frame.origin.x - _recordingImgView.frame.size.width - 5 - 10, 30)];
        [_playButton setBackgroundColor:CreateColor(44, 188, 64)];
        [[_playButton layer] setCornerRadius:15];
        [[_playButton layer] setMasksToBounds:YES];
        [_playButton setTitle:@"播放录音" forState:UIControlStateNormal];
        [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setHidden:YES];
        [_butFather addSubview:_playButton];
    }else {        
        if (!_placeholderLab) {
            _placeholderLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 20)];
            [_placeholderLab setBackgroundColor:[UIColor clearColor]];
            [_placeholderLab setFont:[UIFont systemFontOfSize:12]];
            [_placeholderLab setTextColor:[UIColor lightGrayColor]];
            [_textView addSubview:_placeholderLab];
        }
    }
}

- (void)setInitData
{
    [_recordingImgView setImage:CREATE_IMG(@"tv36")];
    [_recordingButton setHidden:YES];
    [_playButton setHidden:NO];
    [_changeButton setHidden:NO];
}

- (void)changeAction:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_loactionPath]) {
        [fileManager removeItemAtPath:_loactionPath error:nil];
    }
    [_playButton setTitle:@"播放录音" forState:UIControlStateNormal];
    [_changeButton setHidden:YES];
    [_playButton setHidden:YES];
    
    [_recordingButton setHidden:NO];
    [_recordingImgView setImage:CREATE_IMG(@"tv35")];
    
    if (_timer) {
        [_timer invalidate];
        _count = -1;
    }
    if (_audioPlayer!=nil && [_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer=nil;
    }
    _loactionPath = @"";
    _isRecorder = NO;
}

- (void)setLimitCount:(NSInteger)limitCount
{
    if (_toFrom != 1 && _toFrom != 2) {
        [_limitLabel setText:[NSString stringWithFormat:@"请输入文字：（可录入%ld字）",(long)limitCount]];
    }
    _limitCount = limitCount;
}

- (void)buttonPressed:(id)sender
{
    if (_recorder.isRecording) {
        return;
    }
    
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }

    if (_toFrom == 2) {
        if (_delegate && [_delegate respondsToSelector:@selector(replyTeacher:)]) {
            [_delegate replyTeacher:self];
        }
    }else {
        if (_isRecorder) {
            [self makeToastActivity];
            [self addVoicePath:_loactionPath];
        }else{
            if (!_recordingButton.hidden) {
                _voiceUrl = @"";
            }
            if (_toFrom != 1) {
                [self hidenTextView];
            }
        }
    }
}

#pragma mark - start record
- (void)recordingAction:(id)sender
{
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
    //录音
    [self startBeginRecord];
}

- (void)startBeginRecord
{
    //[self setUserInteractionEnabled:NO];
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    __weak typeof(avSession)weakSession = avSession;
    __weak typeof(self)weakSelf = self;
    __weak typeof(_recorder)weakRecorder = _recorder;
    
    /**
     *  新增录音访问权限，仅支持iOS7以及iOS7以上，iOS6中没有此权限
     *- (void)requestRecordPermission:(PermissionBlock)response NS_AVAILABLE_IOS(7_0);
     *  @param requestRecordPermission:
     *
     *  @return
     */
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
        [avSession requestRecordPermission:^(BOOL available) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (available) {
                    //completionHandler
                    
                    if([_recordingButton isTouchInside]){
                        [weakSelf resetRecorder];
                        [weakRecorder record];
                    }
                }
                else
                {
                    [weakSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];//设置类别,表示该应用同时支持播放和录音
                    [weakSession setActive:YES error: nil];//启动音频会话管理,此时会阻断后台音乐的播放.
                }
            });
            
        }];
        
    }
}

- (void)resetRecorder
{
    NSLog(@"重设录音");
    if (_recorder) {
        if ([_recorder isRecording]) {
            [_recorder stop];
        }
        _recorder = nil;
        _loactionPath = @"";
        _isRecorder = NO;
    }
    
    NSError *error = nil;
    AVAudioSession * audioSession = [AVAudioSession sharedInstance]; //得到AVAudioSession单例对象
    [audioSession setCategory:AVAudioSessionCategoryRecord error: &error];//设置类别,表示该应用同时支持播放和录音
    [audioSession setActive:YES error: &error];//启动音频会话管理,此时会阻断后台音乐的播放.
    
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    NSString *filepath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",[NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSString getToday]]]];
    _tempFilePath = filepath;
    NSURL *url = [NSURL fileURLWithPath:filepath];
    
    //初始化
    NSError *error2;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error2];
    [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
    //开启音量检测
    [_recorder recordForDuration:300.0];
    _recorder.delegate = self;
    _curTimeInterval = [[NSString getToday] timeIntervalSince1970];
    
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCallback:) userInfo:@"1" repeats:YES];
}

- (void)timerCallback:(NSTimer *)timer
{
    NSString *type = [timer userInfo];
    if ([type isEqualToString:@"1"]) {
        if (!_recorder.isRecording) {
            if ([_timer isValid]) {
                [_timer invalidate];
            }
            _timer = nil;
            return;
        }
        NSTimeInterval time = [[NSString getToday] timeIntervalSince1970];
        if (time - _curTimeInterval > 280) {
            if (_recorder) {
                [_recorder stop];
            }
            [self hidenRecordingAnimation];
            
            if ([_timer isValid]) {
                [_timer invalidate];
            }
            _timer = nil;
            
            return;
        }
        
        [_recorder updateMeters];
        float avg = [_recorder averagePowerForChannel:0];
        //averagePowerForChannel调用结果
        NSString *name = nil;
        if (avg > -10) {
            name = @"voice_6";
        }
        else if (avg > -20 && avg <= -10)
        {
            name = @"voice_5";
        }
        else if (avg > -30 && avg <= -20)
        {
            name = @"voice_4";
        }
        else if (avg > -40 && avg <= -30)
        {
            name = @"voice_3";
        }
        else if (avg > -50 && avg <= -40)
        {
            name = @"voice_2";
        }
        else if (avg > -60 && avg <= -50)
        {
            name = @"voice_1";
        }
        else
        {
            name = @"voice_0";
        }
        [self showRecordingAnimation:name];
    }else{
        _count ++;
        NSArray *array = @[@"voice10001",@"voice10002",@"voice10003",@"voice10004",@"voice10005",@"voice10006",@"voice10007",@"voice10008",@"voice10009",@"voice10010",@"voice10011",@"voice10012",@"voice10013",@"voice10014",@"voice10015",@"voice10016",@"voice10017",@"voice10018",@"voice10019",@"voice10020",@"voice10021",@"voice10022",@"voice10023",@"voice10024",@"voice10025",@"voice10026",@"voice10027",@"voice10028",@"voice10029",@"voice10030",@"voice10031",@"voice10032",@"voice10033",@"voice10034",@"voice10035",@"voice10036",@"voice10037",@"voice10038",@"voice10039",@"voice10040"];
        if (_count >= [array count]) {
            _count -= [array count];
        }
        [_recordingImgView setImage:CREATE_IMG([array objectAtIndex:_count])];
    }
}
#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    /**
     *  3.录音完成
     */
    NSLog(@"录音完成");
    [_timer invalidate];
    [self hidenRecordingAnimation];
    NSTimeInterval nowTimeInterval = [[NSString getToday] timeIntervalSince1970];
    if (nowTimeInterval - _curTimeInterval < 2) {
        [self setUserInteractionEnabled:YES];
        
        [self makeToast:@"录音时间太短" duration:1.0 position:@"center"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_loactionPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_loactionPath error:nil];
        }
        _loactionPath = @"";
        _isRecorder = NO;
    }
    else
    {
        [self makeToastActivity];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self convertToMp3];
            });
        });
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    [self setUserInteractionEnabled:YES];
}

#pragma mark - 录音完成之后转化为mp3
- (void)convertToMp3
{
    /**
     *  4.录音完成之后转mp3
     */
    NSLog(@"录音完成之后转mp3");
    NSString *mp3Path = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",[NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSString getToday]]]];
    _loactionPath = mp3Path;
    _isRecorder = YES;
    @try {
        int read, write;
        
        FILE *pcm = fopen([_tempFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3Path cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
        }
        while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@",[exception description]);
        [self setUserInteractionEnabled:YES];
    }
    @finally
    {
        [self convertMp3Finish];
    }
}

- (void)convertMp3Finish
{
    /**
     *  5.录音转mp3成功
     */
    [_recordingImgView setImage:CREATE_IMG(@"tv36")];
    [_recordingButton setHidden:YES];
    [_playButton setHidden:NO];
    [_changeButton setHidden:NO];
    
    NSLog(@"录音转mp3成功");
    if ([[NSFileManager defaultManager] fileExistsAtPath:_tempFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_tempFilePath error:nil];
    }
    _tempFilePath = nil;
    _recorder = nil;
    [self hideToastActivity];
    [self setUserInteractionEnabled:YES];
}

- (void)showRecordingAnimation:(NSString *)name
{
    UIImageView *imgView = (UIImageView *)[self.window viewWithTag:147];
    if (!imgView) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        [imgView setCenter:self.window.center];
        [imgView setTag:147];
        [self.window addSubview:imgView];
    }
    [imgView setImage:CREATE_IMG(name)];
}

- (void)hidenRecordingAnimation
{
    UIImageView *imgView = (UIImageView *)[self.window viewWithTag:147];
    if (imgView) {
        [imgView setHidden:YES];
        [imgView removeFromSuperview];
    }
}

- (void)stopAction:(id)sender
{
    [self hidenRecordingAnimation];
    //停止录音
    if (_recorder) {
        [_recorder stop];
    }
}

- (void)playAction:(id)sender
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    _count = -1;
    //播放
    UIButton *btn = (UIButton *)sender;
    if (_audioPlayer != nil && [_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer=nil;
        
        [btn setTitle:@"播放录音" forState:UIControlStateNormal];
        [_recordingImgView setImage:CREATE_IMG(@"tv36")];
    }else {
        [btn setTitle:@"停止" forState:UIControlStateNormal];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCallback:) userInfo:@"2" repeats:YES];
        
        if ([_loactionPath length] > 0) {
            [self videoBeginPlay:_loactionPath];
        }else {
            [self playVoice:nil];
        }
    }
}

- (void)playVoice:(id)sender
{
    if (_audioPlayer != nil && [_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    UIButton *btn = (UIButton *)sender;
    if (btn && [btn tag] == 1011) {
        _playButton = btn;
    }
    if (![_voiceUrl hasPrefix:@"http"]) {
        _voiceUrl = [G_IMAGE_ADDRESS stringByAppendingString:_voiceUrl ?: @""];
    }
    NSString *fileName = [_voiceUrl lastPathComponent];
    NSString *filePaths = [APPCacheDirectory stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePaths]){
        //播放
        [self videoBeginPlay:filePaths];
    }
    else
    {
        __weak typeof(self)weakSelf = self;
        
        [self makeToastActivity];
        [HttpClient downloadFileWithProgress:_voiceUrl complateBlcok:^(NSError *error, NSURL *filePath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideToastActivity];
                //播放
                NSData *fileData = [NSData dataWithContentsOfURL:filePath];
                [fileData writeToFile:filePaths atomically:NO];
                [weakSelf videoBeginPlay:filePaths];
                _tempFilePath = filePaths;
            });
        } progressBlock:^(NSProgress *progress) {
            
        }];
    }
}

#pragma mark - play video
- (void)videoBeginPlay:(NSString *)filePath
{
    if (_audioPlayer && [_audioPlayer isPlaying]) {
        return;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    ;
    _audioPlayer = nil;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
    [_audioPlayer setDelegate:self];
    [_audioPlayer play];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    if ([[self subviews] count] < 2) {
        return;
    }
    
    UIView *bgView = [[self subviews] objectAtIndex:0];
    CGRect bgRec = bgView.frame;
    [bgView setFrame:CGRectMake(bgRec.origin.x, bgRec.origin.y - bgRec.size.height, bgRec.size.width, bgRec.size.height)];
    
    UIView *butFather = [[self subviews] objectAtIndex:1];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - butRec.size.height, butRec.size.width, butRec.size.height)];
    }];
}

- (void)hidenTextView
{
    if (_recorder.isRecording) {
        return;
    }
    
    UIView *imgView = [self.window viewWithTag:147];
    [imgView removeFromSuperview];
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    if (_recorder.isRecording) {
        [_recorder stop];
    }
    
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(hiddenEditTextView:)]) {
        [_delegate hiddenEditTextView:self];
    }
    if ([[self subviews] count] < 2) {
        return;
    }
    
    [self setPalyAction];
    UIView *bgView = [[self subviews] objectAtIndex:0];
    CGRect bgRec = bgView.frame;
    [bgView setFrame:CGRectMake(bgRec.origin.x, bgRec.origin.y + bgRec.size.height, bgRec.size.width, bgRec.size.height)];
    UIView *butFather = [[self subviews] objectAtIndex:1];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setPalyAction
{
    if (_audioPlayer != nil && [_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer = nil;
        
        [_recordingImgView setImage:CREATE_IMG(@"tv36")];
        [_timer invalidate];
        _count = -1;
    }
}

#pragma mark audioPlayerFinishedDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_playButton setTitle:@"播放录音" forState:UIControlStateNormal];
    [_recordingImgView setImage:CREATE_IMG(@"tv36")];
    [_timer invalidate];
    _count = -1;
    if (_audioPlayer != nil && [_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_tempFilePath]) {
        [fileManager removeItemAtPath:_tempFilePath error:nil];
    }
}

#pragma mark - 上传音频
- (void)addVoicePath:(NSString *)path
{
    if ([GlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
        [self makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSString *shooting_time = [NSString stringWithFormat:@"%ld", (long)[[NSString getToday] timeIntervalSince1970]];
    NSMutableDictionary *file_info = [NSMutableDictionary dictionary];
    [file_info setObject:shooting_time forKey:@"shooting_time"];
    [file_info setObject:[NSString getFileMD5WithPath:path] forKey:@"md5"];
    [file_info setObject:[NSString getDeviceUDID] forKey:@"device_no"];
    [file_info setObject:@"" forKey:@"file_client_path"];
    [file_info setObject:@"3" forKey:@"type"];
    [file_info setObject:@"" forKey:@"location"];
    [file_info setObject:@"" forKey:@"location_name"];
    [file_info setObject:@"0" forKey:@"width"];
    [file_info setObject:@"0" forKey:@"height"];

    UserDetailInfo *detailInfo = [GlobalManager shareInstance].detailInfo;
    NSDictionary *lstDic = @{@"token":detailInfo.token,@"file_info":file_info};
    NSData *json = [NSJSONSerialization dataWithJSONObject:lstDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    lstJson = [NSString encrypt:lstJson];
    NSString *gbkStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)lstJson,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
    
    self.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    [HttpClient uploadFile:url filePath:path parameters:nil complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                weakSelf.userInteractionEnabled = YES;
                [weakSelf makeToast:@"语音上传失败" duration:1.0 position:@"center"];
            }
            else{
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *retJson = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                id retData = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                if ([retData isKindOfClass:[NSArray class]]) {
                    retData = [retData firstObject];
                }
                NSString *ret_code = [retData valueForKey:@"ret_code"];
                if ((ret_code.length > 0) && [ret_code isEqualToString:@"0000"]) {
                    [weakSelf singleFinish:retData Suc:YES];
                }else {
                    [weakSelf singleFinish:retData Suc:NO];
                }
            }
        });
    } progressBlock:^(NSProgress *progress) {
        
    }];
}

- (void)singleFinish:(id)result Suc:(BOOL)suc
{
    [self setUserInteractionEnabled:YES];
    [self hideToastActivity];
    
    if (suc) {
        NSString *url = [result valueForKey:@"path"];
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        _voiceUrl = url;
    }
    else{
        [self makeToast:@"音频上传失败" duration:1.0 position:@"center"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:_loactionPath]) {
            [fileManager removeItemAtPath:_loactionPath error:nil];
        }
    }
    if (_toFrom != 1) {
        [self hidenTextView];
    }
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    UIView *father = [self superview];
    CGRect newRect = CGRectMake(self.frame.origin.x, father.frame.size.height - keyboardRect.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    if (_delegate && [_delegate respondsToSelector:@selector(showKeyboardEditTextView:Height:)]) {
        [_delegate showKeyboardEditTextView:keyboardRect.size.height Height:_butFather.frame.size.height];
    }
    if (!(_toFrom == 1 || _toFrom == 2)) {
        
        [UIView animateWithDuration:0.35 animations:^(void) {
            [self setFrame:newRect];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIView *father = [self superview];
    CGRect newRect = CGRectMake(self.frame.origin.x, father.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    if (_delegate && [_delegate respondsToSelector:@selector(hideKeyboardEditTextView:)]) {
        [_delegate hideKeyboardEditTextView:_butFather.frame.size.height];
    }
    if (!(_toFrom == 1 || _toFrom == 2)) {
        [UIView animateWithDuration:0.35 animations:^(void) {
            if ([_textView.text isEqualToString:@""]) {
                [_textView setText:PLACE_BABY_MSG];
            }
            [self setFrame:newRect];
        }];
    }
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_placeholderLab) {
        [_placeholderLab setHidden:YES];
    }
    if (_recorder.isRecording) {
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:PLACE_BABY_MSG]) {
        textView.text = @"";
    }
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if ([text isEqualToString:@"\n"]) {
//        
//        [textView resignFirstResponder];
//        if ([[textView text] length] == 0 && _placeholderLab) {
//            [_placeholderLab setHidden:NO];
//        }
//        
//        return NO;
//    }
//    
//    return YES;
//}

- (void)textViewDidBeginChange:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if (textView != _textView) {
        return;
    }
    
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            [self emojiStrSplit:toBeString];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        [self emojiStrSplit:toBeString];
    }
}

- (void)emojiStrSplit:(NSString *)str
{
    NSInteger emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        NSInteger lenght = emoji % Emoji_Count;
        NSInteger location = emoji / Emoji_Count;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        if ([lastStr length] > _limitCount) {
            lastStr = [lastStr substringToIndex:_limitCount];
        }
        [_textView setText:lastStr];
    }
    if ([lastStr length] > _limitCount) {
        lastStr = [lastStr substringToIndex:_limitCount];
        [_textView setText:lastStr];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(showEditTextContent:)]) {
        [_delegate showEditTextContent:[_textView text]];
    }
}

@end
