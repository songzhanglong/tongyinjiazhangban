//
//  MyOrderViewController.m
//  NewTeacher
//
//  Created by szl on 16/4/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "MyOrderViewController.h"
#import "MyOrderDetailController.h"
#import "MyOrderCell.h"
#import "Toast+UIView.h"

@interface MyOrderViewController ()

@end

@implementation MyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showNewBack = YES;
    self.titleLable.text = @"我的订单";
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    [self createTableViewAndRequestAction:@"grow:order_list" Param:@{@"class_id":user.class_id,@"baby_id":user.baby_id} Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(236, 235, 243)];
    [self beginRefresh];
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

- (void)createTableFootView
{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[UIView new]];
    }
    else{
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90 + 40 +  5 + 14)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake((footView.frameWidth - 44) / 2, 90, 44, 40)];
        [tipImg setImage:CREATE_IMG(@"termTip")];
        [footView addSubview:tipImg];
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, tipImg.frameBottom + 5, footView.frameWidth, 14)];
        [tipLab setBackgroundColor:footView.backgroundColor];
        [tipLab setFont:[UIFont systemFontOfSize:10]];
        [tipLab setTextAlignment:NSTextAlignmentCenter];
        [tipLab setTextColor:[UIColor darkGrayColor]];
        [tipLab setText:@"暂无订单记录"];
        [footView addSubview:tipLab];
        
        [_tableView setTableFooterView:footView];
    }
    
}

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (!success) {
        NSString *ret_msg = [result valueForKey:@"message"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
    else{
        NSArray *dataList = [result valueForKey:@"data"];
        if (dataList && [dataList isKindOfClass:[NSArray class]]) {
            self.dataSource = [MyOrderList arrayOfModelsFromDictionaries:dataList error:nil];
        }
        else{
            self.dataSource = nil;
        }
        [_tableView reloadData];
        [self createTableFootView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-  (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataSource count];
}

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
    static NSString *myOrderIdentifier = @"myOrderIdentifier";
    MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:myOrderIdentifier];
    if (!cell) {
        cell = [[MyOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myOrderIdentifier];
    }
    
    [cell resetDataSource:self.dataSource[indexPath.section]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyOrderDetailController *detail = [[MyOrderDetailController alloc] init];
    detail.dataSource = @[self.dataSource[indexPath.section]];
    [self.navigationController pushViewController:detail animated:YES];
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
