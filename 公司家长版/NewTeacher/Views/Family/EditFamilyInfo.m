//
//  EditFamilyInfo.m
//  NewTeacher
//
//  Created by songzhanglong on 15/5/18.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "EditFamilyInfo.h"
#import "UIButton+WebCache.h"
#import "DJTGlobalManager.h"
#import "Toast+UIView.h"
#import "DJTIdentifierValidator.h"
#import "NSString+Common.h"
#import "DJTGlobalDefineKit.h"

#define COUNT 10000

@implementation EditFamilyInfo
{
    UIButton *_addressBut,*_changeNmBut,*_sure1But,*_sure2But,*_errorBut,*_cancelBut,*_bigCallBut;
    UILabel *_phoneLab,*_callLab;
    UIView *_lineView,*_midView;
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
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        
        //full but
        UIButton *fullBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [fullBut setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [fullBut setBackgroundColor:[UIColor clearColor]];
        [fullBut addTarget:self action:@selector(cancelSelf:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fullBut];
        
        //midview
        UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 20, 215)];
        _midView = midView;
        [midView setCenter:self.center];
        [midView setBackgroundColor:[UIColor whiteColor]];
        [midView.layer setMasksToBounds:YES];
        midView.layer.cornerRadius = 10;
        [self addSubview:midView];
        
        //cancel
        _cancelBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBut setFrame:CGRectMake(frame.size.width - 5 - 25, midView.frame.origin.y - 5, 25, 25)];
        [_cancelBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"closed2" ofType:@"png"]] forState:UIControlStateNormal];
        [_cancelBut addTarget:self action:@selector(cancelSelf:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelBut];
        
        //head
        UIView *headBack = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [headBack setBackgroundColor:[UIColor whiteColor]];
        headBack.layer.masksToBounds = YES;
        headBack.layer.cornerRadius = 25;
        headBack.layer.borderWidth = 0.5;
        headBack.layer.borderColor = [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:239 / 255.0 alpha:1.0].CGColor;
        [midView addSubview:headBack];
        
        _headBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headBut setFrame:CGRectMake(0, 0, 47, 47)];
        [_headBut setCenter:headBack.center];
        _headBut.layer.masksToBounds = YES;
        _headBut.layer.cornerRadius = 23.5;
        [_headBut addTarget:self action:@selector(changeHead:) forControlEvents:UIControlEventTouchUpInside];
        [_headBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"w17" ofType:@"png"]] forState:UIControlStateNormal];
        [midView addSubview:_headBut];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(70, 50, midView.frame.size.width - 70 - 60, 0.5)];
        [_lineView setBackgroundColor:[UIColor lightGrayColor]];
        [midView addSubview:_lineView];
        
        _nameField = [[UITextField alloc]initWithFrame:CGRectMake(70, _lineView.frame.origin.y - 30, _lineView.frame.size.width,30)];
        [_nameField setBackgroundColor:[UIColor whiteColor]];
        [_nameField setTextColor:[UIColor lightGrayColor]];
        [_nameField setFont:[UIFont systemFontOfSize:20]];
        _nameField.autocorrectionType = UITextAutocorrectionTypeNo;
        _nameField.contentVerticalAlignment = 0 ;
        _nameField.textColor = [UIColor lightGrayColor];
        _nameField.returnKeyType = UIReturnKeyDone;
        _nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _nameField.delegate = self;
        [midView addSubview:_nameField];
        
        //left buts
        _changeNmBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeNmBut setTitleColor:[UIColor colorWithRed:78 / 255.0 green:206 / 255.0 blue:58 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        [_changeNmBut setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [_changeNmBut setTitle:@"修改名片" forState:UIControlStateNormal];
        [_changeNmBut.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_changeNmBut setFrame:CGRectMake(midView.frame.size.width - 20 - 65, 25, 65, 20)];
        [_changeNmBut addTarget:self action:@selector(changeName:) forControlEvents:UIControlEventTouchUpInside];
        [_changeNmBut setTag:10];
        [midView addSubview:_changeNmBut];
        
        _sure1But = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sure1But setFrame:CGRectMake(midView.frame.size.width - 20 - 30, _nameField.frame.origin.y, 30, 30)];
        [_sure1But setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gou1@2x" ofType:@"png"]] forState:UIControlStateNormal];
        [_sure1But setTag:11];
        [_sure1But addTarget:self action:@selector(changeName:) forControlEvents:UIControlEventTouchUpInside];
        [midView addSubview:_sure1But];
        
        //mid field
        UIView *midField = [[UIView alloc] initWithFrame:CGRectMake(0, 70, midView.frame.size.width, 70)];
        [midField setBackgroundColor:[UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:239 / 255.0 alpha:1.0]];
        [midField addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkLastInfo:)]];
        [midView addSubview:midField];
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 23, 260, 24)];
        [tipLab setBackgroundColor:[UIColor clearColor]];
        [tipLab setFont:[UIFont systemFontOfSize:20]];
        [tipLab setTextColor:[UIColor blackColor]];
        [tipLab setText:@"给他分享宝宝的最新动态!"];
        [midField addSubview:tipLab];
        
        //bottom
        _addressBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addressBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"w10-1" ofType:@"png"]] forState:UIControlStateNormal];
        [_addressBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"w10" ofType:@"png"]] forState:UIControlStateSelected];
        [_addressBut setFrame:CGRectMake(20, 160, 24, 24)];
        [_addressBut addTarget:self action:@selector(selectAddressbook:) forControlEvents:UIControlEventTouchUpInside];
        [midView addSubview:_addressBut];
        
        _phoneLab = [[UILabel alloc] initWithFrame:CGRectMake(50, _addressBut.frame.origin.y, midView.frame.size.width - 50 - 10 - 10 - 70, 24)];
        [_phoneLab setFont:[UIFont systemFontOfSize:20]];
        [_phoneLab setTextColor:[UIColor colorWithRed:0 green:132 / 255.0 blue:238 / 255.0 alpha:1.0]];
        [_phoneLab setBackgroundColor:[UIColor clearColor]];
        [_phoneLab setBackgroundColor:[UIColor clearColor]];
        [midView addSubview:_phoneLab];
        
        _callLab = [[UILabel alloc] initWithFrame:CGRectMake(_phoneLab.frame.origin.x + 20, _phoneLab.frame.origin.y + _phoneLab.frame.size.height + 2, 70, 16)];
        [_callLab setText:@"修改号码"];
        [_callLab setFont:[UIFont systemFontOfSize:14]];
        [_callLab setTextColor:[UIColor lightGrayColor]];
        [_callLab setBackgroundColor:[UIColor clearColor]];
        [midView addSubview:_callLab];
        
        _bigCallBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bigCallBut setBackgroundColor:[UIColor clearColor]];
        [_bigCallBut setFrame:CGRectMake(_phoneLab.frame.origin.x, _phoneLab.frame.origin.y, _callLab.frame.size.width, _callLab.frame.origin.y + _callLab.frame.size.height)];
        [_bigCallBut addTarget:self action:@selector(callTelphone:) forControlEvents:UIControlEventTouchUpInside];
        [midView addSubview:_bigCallBut];
        
        //
        _errorBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_errorBut setFrame:CGRectMake(midView.frame.size.width - 70 - 10, _phoneLab.frame.origin.y + 2 - 4, 70, 32)];
        [_errorBut setBackgroundColor:CreateColor(245, 106, 74)];
        [_errorBut setTitle:@"分享" forState:UIControlStateNormal];
        [_changeNmBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_errorBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_errorBut.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [_errorBut addTarget:self action:@selector(errorTelphone:) forControlEvents:UIControlEventTouchUpInside];
        [midView addSubview:_errorBut];
        
        //phone
        _phoneField = [[UITextField alloc]initWithFrame:CGRectMake(_phoneLab.frame.origin.x, _phoneLab.frame.origin.y, midView.frame.size.width - 50 - 20 - 55,_phoneLab.frame.size.height)];
        [_phoneField setBackgroundColor:midField.backgroundColor];
        _phoneField.layer.masksToBounds = YES;
        _phoneField.layer.cornerRadius = 2.0;
        _phoneField.placeholder = @"填写手机号码";
        _phoneField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneField.autocorrectionType = UITextAutocorrectionTypeNo;
        _phoneField.contentVerticalAlignment = 0 ;
        _phoneField.textColor = _phoneLab.textColor;
        _phoneField.returnKeyType = UIReturnKeyDone;
        _phoneField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _phoneField.delegate = self;
        [midView addSubview:_phoneField];
        
        _sure2But = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sure2But setFrame:CGRectMake(midView.frame.size.width - 10 - 55, _phoneLab.frame.origin.y, 55, _phoneLab.frame.size.height)];
        _sure2But.layer.masksToBounds = YES;
        _sure2But.layer.cornerRadius = 2.0;
        [_sure2But setBackgroundColor:_changeNmBut.titleLabel.textColor];
        [_sure2But setTitle:@"确定" forState:UIControlStateNormal];
        [_sure2But setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeNmBut setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [_sure2But addTarget:self action:@selector(changePhoneNumber:) forControlEvents:UIControlEventTouchUpInside];
        [midView addSubview:_sure2But];
        
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

- (void)setEditTyppe:(kEditType)editTyppe
{
    _editTyppe = editTyppe;
    BOOL isAdd = (editTyppe == kEditTypeAdd);
    _lineView.hidden = !isAdd;
    _changeNmBut.hidden = ((editTyppe == kEditTypeCheck) || isAdd);
    _sure1But.hidden = ((editTyppe == kEditTypeCheck) || !isAdd);
    _nameField.userInteractionEnabled = !_sure1But.hidden;
    _callLab.hidden = isAdd;
    _addressBut.selected = isAdd;
    _phoneField.hidden = !isAdd;
    _phoneLab.hidden = isAdd;
    _bigCallBut.hidden = isAdd;
    _errorBut.hidden = isAdd;
    _sure2But.hidden = !isAdd;
    _phoneField.userInteractionEnabled = !_sure2But.hidden;
}

- (void)setFamilyModel:(FamilNumberModel *)familyModel
{
    if (_familyModel == familyModel) {
        if (_nameField.userInteractionEnabled) {
            [_nameField becomeFirstResponder];
        }
        
        return;
    }
    
    _familyModel = familyModel;
    _phoneLab.text = familyModel.mobile;
    _phoneField.text = familyModel.mobile;
    _nameField.text = familyModel.name;
    NSString *url = familyModel.face;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    
    [_headBut setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[DJTGlobalManager shareInstance] getFamilyPicture:familyModel.name] ofType:@"png"]]];

    if (((_editTyppe == kEditTypeAdd) && (familyModel && !familyModel.id)) || (_editTyppe == kEditTypeCheck)) {
        //新增直系亲属
        _sure1But.hidden = YES;
        _nameField.userInteractionEnabled = NO;
        _lineView.hidden = YES;
        _changeNmBut.hidden = YES;
        if (_phoneField.userInteractionEnabled) {
            [_phoneField becomeFirstResponder];
        }
    }
    else
    {
        if (_nameField.userInteractionEnabled) {
            [_nameField becomeFirstResponder];
        }
    }
}

#pragma mark - actions
- (void)changeHead:(id)sender
{
    [self cancelFirstResponder];
    if (_delegate && [_delegate respondsToSelector:@selector(changeFace:)]) {
        [_delegate changeFace:self];
    }
}

- (void)changeName:(id)sender
{
    BOOL respon = (([sender tag] - 10) == 0);
    _sure1But.hidden = !respon;
    _changeNmBut.hidden = respon;
    _lineView.hidden = !respon;
    if (!respon) {
        [_nameField resignFirstResponder];
        _nameField.userInteractionEnabled = NO;
        if (_phoneField.isFirstResponder) {
            [_phoneField resignFirstResponder];
        }
    }
    else
    {
        _nameField.userInteractionEnabled = YES;
        [_nameField becomeFirstResponder];
    }
    
    if (!respon) {
        //非新增，直接提交姓名
        if (_editTyppe != kEditTypeAdd) {
            if (!_nameField.text || [_nameField.text length] <= 0) {
                [self makeToast:@"请输入用户名" duration:1.0 position:@"center"];
                return;
            }
            
            _commitType = kCommitTypeName;
            if (_delegate && [_delegate respondsToSelector:@selector(editFamilyInfo:Name:Phone:)]) {
                [_delegate editFamilyInfo:self Name:_nameField.text Phone:_familyModel.mobile];
            }
        }
    }
}

- (void)checkLastInfo:(UITapGestureRecognizer *)tap
{
    [self cancelFirstResponder];
    if (_editTyppe == kEditTypeAdd) {
        [self makeToast:@"请先完善信息" duration:1.0 position:@"center"];
        return;
    }
    
    if (_sure1But.hidden && _sure2But.hidden) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectFamilyDynamic:)]) {
            [_delegate selectFamilyDynamic:self];
        }
    }
}

- (void)selectAddressbook:(id)sender
{
    [self cancelFirstResponder];
    if (!_sure2But.hidden) {
        if (_delegate && [_delegate respondsToSelector:@selector(checkAddressBook:)]) {
            [_delegate checkAddressBook:self];
        }
    }
}

- (void)cancelFirstResponder
{
    if (_phoneField.isFirstResponder) {
        [_phoneField resignFirstResponder];
    }
    else if (_nameField.isFirstResponder)
    {
        [_nameField resignFirstResponder];
    }
}

- (void)cancelSelf:(id)sender
{
    [self cancelFirstResponder];
    __weak typeof(self)weakSelf = self;
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf cancelSelfFormSuper];
    }];
}

- (void)cancelSelfFormSuper
{
    if (_delegate && [_delegate respondsToSelector:@selector(cancelEditInfo:)]) {
        [_delegate cancelEditInfo:self];
    }
    [self removeFromSuperview];
}

- (void)callTelphone:(id)sender
{
    /*
    [self cancelFirstResponder];
    
    
    if (!_phoneLab.text || [_phoneLab.text length] <= 0) {
        [self makeToast:@"暂无手机号" duration:1.0 position:@"center"];
        return;
    }
    
    UIWebView*callWebview = [[UIWebView alloc] init];
    NSString *url = [NSString stringWithFormat:@"tel:%@",_phoneLab.text];
    NSURL *telURL = [NSURL URLWithString:url];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    [self addSubview:callWebview];
     */
    
    _errorBut.hidden = YES;
    _phoneLab.hidden = YES;
    _bigCallBut.hidden = YES;
    _callLab.hidden = YES;
    _addressBut.selected = YES;
    _sure2But.hidden = NO;
    _phoneField.hidden = NO;
    _phoneField.userInteractionEnabled = YES;
    [_phoneField becomeFirstResponder];
}

- (void)errorTelphone:(id)sender
{
    [self checkLastInfo:nil];
}

- (void)changePhoneNumber:(id)sender
{
    //新增必须点击确定后一起提交
    /*
    if (_editTyppe == kEditTypeAdd) {
        if (!_nameField.text || [_nameField.text length] <= 0) {
            [self makeToast:@"请输入用户名" duration:1.0 position:@"center"];
            return;
        }
    }
     */
    
    [self cancelFirstResponder];
    if (!_nameField.text || [_nameField.text length] <= 0) {
        [self makeToast:@"请输入用户名" duration:1.0 position:@"center"];
        return;
    }
    
    if (!_phoneField.text || [_phoneField.text length] <= 0) {
        [self makeToast:@"请输入手机号" duration:1.0 position:@"center"];
        return;
    }
    else if (![DJTIdentifierValidator isValidPhone:_phoneField.text])
    {
        [self makeToast:@"手机号格式错误" duration:1.0 position:@"center"];
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(editFamilyInfo:Name:Phone:)]) {
        if (_commitType == kCommitTypeImage) {
            _commitType = kCommitTypeAll;
        }else{
            _commitType = kCommitTypePhone;
        }
        [_delegate editFamilyInfo:self Name:_nameField.text Phone:_phoneField.text];
    }
}

- (void)cancelPhoneEdit
{
    _errorBut.hidden = NO;
    _phoneLab.hidden = NO;
    _phoneLab.text = _phoneField.text;
    _callLab.hidden = NO;
    _bigCallBut.hidden = NO;
    _addressBut.selected = NO;
    _sure2But.hidden = YES;
    _phoneField.userInteractionEnabled = NO;
    _phoneField.hidden = YES;
}

- (void)cancelNameEdit
{
    _sure1But.hidden = YES;
    _changeNmBut.hidden = NO;
    _lineView.hidden = YES;
    _nameField.userInteractionEnabled = NO;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    NSInteger maxLength = 4;
    if (textField == _phoneField) {
        maxLength = 11;
    }
    
    NSString *toBeString = textField.text;
    NSString *lang = textField.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > maxLength) {
                textField.text = [toBeString substringToIndex:maxLength];
            }
    
            [self emojiStrSplit:textField.text Phone:(textField == _phoneField)];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > maxLength) {
            textField.text = [toBeString substringToIndex:maxLength];
        }
        
        [self emojiStrSplit:textField.text Phone:(textField == _phoneField)];
    }
}

- (void)emojiStrSplit:(NSString *)str Phone:(BOOL)phone
{
    int emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        int lenght = emoji % COUNT;
        int location = emoji / COUNT;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        if (phone) {
            [_phoneField setText:lastStr];
        }
        else
        {
            [_nameField setText:lastStr];
        }
    }
    
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat diffence = self.frame.size.height - ((self.frame.size.height - _midView.frame.size.height) / 2 + _phoneField.frame.origin.y + _phoneField.frame.size.height);
    if (keyboardRect.size.height > diffence) {
        [_midView setCenter:CGPointMake(self.center.x, self.center.y - (keyboardRect.size.height - diffence))];
        [_cancelBut setFrame:CGRectMake(self.frame.size.width - 5 - 25, _midView.frame.origin.y - 5, 25, 25)];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!CGPointEqualToPoint(_midView.center, self.center)) {
        _midView.center = self.center;
        [_cancelBut setFrame:CGRectMake(self.frame.size.width - 5 - 25, _midView.frame.origin.y - 5, 25, 25)];
        
    }
}

@end
