//
//  MessageViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MessageViewController.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"
#import "Toast+UIView.h"
#import "DJTOrderViewController.h"
#import "MyTableBarViewController.h"
#import "MyTableBar.h"
#import "MJRefresh.h"

@interface MessageViewController ()<UIWebViewDelegate,UIScrollViewDelegate,MyTableBarDelegate>

@end

@implementation MessageViewController
{
    UIWebView *_webView;
    BOOL _isReload;
    CGFloat _curPointY,_initYori;
    MyTableBar *_tableBar;
    MJRefreshHeaderView *_headerRefresh;
}

- (void)dealloc
{
    [_headerRefresh free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self createWebView];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://d.goonbaby.com/member"]];
    NSString *param = [NSString stringWithFormat:@"userid=%@&is_teacher=0&from=2&datafrom=1&mid=%@",[DJTGlobalManager shareInstance].userInfo.userid,[DJTGlobalManager shareInstance].userInfo.mid ?: @""];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    [_webView loadRequest:request];
    
    MyTableBar *tabar = [[MyTableBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.tabBarController.tabBar.bounds.size.height, self.view.frame.size.width, self.tabBarController.tabBar.bounds.size.height)];
    _tableBar = tabar;
    [tabar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    tabar.delegate = self;
    [self.view addSubview:tabar];
}

- (void)createWebView
{
    CGFloat yOri = 20;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, yOri, winSize.width, winSize.height - 20)];
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
    //_webView.scrollView.bounces = NO;
    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    //[_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    [_webView setScalesPageToFit:YES];
    [self.view addSubview:_webView];
    
    __weak typeof(self)weakSelf = self;
    MJRefreshHeaderView *hView = [MJRefreshHeaderView header];
    hView.scrollView = _webView.scrollView;
    hView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
        [weakSelf reloadCurentPage];
    };
    hView.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
    };
    _headerRefresh = hView;
}

- (void)reloadCurentPage
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        return;
    }
    
    if (![_webView isLoading]) {
        [_webView reload];
    }
    else
    {
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden  = YES;
    
    _tableBar.nSelectedIndex = 2;
}

- (void)controlTableHidden:(BOOL)hidden
{
    CGFloat barHei = self.navigationController.tabBarController.tabBar.bounds.size.height;
    CGFloat lastYori = hidden ? (self.view.frame.size.height + 10) : (self.view.frame.size.height - barHei);
    CGRect frame = _tableBar.frame;
    if (frame.origin.y == lastYori) {
        return;
    }
    
    frame.origin.y = lastYori;
    CGFloat distance = fabs(lastYori - frame.origin.y);
    CGFloat lastTimer = (distance * 0.35) / (barHei + 10);
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:lastTimer animations:^{
        [_tableBar setFrame:frame];
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
    }];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        
        DJTOrderViewController *adDetail = [[DJTOrderViewController alloc] init];
        adDetail.url = request.URL.absoluteString;
        adDetail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:adDetail animated:YES];
        return NO;
        
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    
    [_headerRefresh endRefreshing];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [_headerRefresh endRefreshing];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isReload) {
        return;
    }
    
    CGFloat barHei = self.navigationController.tabBarController.tabBar.bounds.size.height;
    CGRect frame = _tableBar.frame;
    
    CGFloat yOri = _initYori + (scrollView.contentOffset.y - _curPointY);
    yOri = MAX(yOri, self.view.frame.size.height - barHei);
    yOri = MIN(yOri, self.view.frame.size.height + 10);
    frame.origin.y = yOri;
    [_tableBar setFrame:frame];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    _curPointY = scrollView.contentOffset.y;
    _initYori = _tableBar.frame.origin.y;
    _isReload = _webView.isLoading;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_isReload) {
        return;
    }
    if (_curPointY < scrollView.contentOffset.y) {
        [self controlTableHidden:YES];
    }
    else if (_curPointY > scrollView.contentOffset.y)
    {
        [self controlTableHidden:NO];
    }
    _curPointY = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _curPointY = scrollView.contentOffset.y;
    _initYori = _tableBar.frame.origin.y;
    _isReload = _webView.isLoading;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_isReload) {
        return;
    }
    if (_curPointY < scrollView.contentOffset.y) {
        [self controlTableHidden:YES];
    }
    else if (_curPointY > scrollView.contentOffset.y)
    {
        [self controlTableHidden:NO];
    }
    _curPointY = scrollView.contentOffset.y;
}

#pragma mark - MyTableBarDelegate
- (void)selectTableIndex:(NSInteger)index
{
    MyTableBarViewController *tableBar = (MyTableBarViewController *)self.navigationController.tabBarController;
    if ([tableBar conformsToProtocol:@protocol(MyTableBarDelegate)]) {
        [(id<MyTableBarDelegate>)tableBar selectTableIndex:index];
    }
}

@end
