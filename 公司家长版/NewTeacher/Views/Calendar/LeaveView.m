//
//  LeaveView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/8/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "LeaveView.h"
#import "Toast+UIView.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"

@implementation LeaveView
{
    UIView *_backView;
    UILabel *_dayLabel;
    UITextField *_beginField,*_endField;
    UITextView *_textView;
    
    UIButton *_type1,*_type2;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        
        [self createFullButton:self];
        
        //监视键盘高度变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        UIColor *lightColor = CreateColor(203, 208, 211);
        UIColor *greenColor = CreateColor(81, 186, 83);
        UIColor *orangeColor = CreateColor(252, 183, 105);
        
        
        
        //white view
        CGFloat hei = 340;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - hei, frame.size.width, hei)];
        _backView = backView;
        [backView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [backView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:backView];
        
        [backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackView:)]];
        
        //tips
        NSArray *tmpArr = @[@"请假时间  *必填",@"请假类型  *必填"];
        for (NSInteger i = 0; i < 2; i++) {
            UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 4 + 110 * i, (frame.size.width - 40) / 2, 30)];
            NSString *tipStr = tmpArr[i];
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:tipStr];
            NSRange secRange = [tipStr rangeOfString:@"*必填"];
            NSRange oneRange = NSMakeRange(0, secRange.location - 1);
            [attributedStr addAttribute:NSForegroundColorAttributeName value:orangeColor range:secRange];
            [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:secRange];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:oneRange];
            [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:oneRange];
            [timeLab setAttributedText:attributedStr];
            [backView addSubview:timeLab];
            
            UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(timeLab.frame.origin.x, timeLab.frame.size.height + 1 + timeLab.frame.origin.y, timeLab.frame.size.width, 1)];
            [lineLab setTextColor:[UIColor lightGrayColor]];
            [lineLab setText:@"-------------------------------------"];
            [lineLab setTextAlignment:1];
            [lineLab setLineBreakMode:NSLineBreakByClipping];
            [backView addSubview:lineLab];
        }
        
        //day
        _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2, 4, frame.size.width / 2 - 20, 30)];
        [_dayLabel setTextAlignment:2];
        [backView addSubview:_dayLabel];
        [self resetDayNumber:@"0"];
        
        //time
        NSArray *timeArr = @[@"开始时间:",@"结束时间:"];
        CGFloat imgWei = 180,imgHei = 27;
        for (NSInteger i = 0; i < 2; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5 + 36 + 12 + (8 + imgHei) * i, frame.size.width - 40 - imgWei - 2, imgHei)];
            [label setTextAlignment:2];
            [label setTextColor:[UIColor lightGrayColor]];
            [label setText:timeArr[i]];
            [backView addSubview:label];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 20 - imgWei, label.frame.origin.y, imgWei, imgHei)];
            [imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leave2" ofType:@"png"]]];
            [backView addSubview:imgView];
            
            //textfield
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + 2, imgView.frame.origin.y, imgView.frame.size.width - 4 - 24, imgView.frame.size.height)];
            textField.inputView = [self createInputView];
            textField.inputAccessoryView = [self createInputAccessoryView];
            if (i == 0) {
                _beginField = textField;
            }
            else
            {
                _endField = textField;
            }
            [backView addSubview:textField];
        }
        
        //type
        NSArray *types = @[@"病假",@"事假"];
        CGFloat butWei = 85,butHei = 26;
        for (NSInteger i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(frame.size.width - butWei - 20 - (butWei + 10) * i, 160, butWei, butHei)];
            [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leave1" ofType:@"png"]] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leave1H" ofType:@"png"]] forState:UIControlStateSelected];
            [button setTitle:types[i] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:greenColor forState:UIControlStateSelected];
            [backView addSubview:button];
            
            if (i == 0) {
                _type1 = button;
            }
            else
            {
                _type2 = button;
            }
        }
        
        //tip
        UILabel *otherTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 186, (frame.size.width - 40) / 2, 26)];
        NSString *otherStr = @"备注  选填";
        NSMutableAttributedString *otherAttri = [[NSMutableAttributedString alloc]initWithString:otherStr];
        NSRange otherRange1 = [otherStr rangeOfString:@"选填"];
        NSRange otherRange2 = NSMakeRange(0, otherRange1.location - 1);
        [otherAttri addAttribute:NSForegroundColorAttributeName value:orangeColor range:otherRange1];
        [otherAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:otherRange1];
        [otherAttri addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:otherRange2];
        [otherAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:otherRange2];
        [otherTip setAttributedText:otherAttri];
        [backView addSubview:otherTip];
        
        //textViev
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 212, frame.size.width - 40, 72)];
        [_textView setBackgroundColor:lightColor];
        [_textView setTextColor:[UIColor blackColor]];
        _textView.delegate = self;
        [backView addSubview:_textView];
        
        //buttons
        NSArray *tips = @[@"取消",@"确定"];
        for (NSInteger i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:tips[i] forState:UIControlStateNormal];
            [button setTag:i + 1];
            [button setBackgroundColor:(i == 0) ? lightColor : greenColor];
            [button addTarget:self action:@selector(commitInfo:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:(i == 0) ? [UIColor blackColor] : [UIColor whiteColor] forState:UIControlStateNormal];
            [button setFrame:CGRectMake((frame.size.width / 2) * i, hei - 40, frame.size.width / 2, 40)];
            [button setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
            [backView addSubview:button];
        }
        
    }
    return self;
}

- (void)createFullButton:(UIView *)father
{
    //full button
    UIButton *fullBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullBut setBackgroundColor:[UIColor clearColor]];
    [fullBut setFrame:CGRectMake(0, 0, father.frame.size.width, father.frame.size.height)];
    [fullBut addTarget:self action:@selector(clearSelf:) forControlEvents:UIControlEventTouchUpInside];
    [father addSubview:fullBut];
}

- (void)touchBackView:(UITapGestureRecognizer *)tap
{
    [self resignTowFields];
}

- (void)resignTowFields
{
    if (_beginField.isFirstResponder) {
        [_beginField resignFirstResponder];
    }
    else if (_endField.isFirstResponder)
    {
        [_endField resignFirstResponder];
    }
    else if (_textView.isFirstResponder)
    {
        [_textView resignFirstResponder];
    }
}

- (void)hideKeyboadr:(id)sender
{
    [self resignTowFields];
}

- (void)confirmContent:(id)sender
{
    UITextField *textField = _beginField.isFirstResponder ? _beginField : _endField;
    UIDatePicker *dataPicker = (UIDatePicker *)textField.inputView;
    NSDate *date = [dataPicker date];
    NSString *time = [NSString stringByDate:@"yyyy-MM-dd HH:mm" Date:date];
    [textField setText:time];
    
    [self resignTowFields];
}

- (void)selectType:(UIButton *)button
{
    if (button == _type1) {
        _type1.selected = !_type1.selected;
        if (_type1.selected && _type2.selected) {
            _type2.selected = NO;
        }
    }
    else
    {
        _type2.selected = !_type2.selected;
        if (_type2.selected && _type1.selected) {
            _type1.selected = NO;
        }
    }
}

- (void)showInView:(UIView *)father
{
    self.userInteractionEnabled = NO;
    self.alpha = 0;
    [father addSubview:self];
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
}

- (UIView *)createInputAccessoryView
{
    //inputAccessoryView
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 44)];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboadr:)];
    item1.width = 40;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    CGFloat wei = winSize.width - 40 * 3;
    space.width = wei;
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmContent:)];
    item2.width = 40;
    toolBar.items = @[item1,space,item2];
    return toolBar;
}

- (UIView *)createInputView
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    // 初始化UIDatePicker
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 180)];
    // 设置时区
    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    // 设置当前显示时间
    [datePicker setDate:[NSDate date] animated:YES];

    // 设置UIDatePicker的显示模式
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];

    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
    datePicker.locale = locale;
    return datePicker;
}

- (void)datePickerValueChanged:(id)sender
{
    NSDate *date = [(UIDatePicker *)sender date];
    NSString *time = [NSString stringByDate:@"yyyy-MM-dd HH:mm" Date:date];
    if (_beginField.isFirstResponder) {
        [_beginField setText:time];
    }
    else if (_endField.isFirstResponder)
    {
        [_endField setText:time];
    }
}

- (void)resetDayNumber:(NSString *)str
{
    NSString *dayTip = [NSString stringWithFormat:@"共%@天",str];
    NSMutableAttributedString *dayAttri = [[NSMutableAttributedString alloc]initWithString:dayTip];
    NSRange daySec = [dayTip rangeOfString:str];
    NSRange dayOne = NSMakeRange(0, 1);
    NSRange dayThird = NSMakeRange(dayTip.length - 1, 1);
    [dayAttri addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:daySec];
    [dayAttri addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:dayOne];
    [dayAttri addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:dayThird];
    [dayAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:daySec];
    [dayAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:dayOne];
    [dayAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:dayThird];
    [_dayLabel setAttributedText:dayAttri];
}

- (void)clearSelf:(id)sender
{
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
        return;
    }
    else if (_beginField.isFirstResponder)
    {
        [_beginField resignFirstResponder];
        return;
    }
    else if (_endField.isFirstResponder)
    {
        [_endField resignFirstResponder];
        return;
    }
    
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
}

- (void)commitInfo:(UIButton *)button
{
    if (button.tag - 1 == 0) {
        [self clearSelf:nil];
    }
    else
    {
        
    }
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!_textView.isFirstResponder) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGRect tabRect = _backView.frame;
    [_backView setFrame:CGRectMake(tabRect.origin.x, self.frame.size.height - tabRect.size.height - keyboardRect.size.height, tabRect.size.width, tabRect.size.height)];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect tabRect = _backView.frame;
    [_backView setFrame:CGRectMake(tabRect.origin.x, self.frame.size.height - tabRect.size.height, tabRect.size.width, tabRect.size.height)];
}

@end
