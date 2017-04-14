//
//  DJTTableViewVC.m
//  TY
//
//  Created by songzhanglong on 14-5-28.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "DJTHttpClient.h"
#import "Toast+UIView.h"
#import "MJRefresh.h"
#import "AppDelegate.h"

@interface DJTTableViewController ()

@end

@implementation DJTTableViewController
{
    MJRefreshHeaderView *_headerRefresh;
    MJRefreshFooterView *_footerRefresh;
    
}

- (void)dealloc
{
    [_footerRefresh free];
    [_headerRefresh free];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_browserPhotos removeAllObjects];
}

/**
 *	@brief	创建表和网络请求
 *
 *	@param 	action 	接口动作类型
 *	@param 	param 	接口参数
 *	@param 	header 	下拉
 *	@param 	foot 	上拉
 */
- (void)createTableViewAndRequestAction:(NSString *)action Param:(NSDictionary *)param Header:(BOOL)header Foot:(BOOL)foot
{
    self.param = param;
    self.action = action;
    
    //data source
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:footView];
    [self.view addSubview:_tableView];
    
    if (header || foot) {
        [self addHeaderView:header FootView:foot TableView:_tableView];
    }
}

- (void)createCollectionViewLayout:(UICollectionViewLayout *)layout Action:(NSString *)action Param:(NSDictionary *)param Header:(BOOL)header Foot:(BOOL)foot
{
    self.param = param;
    self.action = action;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_collectionView];
    
    if (header || foot) {
        [self addHeaderView:header FootView:foot TableView:_collectionView];
    }
}

#pragma mark - 下拉，上拉刷新
/**
 *	@brief	添加下拉，上拉刷新视图
 *
 *	@param 	header 	yes－添加下拉刷新
 *	@param 	foot 	yes－添加上拉加载
 *	@param 	tableView 	表格视图
 */
- (void)addHeaderView:(BOOL)header FootView:(BOOL)foot TableView:(UIScrollView *)tableView
{
    __weak typeof(self)weakSelf = self;
    if (header) {
        MJRefreshHeaderView *hView = [MJRefreshHeaderView header];
        hView.scrollView = tableView;
        hView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
            [weakSelf startPullRefresh];
        };
        hView.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
            // 刷新完毕就会回调这个Block
            //NSLog(@"刷新完毕");
        };
        _headerRefresh = hView;
    }
    
    if (foot) {
        MJRefreshFooterView *fView = [MJRefreshFooterView footer];
        fView.scrollView = tableView;
        fView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
            [weakSelf startPullRefresh2];
        };
        fView.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
            // 刷新完毕就会回调这个Block
            NSLog(@"刷新完毕");
        };
        _footerRefresh = fView;
    }
}

/**
 *	@brief	开始刷新
 */
- (void)beginRefresh
{
    if (_headerRefresh) {
        [_headerRefresh beginRefreshing];
    }
    else if (_footerRefresh)
    {
        [_footerRefresh beginRefreshing];
    }
}

- (BOOL)isRefreshing
{
    return _headerRefresh.isRefreshing || _footerRefresh.isRefreshing;
}

/**
 *	@brief	结束下拉刷新
 */
- (void)finishRefresh
{
    if (_headerRefresh) {
        [_headerRefresh endRefreshing];
    }
    
    if (_footerRefresh) {
        [_footerRefresh endRefreshing];
    }
}

/**
 *	@brief	重置请求参数，子类覆盖
 */
- (void)resetRequestParam
{
    
}

/**
 *	@brief	开始刷新
 */
- (void)startPullRefresh
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
        return;
    }
    
    //重置请求参数
    [self resetRequestParam];
    
    if (!_action || !_param) {
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
        return;
    }
    
    if (!_headerRefresh && !_footerRefresh) {
        [self.view makeToastActivity];
    }
    __weak __typeof(self)weakSelf = self;
    
    if (_useNewInterface) {
        //针对新接口
        NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:_action];
        self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:_param successBlcok:^(BOOL success, id data, NSString *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestFinish:success Data:data];
            });
        } failedBlock:^(NSString *description) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestFinish:NO Data:nil];
            });
        }];
    }
    else
    {
        //针对老接口
        NSString *url = [URLFACE stringByAppendingString:_action];
        
        self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:_param successBlcok:^(BOOL success, id data, NSString *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestFinish:success Data:data];
            });
        } failedBlock:^(NSString *description) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestFinish:NO Data:nil];
            });
        }];
    }
}

- (void)startPullRefresh2
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
        return;
    }
    
    //重置请求参数
    [self resetRequestParam];
    
    if (!_action || !_param) {
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
        return;
    }
    
    if (!_headerRefresh && !_footerRefresh) {
        [self.view makeToastActivity];
    }
    __weak __typeof(self)weakSelf = self;
    
    if (_useNewInterface) {
        //针对新接口
        NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:_action];
        self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:_param successBlcok:^(BOOL success, id data, NSString *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestFinish2:success Data:data];
            });
        } failedBlock:^(NSString *description) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestFinish2:NO Data:nil];
            });
        }];
    }
    else
    {
        //针对老接口
        NSString *url = [URLFACE stringByAppendingString:_action];
        
        self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:_param successBlcok:^(BOOL success, id data, NSString *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestFinish2:success Data:data];
            });
        } failedBlock:^(NSString *description) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestFinish2:NO Data:nil];
            });
        }];
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
    [self.view hideToastActivity];
    _tableView.userInteractionEnabled = YES;
    self.httpOperation = nil;
    [self finishRefresh];
    
    if (!success) {
        NSString *ret_code = [result valueForKey:@"ret_code"];
        if (ret_code && [ret_code isEqualToString:@"8888"]) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app popToLoginViewController];
        }
        /*
        else
        {
            id ret_msg = [result valueForKey:@"ret_msg"];
            [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
        }
         */
    }
    
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    _tableView.userInteractionEnabled = YES;
    self.httpOperation = nil;
    [self finishRefresh];
    
    if (!success) {
        NSString *ret_code = [result valueForKey:@"ret_code"];
        if (ret_code && [ret_code isEqualToString:@"8888"]) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app popToLoginViewController];
        }
        /*
        else
        {
            NSString *ret_msg = [result valueForKey:@"ret_msg"];
            ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
            [self.view makeToast:ret_msg duration:1.0 position:@"center"];
        }
         */
    }
    
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _browserPhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _browserPhotos.count)
        return [_browserPhotos objectAtIndex:index];
    return nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return nil;
}

@end
