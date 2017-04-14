//
//  DJTWebViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/5/20.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTWebViewController.h"
#import "DJTShareView.h"
#import "UMSocial.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"

@interface DJTWebViewController ()<UIWebViewDelegate,DJTShareViewDelegate,UMSocialUIDelegate>

@end

@implementation DJTWebViewController
{
    UIWebView *_webView;
    BOOL _hasLoaded;
    NSString *title_type,*title_content,*title_website;
    MJRefreshHeaderView *_headerRefresh;
}

- (void)dealloc
{
    [_headerRefresh free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLable.textColor = [UIColor whiteColor];
    [self createLeftBut];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView = webView;
    [webView setBackgroundColor:[UIColor whiteColor]];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _webView.delegate = self;
    //_webView.scrollView.bounces = NO;
    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    [_webView setScalesPageToFit:YES];
    [self.view addSubview:webView];
    
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
    if (![_webView isLoading]) {
        [_webView reload];
    }
    else
    {
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
    }
}

- (void)createLeftBut
{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToFather:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)createLeftButs
{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToFather:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(40, 0, 30.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"closedWeb" ofType:@"png"]] forState:UIControlStateNormal];
    [saveBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"closedWeb_1" ofType:@"png"]] forState:UIControlStateHighlighted];
    [saveBtn addTarget:self action:@selector(backToFather2:) forControlEvents:UIControlEventTouchUpInside];

    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [backView setBackgroundColor:[UIColor clearColor]];
    [backView addSubview:backBtn];
    [backView addSubview:saveBtn];
    UIBarButtonItem *barButItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,barButItem];
}

- (void)createRightButton
{
    NSInteger type = [title_type integerValue];
    UIView *leftView = ((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    if (type == 1) {
        CGFloat yOri = leftView.bounds.size.width - 30;
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftView.bounds.size.width, 30)];
        [rightView setBackgroundColor:[UIColor clearColor]];
        
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame = CGRectMake(yOri, 0, 30.0, 30.0);
        [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"qw_1" ofType:@"png"]] forState:UIControlStateHighlighted];
        [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"qw" ofType:@"png"]] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(popMoreItems:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:moreBtn];
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBtn];
    }
    else if (type == 2)
    {
        //链接
        UIButton *linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat lastWei = MIN([title_content length] * 20, 75);
        linkBtn.frame = CGRectMake(0, 0, lastWei, 20.0);
        [linkBtn setTitle:title_content forState:UIControlStateNormal];
        [linkBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [linkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [linkBtn setBackgroundColor:[UIColor clearColor]];
        [linkBtn addTarget:self action:@selector(loadNewWebSite:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:linkBtn];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
    }
    else
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftView.bounds.size.width, 20)];
        [view setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:view];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBtn];
    }
}

- (void)backToFather:(UIButton *)sender{
    if (_webView.canGoBack) {
        [_webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backToFather2:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popMoreItems:(id)sender
{
    if (![DJTShareView isCanShareToOtherPlatform]) {
        [self.view.window makeToast:SHARE_TIP_INFO duration:1.0 position:@"center"];
        return;
    }
    
    DJTShareView *shareView = [[DJTShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [shareView setDelegate:self];
    [shareView showInView:self.view.window];
}

- (void)loadNewWebSite:(id)sender
{
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:title_website ?: @""]]];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor blackColor];
    }
    else
    {
        navBar.tintColor = [UIColor blackColor];
    }
    
    if (!_hasLoaded) {
        _hasLoaded = YES;
        
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        NSString *str = [NSString stringWithFormat:@"http://wap.goonbaby.com/album_share/a%@_b%@_f1_t%@.htm?apptype=1",manager.userInfo.album_id,_baby_id ?: manager.userInfo.userid,_phone];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_webView.isLoading) {
        [_webView stopLoading];
    }
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = [UIColor whiteColor];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
    self.titleLable.text = @"加载中...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    
    [_headerRefresh endRefreshing];
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    
    NSString *theTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.titleLable.text = theTitle;
    
    title_type = [webView stringByEvaluatingJavaScriptFromString:@"title_type"];
    title_content = [webView stringByEvaluatingJavaScriptFromString:@"title_content"];
    title_website = [webView stringByEvaluatingJavaScriptFromString:@"title_website"];
    
    UIBarButtonItem *barBut = [self.navigationItem.leftBarButtonItems lastObject];
    UIView *customView = barBut.customView;
    if ([customView isKindOfClass:[UIButton class]]) {
        if (_webView.canGoBack) {
            [self createLeftButs];
        }
    }
    else
    {
        if (!_webView.canGoBack) {
            [self createLeftBut];
        }
    }
    [self createRightButton];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [_headerRefresh endRefreshing];
    self.titleLable.text = @"加载失败";
}

#pragma mark - DJTShareViewDelegate
- (void)shareViewTo:(NSInteger)index
{
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            NSString *str = _webView.request.URL.absoluteString;
            NSString *shareType = nil;
            if (index == 0) {
                [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
                [UMSocialData defaultData].extConfig.wechatSessionData.url = str;
                shareType = UMShareToWechatSession;
            }
            else if (index == 1)
            {
                [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = str;
                shareType = UMShareToWechatTimeline;
            }
            else if (index == 2)
            {
                [UMSocialData defaultData].extConfig.qqData.url = str;
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
                shareType = UMShareToQQ;
            }
            else
            {
                [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeMusic url:str];
                shareType = UMShareToSina;
            }
            
            NSString *lastStr = str;
            [[UMSocialControllerService defaultControllerService] setShareText:lastStr shareImage:nil socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:shareType].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        }
            break;
        case 4:
        {
            [[UIApplication sharedApplication] openURL:_webView.request.URL];
        }
            break;
        case 5:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = _webView.request.URL.absoluteString;
        }
            break;
        case 6:
        {
            [_webView reload];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UMSocialUIDelegate
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess) {
        NSLog(@"分享成功！");
    }
}

@end
