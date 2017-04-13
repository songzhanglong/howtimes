//
//  TopScrollView.m
//  网易首页
//
//  Created by City--Online on 15/9/1.
//  Copyright (c) 2015年 City--Online. All rights reserved.
//

#import "YWCTopScrollView.h"

@interface YWCTopScrollView ()
{
    UIView *lineView;
    CGFloat _margin;
}

@end

@implementation YWCTopScrollView

- (id)initWithFrame:(CGRect)frame andItems:(NSArray*)titleArray Index:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _selectedIndex = index;

        _buttonArray = [NSMutableArray array];
        
        UIFont *font = [UIFont systemFontOfSize:KTopButtonFont];
        _margin = 15;
        NSInteger count = titleArray.count;
        
        //宽度集合
        NSMutableArray *widthArr = [NSMutableArray array];
        CGFloat lastWei = 0;
        for (NSInteger i = 0; i < count; i++) {
            NSString *str = titleArray[i];
            CGFloat titleWidth = [self width:str heightOfFatherView:30 textFont:font];
            [widthArr addObject:[NSNumber numberWithFloat:titleWidth]];
            lastWei += titleWidth;
        }
        
        //间隔
        if (lastWei + _margin * (count + 1) < frame.size.width) {
            //超过屏幕宽，间隔为10,小于宽，居中显示
            _margin = (frame.size.width - lastWei) / (count + 1);
        }
        
        CGFloat xOri = _margin;
        for (NSInteger i = 0 ; i < count; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.titleLabel.font = [UIFont systemFontOfSize:KTopButtonFont];
            if (i == _selectedIndex) {
                [button setTitleColor:BASELINE_COLOR forState:UIControlStateNormal];
            }
            else{
                [button setTitleColor:KRGBCOLOR(101, 101, 101) forState:UIControlStateNormal];
            }
            NSString *title = [titleArray objectAtIndex:i];
            [button setTitle:title forState:UIControlStateNormal];
            button.tag = KButtonTagStart + i;

            CGFloat titleWidth = [widthArr[i] floatValue];
            button.frame = CGRectMake(xOri, 7, titleWidth, 30);
            [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [_buttonArray addObject:button];
            
            xOri += titleWidth + _margin;
        }
        self.contentSize = CGSizeMake(xOri, self.frame.size.height);
        self.showsHorizontalScrollIndicator = NO;
        
        //down but
        CGRect rc  = [self viewWithTag:_selectedIndex + KButtonTagStart].frame;
        lineView = [[UIView alloc] initWithFrame:CGRectMake(rc.origin.x, self.frame.size.height - 2, rc.size.width, 2)];
        lineView.backgroundColor = BASELINE_COLOR;
        [self addSubview:lineView];
        
        CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        if (!CGRectContainsRect(rect, lineView.frame)) {
            CGFloat offMiddleX = lineView.frameX + lineView.frameWidth / 2 - frame.size.width / 2;
            offMiddleX = MAX(0, offMiddleX);
            offMiddleX = MIN(self.contentSize.width - self.frameWidth, offMiddleX);
            [self setContentOffset:CGPointMake(offMiddleX, 0) animated:YES];
        }
    }
    return self;
}

-(void)onClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (_selectedIndex != btn.tag - KButtonTagStart){
        NSInteger index = btn.tag - KButtonTagStart;
        [self selectIndex:index withFlag:NO];
        if (_topViewDelegate && [_topViewDelegate respondsToSelector:@selector(barSelectedIndexChanged:)]) {
            [_topViewDelegate barSelectedIndexChanged:index];
        }
    }
}

- (void)selectIndexToController:(NSInteger)index
{
    [self selectIndex:index withFlag:NO];
    if (_topViewDelegate && [_topViewDelegate respondsToSelector:@selector(barSelectedIndexChanged:)]) {
        [_topViewDelegate barSelectedIndexChanged:index];
    }
}

- (void)selectIndex:(NSInteger)index withFlag:(BOOL)flag
{
    if (_selectedIndex != index) {
        UIButton *lastBut = _buttonArray[_selectedIndex];
        UIButton *curBut = _buttonArray[index];
        _selectedIndex = index;
        [UIView animateWithDuration:0.15 animations:^{
            [lastBut setTitleColor:KRGBCOLOR(101, 101, 101) forState:UIControlStateNormal];
            [curBut setTitleColor:BASELINE_COLOR forState:UIControlStateNormal];
            [lineView setFrame:CGRectMake(curBut.frameX, lineView.frameY, curBut.frameWidth, lineView.frameHeight)];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (CGFloat)width:(NSString *)contentString heightOfFatherView:(CGFloat)height textFont:(UIFont *)font{
    NSDictionary *attributesDic = @{NSFontAttributeName:font};
    CGSize size = [contentString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDic context:nil].size;
    return size.width;
}

- (void)changeOffset:(CGFloat)offsetX
{
    CGFloat curX = _selectedIndex * SCREEN_WIDTH;
    CGFloat curOff = fabs(offsetX - curX);
    curOff = MIN(curOff, SCREEN_WIDTH);
    
    //过滤
    UIButton *curBut = _buttonArray[_selectedIndex];
    NSInteger nextIndex = (offsetX > curX) ? (_selectedIndex + 1) : (_selectedIndex - 1);
    if (nextIndex < 0 || nextIndex >= _buttonArray.count) {
        return;
    }
    
    CGFloat diffScale = curOff / SCREEN_WIDTH,lineDiff = 0;
    UIView *nextView = _buttonArray[nextIndex];
    CGFloat diffWei = nextView.frameWidth - curBut.frameWidth;
    if (nextIndex > _selectedIndex) {
        lineDiff = diffScale * (curBut.frameWidth + _margin);
        [lineView setFrame:CGRectMake(curBut.frameX + lineDiff, lineView.frameY, curBut.frameWidth + diffScale * diffWei, lineView.frameHeight)];
    }
    else{
        lineDiff = diffScale * (nextView.frameWidth + _margin);
        [lineView setFrame:CGRectMake(curBut.frameX - lineDiff, lineView.frameY, curBut.frameWidth + diffWei * diffScale, lineView.frameHeight)];
    }
    
    CGRect rect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height);
    if (!CGRectContainsRect(rect, nextView.frame)) {
        CGFloat offMiddleX = nextView.frameX + nextView.frameWidth / 2 - self.frameWidth / 2;
        offMiddleX = MAX(0, offMiddleX);
        offMiddleX = MIN(self.contentSize.width - self.frameWidth, offMiddleX);
        [self setContentOffset:CGPointMake(offMiddleX, 0) animated:YES];
    }

    for (NSInteger i = 0; i < _buttonArray.count; i++) {
        UIButton *btn = _buttonArray[i];
        if (i == _selectedIndex) {
            CGFloat redDif = diffScale * (154 - 101),greenDif = diffScale * (125 - 101),blueDif = diffScale * (251 - 101);
            [btn setTitleColor:rgba(154 - redDif, 125 - greenDif, 251 - blueDif, 1) forState:UIControlStateNormal];
        }
        else if (i == nextIndex) {
            CGFloat redDif = diffScale * (154 - 101),greenDif = diffScale * (125 - 101),blueDif = diffScale * (251 - 101);
            [btn setTitleColor:rgba(101 + redDif, 101 + greenDif, 101 + blueDif, 1) forState:UIControlStateNormal];
        }
        else{
            [btn setTitleColor:KRGBCOLOR(101, 101, 101) forState:UIControlStateNormal];
        }
    }

}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex == selectedIndex) {
        return;
    }
    
    _selectedIndex = selectedIndex;
    for (NSInteger i = 0; i < _buttonArray.count; i++) {
        UIButton *btn = _buttonArray[i];
        if (i == _selectedIndex) {
            [btn setTitleColor:KRGBCOLOR(154, 125, 251) forState:UIControlStateNormal];
            if (btn.frameX != lineView.frameX || btn.frameWidth != lineView.frameWidth) {
                [UIView animateWithDuration:0.15 animations:^{
                    [lineView setFrame:CGRectMake(btn.frameX, lineView.frameY, btn.frameWidth, lineView.frameHeight)];
                } completion:nil];
            }
        }
        else {
            [btn setTitleColor:KRGBCOLOR(101, 101, 101) forState:UIControlStateNormal];
        }
    }
}

@end
