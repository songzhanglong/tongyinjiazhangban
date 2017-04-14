//
//  DJTInputBar.m
//  MZJD
//
//  Created by songzhanglong on 14-4-29.
//  Copyright (c) 2014年 DIGIT. All rights reserved.
//

#import "InputBar.h"
#import "DJTGlobalManager.h"
#import "NSString+Common.h"
#import "DJTGlobalDefineKit.h"
#define COUNT 10000
@implementation InputBar
{
    UIButton *_sendButton;
}

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
        
        self.backgroundColor = [UIColor colorWithRed:88.0 / 255 green:73.0 / 255 blue:67.0 / 255 alpha:1.0];
        
        float sendWei = 54.0;
        
        //uitextfield
        UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10 - sendWei, frame.size.height - 10)];
        _textField = textFiled;
        UIColor *color = [UIColor whiteColor];
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
        //垂直居中
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [textFiled setBackgroundColor:[UIColor colorWithRed:105.0 / 255 green:92.0 / 255 blue:86.0 / 255 alpha:1.0]];
        textFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textFiled.delegate = self;
        textFiled.textColor = [UIColor whiteColor];
        textFiled.returnKeyType = UIReturnKeyDone;
        [self addSubview:textFiled];
        
        //send
        UIButton *sendBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton = sendBut;
        [sendBut setBackgroundColor:[UIColor colorWithRed:254.0 / 255 green:177.0 / 255 blue:91.0 / 255 alpha:1]];
        [sendBut setFrame:CGRectMake(frame.size.width - 5 - sendWei, 5, sendWei, frame.size.height - 10)];
        [sendBut setTitle:@"回复" forState:UIControlStateNormal];
        [sendBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sendBut addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)setBackgroundColorToType
{
    self.backgroundColor = CreateColor(239, 244, 248);
    
    CGRect frame = _textField.frame;
    frame.size.width -= 15;
    frame.origin.x += 5;
    [_textField setFrame:frame];
    _textField.layer.masksToBounds = YES;
    _textField.layer.cornerRadius = 2.0;
    [_textField setBackgroundColor:[UIColor whiteColor]];
    _textField.textColor = [UIColor blackColor];
    UIColor *color = [UIColor blackColor];
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
    
    _sendButton.backgroundColor = CreateColor(52, 96, 233);
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.cornerRadius = 2.0;
}

- (void)buttonPressed:(id)sender
{
    if(_textField.text!=nil&&![_textField.text isEqualToString:@""]){
        [_textField resignFirstResponder];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(sendComment:)]) {
        [_delegate sendComment:_textField.text];
    }
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    if (_delegate && [_delegate respondsToSelector:@selector(changeViewHeight:)]) {
        [_delegate changeViewHeight:keyboardRect.size.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (_delegate && [_delegate respondsToSelector:@selector(changeViewHeight:)]) {
        [_delegate changeViewHeight:0];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(cancelIndexPath)]) {
        [_delegate cancelIndexPath];
    }
    [textField resignFirstResponder];
    return YES;
}
/*
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 {
 BOOL emoji = [NSString isContainsEmoji:string];
 return !emoji;
 }
 */
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
    int emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        int lenght = emoji % COUNT;
        int location = emoji / COUNT;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        [_textField setText:lastStr];
    }
    
}

@end
