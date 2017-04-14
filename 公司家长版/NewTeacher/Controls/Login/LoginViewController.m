//
//  LoginViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "LoginViewController.h"
#import "DJTLoginView.h"
#import "Toast+UIView.h"
#import "DataBaseOperation.h"
#import "AppDelegate.h"
#import "MobClick.h"
#import "NSString+Common.h"
#import "DJTHttpClient.h"
#import "DJTGlobalManager.h"
#import "GuideScrollView.h"
#import "DJTSetPassViewController.h"
#import "DJTOrderViewController.h"

@interface LoginViewController ()<LoginViewDelegate,GuideScrollViewDelegate>

@end

@implementation LoginViewController
{
    DJTLoginView *_loginView;
    NSDictionary *_requestParam;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //监视键盘高度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(117, 194, 242);
    }
    else
    {
        navBar.tintColor = CreateColor(117, 194, 242);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_loginView) {
        return;
    }
    
    //login view
    float yOri = 0;
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    DJTLoginView *loginView = [[DJTLoginView alloc] initWithFrame:CGRectMake(0, yOri, winSize.width, winSize.height - yOri)];
    _loginView = loginView;
    loginView.delegate = self;
    [self.view addSubview:loginView];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *firstLaunch = [userDef objectForKey:APP_FIRST_LAUNCH];
    if (!firstLaunch) {
        [userDef removeObjectForKey:@"firstLaunch"];
        [userDef removeObjectForKey:@"firstLaunch1"];
        [userDef setObject:@"1" forKey:APP_FIRST_LAUNCH];
        
        GuideScrollView *guide = [[GuideScrollView alloc] initWithFrame:self.view.window.bounds];
        guide.delegate = self;
        [self.view.window addSubview:guide];
    }
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    float yOri = 0;
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    CGFloat diffence = (yOri + _loginView.passField.frame.size.height + _loginView.passField.frame.origin.y) - (winSize.height - keyboardRect.size.height);
    if (diffence > 0) {
        [_loginView setFrame:CGRectMake(0, yOri - diffence, winSize.width, winSize.height - yOri)];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    float yOri = 0;
    CGSize winSize = [[UIScreen mainScreen] bounds].size;

    [_loginView setFrame:CGRectMake(0, yOri, winSize.width, winSize.height - yOri)];
}

#pragma mark - 登录请求结果
/**
 *	@brief	登录请求结果
 *
 *	@param 	success 	yes－成功
 *	@param 	result 	服务器返回数据
 */
- (void)loginFinish:(BOOL)success Data:(id)result
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    _loginView.userInteractionEnabled = YES;
    
    if (!success) {
        NSString *str = [result objectForKey:@"ret_msg"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        //登录签名
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:_loginView.nameField.text forKey:LOGIN_ACCOUNT];
        if (!_loginView.remberBut.selected) {
            [userDefault setObject:@"" forKey:LOGIN_PASSWORD];
        }else{
            [userDefault setObject:_loginView.passField.text forKey:LOGIN_PASSWORD];
        }
        [userDefault setBool:NO forKey:LOGIN_ATTENDANCE];
        [userDefault synchronize];
        
        id ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        NSMutableArray *chileren = [NSMutableArray array];
        for (id child in ret_data) {
            //用户数据处理
            NSError *error;
            DJTUser *user = [[DJTUser alloc] initWithDictionary:child error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [user caculateClass_nameWei];
            [chileren addObject:user];
        }
        
        //友盟
        [MobClick event:@"LoginId" attributes:@{@"time":[NSString stringByDate:@"yyyy-MM-dd HH:mm:ss" Date:[NSDate date]]}];
        [[DJTGlobalManager shareInstance] setChildrens:chileren];
        
        if (chileren.count == 0) {
            [self.view makeToast:@"您还没有添加小孩" duration:1.0 position:@"center"];
        }
        else if (chileren.count == 1)
        {
            //用户数据处理
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app selectLoginChildIdx:0];
        }
        else
        {
            //多个小孩页面
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app popSelectedChildrenView];
        }
    }
}

#pragma mark - LoginViewDelegate
- (void)forgetPassword{
    DJTSetPassViewController *setPass = [[DJTSetPassViewController alloc] init];
    setPass.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setPass animated:YES];
}
- (void)openAgreement
{
    DJTOrderViewController *web = [[DJTOrderViewController alloc] init];
    web.url = @"http://www.goonbaby.com/web_dpage/agree.html";
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}
- (void)loginWithUsername:(NSString *)userName Password:(NSString *)password
{
    if (self.httpOperation) {
        return;
    }
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN)
    {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    [self.view makeToastActivity];
    _loginView.userInteractionEnabled = NO;
    

    NSMutableDictionary *param = [manager requestinitParamsWith:@"memberLogin"];
    [param setObject:password forKey:@"password"];
    [param setObject:userName forKey:@"userName"];
    [param setObject:manager.deviceToken ?: @"" forKey:@"deviceToken"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    _requestParam = param;
    
    [self startRequest];
}

- (void)startRequest
{
    __weak __typeof(self)weakSelf = self;

    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"login"] parameters:_requestParam successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf loginFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf loginFinish:NO Data:nil];
    }];
}

#pragma mark - GuideScrollViewDelegate
- (void)startLaunchApp:(GuideScrollView *)guideView
{
    [UIView animateWithDuration:0.3 animations:^{
        guideView.alpha = 0;
    } completion:^(BOOL finished) {
        [guideView removeFromSuperview];
    }];
}

@end
