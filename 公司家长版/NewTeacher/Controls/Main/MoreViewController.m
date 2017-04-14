//
//  MoreViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MoreViewController.h"
#import "SchoolInfoViewController.h"     //幼儿园信息
#import "PersonalInfoViewController.h"   //个人信息
#import "ChangePassViewController.h"    //修改密码
#import "AboutViewController.h"         //关于
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "UIButton+WebCache.h"
#import "MoreCell.h"
#import "MyHomeViewController.h"
#import "DJTWebViewController.h"
#import "DJTTimeCardViewController.h"
#import "DJTOrderViewController.h"
#import "BindingTimeCardController.h"
#import "MyOrderViewController.h"

@interface MoreViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    UIButton *_headBut;
    BOOL _checkAssistant;
    NSString *_urlString,*_assistantTip;
}

@end

@implementation MoreViewController
{
    NSString *_pay_url;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_USER_HEADER object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader:) name:CHANGE_USER_HEADER object:nil];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_tableView setBackgroundColor:[UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:239 / 255.0 alpha:1.0]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setTableHeaderView:[self createHeaderView]];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:footView];
    [self.view addSubview:_tableView];
    
    [self checkPrentAssistant];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    [_headBut setImageWithURL:[NSURL URLWithString:[DJTGlobalManager shareInstance].userInfo.face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    if (!_hasTimeCard) {
        _hasTimeCard = user.hasTimeCard;
        if (_hasTimeCard) {
            [_tableView reloadData];
        }
    }
    if (_hasTimeCard) {
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        if ((user.payType & ePayMoney) != ePayMoney) {
            [self checkPay:NO];
        }
    }
}

#pragma mark - 教师小助手
- (void)checkPrentAssistant
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN)
    {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"class"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"checkAssistant"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf checkAssistant:success Data:data];
        
    } failedBlock:^(NSString *description) {
        [weakSelf checkAssistant:NO Data:nil];
    }];
}

- (void)checkAssistant:(BOOL)success Data:(id)result
{
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data) {
            NSString *have_device = [ret_data valueForKey:@"check"];
            if (have_device) {
                _urlString = [ret_data valueForKey:@"url"];
                if ([have_device integerValue] == 1) {
                    _checkAssistant = YES;
                }else {
                    _checkAssistant = NO;
                }
                [_tableView reloadData];
            }
        }
    }
    else{
        _assistantTip = [result valueForKey:@"ret_msg"];
    }
}

- (UIView *)createHeaderView{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat hei = 150;
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, winSize.width, hei)];
    backView.backgroundColor = [UIColor colorWithRed:252.0 / 255.0 green:205.0 / 255.0 blue:68.0 / 255.0 alpha:1];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    //head
    UIButton *headerView = [UIButton buttonWithType:UIButtonTypeCustom];
    _headBut = headerView;
    headerView.frame = CGRectMake((winSize.width - 60) / 2, 30, 60, 60);
    headerView.layer.masksToBounds = YES;
    headerView.layer.cornerRadius = 30;
    headerView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerView.layer.borderWidth = 1.0;
    [headerView setImageWithURL:[NSURL URLWithString:user.face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    [headerView addTarget:self action:@selector(pushToPerIn:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:headerView];
    
    //name
    UILabel *babyNamelab = [[UILabel alloc]initWithFrame:CGRectMake((winSize.width - 200) / 2, headerView.frame.size.height + headerView.frame.origin.y + 5, 200, 20)];
    babyNamelab.text = user.uname;
    babyNamelab.textAlignment = 1;
    babyNamelab.backgroundColor = [UIColor clearColor];
    [backView addSubview:babyNamelab];
    
    //school
    UILabel *schLab = [[UILabel alloc] initWithFrame:CGRectMake(babyNamelab.frame.origin.x, babyNamelab.frame.origin.y + babyNamelab.frame.size.height + 5, babyNamelab.frame.size.width, 14)];
    [schLab setText:[user.school_name stringByAppendingFormat:@"(%@)",user.class_name]];
    [schLab setTextColor:[UIColor darkGrayColor]];
    [schLab setTextAlignment:1];
    [schLab setFont:[UIFont systemFontOfSize:12]];
    [schLab setBackgroundColor:[UIColor clearColor]];
    [backView addSubview:schLab];
    
    //login out
    UIButton *unLoginBut = [UIButton buttonWithType:UIButtonTypeCustom];
    unLoginBut.frame = CGRectMake(winSize.width - 60, headerView.frame.origin.y, 60, 30);
    [unLoginBut setTitle:@"退出" forState:UIControlStateNormal];
    [unLoginBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [unLoginBut setBackgroundColor:[UIColor clearColor]];
    [unLoginBut addTarget:self action:@selector(unLogin:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:unLoginBut];
    
    //school info
    UIButton *tranBut = [UIButton buttonWithType:UIButtonTypeCustom];
    tranBut.frame = CGRectMake(winSize.width - 46, schLab.frame.origin.y + schLab.frame.size.height - 28, 46, 28);
    [tranBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"w7" ofType:@"png"]] forState:UIControlStateNormal];
    [backView addSubview:tranBut];
    [tranBut addTarget:self action:@selector(pushToSchoolInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToPerIn:)];
    [backView addGestureRecognizer:tapGesture];
   
    return backView;
}

#pragma mark - 用户信息
- (void)pushToPerIn:(UIButton *)sender
{
    PersonalInfoViewController *person = [[PersonalInfoViewController alloc] init];
    person.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:person animated:YES];
}

#pragma mark - 校园信息
- (void)pushToSchoolInfo:(id)sender
{
    SchoolInfoViewController *school = [[SchoolInfoViewController alloc] init];
    school.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:school animated:YES];
}

#pragma mark - 退出登录
- (void)unLogin:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popToLoginViewController];
}

#pragma mark - 刷新头像
- (void)refreshHeader:(NSNotification *)notifi
{
    [_headBut setImageWithURL:[NSURL URLWithString:[DJTGlobalManager shareInstance].userInfo.face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((section == 2) && !_hasTimeCard){
        return 0;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ((section == 2) && !_hasTimeCard){
        return 0;
    }
    return 9;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MoreCell";
    MoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSMutableArray *topTitles = [NSMutableArray arrayWithObjects:@"云端相册",@"育苗计划",@"我的考勤卡",@"我的家人",@"我的订单",@"修改密码",@"清除缓存",@"版本记录",@"关于", nil];
    NSMutableArray *imgs = [NSMutableArray arrayWithObjects:@"cloud",@"growSeed",@"w22",@"w2",@"w24",@"w3",@"w4",@"w19", @"w5",nil];
    
    [cell.imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgs[indexPath.section] ofType:@"png"]]];
    [cell.titleLab setText:topTitles[indexPath.section]];
    cell.contLab.hidden = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    cell.tipImg.hidden = (indexPath.section != 0) || [defaults objectForKey:@"isShowNewIcon"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            //云端相册
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"isShowNewIcon"];
            [defaults synchronize];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
            DJTWebViewController *web = [[DJTWebViewController alloc]init];
            web.baby_id = user.userid;
            NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_ACCOUNT];
            web.phone = phone;
            web.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:web animated:YES];
        }
            break;
        case 1:
        {
            //育苗计划
            DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
            order.hidesBottomBarWhenPushed = YES;
            order.url = @"http://d.goonbaby.com/order";
            order.param = [NSString stringWithFormat:@"userid=%@&is_teacher=0&datafrom=1&from=2&mid=%@",[DJTGlobalManager shareInstance].userInfo.userid ?: @"",[DJTGlobalManager shareInstance].userInfo.mid ?: @""];
            [self.navigationController pushViewController:order animated:YES];
        }
            break;
        case 2:
        {
            //我的考勤卡
            DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
            if ((user.payType & ePayBind) == ePayBind) {
                //我的考勤卡
                DJTTimeCardViewController *timeCard = [[DJTTimeCardViewController alloc] init];
                timeCard.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:timeCard animated:YES];
            }
            else
            {
                BindingTimeCardController *bind = [[BindingTimeCardController alloc] init];
                bind.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:bind animated:YES];
            }
        }
            break;
        case 3:
        {
            //我的家人
            MyHomeViewController *addRel = [[MyHomeViewController alloc] init];
            addRel.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addRel animated:YES];
        }
            break;
        case 4:{
            //我的订单
            MyOrderViewController *order = [[MyOrderViewController alloc] init];
            order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:order animated:YES];
        }
            break;
        case 5:
        {
            //修改密码
            ChangePassViewController *schoolInfo = [[ChangePassViewController alloc] init];
            schoolInfo.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:schoolInfo animated:YES];
        }
            break;
        case 6:
        {
            //清空缓存
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要清除缓存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 1;
            [alertView show];
        }
            break;
        case 7:
        {
            //版本记录
            DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
            order.url = @"http://wap.goonbaby.com/version?is_teacher=0&tag=ios";
            order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:order animated:YES];
        }
            break;
        case 8:
        {
            //关于
            AboutViewController *schoolInfo = [[AboutViewController alloc] init];
            schoolInfo.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:schoolInfo animated:YES];
        }
            break;
        
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 1) {
            NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *docDir = [path objectAtIndex:0];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:docDir error:nil];
            [self.view makeToast:@"清除完毕" duration:1.0 position:@"center"];
        }
        else if (alertView.tag == 2)
        {
            if (self.httpOperation) {
                [self.view makeToast:@"数据正在刷新，请等待" duration:1.0 position:@"center"];
            }
            else if ([_pay_url length] == 0)
            {
                [self checkPay:YES];
            }
            else
            {
                DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
                order.url = _pay_url;
                order.param = [NSString stringWithFormat:@"userid=%@&is_teacher=0&datafrom=1&from=2&mid=%@",[DJTGlobalManager shareInstance].userInfo.userid ?: @"",[DJTGlobalManager shareInstance].userInfo.mid ?: @""];
                order.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:order animated:YES];
            }
        }
    }
}

#pragma mark - 判断用户当前是否已支付
- (void)checkPay:(BOOL)tip
{
    if (self.httpOperation) {
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    DJTUser *userInfo = manager.userInfo;
    NSMutableDictionary *param = [manager requestinitParamsWith:@"checkPay"];
    [param setObject:userInfo.mid ?: @"" forKey:@"mid"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"attence"];
    
    if (tip) {
        _tableView.userInteractionEnabled = NO;
        [self.view makeToastActivity];
    }
    
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf checkPayFinish:success Data:data Tip:tip];
    } failedBlock:^(NSString *description) {
        [weakSelf checkPayFinish:NO Data:nil Tip:tip];
    }];
}

- (void)checkPayFinish:(BOOL)suc Data:(id)result Tip:(BOOL)tip
{
    self.httpOperation = nil;
    if (tip) {
        _tableView.userInteractionEnabled = YES;
        [self.view hideToastActivity];
    }
    
    if (suc) {
        id ret_data = [result valueForKey:@"ret_data"];
        _pay_url = [ret_data valueForKey:@"pay_url"];
        
        NSString *pay_status = [ret_data valueForKey:@"pay_status"];
        NSString *haveCard = [ret_data valueForKey:@"haveCard"];
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        user.payType = (ePayType)(([haveCard integerValue] << 1) | ([pay_status integerValue]));
        
        if (tip) {
            if ((user.payType & ePayMoney) == ePayMoney) {
                if ((user.payType & ePayBind) == ePayBind) {
                    //我的考勤卡
                    DJTTimeCardViewController *timeCard = [[DJTTimeCardViewController alloc] init];
                    timeCard.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:timeCard animated:YES];
                }
                else
                {
                    BindingTimeCardController *bind = [[BindingTimeCardController alloc] init];
                    bind.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:bind animated:YES];
                }
                
            }
            else
            {
                DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
                order.url = _pay_url ?: @"";
                order.param = [NSString stringWithFormat:@"userid=%@&is_teacher=0&datafrom=1&from=2&mid=%@",[DJTGlobalManager shareInstance].userInfo.userid ?: @"",[DJTGlobalManager shareInstance].userInfo.mid ?: @""];
                order.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:order animated:YES];
            }
        }
    }
    else
    {
        if (tip) {
            NSString *str = REQUEST_FAILE_TIP;
            NSString *ret_msg = nil;
            if ((ret_msg = [result valueForKey:@"ret_msg"])) {
                str = ret_msg;
            }
            [self.view.window makeToast:str duration:1.0 position:@"center"];
        }
        
    }
}

@end
