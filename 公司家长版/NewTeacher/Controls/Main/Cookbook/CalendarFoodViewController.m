//
//  CalendarFoodViewController.m
//  NewTeacher
//
//  Created by mac on 15/7/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarFoodViewController.h"
#import "MJRefresh.h"
#import "NSString+Common.h"
#import "MyCalendarView2.h"
#import "Toast+UIView.h"
#import "NSObject+Reflect.h"
#import "UIImage+Caption.h"
#import "NotificationListViewController.h"
#import "NSDate+Calendar.h"
#import "CookbookCell.h"

@interface CalendarFoodViewController ()<MyCalendarView2Delegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation CalendarFoodViewController
{
    MyCalendarView2 *_calendarView;
    UITableView *_downTableView;
    NSMutableDictionary *_dateDic;
    UIScrollView *_scrollView;//background
    //MJRefreshHeaderView *_headerRefresh;
}
- (void)dealloc
{
    //[_headerRefresh free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [NSMutableArray array];
    allArray = [NSMutableArray array];
    self.showBack = YES;
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    
    self.titleLable.text = [NSString stringByDate:@"yyyy年MM月" Date:[NSDate date]];
    self.titleLable.textColor = [UIColor whiteColor];
    _dateDic = [NSMutableDictionary dictionary];
    isRefresh = NO;
    
    _scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _scrollView.showsVerticalScrollIndicator = NO;
    
//    MJRefreshHeaderView *hView = [MJRefreshHeaderView header];
//    hView.scrollView = _scrollView;
//    __weak typeof(self)weakSelf = self;
//    hView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
//        [weakSelf sendRequest];
//    };
//    _headerRefresh = hView;
    [self.view addSubview:_scrollView];
    
    [self createRightBarButton];
    //日历
    MyCalendarView2 *calendar = [[MyCalendarView2 alloc] initWithFrame:CGRectZero];
    _calendarView = calendar;
    calendar.delegate = self;
    [calendar setCurDate:[NSDate date]];
    [_scrollView addSubview:calendar];
    
    //表格
    _downTableView = [[UITableView alloc] init];
    _downTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _downTableView.dataSource = self;
    _downTableView.scrollEnabled = NO;
    _downTableView.delegate = self;
    [_scrollView addSubview:_downTableView];
    [_downTableView registerClass:[CookbookCell class] forCellReuseIdentifier:@"CalendarCookbookCell"];
    
    CGFloat scroHei = _downTableView.frame.origin.y + _downTableView.frame.size.height;
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, MAX(_scrollView.frame.size.height +1, scroHei))];
    
    [self sendRequest];
    
}
- (void)sendRequest
{
    NSDate *todayDate = [NSDate date];
    NSString *year = [self stringFromDate:todayDate];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getRecipes"];
    [param setObject:manager.userInfo.class_id forKey:@"class_id"];
    [param setObject:[NSString stringWithFormat:@"%@-01-01",year] forKey:@"start_time"];
    [param setObject:[NSString stringWithFormat:@"%@-12-31",year] forKey:@"end_time"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [self.view makeToastActivity];
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"recipes"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getDateFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf getDateFinish:NO Data:nil];
    }];
}
- (void)getDateFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    self.httpOperation = nil;
    if (!success) {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
    else
    {
        NSArray *ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            for (NSDictionary *dic in ret_data) {
                NSString *key = [[dic allKeys] firstObject];
                NSArray *array = [[dic allValues] firstObject];
                CookBookModel *model = [[CookBookModel alloc] init];
                model.indexDate = key;
                model.date = key;
                
                NSMutableArray *tmpArr = [NSMutableArray array];
                for (id subDic in array) {
                    CookBookItem *item = [[CookBookItem alloc] init];
                    [item reflectDataFromOtherObject:subDic];
                    [item calculeteConSize:winSize.width - 40 Font:[UIFont systemFontOfSize:14]];
                    [tmpArr addObject:item];
                }
                [model setItems:tmpArr];
                [allArray addObject:model];
                
            }
        }
        BOOL isFind = NO;
        NSDate *todayDate = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        [formatter setDateFormat:@"yyyy"];
        NSUInteger _year = [[formatter stringFromDate:todayDate] integerValue];
        [formatter setDateFormat:@"MM"];
        NSUInteger _month = [[formatter stringFromDate:todayDate] integerValue];
        [formatter setDateFormat:@"dd"];
        NSUInteger _day = [[formatter stringFromDate:todayDate] integerValue];
        NSString *dataString = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(unsigned long)_year,(unsigned long)_month,(unsigned long)_day];
        CGFloat indexFloat = 20.0;
        for (int i = 0; i < [allArray count]; i++) {
            CookBookModel *model = [allArray objectAtIndex:i];
            if (model.indexDate && [dataString isEqualToString:model.indexDate]) {
                _currModel = model;
                for (CookBookItem *item in model.items) {
                    indexFloat += ([item.teacher_id length] <= 0) ? 70 : (20 + MAX(item.nameSize.height, item.contentSize.height));
                }
                [_dataArray addObject:model];
                isFind = YES;
            }
        }
        if (!isFind) {
            CookBookModel *model = [[CookBookModel alloc] init];
            model.date = dataString;
            model.indexDate = dataString;
            NSMutableArray *tmpArr = [NSMutableArray array];
            CookBookItem *item = [[CookBookItem alloc] init];
            [tmpArr addObject:item];
            [model setItems:tmpArr];
            [_dataArray addObject:model];
            for (CookBookItem *item in model.items) {
                indexFloat += ([item.teacher_id length] <= 0) ? 70 : (20 + MAX(item.nameSize.height, item.contentSize.height));
            }
        }
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        _downTableView.frame = CGRectMake(0, _calendarView.frame.size.height, winSize.width, indexFloat);
        CGFloat scroHei = _downTableView.frame.origin.y + _downTableView.frame.size.height;
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, MAX(_scrollView.frame.size.height +1, scroHei))];
        [_downTableView reloadData];
    }
}
- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
- (void)createRightBarButton
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    rightBtn.backgroundColor = [UIColor clearColor];
    [rightBtn setImage:[UIImage imageNamed:@"rl1.png"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"rl1_1.png"] forState:UIControlStateHighlighted];
    //[rightBtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn addTarget:self action:@selector(backToToday:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}
- (void)backToToday:(id)sender
{
    [_calendarView changeToToday];
    [_dataArray removeAllObjects];
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateFormat:@"yyyy"];
    NSUInteger _year = [[formatter stringFromDate:todayDate] integerValue];
    [formatter setDateFormat:@"MM"];
    NSUInteger _month = [[formatter stringFromDate:todayDate] integerValue];
    [formatter setDateFormat:@"dd"];
    NSUInteger _day = [[formatter stringFromDate:todayDate] integerValue];
    NSString *dataString = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(unsigned long)_year,(unsigned long)_month,(unsigned long)_day];
    CGFloat indexFloat = 20.0;
    BOOL isFind = NO;
    for (int i = 0; i < [allArray count]; i++) {
        CookBookModel *model = [allArray objectAtIndex:i];
        if (model.indexDate && [dataString isEqualToString:model.indexDate]) {
            _currModel = model;
            for (CookBookItem *item in model.items) {
                indexFloat += ([item.teacher_id length] <= 0) ? 70 : (20 + MAX(item.nameSize.height, item.contentSize.height));
            }
            [_dataArray addObject:model];
            isFind = YES;
        }
    }
    if (!isFind) {
        CookBookModel *model = [[CookBookModel alloc] init];
        model.date = dataString;
        model.indexDate = dataString;
        NSMutableArray *tmpArr = [NSMutableArray array];
        CookBookItem *item = [[CookBookItem alloc] init];
        [tmpArr addObject:item];
        [model setItems:tmpArr];
        [_dataArray addObject:model];
        for (CookBookItem *item in model.items) {
            indexFloat += ([item.teacher_id length] <= 0) ? 70 : (20 + MAX(item.nameSize.height, item.contentSize.height));
        }
    }
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    _downTableView.frame = CGRectMake(0, _calendarView.frame.size.height, winSize.width, indexFloat);
    CGFloat scroHei = _downTableView.frame.origin.y + _downTableView.frame.size.height;
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, MAX(_scrollView.frame.size.height +1, scroHei))];
    [_downTableView reloadData];
}
#pragma mark- MyCalendarView delegate
- (void)changeMonth:(MyCalendarView2 *)calendar
{
    self.titleLable.text = [NSString stringWithFormat:@"%ld年%02ld月",(long)calendar.year,(long)calendar.month];
}
- (void)changeDay:(MyCalendarView2 *)calendar
{
    [_dataArray removeAllObjects];
    NSString *dataString = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)calendar.year,(long)calendar.month,(long)calendar.day];
    CGFloat indexFloat = 20.0;
    
    BOOL isFind = NO;
    for (int i = 0; i < [allArray count]; i++) {
        CookBookModel *model = [allArray objectAtIndex:i];
        if (model.indexDate && [dataString isEqualToString:model.indexDate]) {
            _currModel = model;
            for (CookBookItem *item in model.items) {
                indexFloat += ([item.teacher_id length] <= 0) ? 70 : (20 + MAX(item.nameSize.height, item.contentSize.height));
            }
            [_dataArray addObject:model];
            
            isFind = YES;
        }
    }
    if (!isFind) {
        CookBookModel *model = [[CookBookModel alloc] init];
        model.date = dataString;
        model.indexDate = dataString;
        NSMutableArray *tmpArr = [NSMutableArray array];
        CookBookItem *item = [[CookBookItem alloc] init];
        [tmpArr addObject:item];
        [model setItems:tmpArr];
        [_dataArray addObject:model];
        for (CookBookItem *item in model.items) {
            indexFloat += ([item.teacher_id length] <= 0) ? 70 : (20 + MAX(item.nameSize.height, item.contentSize.height));
        }
    }
    
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    _downTableView.frame = CGRectMake(0, _calendarView.frame.size.height, winSize.width, indexFloat);
    CGFloat scroHei = _downTableView.frame.origin.y + _downTableView.frame.size.height;
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, MAX(_scrollView.frame.size.height +1, scroHei))];
    [_downTableView reloadData];
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
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cookbookCell = @"CalendarCookbookCell";
    CookbookCell *cell = [tableView dequeueReusableCellWithIdentifier:cookbookCell];
    if (cell == nil)
    {
        cell = [[CookbookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cookbookCell];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    CookBookModel *model = [_dataArray objectAtIndex:0];
    CookBookItem *item = model.items[indexPath.row];
    [cell resetClassCookbookData:item isHidden:NO];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //    EditCookbookViewController *editController = [[EditCookbookViewController alloc] init];
    //    editController.titleLable.text = [NSString stringWithFormat:@"编辑食谱(%@)",[_currModel.date substringWithRange:NSMakeRange(4, [_currModel.date length]-5)]];
    //    editController.currData = _currModel.indexDate;
    //    editController.cookModel = _currModel;
    //    [self.navigationController pushViewController:editController animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CookBookModel *model = [_dataArray objectAtIndex:0];
    CookBookItem *item = model.items[indexPath.row];
    return ([item.teacher_id length] <= 0) ? 70 : (20 + MAX(item.nameSize.height, item.contentSize.height));
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_dataArray count] > 0) {
        CookBookModel *model = [_dataArray objectAtIndex:0];
        return [model.items count];
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CookBookModel *model = [_dataArray objectAtIndex:0];
    UIView *mview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    mview.backgroundColor = CreateColor(225, 226, 229);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, mview.bounds.size.width-20, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = model.date;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:14];
    [mview addSubview:label];
    return mview;
}

@end
