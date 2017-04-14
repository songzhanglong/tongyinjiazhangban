//
//  NotificationListViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/10.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationListViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "NotificationListModel.h"
#import "NotificationListCell.h"
#import "NotificationDetailViewController.h"

@interface NotificationListViewController ()
{
    NSInteger _pageIndex;
}

@end

@implementation NotificationListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"园所通知";
    self.useNewInterface = YES;
    _pageIndex = 1;
    
    //表格＋网络
    [self createTableViewAndRequestAction:@"message" Param:nil Header:YES Foot:YES];
    [_tableView registerClass:[NotificationListCell class] forCellReuseIdentifier:@"notificationCellId"];
    
    [self beginRefresh];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=NO;
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMessage"];
    [param setObject:manager.userInfo.baby_id forKey:@"baby_id"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIndex] forKey:@"page"];
    [param setObject:@"10" forKey:@"pageSize"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)startPullRefresh
{
    _pageIndex = 1;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    NSInteger count = [self.dataSource count];
    
    if ((count % 10) > 0) {
        [self.view makeToast:@"已到最后一页" duration:1.0 position:@"center"];
        
        //isStopRefresh
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
    }
    else
    {
        _pageIndex = count / 10 + 1;
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        if (!ret_data || [ret_data isKindOfClass:[NSNull class]]) {
            [self.view makeToast:@"园所通知暂无" duration:1.0 position:@"center"];
            return;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error = nil;
            NotificationListModel *model = [[NotificationListModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [model calculateNotificationRect];
            [array addObject:model];
        }
        
        self.dataSource = array;
        [_tableView reloadData];
    }
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (!ret_data || [ret_data isKindOfClass:[NSNull class]]) {
            return;
        }
        
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSInteger curCount = [self.dataSource count];
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger section = [_tableView numberOfSections] - 1;
        for (id subDic in data) {
            NSError *error = nil;
            NotificationListModel *model = [[NotificationListModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [model calculateNotificationRect];
            if (!self.dataSource) {
                self.dataSource = [NSMutableArray array];
            }
            [self.dataSource addObject:model];
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:curCount++ inSection:section]];
        }
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        if (_pageIndex > 1) {
            _pageIndex -= 1;
        }
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCellId" forIndexPath:indexPath];
    [cell resetNotifiCationSource:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationListModel *model = self.dataSource[indexPath.row];
    return MIN(model.conSize.height, 61) + 48 + 20 + 16;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NotificationDetailViewController *notificationDetailViewController = [[NotificationDetailViewController alloc] init];
    notificationDetailViewController.listModel = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:notificationDetailViewController animated:YES];
}

@end
