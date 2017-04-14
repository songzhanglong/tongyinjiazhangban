//
//  DJTSetPass2ViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/7/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTSetPass2ViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"

@interface DJTSetPass2ViewController ()<UITextFieldDelegate>

@end

@implementation DJTSetPass2ViewController
{
    UITextField *_velifyField,*_newField,*_againField;
    NSTimer *_timer;
    UIButton *_resendBut;
    UILabel *_timerLab;
    NSInteger _nSeconds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d13" ofType:@"png"]] forState:UIControlStateNormal];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d13_1" ofType:@"png"]] forState:UIControlStateHighlighted];
    
    self.titleLable.text = @"获取验证码";
    self.titleLable.textColor = [UIColor whiteColor];
    
    [self.view setBackgroundColor:CreateColor(236, 249, 248)];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    //tip
    NSString *tipStr = [@"您的手机号:" stringByAppendingString:_phoneNum];
    NSRange range = [tipStr rangeOfString:_phoneNum];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:tipStr];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,5)];
    [str addAttribute:NSForegroundColorAttributeName value:CreateColor(117, 194, 242) range:range];
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, winSize.width - 20, 20)];
    tipLab.attributedText = str;
    [tipLab setTextAlignment:1];
    [tipLab setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tipLab];
    
    UILabel *subTip = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, winSize.width - 20, 16)];
    [subTip setFont:[UIFont systemFontOfSize:14]];
    [subTip setTextAlignment:1];
    [subTip setText:@"您会收到一条带有验证码的短信，请输入验证码"];
    [subTip setTextColor:[UIColor lightGrayColor]];
    [self.view addSubview:subTip];

    CGFloat yOri = 70;
    NSArray *tips = @[@"请输入手机收到的验证码",@"请输入新密码",@"请确认新密码"];
    for (NSInteger i = 0; i < 3; i++) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, yOri, winSize.width, 50)];
        [backView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:backView];
        
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, backView.frame.origin.y + 10, [UIScreen mainScreen].bounds.size.width - 20, 30)];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.placeholder = tips[i];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.textAlignment = 1;
        textField.contentVerticalAlignment = 0 ;
        textField.textColor = [UIColor blackColor];
        textField.returnKeyType = UIReturnKeySend;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.delegate = self;
        textField.secureTextEntry = (i != 0);
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setKeyboardType:UIKeyboardTypeASCIICapable];
        
        if (i == 0) {
            _velifyField = textField;
        }
        else if (i == 1)
        {
            _newField = textField;
        }
        else
        {
            _againField = textField;
        }
        [self.view addSubview:textField];
        
        yOri += 50 + 1;
    }
    
    //button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 279) / 2, yOri + 30, 279, 51)];
    [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d11" ofType:@"png"]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d11_1" ofType:@"png"]] forState:UIControlStateHighlighted];
    [button setTitleColor:CreateColor(60, 136, 192) forState:UIControlStateNormal];
    [button setTitle:@"确 定" forState:UIControlStateNormal];
    [button.titleLabel setFont:self.titleLable.font];
    [button addTarget:self action:@selector(findMyPassWord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    //重新发送
    UIButton *reSend = [UIButton buttonWithType:UIButtonTypeCustom];
    _resendBut = reSend;
    reSend.enabled = NO;
    [reSend setFrame:CGRectMake((winSize.width - 112) / 2, button.frame.origin.y + button.frame.size.height + 10, 112, 18)];
    [reSend.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [reSend setTitle:@"没收到，重新发送" forState:UIControlStateNormal];
    [reSend addTarget:self action:@selector(getValifyCode:) forControlEvents:UIControlEventTouchUpInside];
    [reSend setTitleColor:CreateColor(117, 194, 242) forState:UIControlStateNormal];
    [reSend setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [reSend setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:reSend];
    
    UILabel *timLab = [[UILabel alloc] initWithFrame:CGRectMake((winSize.width - 200) / 2, reSend.frame.origin.y + reSend.frame.size.height + 5, 200, 18)];
    _timerLab = timLab;
    [timLab setFont:[UIFont systemFontOfSize:14]];
    [timLab setTextAlignment:1];
    [timLab setTextColor:CreateColor(117, 194, 242)];
    [timLab setText:@"60s后重新获取验证码"];
    [self.view addSubview:timLab];
    
    _nSeconds = 60;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTimer:) userInfo:nil repeats:YES];
}

- (void)backToPreControl:(id)sender
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getValifyCode:(id)sender
{
    [self beginGetVelifyCode:_phoneNum];
}

- (void)refreshTimer:(NSTimeInterval)time
{
    _nSeconds -= 1;
    if (_nSeconds <= 0) {
        [_timerLab setHidden:YES];
        _resendBut.enabled = YES;
        [_timer invalidate];
        _timer = nil;
    }
    else
    {
        [_timerLab setText:[NSString stringWithFormat:@"%lds后重新获取验证码",(long)_nSeconds]];
    }
}

- (void)findMyPassWord:(id)sender
{
    if (!_velifyField.text || [_velifyField.text length] <= 0) {
        [self.view.window makeToast:@"请输入手机收到的验证码" duration:1.0 position:@"center"];
        return;
    }
    else if (![_velifyField.text isEqualToString:_code])
    {
        [self.view.window makeToast:@"验证码不正确哦！" duration:1.0 position:@"center"];
        return;
    }
    else if (!_newField.text || [_newField.text length] <= 0)
    {
        [self.view.window makeToast:@"请输入新密码" duration:1.0 position:@"center"];
        return;
    }
    else if ([_newField.text length] < 6)
    {
        [self.view.window makeToast:@"为保障您账号安全，密码至少包含6位数字或字母哦！" duration:1.0 position:@"center"];
        return;
    }
    else if ([_newField.text length] > 32)
    {
        [self.view.window makeToast:@"密码太长了，不好记，简短一点吧！" duration:1.0 position:@"center"];
        return;
    }
    else if (!_againField.text || [_againField.text length] <= 0)
    {
        [self.view.window makeToast:@"请确认新密码" duration:1.0 position:@"center"];
        return;
    }
    else if (![_newField.text isEqualToString:_againField.text])
    {
        [self.view.window makeToast:@"两次输入密码不一致" duration:1.0 position:@"center"];
        return;
    }
    
    [self resignAllTextFileds];
    
    [self changePassWord];
}

- (void)resignAllTextFileds
{
    if (_velifyField.isFirstResponder) {
        [_velifyField resignFirstResponder];
    }
    else if (_newField.isFirstResponder)
    {
        [_newField resignFirstResponder];
    }
    else if (_againField.isFirstResponder)
    {
        [_againField resignFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resignAllTextFileds];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 获取验证码
- (void)beginGetVelifyCode:(NSString *)mobile
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"send"];
    [dic setObject:mobile forKey:@"mobile"];
    [dic setObject:@"0" forKey:@"is_teacher"];
    [dic setObject:@"60" forKey:@"cache"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"code"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestVelifyCodeFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestVelifyCodeFinish:NO Data:nil];
    }];
}

- (void)requestVelifyCodeFinish:(BOOL)success Data:(id)result
{
    self.view.userInteractionEnabled = YES;
    self.httpOperation = nil;
    [self.view hideToastActivity];
    if (success) {
        _nSeconds = 60;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTimer:) userInfo:nil repeats:YES];
        _resendBut.enabled = NO;
        [_timerLab setHidden:NO];
        [_timerLab setText:@"60s后重新获取验证码"];
        
        NSString *ret_msg = @"验证码获取成功";
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
    else
    {
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
}

#pragma mark - 修改密码
- (void)changePassWord
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"changePwd"];
    [dic setObject:_phoneNum forKey:@"mobile"];
    [dic setObject:@"0" forKey:@"is_teacher"];
    [dic setObject:_velifyField.text forKey:@"code"];
    [dic setObject:_newField.text forKey:@"password"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"member"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf changePassWordFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf changePassWordFinish:NO Data:nil];
    }];
}

- (void)changePassWordFinish:(BOOL)success Data:(id)result
{
    self.view.userInteractionEnabled = YES;
    self.httpOperation = nil;
    [self.view hideToastActivity];
    if (success) {
        [self.navigationController.view makeToast:@"密码修改完成，请重新登录" duration:1.0 position:@"center"];
        
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self findMyPassWord:nil];
    return YES;
}

@end
