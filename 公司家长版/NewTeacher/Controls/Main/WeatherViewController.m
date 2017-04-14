//
//  WeatherViewController.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/14.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "WeatherViewController.h"
#import "WeatherTableViewCell.h"
#import "WeatherTableViewCell2.h"
#import "WeatherModel.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "NSDate+Calendar.h"

#define CITY_NAME       @"city_name"
#define WEALTHY_DATA    @"weatherData"
#define WEALTHY         @"weather"
#define DAY_IMG         @"day_img"
#define NIGHT_IMG       @"night_img"
#define WEAL_TIME       @"wealTime"
#define LOWEST          @"lowest"

@interface WeatherViewController ()

@end

@implementation WeatherViewController
{
    WeatherModel *_weatherModel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [bgView setImage:CREATE_IMG(@"weather_bg")];
    [bgView setUserInteractionEnabled:YES];
    [self.view addSubview:bgView];
    
    CGFloat yOri = 20;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, yOri + 7, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:CREATE_IMG(@"backL@2x") forState:UIControlStateNormal];
    [backBtn setImage:CREATE_IMG(@"back_1") forState:UIControlStateSelected];
    [backBtn addTarget:self action:@selector(backToPreControl:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    self.useNewInterface = NO;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"class_id":manager.userInfo.class_id,@"mid":manager.userInfo.mid,@"mobile":[userDefault objectForKey:LOGIN_ACCOUNT]};
    [self createTableViewAndRequestAction:@"weather:info" Param:dic Header:YES Foot:NO];
    [_tableView setFrame:CGRectMake(0, yOri + 44 + 10, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    _tableView.backgroundColor = [UIColor clearColor];

    [self beginRefresh];
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        NSDictionary *dic = [result valueForKey:@"data"];
        if (dic) {
            NSDictionary *pm = [dic valueForKey:@"pm"];
            NSError *error;
            PMModel *pmModel = [[PMModel alloc] initWithDictionary:pm error:&error];
            if (error) {
                NSLog(@"%@",error.description);
            }
            [pmModel setPM25Value];
            
            NSDictionary *weather = [dic valueForKey:@"weather"];
            WeatherModel *weatherModel= [[WeatherModel alloc] initWithDictionary:weather error:&error];
            if (error) {
                NSLog(@"%@",error.description);
            }
            weatherModel.pmMdel = pmModel;
            weatherModel.tip = [NSString stringWithFormat:@"派派提醒您：%@", weatherModel.tip ?: @""];
            [weatherModel calculeteConSize];
            
            _weatherModel = weatherModel;
            
            [self setNavRightView];
            
            [self createTableHeaderView];
            
            [_tableView reloadData];
        }
    }else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"message"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}
- (void)setNavRightView
{
    CGFloat yOri = 20;
    UIImageView *imgView = (UIImageView *)[self.view viewWithTag:6];
    if (!imgView) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, yOri + 17, 10.0, 10.0)];
        [imgView setImage:CREATE_IMG(@"weather3")];
        [imgView setTag:6];
        [self.view addSubview:imgView];
    }
    
    UILabel *timeLabel = (UILabel *)[self.view viewWithTag:7];
    if (!timeLabel) {
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 5, yOri + 13, SCREEN_WIDTH - imgView.frameRight - 5, 18)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:10];
        [timeLabel setTag:7];
        [self.view addSubview: timeLabel];
    }
    NSDate *publicDate = [NSDate dateWithTimeIntervalSince1970:_weatherModel.pubtime.doubleValue];
    timeLabel.text = [NSString stringWithFormat:@"发布时间  %@",[NSString stringByDate:@"HH:mm" Date:publicDate]];
}
- (void)createTableHeaderView {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 105)];
    headView.backgroundColor = [UIColor clearColor];
    
    NSString *lowest = _weatherModel.lowest ?: @"";
    NSString *hightest = _weatherModel.hightest ?: @"";
    NSString *lowToHigh = [lowest stringByAppendingString:[NSString stringWithFormat:@"~%@°",hightest]];
    
    UILabel *wdlab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 175, 60)];
    wdlab.backgroundColor = [UIColor clearColor];
    wdlab.textAlignment = NSTextAlignmentRight;
    if (![lowToHigh hasPrefix:@"~"]) {
        [wdlab setText:lowToHigh];
    }
    wdlab.textColor = [UIColor whiteColor];
    wdlab.font = [UIFont boldSystemFontOfSize:40];
    [headView addSubview:wdlab];
    
    NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
    UIImageView *wealthy = [[UIImageView alloc] initWithFrame:CGRectMake(wdlab.frameRight + 5, 0, 75 / 2, 65 / 2)];
    NSString *day_img = [[NSUserDefaults standardUserDefaults] objectForKey:[DAY_IMG stringByAppendingString:userId]];
    if (day_img) {
        [wealthy setImageWithURL:[NSURL URLWithString:day_img]];
    }
    [wealthy setContentMode:UIViewContentModeScaleAspectFit];
    [headView addSubview:wealthy];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(wdlab.frameRight + 5 - 20, wealthy.frameBottom + 5, 75 / 2 + 40, 20)];
    nameLab.backgroundColor = [UIColor clearColor];
    nameLab.text = _weatherModel.weather;
    nameLab.textColor = [UIColor whiteColor];
    nameLab.textAlignment = NSTextAlignmentCenter;
    nameLab.font = [UIFont boldSystemFontOfSize:16];
    [headView addSubview:nameLab];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, headView.frameHeight - 25 - 2.5, 15, 15)];
    [imgView setImage:CREATE_IMG(@"weather1")];
    [headView addSubview:imgView];
    
    UILabel *placeLab = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 10, headView.frameHeight - 30, 60, 20)];
    placeLab.backgroundColor = [UIColor clearColor];
    placeLab.text = _weatherModel.city_name;
    placeLab.font = [UIFont boldSystemFontOfSize:14];
    placeLab.textColor = [UIColor whiteColor];
    [headView addSubview:placeLab];
    
    UILabel *dateLab = [[UILabel alloc] initWithFrame:CGRectMake(placeLab.frameRight + 10, headView.frameHeight - 30,  headView.frameWidth - placeLab.frameRight - 20, 20)];
    dateLab.backgroundColor = [UIColor clearColor];
    NSString *timeStr = [NSString stringByDate:@"yyyy年MM月dd日" Date:[NSDate date]];
    NSString *week = @"";
    for (int i = 0 ; i< 7; i ++) {
        NSUInteger weekDay =[[NSDate date] weekday];
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
    }
    dateLab.text = [NSString stringWithFormat:@"%@ %@",timeStr,week];
    dateLab.font = [UIFont boldSystemFontOfSize:12];
    dateLab.textAlignment = NSTextAlignmentRight;
    dateLab.textColor = [UIColor whiteColor];
    [headView addSubview:dateLab];
    
    [_tableView setTableHeaderView:headView];
}
- (void)backToPreControl:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = (indexPath.section == 0) ? @"tipCell" : ((indexPath.section == 1) ? @"qualityCell" : @"qualityCell2");
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (indexPath.section == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 40)];
            bgView.backgroundColor = [UIColor blackColor];
            bgView.alpha = 0.3;
            [bgView setTag:9];
            [cell.contentView addSubview:bgView];
            
            UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 40, 40)];
            tipLabel.backgroundColor = [UIColor clearColor];
            tipLabel.numberOfLines = 0;
            [tipLabel setTag:10];
            tipLabel.textColor = [UIColor whiteColor];
            tipLabel.font = [UIFont boldSystemFontOfSize:12];
            [cell.contentView addSubview:tipLabel];
            
        }else if (indexPath.section == 1) {
            cell = [[WeatherTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }else {
            cell = [[WeatherTableViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0) {
        UILabel *tipLabel = (UILabel *)[cell.contentView viewWithTag:10];
        [tipLabel setText:_weatherModel.tip];
        [tipLabel setFrame:CGRectMake(20, 0, SCREEN_WIDTH - 40, _weatherModel.contSize.height)];
        UIView *bgView = (UIView *)[cell.contentView viewWithTag:9];
        [bgView setFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, _weatherModel.contSize.height)];
    }
    else if (indexPath.section == 1) {
        [(WeatherTableViewCell *)cell resetDataSource:_weatherModel];
    }else if (indexPath.section == 2){
        [(WeatherTableViewCell2 *)cell resetDataSource:_weatherModel];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0) ? _weatherModel.contSize.height : ((indexPath.section == 1) ? 95 : 215);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
