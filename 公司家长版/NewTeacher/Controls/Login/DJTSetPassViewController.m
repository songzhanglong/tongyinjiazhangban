//
//  DJTSetPassViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/7/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTSetPassViewController.h"
#import "DJTSetPass2ViewController.h"
#import "DJTIdentifierValidator.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"

@interface DJTSetPassViewController ()<UITextFieldDelegate>

@end

@implementation DJTSetPassViewController
{
    UITextField *_textField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d13" ofType:@"png"]] forState:UIControlStateNormal];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d13_1" ofType:@"png"]] forState:UIControlStateHighlighted];
    
    self.titleLable.text = @"忘记密码";
    self.titleLable.textColor = [UIColor whiteColor];
    
    [self.view setBackgroundColor:CreateColor(236, 249, 248)];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 50)];
    [backView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:backView];
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, backView.frame.origin.y + 10, [UIScreen mainScreen].bounds.size.width - 20, 30)];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.placeholder = @"请输入您注册的手机号码";
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.textAlignment = 1;
    textField.contentVerticalAlignment = 0 ;
    textField.textColor = [UIColor blackColor];
    textField.returnKeyType = UIReturnKeySend;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = self;
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];

    _textField = textField;
    [self.view addSubview:textField];
    
    //button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 279) / 2, 100, 279, 51)];
    [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d11" ofType:@"png"]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"d11_1" ofType:@"png"]] forState:UIControlStateHighlighted];
    [button setTitleColor:CreateColor(60, 136, 192) forState:UIControlStateNormal];
    [button setTitle:@"确 定" forState:UIControlStateNormal];
    [button.titleLabel setFont:self.titleLable.font];
    [button addTarget:self action:@selector(getVelifyCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)getVelifyCode:(id)sender
{
    if (!_textField.text || [_textField.text length] <= 0) {
        [self.view.window makeToast:@"手机号码还没填呢。" duration:1.0 position:@"center"];
        return;
    }
    else if (![DJTIdentifierValidator isValidPhone:_textField.text])
    {
        [self.view.window makeToast:@"手机账号格式不正确" duration:1.0 position:@"center"];
        return;
    }
    
    if (_textField.isFirstResponder) {
        [_textField resignFirstResponder];
    }
    
    
    [self beginGetVelifyCode:_textField.text];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_textField.isFirstResponder) {
        [_textField resignFirstResponder];
    }
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
        NSDictionary *dic = [result valueForKey:@"ret_data"];
        if (dic) {
            NSString *code = [dic valueForKey:@"code"];
            DJTSetPass2ViewController *pass2 = [[DJTSetPass2ViewController alloc] init];
            pass2.phoneNum = _textField.text;
            pass2.code = code;
            [self.navigationController pushViewController:pass2 animated:YES];
        }else{
            [self.view makeToast:@"忘记密码，一天只能获取3次" duration:1.0 position:@"center"];
        }
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
    [self getVelifyCode:nil];
    return YES;
}

@end
