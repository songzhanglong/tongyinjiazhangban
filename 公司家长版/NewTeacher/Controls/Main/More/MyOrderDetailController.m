//
//  MyOrderDetailController.m
//  NewTeacher
//
//  Created by szl on 16/5/12.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "MyOrderDetailController.h"
#import "MyOrderCell.h"
#import "NSString+Common.h"

@interface MyOrderDetailController ()

@end

@implementation MyOrderDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showNewBack = YES;
    self.titleLable.text = @"我的订单";
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [_tableView setBackgroundColor:CreateColor(236, 235, 243)];
    [self createTableHeaderView];
}

- (void)createTableHeaderView
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 66)];
    [topView setBackgroundColor:CreateColor(63, 71, 97)];
    
    MyOrderList *order = [self.dataSource firstObject];
    
    UILabel *orderLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, topView.frameWidth - 20, 18)];
    [orderLab setText:[NSString stringWithFormat:@"发货备注：%@，单号%@",order.delivery_remark,order.order_no]];
    [orderLab setBackgroundColor:topView.backgroundColor];
    [orderLab setTextColor:[UIColor whiteColor]];
    [orderLab setFont:[UIFont systemFontOfSize:14]];
    [topView addSubview:orderLab];
    
    UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(orderLab.frameX, orderLab.frameBottom + 6, orderLab.frameWidth, 16)];
    [timeLab setFont:[UIFont systemFontOfSize:12]];
    [timeLab setBackgroundColor:topView.backgroundColor];
    [timeLab setTextColor:orderLab.textColor];
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:order.create_time.doubleValue];
    [timeLab setText:[NSString stringWithFormat:@"发货时间：%@",[NSString stringByDate:@"yyyy-MM-dd" Date:updateDate]]];
    [topView addSubview:timeLab];
    
    [_tableView setTableHeaderView:topView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(245, 245, 245);
    }
    else
    {
        navBar.tintColor = CreateColor(245, 245, 245);
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myOrderIdentifier2 = @"myOrderIdentifier2";
    MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:myOrderIdentifier2];
    if (!cell) {
        cell = [[MyOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myOrderIdentifier2];
    }
    
    [cell resetDataSource:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 107;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

@end
