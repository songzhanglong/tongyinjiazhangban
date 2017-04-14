//
//  CookbookViewController.m
//  NewTeacher
//
//  Created by mac on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CookbookViewController.h"
#import "CookbookCell.h"
#import "NSString+Common.h"
#import "NSDate+Calendar.h"
#import "NSObject+Reflect.h"
#import "CookBookModel.h"
#import "CalendarFoodViewController.h"

@interface CookbookViewController ()

@end

@implementation CookbookViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isRefresh == YES) {
        [self beginRefresh];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showBack = YES;
    self.titleLable.text = @"每日食谱";
    
    isRefresh = NO;
    
    [self createRightBarButton];
    
    [self getWeekDay];
    
    NSDictionary *param = [self configRequestParam];
    self.useNewInterface = YES;
    [self createTableViewAndRequestAction:@"recipes" Param:param Header:YES Foot:NO];
    [_tableView setFrame:self.view.bounds];
    _tableView.backgroundColor = CreateColor(245, 245, 245);
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self beginRefresh];
}

#pragma mark - 参数配置
- (NSDictionary *)configRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getRecipes"];
    [param setObject:manager.userInfo.class_id forKey:@"class_id"];
    [param setObject:start_time forKey:@"start_time"];
    [param setObject:end_time forKey:@"end_time"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    return param;
}

#pragma mark - 获取时间数据
- (void)getWeekDay{
    _keyArray   = [NSMutableArray array];
    _titleArray = [NSMutableArray array];
    _dataArray = [NSMutableArray array];
    NSDate *todayDate = [NSDate date];
    NSDate *firstDate = [todayDate firstDayOfTheWeek];
    NSDate *lastDate = [firstDate followingDay];
    for (int i = 0 ; i< 7; i ++) {
        NSUInteger weekDay =[lastDate weekday];
        NSString *week = nil;
        switch (weekDay) {
            case 2:
                week = @"星期一";
                break;
            case 3:
                week = @"星期二";
                break;
            case 4:
                week = @"星期三";
                break;
            case 5:
                week = @"星期四";
                break;
            case 6:
                week = @"星期五";
                break;
            case 7:
                week = @"星期六";
                break;
            case 1:
                week = @"星期日";
                break;
            default:
                break;
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        [formatter setDateFormat:@"yyyy"];
        NSUInteger _year = [[formatter stringFromDate:lastDate] integerValue];
        [formatter setDateFormat:@"MM"];
        NSUInteger _month = [[formatter stringFromDate:lastDate] integerValue];
        [formatter setDateFormat:@"dd"];
        NSUInteger _day = [[formatter stringFromDate:lastDate] integerValue];
        NSString *weekTime = [NSString stringWithFormat:@"%@（%ld月%ld日）",week,(unsigned long)_month,(unsigned long)_day];
        NSString *keyString = [NSString stringWithFormat:@"%02ld月%02ld日",(unsigned long)_month,(unsigned long)_day];
        NSString *dataString = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(unsigned long)_year,(unsigned long)_month,(unsigned long)_day];
        [_dataArray addObject:dataString];
        [_keyArray   addObject:keyString];
        [_titleArray addObject:weekTime];
        
        lastDate  = [lastDate followingDay];
    }
    start_time = [self stringFromDate:[firstDate followingDay]];
    end_time   = [self stringFromDate:[lastDate previousDay]];
}

#pragma mark - 日期转字符串
- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

- (UIView *)createTableHeadView
{
    UIView *mview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    mview.backgroundColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, mview.bounds.size.width-20, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"星期一";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    [mview addSubview:label];
    return mview;
}

- (void)createRightBarButton
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    rightBtn.backgroundColor = [UIColor clearColor];
    [rightBtn setImage:[UIImage imageNamed:@"sp5.png"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"sp5_1.png"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)rightAction:(id)sender
{
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
    
    int index = 0;
    for (int i = 0; i < [_dataArray count]; i++) {
        if ([dataString isEqualToString:_dataArray[i]]) {
            index = i;
        }
    }
    CalendarFoodViewController *calendar = [[CalendarFoodViewController alloc] init];
    calendar.hidesBottomBarWhenPushed = YES;
    calendar.cookbookModel = self.dataSource[index];
    [self.navigationController pushViewController:calendar animated:YES];
}

#pragma mark - 网络请求结束
/**
 *	@brief	数据请求结果
 *
 *	@param 	success 	yes－成功
 *	@param 	result 	服务器返回数据
 */
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        NSArray *ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            NSMutableArray *indexArray = [NSMutableArray array];
            
            for (int i = 0; i < [_dataArray count]; i++) {
                CookBookModel *model = [[CookBookModel alloc] init];
                model.date = [_titleArray objectAtIndex:i];
                model.indexDate = [_dataArray objectAtIndex:i];
                NSMutableArray *tmpArr = [NSMutableArray array];
                CookBookItem *item = [[CookBookItem alloc] init];
                [tmpArr addObject:item];
                [model setItems:tmpArr];
                [indexArray addObject:model];
            }
            
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            for (NSDictionary *dic in ret_data) {
                NSString *key = [[dic allKeys] firstObject];
                NSArray *array = [[dic allValues] firstObject];
                for (int i = 0; i < [_dataArray count]; i++) {
                    NSString  *str = [_dataArray objectAtIndex:i];
                    if ([str isEqualToString:key]) {
                        CookBookModel *model = [[CookBookModel alloc] init];
                        model.date = _titleArray[i];
                        model.indexDate = key;
                        
                        NSMutableArray *tmpArr = [NSMutableArray array];
                        for (id subDic in array) {
                            CookBookItem *item = [[CookBookItem alloc] init];
                            [item reflectDataFromOtherObject:subDic];
                            [item calculeteConSize:winSize.width - 40 Font:[UIFont systemFontOfSize:14]];
                            [tmpArr addObject:item];
                        }
                        [model setItems:tmpArr];
                        [indexArray replaceObjectAtIndex:i withObject:model];
                    }
                }
                
            }
            self.dataSource = indexArray;
        }
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cookbookCell = @"cookbookCell";
    
    CookbookCell *cell = [tableView dequeueReusableCellWithIdentifier:cookbookCell];
    if (cell == nil)
    {
        cell = [[CookbookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cookbookCell];
    }
    
    CookBookModel *model = self.dataSource[indexPath.section];
    CookBookItem *item = model.items[indexPath.row];
    [cell resetClassCookbookData:item isHidden:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CookBookModel *model = self.dataSource[indexPath.section];
    CookBookItem *item = model.items[indexPath.row];
    return ([item.teacher_id length] <= 0) ? 70 : (20 + MAX(item.nameSize.height, item.contentSize.height));
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CookBookModel *model = self.dataSource[section];
    return [model.items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *mview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    mview.backgroundColor = CreateColor(225, 226, 229);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, mview.bounds.size.width-20, 20)];
    label.backgroundColor = [UIColor clearColor];
    CookBookModel *model = self.dataSource[section];
    label.text = model.date;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:14];
    [mview addSubview:label];
    return mview;
}

@end
