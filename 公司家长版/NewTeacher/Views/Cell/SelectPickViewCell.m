//
//  SelectPickViewCell.m
//  ChildrenKing
//
//  Created by songzhanglong on 15/3/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectPickViewCell.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"
#import "DJTGlobalManager.h"

@implementation SelectPickViewCell
{
    NSString *timerString;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //监视键盘高度变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 11.5, 120, 21)];
        [self.contentView addSubview:_tipLabel];
        
        //CGFloat imgWei = 6.0;//iPhone6Plus ? 8.0 : (iPhone6 ? 7.0 : 6.0);
        
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(180, 7, winSize.width - 200, 30)];
        _textField = field;
        //_textField.textAlignment = 2;
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self resetInputViewAndAccessoryView];
        self.textField.inputAccessoryView = [self getInputAccessoryView];
        [self.contentView addSubview:field];
        
        timerString = [NSString stringByDate:@"yyyy-MM-dd" Date:[NSDate date]];

        //        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height - 1, winSize.width - 10, 1)];
//        [lineView setBackgroundColor:G_ORANGE_COLOR];
//        [lineView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
//        [self.contentView addSubview:lineView];
    }
    
    return self;
}

- (void)resetInputViewAndAccessoryView
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    // 初始化UIDatePicker
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 216)];
    // 设置时区
    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    // 设置当前显示时间
    [datePicker setDate:[NSDate date] animated:YES];
    // 设置显示最大时间（此处为当前时间）
    // 设置UIDatePicker的显示模式
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    // 当值发生改变的时候调用的方法
    datePicker.maximumDate = [NSDate date];
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
    datePicker.locale = locale;
    
    _textField.inputView = datePicker;
}

/**
 *	@brief	获取inputAccessoryView，如无，则新建
 *
 *	@return	UIToolbar
 */
- (UIToolbar *)getInputAccessoryView
{
    //inputAccessoryView
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIToolbar *_inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, winSize.width, 44)];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doresignFirstResponderOfTextField:)];
    [left setTag:1];
    UIBarButtonItem *apace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    apace.width = [[UIScreen mainScreen] bounds].size.width - 120;

    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doresignFirstResponderOfTextField:)];
    [right setTag:2];
    _inputAccessoryView.items = [NSArray arrayWithObjects:left,apace,right, nil];
    return _inputAccessoryView;
}

- (void)doresignFirstResponderOfTextField:(id)sender
{
    [_textField resignFirstResponder];
    
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    if (item.tag == 2) {
        if (_delegate && [_delegate respondsToSelector:@selector(pickChangeContent:)]) {
            [_delegate pickChangeContent:timerString];
        }
    }
}

- (void)datePickerValueChanged:(id)sender
{
    NSDate *date = [(UIDatePicker *)sender date];
    NSString *time = [NSString stringByDate:@"yyyy-MM-dd" Date:date];
    [_textField setText:time];
    timerString = time;
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!_textField.isFirstResponder) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    UITableView *tableView = [DJTGlobalManager viewController:self Class:[UITableView class]];
    UIViewController *control = [DJTGlobalManager viewController:tableView Class:[UIViewController class]];
    CGRect cellRect = [control.view convertRect:self.frame fromView:tableView];
    
    if (cellRect.size.width == 0) {
        return;
    }
    
    CGFloat diffence = (control.view.frame.size.height - cellRect.origin.y - cellRect.size.height) - keyboardRect.size.height;
    if (diffence < 0) {
        CGRect tabRect = tableView.frame;
        [tableView setFrame:CGRectMake(tabRect.origin.x, diffence, tabRect.size.width, tabRect.size.height)];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UITableView *tableView = [DJTGlobalManager viewController:self Class:[UITableView class]];
    CGRect tabRect = tableView.frame;
    if (tabRect.origin.y == 0) {
        return;
    }
    [tableView setFrame:CGRectMake(tabRect.origin.x, 0, tabRect.size.width, tabRect.size.height)];
}

@end
