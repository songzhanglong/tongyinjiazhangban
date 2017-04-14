//
//  MyMsgViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/2/26.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyMsgViewController.h"
#import "DataBaseOperation.h"
#import "MyMsgModel.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "MyMsgView.h"
#import "ClassReplyDetailController.h"
#import "NotificationListViewController.h"
#import "YQSlideMenuController.h"
#import "MyTableBarViewController.h"
#import "MainViewController.h"
#import "MyCalendarViewController.h"
#import "GrowAlbumViewController.h"
#import "DJTOrderViewController.h"

@interface MyMsgViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@end

@implementation MyMsgViewController
{
    UITableView *_tableView;
    NSMutableArray *_dataSource,*_headsArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
    self.showBack = YES;
    self.titleLable.text = @"关于我的消息";

    _dataSource = [NSMutableArray array];
    _headsArr = [NSMutableArray array];
    
    __weak typeof(_dataSource)weakSource = _dataSource;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[DataBaseOperation shareInstance] selectMyMsgByDateAsc:NO];
        
        [weakSource addObjectsFromArray:array];
        NSMutableArray *ids = [NSMutableArray array];
        for (MyMsgModel *model in array) {
            [ids addObject:model.sender];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ids.count > 0) {
                NSString *userids = [ids componentsJoinedByString:@","];
                [weakSelf requestHeads:userids];
            }
            else
            {
                [weakSelf.view makeToast:@"暂无历史消息" duration:1.0 position:@"center"];
            }
        });
    });
}

- (void)selectDelete:(id)sender
{
    if (_dataSource.count == 0) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除通知" message:@"您确定全部清空吗?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)createTableView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"sticknotedelete2.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"sticknotedelete.png"] forState:UIControlStateHighlighted];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:@selector(selectDelete:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:footView];
    [self.view addSubview:_tableView];
}

#pragma mark - 头像信息
- (void)requestHeads:(NSString *)userids
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    //
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMemberFace"];
    [param setObject:userids forKey:@"userids"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"member"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestHeadsFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestHeadsFinish:NO Data:nil];
    }];
}

- (void)requestHeadsFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    
    if (suc) {
        NSArray *ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        [_headsArr addObjectsFromArray:ret_data];
        if (_headsArr.count == _dataSource.count) {
            [self createTableView];
        }
        else
        {
            [self.view makeToast:@"数据获取异常" duration:1.0 position:@"center"];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierBase = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBase];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBase];
        
        //preView
        MyMsgView *preView = [[MyMsgView alloc] initWithFrame:cell.bounds];
        [preView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [preView setTag:2];
        [cell.contentView addSubview:preView];
        
    }
    
    MyMsgView *msgView = (MyMsgView *)[cell.contentView viewWithTag:2];
    
    NSDictionary *dic = [[[_headsArr objectAtIndex:indexPath.row] allValues] firstObject];
    if ([dic isKindOfClass:[NSNull class]]) {
        dic = @{};
    }
    MyMsgModel *model = _dataSource[indexPath.row];
    
    NSString *url = [dic valueForKey:@"face"];
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [msgView.headImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    [msgView.nameLab setText:[dic valueForKey:@"name"]];
    
    CGRect contentRect = msgView.contentLab.frame;
    [msgView.contentLab setFrame:CGRectMake(contentRect.origin.x, contentRect.origin.y, contentRect.size.width, model.conSize.height)];
    [msgView.contentLab setText:model.eachData];
    
    CGRect timeRec = msgView.timeLab.frame;
    [msgView.timeLab setFrame:CGRectMake(timeRec.origin.x, contentRect.origin.y + model.conSize.height, timeRec.size.width, timeRec.size.height)];
    [msgView.timeLab setText:[NSString calculateTimeDistance:model.date]];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyMsgModel *model = _dataSource[indexPath.row];
    switch (model.mdFlag.integerValue) {
        case 6:
        {
            NotificationListViewController *list = [[NotificationListViewController alloc] init];
            [self.navigationController pushViewController:list animated:YES];
        }
            break;
        case 7:
        case 8:
        case 9:
        case 11:
        {
            ClassReplyDetailController *reply = [[ClassReplyDetailController alloc] init];
            reply.circleId = model.id;
            [self.navigationController pushViewController:reply animated:YES];
        }
            break;
        case 10:
        {
            NotificationListViewController *list = [[NotificationListViewController alloc] init];
            [self.navigationController pushViewController:list animated:YES];
        }
            break;
        case 12:
        {
            [self getCKey];
//            MyCalendarViewController *detail = [[MyCalendarViewController alloc]init];
//            [self.navigationController pushViewController:detail animated:YES];
        }
            break;
        case 13:
        {
            GrowAlbumViewController *grow = [[GrowAlbumViewController alloc]init];
            [self.navigationController pushViewController:grow animated:YES];
        }
            break;
            
        default:
            if (([model.url length] > 0) && ([model.url rangeOfString:@"null"].location == NSNotFound)) {
                DJTOrderViewController *controller = [[DJTOrderViewController alloc] init];
                controller.url = [model.url stringByAppendingFormat:@"&mid=%@", [DJTGlobalManager shareInstance].userInfo.mid];
                [self.navigationController pushViewController:controller animated:YES];
            }
            break;
    }
    
    [_dataSource removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DataBaseOperation shareInstance] deleteMyMsg:@[model]];
    });
    
    YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    if ([sideCon isKindOfClass:[YQSlideMenuController class]]) {
        MyTableBarViewController *tabBarCon = (MyTableBarViewController *)sideCon.contentViewController;
        UINavigationController *mainNav = [tabBarCon.viewControllers firstObject];
        MainViewController *main = [[mainNav viewControllers] firstObject];
        main.refreshNotice = YES;
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber -= 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyMsgModel *model = _dataSource[indexPath.row];
    return MAX(model.conSize.height + 20 + 18 + 20, 60);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        MyMsgModel *model = _dataSource[indexPath.row];
        [_dataSource removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DataBaseOperation shareInstance] deleteMyMsg:@[model]];
        });
        
        YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
        if ([sideCon isKindOfClass:[YQSlideMenuController class]]) {
            MyTableBarViewController *tabBarCon = (MyTableBarViewController *)sideCon.contentViewController;
            UINavigationController *mainNav = [tabBarCon.viewControllers firstObject];
            MainViewController *main = [[mainNav viewControllers] firstObject];
            main.refreshNotice = YES;
        }
        
        UIApplication *app = [UIApplication sharedApplication];
        app.applicationIconBadgeNumber -= 1;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSMutableArray *arraySource = [NSMutableArray array];
        [arraySource addObjectsFromArray:_dataSource];
        [_dataSource removeAllObjects];
        [_tableView reloadData];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DataBaseOperation shareInstance] deleteMyMsg:arraySource];
        });
        
        YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
        if ([sideCon isKindOfClass:[YQSlideMenuController class]]) {
            MyTableBarViewController *tabBarCon = (MyTableBarViewController *)sideCon.contentViewController;
            UINavigationController *mainNav = [tabBarCon.viewControllers firstObject];
            MainViewController *main = [[mainNav viewControllers] firstObject];
            main.refreshNotice = YES;
        }
        
        UIApplication *app = [UIApplication sharedApplication];
        app.applicationIconBadgeNumber = 0;
    }
}

#pragma mark - 获取密钥
- (void)getCKey
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getKey"];
    [param setObject:@"parent" forKey:@"from"];
    [param setObject:manager.userInfo.class_id forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"token"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getKeyFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf getKeyFinish:NO Data:nil];
    }];
}

- (void)getKeyFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    if (!suc) {
        NSString *str = [result valueForKey:@"ret_msg"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        //用户数据处理
        id ret_data = [result valueForKey:@"ret_data"];
        if ([ret_data isKindOfClass:[NSNull class]]) {
            ret_data = [ret_data lastObject];
        }
        
        NSString *value = [ret_data valueForKey:@"key"];
        DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
        NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/Home/kq/classKqIndex/key/%@/isTeacher/0/type/1.html",value];
        order.url = url;
        order.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:order animated:YES];
    }
}

@end
