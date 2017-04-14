//
//  DJTLoginView.m
//  GoOnBaby
//
//  Created by user7 on 11/18/14.
//  Copyright (c) 2014 Summer. All rights reserved.
//

#import "DJTLoginView.h"
#import "Toast+UIView.h"
#import "DJTIdentifierValidator.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"
#import "Toast+UIView.h"
#import "AudioToolbox/AudioToolbox.h"
#import <TencentOpenAPI/QQApiInterface.h>

#pragma mark - 视图比例
//up
#define TOP_HEIGHT      (543.0 / 1136.0)


#define MIDDLE_HEIGHT   (180.0 / 1136.0)
#define BOTTOM_HEIGHT   (413.0 / 1136.0)
#define DOWN_HEIGHT     (128.0 / 1136.0)

//#define CURENT_HEIGHT   1136.0

@implementation DJTLoginView
{
    UIButton *_userLoginBtn;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    
    self.backgroundColor = [UIColor colorWithRed:237/255.0 green:248/255.0 blue:250/255.0 alpha:1];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat maxHei = winSize.height;
    CGFloat topHei = maxHei * TOP_HEIGHT;
    CGFloat midHei = maxHei * MIDDLE_HEIGHT;
    CGFloat bottomHei = maxHei * BOTTOM_HEIGHT;
    
    //tip
    UIImageView *tipLog = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d9" ofType:@"png"]]];
    tipLog.frame = CGRectMake(winSize.width - 40, 30, 30, 60);
    [self addSubview:tipLog];
    
    if ([QQApiInterface isQQInstalled]){
        UIButton *qqBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [qqBut setFrame:CGRectMake(tipLog.frameX, tipLog.frameBottom + 5, 30, 30)];
        [qqBut setImage:CREATE_IMG(@"qqLogo") forState:UIControlStateNormal];
        [qqBut addTarget:self action:@selector(launchQQ:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:qqBut];
    }
    
    //header
    UIImageView *headerImg = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d7" ofType:@"png"]]];
    CGFloat headWei = 186,headHei = 168;
    headerImg.frame = CGRectMake((winSize.width - headWei) / 2, (topHei - headHei) * 2 / 3, headWei, headHei);
    [self addSubview:headerImg];
    
    //middle
    UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(0, topHei, winSize.width, midHei)];
    nameView.backgroundColor = [UIColor whiteColor];
    [self addSubview:nameView];
    
    NSArray *leftTips = @[@"d1",@"d2"];
    NSArray *holds = @[@"请输入手机账号",@"请输入密码"];
    CGFloat hei = midHei / 2;
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(0, hei, winSize.width, 1)];
    [midLine setBackgroundColor:CreateColor(237, 241, 242)];
    [nameView addSubview:midLine];
    
    //已有账号
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *loginAccount = [userDefault objectForKey:LOGIN_ACCOUNT];
    NSString *loginPass = [userDefault objectForKey:LOGIN_PASSWORD];
    for (NSInteger i = 0; i < 2; i++) {

        UIImageView *leftImg = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:leftTips[i] ofType:@"png"]]];
        [leftImg setBackgroundColor:[UIColor whiteColor]];
        leftImg.frame = CGRectMake(35, nameView.frame.origin.y + (hei - 21) / 2 + hei * i, 21, 21);
        [self addSubview:leftImg];
        
        CGFloat xOri = leftImg.frame.origin.x + leftImg.frame.size.width + 20;
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(xOri, leftImg.frame.origin.y - 4.5, winSize.width - xOri - 10, 30)];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.placeholder = holds[i];
        textField.text = ((i == 0) ? loginAccount : loginPass);
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.textAlignment = 0;
        textField.contentVerticalAlignment = 0 ;
        textField.textColor = [UIColor blackColor];
        textField.returnKeyType = UIReturnKeySend;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.delegate = self;
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setKeyboardType:((i == 0) ? UIKeyboardTypeNumberPad : UIKeyboardTypeASCIICapable)];
        textField.secureTextEntry = (i != 0);
        if (i == 0) {
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            _nameField = textField;
        }
        else
        {
            _passField = textField;
        }
        [self addSubview:textField];
        
        
    }
    
    
    //rember
    UIButton *remberPasBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _remberBut = remberPasBut;
    [remberPasBut setFrame:CGRectMake(35,topHei + midHei + 5, 20, 20)];
    [remberPasBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d3_1" ofType:@"png"]] forState:UIControlStateSelected];
    [remberPasBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d3" ofType:@"png"]] forState:UIControlStateNormal];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isrember = [userDefaults boolForKey:LOGIN_REMBER];
    remberPasBut.selected = !isrember;
    [remberPasBut addTarget:self action:@selector(remberPass:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:remberPasBut];
    
    UILabel *remberPasLab = [[UILabel alloc] initWithFrame:CGRectMake(remberPasBut.frame.origin.x + remberPasBut.frame.size.width + 2, remberPasBut.frame.origin.y, 70, 20)];
    remberPasLab.textColor = CreateColor(32, 31, 32);
    remberPasLab.text = @"记住密码";
    [remberPasLab setFont:[UIFont systemFontOfSize:12]];
    remberPasLab.backgroundColor = [UIColor clearColor];
    [self addSubview:remberPasLab];
    
    //agreement
    UIButton *agreementBut1 = [UIButton buttonWithType:UIButtonTypeCustom];
    agreementBut1.tag = 100;
    [agreementBut1 setFrame:CGRectMake(remberPasLab.frame.origin.x + remberPasLab.frame.size.width - 5,topHei + midHei + 5, 20, 20)];
    [agreementBut1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d3_1" ofType:@"png"]] forState:UIControlStateSelected];
    [agreementBut1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d3" ofType:@"png"]] forState:UIControlStateNormal];
    agreementBut1.selected = YES;
    [agreementBut1 addTarget:self action:@selector(agreementBut:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:agreementBut1];
    
    UIButton *agreementBut2 = [UIButton buttonWithType:UIButtonTypeCustom];
    agreementBut2.tag = 200;
    [agreementBut2 setFrame:CGRectMake(agreementBut1.frame.origin.x + agreementBut1.frame.size.width + 2,remberPasBut.frame.origin.y , 70, 20)];
    [agreementBut2.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [agreementBut2 setTitle:@"使用协议" forState:UIControlStateNormal];
    [agreementBut2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [agreementBut2 setTitleColor:CreateColor(32, 31, 32) forState:UIControlStateNormal];
    [agreementBut2 addTarget:self action:@selector(agreementBut:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:agreementBut2];
    
    //forget
    UIImageView *forgetImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d3_2" ofType:@"png"]]];
    forgetImgView.frame = CGRectMake(winSize.width - 112,remberPasBut.frame.origin.y , 20, 20);
    [self addSubview:forgetImgView];
    
    UIButton *forgetBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetBut setFrame:CGRectMake(winSize.width - 90,remberPasBut.frame.origin.y , 70, 20)];
    forgetBut.titleLabel.textAlignment = 1;
    [forgetBut.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [forgetBut setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [forgetBut setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetBut setTitleColor:CreateColor(32, 31, 32) forState:UIControlStateNormal];
    [forgetBut addTarget:self action:@selector(forgotPasBut:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:forgetBut];
    
    //login
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _userLoginBtn = loginBtn;
    [loginBtn setFrame:CGRectMake((winSize.width - 279) / 2,topHei + midHei + (bottomHei - 50) / 3, 279, 50)];
    [loginBtn setImage:[UIImage imageNamed:@"d8_1"] forState:UIControlStateNormal];
    [loginBtn setImage:[UIImage imageNamed:@"d8"] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(userLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:loginBtn];
    
    //tip
    CGFloat downHei = maxHei * DOWN_HEIGHT;
    UILabel *versionLab = [[UILabel alloc]initWithFrame:CGRectMake((winSize.width - 100) / 2, maxHei - downHei - 25, 100, 20)];
    versionLab.textAlignment = 1;
    versionLab.backgroundColor = [UIColor clearColor];
    versionLab.font = [UIFont systemFontOfSize:11];
    versionLab.textColor = CreateColor(154, 194, 217);
    versionLab.text = @"迪杰特·童印";
    [self addSubview:versionLab];
    
    //down
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, maxHei - downHei, winSize.width, downHei)];
    [downView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:downView];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(28, (downHei - 24) / 2, 67, 24)];
    [logo setBackgroundColor:[UIColor whiteColor]];
    [logo setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d6" ofType:@"png"]]];
    [downView addSubview:logo];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(100, logo.frame.origin.y, 0.5, logo.frame.size.height)];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [downView addSubview:lineView];
    
    NSString *loginSchool = [userDefault valueForKey:LOGIN_SCHOOL];
    UILabel *upLab = [[UILabel alloc] initWithFrame:CGRectMake(105, lineView.frame.origin.y - 1, winSize.width - 110, 14)];
    [upLab setFont:[UIFont systemFontOfSize:12]];
    [upLab setText:([loginSchool length] > 0) ? loginSchool : @"江苏迪杰特教育科技股份有限公司"];
    [downView addSubview:upLab];
    
    UILabel *downLab = [[UILabel alloc] initWithFrame:CGRectMake(upLab.frame.origin.x, lineView.frame.size.height + lineView.frame.origin.y - 10, upLab.frame.size.width, 11)];
    [downLab setText:([loginSchool length] > 0) ? @"幼儿园欢迎您" : @"欢迎您"];
    [downLab setFont:[UIFont systemFontOfSize:9]];
    [downLab setTextColor:[UIColor lightGrayColor]];
    [downView addSubview:downLab];
    
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)launchQQ:(id)sender{
    QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:[DJTGlobalManager shareInstance].qqInfo];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

#pragma mark - 是否记住密码
- (void)remberPass:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:!sender.selected forKey:LOGIN_REMBER];
    [userDefaults synchronize];
}
#pragma mark - 打开使用协议
- (void)agreementBut:(UIButton *)sender{
    if (sender.tag == 100) {
        sender.selected = !sender.selected;
        _userLoginBtn.enabled = sender.selected;
    }else{
        if (_delegate &&[_delegate respondsToSelector:@selector(openAgreement)]) {
            [_delegate openAgreement];
        }
    }
}
#pragma mark - 忘记密码
- (void)forgotPasBut:(UIButton *)sender{
     if (_delegate &&[_delegate respondsToSelector:@selector(forgetPassword)]) {
         [_delegate forgetPassword];
     }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self keyBoardResinFirstResponds];
}

- (void)keyBoardResinFirstResponds
{
    if (_nameField.isFirstResponder) {
        [_nameField resignFirstResponder];
    }
    else if (_passField.isFirstResponder)
    {
        [_passField resignFirstResponder];
    }
}

- (void)userLogin:(id)sender
{
    if (!_nameField.text || [_nameField.text length] <= 0) {
        [self makeToast:@"账号还没填呢。" duration:1.0 position:@"center"];
        return;
    }
    else if (![DJTIdentifierValidator isValidPhone:_nameField.text])
    {
        [self makeToast:@"手机账号格式不正确" duration:1.0 position:@"center"];
        return;
    }
    
    if (!_passField.text || [_passField.text length] <= 0) {
        [self makeToast:@"密码还没填呢。" duration:1.0 position:@"center"];
        return;
    }
    else if ([_passField.text length] < 6)
    {
        [self makeToast:@"密码不能小于6位" duration:1.0 position:@"center"];
        return;
    }
    if (!_userLoginBtn.enabled)
    {
        [self makeToast:@"请选择使用协议" duration:1.0 position:@"center"];
        return;
    }
    
    [self keyBoardResinFirstResponds];
    
    if (_delegate && [_delegate respondsToSelector:@selector(loginWithUsername:Password:)]) {
        [_delegate loginWithUsername:_nameField.text Password:_passField.text];
    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self userLogin:nil];
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == _nameField) {
        if (textField.text.length > 11) {
            [self makeToast:@"手机号不能超过11位" duration:1.0 position:@"center"];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            textField.text = [textField.text substringToIndex:11];
        }
    }
}

@end
