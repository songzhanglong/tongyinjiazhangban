//
//  MyCalendarViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/22.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyCalendarViewController.h"
#import "MyCalendarView.h"
#import "Toast+UIView.h"
#import "NSObject+Reflect.h"
#import "NSString+Common.h"
#import "MobClick.h"
#import "MJRefresh.h"
#import "BindingTimeCardController.h"
#import "CalendarCarCell.h"
#import "CalendarPhotoCell.h"
#import "LeaveView.h"
#import "NSDate+Calendar.h"
#import "DJTOrderViewController.h"
#import "PhoneAllEditView.h"

typedef enum
{
    kTimeCardUnknown = 0,
    kTimeCardNot,           //没有考勤机
    kTimeCardHave,          //有考勤机，只做初始化判断用，没啥意义
    kTimeCardNoPayNoBind,   //未支付，未绑定
    kTimeCardNoPayBind,     //未支付，绑定
    kTimeCardPayNoBind,     //支付，未绑定
    kTimeCardPayBind        //支付，绑定
}kTimeCardType;

@interface MyCalendarViewController ()<MyCalendarViewDelegate,UITableViewDataSource,UITableViewDelegate,LeaveViewDelegate,TimeCardBindingDelegate,PhoneAllEditViewDelegate>

@end

@implementation MyCalendarViewController
{
    UIView *_followView;
    MyCalendarView *_calendarView;
    MJRefreshHeaderView *_headerRefresh;
    UITableView *_tableView;
    CGFloat _canlendHei;
    NSArray *_timeCardList;
    
    UIImageView *navBarHairlineImageView;
    BOOL _showActivity,_changeToPay;
    LeaveView *_leaveView;
    NSDate *_today;
    NSInteger _thisYear,_thisMonth;
    kTimeCardType _timeCardType;
    NSMutableDictionary *_typeDic,*_dateArrDic;
    NSString *_pay_url;
    PhoneAllEditView *_phoneEditView;
}

- (void)dealloc
{
    [MobClick endEvent:@"DailyCheck"];
    [_headerRefresh free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick beginEvent:@"DailyCheck"];
    _timeCardType = [DJTGlobalManager shareInstance].userInfo.hasTimeCard ? kTimeCardHave : kTimeCardNot;
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    _typeDic = [NSMutableDictionary dictionary];
    _dateArrDic = [NSMutableDictionary dictionary];
    
    self.showBack = YES;
    [self.titleLable setTextColor:[UIColor whiteColor]];
    UIButton *rigBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [rigBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [rigBut setFrame:CGRectMake(0, 0, 40, 30)];
    
    //日历
    _calendarView = [[MyCalendarView alloc] initWithFrame:CGRectZero];
    [_calendarView setDelegate:self];
    
    _today = [NSDate date];
    _thisMonth = _today.month;
    _thisYear = _today.year;
    [_calendarView setCurDate:_today];
    _canlendHei = _calendarView.frame.size.height;
    self.titleLable.text = [NSString stringWithFormat:@"%02ld月%04ld",(long)_calendarView.month,(long)_calendarView.year];
    
    _followView = [[[NSBundle mainBundle]loadNibNamed:@"CalendarTipView" owner:self options:0] lastObject];;
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height - 64.0 - 50) style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setDelegate:self];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:footView];
    [self.view addSubview:_tableView];
    
    //表头
    [self resetTableHeaderView];
    
    //请假
    [self createCallView];
    
    //下拉刷新
    if (_timeCardType > kTimeCardNot) {
        __weak typeof(self)weakSelf = self;
        MJRefreshHeaderView *hView = [MJRefreshHeaderView header];
        hView.scrollView = _tableView;
        hView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
            [weakSelf refreshTimeCard];
        };
        hView.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
            // 刷新完毕就会回调这个Block
        };
        _headerRefresh = hView;
        
        //新日历数据
        [self getAttenceStudentByMonth:YES];
    }
    else
    {
        //旧日历数据
        [self requestAllData];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(235.0, 73.0, 65.0);
    }
    else
    {
        navBar.tintColor = CreateColor(235.0, 73.0, 65.0);
    }
    
    navBarHairlineImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_changeToPay) {
        _changeToPay = NO;
        [self checkPay];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
    
    navBarHairlineImageView.hidden = NO;
}



- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)createCallView
{
    /*
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(45, winSize.height - 64 - 50 + 9, 230, 32)];
    button.backgroundColor = CreateColor(43, 184, 100);
    [[button layer]setCornerRadius:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"请 假" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [button addTarget:self action:@selector(callTeacher:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
 */
    
    //
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIView *callView = [[UIView alloc] initWithFrame:CGRectMake(0, winSize.height - 64 - 50, winSize.width, 50)];
    [callView setBackgroundColor:CreateColor(88.0, 73.0, 68.0)];
    [self.view addSubview:callView];
    
    CGFloat yOri = 7;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(10, yOri, 36, 36)];
    [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kq4" ofType:@"png"]] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(callTeacher:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor clearColor]];
    [callView addSubview:button];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(10 + 36 + 5, yOri, winSize.width - 66 - 10 * 4 - 36, 16)];
    [nameLab setBackgroundColor:[UIColor clearColor]];
    [nameLab setFont:[UIFont systemFontOfSize:14]];
    [nameLab setTextColor:CreateColor(253, 176, 90)];
    [nameLab setText:[DJTGlobalManager shareInstance].userInfo.teacher_name];
    [callView addSubview:nameLab];
    
    UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height, nameLab.frame.size.width, 20)];
    [numLab setText:[DJTGlobalManager shareInstance].userInfo.teacher_tel];
    [numLab setBackgroundColor:[UIColor clearColor]];
    [numLab setFont:[UIFont systemFontOfSize:17]];
    [numLab setTextColor:nameLab.textColor];
    [callView addSubview:numLab];
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    [but setFrame:CGRectMake(winSize.width - 10 - 66, 13, 66, 24)];
    [but setBackgroundColor:numLab.textColor];
    but.layer.masksToBounds = YES;
    but.layer.cornerRadius = 2;
    [but setTitle:@"请假" forState:UIControlStateNormal];
    [but.titleLabel setFont:nameLab.font];
    [but setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    but.hidden = YES;
    [but addTarget:self action:@selector(callTeacher:) forControlEvents:UIControlEventTouchUpInside];
    [callView addSubview:but];

}

- (void)beginLeave:(id)sender
{
    if (!_leaveView) {
        _leaveView = [[LeaveView alloc] initWithFrame:self.view.window.bounds];
        _leaveView.delegate = self;
    }
    [_leaveView showInView:self.view.window];
}

- (void)callTeacher:(id)sender
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSArray *dataArray = manager.userInfo.teacher_datas;
    if (!dataArray || [dataArray count] <= 0) {
        [self.view makeToast:@"没有关联相关老师" duration:1.0 position:@"center"];
        return;
    }
    if (_phoneEditView) {
        [_phoneEditView removeFromSuperview];
    }
    _phoneEditView = [[PhoneAllEditView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _phoneEditView.delegate = self;
    [_phoneEditView showInView:self.view.window];
}
#pragma mark - PhoneAllEditView delegate
- (void)selectEditIndex:(NSString *)phone
{
    if (phone && [phone length] > 0) {
        NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phone]];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [webView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
        [self.view addSubview:webView];
    }else{
        [self.view makeToast:@"老师没有登记手机号码" duration:1.0 position:@"center"];
    }
}
- (void)resetTableHeaderView
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, _canlendHei + _followView.frame.size.height + 5)];
    [headView addSubview:_calendarView];
    
    [_followView setFrame:CGRectMake((winSize.width - _followView.frame.size.width) / 2, _canlendHei, _followView.frame.size.width, _followView.frame.size.height)];
    [headView addSubview:_followView];
    [_tableView setTableHeaderView:headView];
}

- (void)resetTableFootView
{
    BOOL isThisMoth = (_calendarView.year == _thisYear) && (_calendarView.month == _thisMonth);
    if ((_timeCardType != kTimeCardPayBind) && (_timeCardType != kTimeCardNoPayBind)) {
        //未绑定
        if (isThisMoth) {
            //当月
            [_tableView setTableFooterView:[[UIView alloc] init]];
        }
        else
        {
            //非当月
            [self createTipFootView];
        }
        
    }
    else if ([_timeCardList count] > 0)
    {
        //绑定，但数据不为空
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else
    {
        [self createTipFootView];
    }
}

- (void)createTipFootView
{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    //绑定，但数据空
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat hei = 20 + 111 + 10 + 14 + 30;
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 111) / 2, 20, 111, 92)];
    [img setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"moren2" ofType:@"png"]]];
    [footView addSubview:img];
    
    UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 230) / 2, img.frame.origin.y + img.frame.size.height + 10, 230, 14)];
    [tipImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"moren3" ofType:@"png"]]];
    [footView addSubview:tipImg];
    
    [footView setFrame:CGRectMake(0, 0, winSize.width, hei)];
    
    [_tableView setTableFooterView:footView];
}

#pragma mark - MyCalendarViewDelegate
- (void)changeMonth:(MyCalendarView *)calendar
{
    CGFloat lastHei = calendar.frame.size.height;
    if (_canlendHei != lastHei) {
        _canlendHei = lastHei;
        [self resetTableHeaderView];
    }
    self.titleLable.text = [NSString stringWithFormat:@"%02ld月%04ld",(long)_calendarView.month,(long)_calendarView.year];

    if (_timeCardType <= kTimeCardNot) {
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%04ld-%02ld",(long)_calendarView.year,(long)_calendarView.month];
    //日历数据
    NSArray *dateList = [_dateArrDic valueForKey:key];
    BOOL shouldRefresh = (dateList == nil); //是否需要刷新日历，非考勤卡，为空需要刷新， 否则，直接填充数据就好
    if (!shouldRefresh) {
        [_calendarView setDateArr:dateList];
    }
    
    NSInteger todayYear = _today.year;
    NSInteger todayMonth = _today.month;
    if ((calendar.year > todayYear) || ((calendar.year == todayYear) && calendar.month > todayMonth)) {
        //下月
        _timeCardType = kTimeCardPayBind;
        _timeCardList = nil;
        [self resetTableFootView];
        [_tableView reloadData];
    }
    else if (((calendar.year == todayYear) && (calendar.month == todayMonth)) && ([calendar.curDate compare:_today] == NSOrderedDescending))
    {
        //当月，但是在今日之后
        NSNumber *number = [_typeDic valueForKey:key];
        if (number) {
            _timeCardType = (int)number.integerValue;
            _timeCardList = nil;
            [self resetTableFootView];
            [_tableView reloadData];
            
            if (shouldRefresh) {
                [self getAttenceStudentByMonth:NO];
            }
        }
        else
        {
            if (shouldRefresh) {
                _showActivity = YES;
                [self getAttenceStudentByMonth:YES];
            }
            else
            {
                //表示当月未获取成功数据
                _showActivity = YES;
                [self refreshTimeCard];
            }
        }
    }
    else
    {
        if (shouldRefresh) {
            _showActivity = YES;
            [self getAttenceStudentByMonth:YES];
        }
        else
        {
            _showActivity = YES;
            [self refreshTimeCard];
        }
        
    }
}

- (void)changeDay:(MyCalendarView *)calendar
{
    if (_timeCardType <= kTimeCardNot) {
        return;
    }
    
    if ([calendar.curDate compare:_today] == NSOrderedDescending) {
        _timeCardList = nil;
        [self resetTableFootView];
        [_tableView reloadData];
    }
    else
    {
        _showActivity = YES;
        [self refreshTimeCard];
    }
}

#pragma mark - TimeCardBindingDelegate
- (void)bindTimeCardCount
{
    _timeCardType = kTimeCardPayBind;
    [_typeDic setObject:[NSNumber numberWithInt:_timeCardType] forKey:[NSString stringWithFormat:@"%04ld-%02ld",(long)_calendarView.year,(long)_calendarView.month]];
    [self resetTableFootView];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    if ((_timeCardType == kTimeCardPayBind) || (_timeCardType == kTimeCardNoPayBind)) {
        return [_timeCardList count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"typeCellId";
    if (indexPath.section != 0) {
        TimeCardRecord *record = _timeCardList[indexPath.row];
        if ([record.type isEqualToString:@"car"]) {
            cellId = @"carCellId";
        }
        else{
            if ((_timeCardType == kTimeCardPayBind) && ((record.check_face.length > 0) && ![record.check_face hasSuffix:@"nophoto.png"])){
                cellId = @"photoCellId";
            }
            else{
                cellId = @"noPhotoCellId";
            }
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        if (indexPath.section == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
            
            //
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
            [imgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [imgView setTag:1];
            [cell.contentView addSubview:imgView];
        }
        else if ([cellId isEqualToString:@"carCellId"])
        {
            cell = [[CalendarCarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        else if ([cellId isEqualToString:@"photoCellId"])
        {
            cell = [[CalendarPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        else
        {
            cell = [[CalendarNoPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
    }
    
    if (indexPath.section == 0) {
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
        BOOL isThisMonth = (_calendarView.year == _thisYear) && (_calendarView.month == _thisMonth);
        if (isThisMonth) {
            NSString *str = nil;
            switch (_timeCardType) {
                case kTimeCardNoPayNoBind:
                {
                    str = @"noPayNoBind";
                }
                    break;
                case kTimeCardPayNoBind:
                {
                    str = @"payNoBind";
                }
                    break;
                case kTimeCardNoPayBind:
                {
                    str = @"noPayBind";
                }
                    break;
                default:
                    break;
            }
            if (str) {
                [imgView setHidden:NO];
                [imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:str ofType:@"png"]]];
            }
            else
            {
                [imgView setHidden:YES];
            }
        }
        else
        {
            [imgView setHidden:YES];
        }
    }
    else
    {
        TimeCardRecord *record = _timeCardList[indexPath.row];
        [(CalendarNoPhotoCell *)cell resetTimeCard:record];
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (_timeCardType) {
            case kTimeCardNoPayNoBind:
            case kTimeCardNoPayBind:
            {
                if ([_pay_url length] == 0) {
                    [self.view makeToast:@"数据异常，请等待" duration:1.0 position:@"center"];
                }
                else
                {
                    _changeToPay = YES;
                    DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
                    order.url = _pay_url;
                    order.param = [NSString stringWithFormat:@"userid=%@&is_teacher=0&datafrom=1&from=2&mid=%@",[DJTGlobalManager shareInstance].userInfo.userid ?: @"",[DJTGlobalManager shareInstance].userInfo.mid ?: @""];
                    [self.navigationController pushViewController:order animated:YES];
                }
            }
                break;
            case kTimeCardPayNoBind:
            {
                //我的考勤卡
                BindingTimeCardController *timeCard = [[BindingTimeCardController alloc] init];
                timeCard.delegate = self;
                [self.navigationController pushViewController:timeCard animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat hei = 0;
        BOOL isThisMonth = (_calendarView.year == _thisYear) && (_calendarView.month == _thisMonth);
        if (isThisMonth) {
            switch (_timeCardType) {
                case kTimeCardNoPayNoBind:
                {
                    hei = winSize.width * 223 / 640;
                }
                    break;
                case kTimeCardPayNoBind:
                case kTimeCardNoPayBind:
                {
                    hei = winSize.width * 255 / 640;
                }
                    break;
                default:
                    break;
            }
        }
        
        return hei;
    }
    else
    {
        TimeCardRecord *record = _timeCardList[indexPath.row];
        if ([record.type isEqualToString:@"car"]) {
            return 90;
        }
        else{
            if ((_timeCardType == kTimeCardPayBind) && ((record.check_face.length > 0) && ![record.check_face hasSuffix:@"nophoto.png"])){
                return 116;
            }
            else{
                return 90;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 0;
    }
    return (_timeCardType <= kTimeCardNot) ? 0 : 32;
    //return ([_timeCardList count] > 0) ? 32 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    /*
    if ([_timeCardList count] == 0) {
        return nil;
    }
     */
    if (section == 1) {
        return nil;
    }
    
    if (_timeCardType <= kTimeCardNot) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 32)];
    [label setBackgroundColor:CreateColor(225, 225, 225)];
    [label setText:[NSString stringWithFormat:@"  %04ld年%02ld月%02ld日",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day]];
    return label;
}
/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:CreateColor(236, 236, 236)];
}
 */

#pragma mark - 考勤卡
- (void)refreshTimeCard
{
    //无考勤机
    if (_timeCardType <= kTimeCardNot) {
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        [self.view hideToastActivity];
        _tableView.userInteractionEnabled = YES;
        _showActivity = NO;
        return;
    }
    
    //今日之后
    if ([_calendarView.curDate compare:_today] == NSOrderedDescending) {
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        [self.view hideToastActivity];
        _tableView.userInteractionEnabled = YES;
        
        _timeCardList = nil;
        [_tableView reloadData];
        _showActivity = NO;
        return;
    }
    
    //网络
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        [self.view hideToastActivity];
        _tableView.userInteractionEnabled = YES;

        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        _showActivity = NO;
        return;
    }
    
    if (_showActivity) {
        [self.view makeToastActivity];
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAttenceDay"];
    [param setObject:[NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day] forKey:@"date"];
    [param setObject:[DJTGlobalManager shareInstance].userInfo.mid forKey:@"mid"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"attence"];
    _tableView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf refreshTimeCardFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf refreshTimeCardFinish:NO Data:nil];
    }];
}

- (void)refreshTimeCardFinish:(BOOL)suc Data:(id)result
{
    _showActivity = NO;
    [self.view hideToastActivity];
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    [_headerRefresh endRefreshing];
    
    _timeCardType = kTimeCardPayBind;
    if (suc) {
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        user.payType = (ePayMoney | ePayBind);
        NSString *str1 = [result valueForKey:@"ret_code"];
        if ([str1 isEqualToString:@"2001"]) {
            //未付费未绑定
            _timeCardType = kTimeCardNoPayNoBind;
            user.payType = ePayNull;
        }
        else if ([str1 isEqualToString:@"2002"])
        {
            //已付费未绑定
            _timeCardType = kTimeCardPayNoBind;
            user.payType = ePayMoney;
        }
        else if ([str1 isEqualToString:@"2003"])
        {
            //未支付已绑定
            _timeCardType = kTimeCardNoPayBind;
            user.payType = ePayBind;
        }
        
        [_typeDic setObject:[NSNumber numberWithInt:_timeCardType] forKey:[NSString stringWithFormat:@"%04ld-%02ld",(long)_calendarView.year,(long)_calendarView.month]];
        
        id ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        NSMutableArray *array = [NSMutableArray array];
        for (id subDic in ret_data) {
            TimeCardRecord *record = [[TimeCardRecord alloc] init];
            [record reflectDataFromOtherObject:subDic];
            [array addObject:record];
            
            if ([array count] > 2) {
                NSArray *sortArr = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    TimeCardRecord *stu1 = (TimeCardRecord *)obj1;
                    TimeCardRecord *stu2 = (TimeCardRecord *)obj2;
                    return (stu1.check_time.doubleValue > stu2.check_time.doubleValue);
                }];
                array = [NSMutableArray arrayWithArray:sortArr];
            }
        }
        _timeCardList = array;
        
        if ((_calendarView.year == _thisYear) && (_calendarView.month == _thisMonth)) {
            //当月不保存，以便数据刷新
            _pay_url = [result valueForKey:@"ret_msg"];
        }
    }
    else
    {
        _timeCardList = nil;
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
    [self resetTableFootView];
    [_tableView reloadData];
}

#pragma mark - php考勤记录
- (void)requestAllData
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSString *url = [URLFACE stringByAppendingString:@"attence:data"];
    NSDictionary *dic = @{@"student_id": user.userid,@"term_id": user.term_id};
    _tableView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    [self.view makeToastActivity];
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf finishAllDataRequest:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf finishAllDataRequest:NO Data:nil];
    }];
}

- (void)finishAllDataRequest:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        //日历数据
        NSArray *list = [result valueForKey:@"list"];
        list = (!list || [list isKindOfClass:[NSNull class]]) ? [NSArray array] : list;

        if ([list isKindOfClass:[NSArray class]] && [list count] > 0) {
            [_calendarView setDateArr:list];
        }
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 获取月考勤记录
- (void)getAttenceStudentByMonth:(BOOL)nextRequest
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    DJTUser *userInfo = manager.userInfo;
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAttenceStudentByMonth"];
    [param setObject:[NSString stringWithFormat:@"%04ld-%02ld",(long)_calendarView.year,(long)_calendarView.month] forKey:@"month"];
    [param setObject:userInfo.userid ?: @"" forKey:@"student_id"];
    [param setObject:userInfo.term_id ?: @"" forKey:@"term_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"attence"];
    _tableView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getAttenceStudentByMonthFinish:success Data:data Next:nextRequest];
    } failedBlock:^(NSString *description) {
        [weakSelf getAttenceStudentByMonthFinish:NO Data:nil Next:nextRequest];
    }];
}

- (void)getAttenceStudentByMonthFinish:(BOOL)suc Data:(id)result Next:(BOOL)nextRequest
{
    self.httpOperation = nil;
    
    if (suc) {
        NSArray *ret_data = [result valueForKey:@"ret_data"];
        if ([ret_data isKindOfClass:[NSArray class]]) {
            if ((_calendarView.year == _thisYear) && (_calendarView.month == _thisMonth)) {
                //当月不保存，以便数据刷新
            }
            else
            {
                [_dateArrDic setObject:ret_data forKey:[NSString stringWithFormat:@"%04ld-%02ld",(long)_calendarView.year,(long)_calendarView.month]];
            }
            
            if ([ret_data count] > 0) {
                [_calendarView setDateArr:ret_data];
            }
            
        }
        
        if (nextRequest) {
            [self refreshTimeCard];
        }
        else
        {
            _tableView.userInteractionEnabled = YES;
            [self.view hideToastActivity];
        }
    }
    else
    {
        _tableView.userInteractionEnabled = YES;
        [self.view hideToastActivity];
        
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 判断用户当前是否已支付
- (void)checkPay
{
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
    
    _tableView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf checkPayFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf checkPayFinish:NO Data:nil];
    }];
}

- (void)checkPayFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSString *pay_status = [ret_data valueForKey:@"pay_status"];
        NSString *haveCard = [ret_data valueForKey:@"haveCard"];
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        user.payType = (ePayType)(([haveCard integerValue] << 1) | ([pay_status integerValue]));
        if ((user.payType & ePayMoney) == ePayMoney) {
            kTimeCardType type = _timeCardType;
            if (type == kTimeCardNoPayBind) {
                _timeCardType = kTimeCardPayBind;
                [self resetTableFootView];
                [_tableView reloadData];
            }
            else if (type == kTimeCardNoPayNoBind)
            {
                _timeCardType = kTimeCardPayNoBind;
                [self resetTableFootView];
                [_tableView reloadData];
            }
        }
    }
}

@end
