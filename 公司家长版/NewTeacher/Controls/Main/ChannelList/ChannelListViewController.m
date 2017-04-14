//
//  ChannelListViewController.m
//  NewTeacher
//
//  Created by szl on 16/4/19.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "ChannelListViewController.h"
#include "PlayerApi.h"
#import "Toast+UIView.h"
#import "PlayVideoViewController.h"
#import "NSString+Common.h"

@interface ChannelListViewController ()

@property (nonatomic) int iNodeIndex;
@property (nonatomic) int iViindex;

@end

@implementation ChannelListViewController

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getOpenPower) object:nil];
    API_RequestLogout();
    API_DeleteLibInstance();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"园所视眼";
    
    //数据处理
    [self dealWithCurrentList];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    UIImageView *headerImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 282 / 640)];
    [headerImg setImage:CREATE_IMG(@"yssy3")];
    [_tableView setTableHeaderView:headerImg];
    
    //表尾
    [self tableFootViewRefresh];
    
    //数据刷新
    [self performSelector:@selector(getOpenPower) withObject:nil afterDelay:5 * 60];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [_tableView reloadData];
}

#pragma mark - Private Methods
- (void)dealWithCurrentList
{
    NSMutableArray *lstArr = [NSMutableArray array];
    for (PowerOpen *power in _powerList) {
        for (NSInteger i = 0; i < _deviceList.count; i++) {
            ChannelModel *deviceModel = [_deviceList objectAtIndex:i];
            if ([power.name isEqualToString:deviceModel.name]) {
                ChannelModel *model = [[ChannelModel alloc] init];
                model.name = deviceModel.name;
                model.nodeIdx = deviceModel.nodeIdx;
                model.open_time = power.open_time;
                model.is_valid = power.is_valid;
                [lstArr addObject:model];
                break;
            }
        }
    }
    self.dataSource = lstArr;
}

- (void)tableFootViewRefresh
{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, footView.frameBottom- 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:[UIColor lightGrayColor]];
        [label setText:@"暂未搜索到设备"];
        [footView addSubview:label];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((_tableView.frameWidth - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        [_tableView setTableFooterView:footView];
    }
}

- (BOOL)checkIsOpen:(ChannelModel *)model
{
    int status = model.nodeIdx;
    if (status == 0x1000 || status == 0x1001 || status == 0x1002)
    {
        return NO;
    }
    
    if (model.is_valid.integerValue == 1) {
        if (model.open_time.length > 0) {
            NSArray *array = [model.open_time componentsSeparatedByString:@","];
            NSString *curDate = [NSString stringByDate:@"HH:mm" Date:[NSDate date]];
            for (NSString *str in array) {
                NSArray *tmpArr = [str componentsSeparatedByString:@"-"];
                if (tmpArr.count == 2) {
                    if (([curDate compare:tmpArr[0]] != NSOrderedAscending) && ([curDate compare:tmpArr[1]] == NSOrderedAscending)) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

#pragma mark - 数据刷新，5分钟一次
- (void)getOpenPower
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    DJTUser *user = [manager userInfo];
    NSMutableDictionary *dic = [manager requestinitParamsWith:@"getMonitorList"];
    [dic setObject:user.school_id forKey:@"school_id"];
    [dic setObject:@"1" forKey:@"type"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"monitor"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getOpenPowerFinish:success Data:data];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getOpenPowerFinish:NO Data:nil];
        });
    }];
}

- (void)getOpenPowerFinish:(BOOL)success Data:(id)result
{
    self.httpOperation = nil;
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            NSMutableArray *powers = [PowerOpen arrayOfModelsFromDictionaries:ret_data error:nil];
            if (![powers isEqualToArray:_powerList]) {
                //不相同
                self.powerList = powers;
                [self dealWithCurrentList];
                [_tableView reloadData];
            }
        }
    }
    [self performSelector:@selector(getOpenPower) withObject:nil afterDelay:5 * 60];
}

#pragma mark - UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"DisclosureButtonCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 40)];
        [backView setTag:1];
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 4;
        [cell.contentView addSubview:backView];
        
        UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 16, 16)];
        [leftImg setImage:CREATE_IMG(@"yssy1")];
        [backView addSubview:leftImg];
        
        UIImageView *rightImg = [[UIImageView alloc] initWithFrame:CGRectMake(backView.frameWidth - 10 - 16, 12, 16, 16)];
        [rightImg setImage:CREATE_IMG(@"yssy2")];
        [rightImg setTag:11];
        [backView addSubview:rightImg];
        
        UILabel *rightLab = [[UILabel alloc] initWithFrame:CGRectMake(backView.frameWidth - 10 - 50, 11, 50, 18)];
        [rightLab setTextColor:[UIColor whiteColor]];
        [rightLab setTextAlignment:NSTextAlignmentRight];
        [rightLab setBackgroundColor:[UIColor clearColor]];
        [rightLab setFont:[UIFont systemFontOfSize:14]];
        [rightLab setText:@"未开启"];
        [rightLab setTag:10];
        [backView addSubview:rightLab];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5 + leftImg.frameRight, 10, rightLab.frameX - 10 - leftImg.frameRight, 20)];
        [label setFont:[UIFont systemFontOfSize:16]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTag:2];
        [label setBackgroundColor:[UIColor clearColor]];
        [backView addSubview:label];
    }
    // Configure the cell
    
    NSUInteger section = [indexPath section];
    
    ChannelModel *model =  [self.dataSource objectAtIndex:section];
    
    UIView *backView = [cell.contentView viewWithTag:1];
    [backView setBackgroundColor:(section % 2 == 0) ? rgba(73, 137, 250, 1) : rgba(47, 185, 126, 1)];
    
    UILabel *label = (UILabel *)[backView viewWithTag:2];
    [label setText:model.name];
    
    UIView *rightImg = [backView viewWithTag:11];
    UIView *rightLab = [backView viewWithTag:10];
    
    BOOL isOpen = [self checkIsOpen:model];
    rightImg.hidden = !isOpen;
    rightLab.hidden = isOpen;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = [indexPath section];
    ChannelModel *model =  [self.dataSource objectAtIndex:section];
    BOOL isOpen = [self checkIsOpen:model];
    if (!isOpen) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            UIView *backView = [cell.contentView viewWithTag:1];
            UIView *rightImg = [backView viewWithTag:11];
            if (rightImg && !rightImg.hidden) {
                [tableView reloadData];
            }
        }
        return;
    }
    
    _iNodeIndex = model.nodeIdx;
    
    PlayVideoViewController *playViewController = [[PlayVideoViewController alloc] init];
    playViewController.titleLable.text = model.name;
    playViewController.iNodeIndex = _iNodeIndex;
    playViewController.iViindex = _iViindex;
    [self.navigationController pushViewController:playViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

@end
