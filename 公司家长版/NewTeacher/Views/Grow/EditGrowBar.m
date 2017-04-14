//
//  EditGrowBar.m
//  NewTeacher
//
//  Created by songzhanglong on 15/6/11.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "EditGrowBar.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"

@implementation EditGrowBar

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor blackColor];
        
        CGFloat sendWei = 50.0;
        
        UIColor *textColor = [UIColor colorWithRed:105.0 / 255 green:92.0 / 255 blue:86.0 / 255 alpha:1.0];
        //label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, sendWei, frame.size.height - 10)];
        _tipLab = label;
        [label setBackgroundColor:[UIColor blackColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextAlignment:1];
        [label setTextColor:textColor];
        [self addSubview:label];
        
        //uitextfield
        UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(sendWei + 10  * 2, 5, frame.size.width - 10 * 4 - sendWei * 2, frame.size.height - 10)];
        _textField = textFiled;

        //垂直居中
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textFiled setBackgroundColor:textColor];
        textFiled.textColor = [UIColor whiteColor];
        textFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textFiled.delegate = self;
        [textFiled setClearButtonMode:UITextFieldViewModeWhileEditing];
        textFiled.returnKeyType = UIReturnKeyDone;
        [self addSubview:textFiled];
        
        //send
        UIButton *sendBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBut setBackgroundColor:[UIColor colorWithRed:254.0 / 255 green:177.0 / 255 blue:91.0 / 255 alpha:1]];
        [sendBut setFrame:CGRectMake(frame.size.width - 10 - sendWei, 5, sendWei, frame.size.height - 10)];
        sendBut.layer.masksToBounds = YES;
        sendBut.layer.cornerRadius = 2;
        [sendBut setTitle:@"完成" forState:UIControlStateNormal];
        [sendBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sendBut addTarget:self action:@selector(commitPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendBut];
        
        //监视键盘高度变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)commitPressed:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(commitEditInfo:)]) {
        [_delegate commitEditInfo:_textField.text];
    }
    
    [_textField resignFirstResponder];
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
    if (self.alpha == 0) {
        [father setUserInteractionEnabled:NO];
        [UIView animateWithDuration:0.35 animations:^(void) {
            [self setAlpha:1];
            [self setFrame:newRect];
        } completion:^(BOOL finished) {
            [father setUserInteractionEnabled:YES];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.35 animations:^(void) {
            [self setFrame:newRect];
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIView *father = [self superview];
    CGRect newRect = CGRectMake(self.frame.origin.x, father.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [father setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:0.35 animations:^(void) {
        [self setFrame:newRect];
    } completion:^(BOOL finished) {
        [father setUserInteractionEnabled:YES];
        [self removeFromSuperview];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self commitPressed:nil];
    return YES;
}

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField != _textField) {
        return;
    }
    
    NSString *toBeString = textField.text;
    NSString *lang = textField.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > _maxNum) {
                textField.text = [toBeString substringToIndex:_maxNum];
            }
            [self emojiStrSplit:textField.text];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > _maxNum) {
            textField.text = [toBeString substringToIndex:_maxNum];
        }
        [self emojiStrSplit:toBeString];
    }
}

- (void)emojiStrSplit:(NSString *)str
{
    int emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        int lenght = emoji % 10000;
        int location = emoji / 10000;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        [_textField setText:lastStr];
    }
    [_tipLab setText:[NSString stringWithFormat:@"%ld / %ld",(long)[_textField.text length],(long)_maxNum]];
}

@end
