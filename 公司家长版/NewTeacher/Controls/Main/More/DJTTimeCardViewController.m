//
//  DJTTimeCardViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTimeCardViewController.h"
#import "NSString+Common.h"
#import "TimeCardModel.h"
#import "Toast+UIView.h"
#import "BindingTimeCardController.h"
#import "TimeCardViewCell.h"

@interface DJTTimeCardViewController ()<UIAlertViewDelegate,TimeCardBindingDelegate,TimeCardViewCellDelegate>

@end

@implementation DJTTimeCardViewController
{
    NSIndexPath *_indexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    [self createRightBtn];
    self.titleLable.text = @"考勤卡";
    self.useNewInterface = YES;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getCards"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [self createTableViewAndRequestAction:@"attence" Param:param Header:YES Foot:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView registerClass:[TimeCardViewCell class] forCellReuseIdentifier:@"timeCardCellId"];
    [self beginRefresh];
}

- (void)createRightBtn
{
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    addBtn.backgroundColor = [UIColor clearColor];
    [addBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"jia" ofType:@"png"]] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"jia_1" ofType:@"png"]] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addNewTimeCard:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,addBarButtonItem];
}

- (void)addNewTimeCard:(id)sender
{
    if (self.httpOperation) {
        [self.view makeToast:@"数据正在加载，请稍候" duration:1.0 position:@"center"];
        return;
    }
    else if ([self.dataSource count] > 5) {
        [self.view makeToast:@"绑定的考勤卡不可超过5张" duration:1.0 position:@"center"];
        return;
    }
    
    BindingTimeCardController *binding = [[BindingTimeCardController alloc] init];
    [self.navigationController pushViewController:binding animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_shouldRefresh) {
        _shouldRefresh = NO;
        [self beginRefresh];
    }
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
        id ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        if ([ret_data count] == 0) {
            [self.view makeToast:@"暂无绑定的考勤卡" duration:1.0 position:@"center"];
        }
        else
        {
            NSMutableArray *source = [NSMutableArray array];
            for (id sub in ret_data) {
                NSError *error;
                TimeCardModel *timeCard = [[TimeCardModel alloc] initWithDictionary:sub error:&error];
                if (error) {
                    NSLog(@"%@",error.description);
                    continue;
                }
                [source addObject:timeCard];
            }
            
            self.dataSource = source;
            [_tableView reloadData];
        }
        
    }
}

#pragma mark - TimeCardBindingDelegate
- (void)reloadTimeCardCell
{
    [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - TimeCardViewCellDelegate
- (void)cancelBindAndChangeInfo:(UITableViewCell *)cell Tag:(NSInteger)index
{
    _indexPath = [_tableView indexPathForCell:cell];
    if (index == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否解除此卡绑定？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else if (index == 1){
        //修改信息
        BindingTimeCardController *binding = [[BindingTimeCardController alloc] init];
        binding.cardModel = self.dataSource[_indexPath.row];
        binding.delegate = self;
        [self.navigationController pushViewController:binding animated:YES];
    }
}

#pragma mark - 解除绑定
- (void)cancelBinding:(NSString *)cardId
{
    _tableView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"relieve"];
    [param setObject:cardId forKey:@"card_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"attence"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf cancelBindingFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf cancelBindingFinish:NO Data:nil];
    }];
}

- (void)cancelBindingFinish:(BOOL)success Data:(id)result
{
    _tableView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    self.httpOperation = nil;
    if (success) {
        [self.dataSource removeObjectAtIndex:_indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [DJTGlobalManager shareInstance].userInfo.payType = ([self.dataSource count] == 0) ? ePayMoney : (ePayBind | ePayMoney);
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 挂失与解除挂失
- (void)lossMyCard
{
    _tableView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    
    TimeCardModel *timeCard = self.dataSource[_indexPath.row];
    NSString *ckey = ([timeCard.status integerValue] == 2) ? @"unloss" : @"loss";
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:ckey];
    [param setObject:timeCard.card_id forKey:@"card_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"attence"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf lossCardFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf lossCardFinish:NO Data:nil];
    }];
}

- (void)lossCardFinish:(BOOL)suc Data:(id)result
{
    _tableView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    self.httpOperation = nil;
    TimeCardModel *timeCard = self.dataSource[_indexPath.row];
    if (suc) {
        if ([timeCard.status integerValue] == 2) {
            timeCard.status = @"1";
        }
        else
        {
            timeCard.status = @"2";
        }
        [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
            [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            return;
        }
        
        TimeCardModel *timeCard = self.dataSource[_indexPath.row];
        [self cancelBinding:timeCard.card_id];
        //[self lossMyCard];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeCardViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCardCellId" forIndexPath:indexPath];
    cell.delegate = self;
    [cell resetTimeCard:self.dataSource[indexPath.row]];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 264.5;
}

@end
