//
//  DJTBaseViewController.m
//  MZJD
//
//  Created by mac on 14-4-14.
//  Copyright (c) 2014年 DIGIT. All rights reserved.
//

#import "DJTBaseViewController.h"

@interface DJTBaseViewController ()

@end

@implementation DJTBaseViewController

@synthesize showBack = _showBack;


- (void)dealloc
{
    if (_httpOperation && (![_httpOperation isCancelled] && ![_httpOperation isFinished])) {
        [_httpOperation cancel];
        NSLog(@"[_httpOperation cancel];");
    }
    self.httpOperation = nil;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    //避免push时会看似停顿
    //self.view.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
}

/**
 *	@brief	back按钮
 *
 *	@param 	showBack 	是否显示
 */
- (void)setShowBack:(BOOL)showBack
{
    if (showBack) {
        //返回按钮
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
        backBtn.backgroundColor = [UIColor clearColor];
        [backBtn setImage:CREATE_IMG(@"back@2x") forState:UIControlStateNormal];
        [backBtn setImage:CREATE_IMG(@"back_1@2x") forState:UIControlStateSelected];
        [backBtn addTarget:self action:@selector(backToPreControl:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, backBarButtonItem];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [rightView setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *rigBtn = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        UIBarButtonItem *negativeSpacer2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer2.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer2,rigBtn];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setShowNewBack:(BOOL)showNewBack
{
    if (showNewBack) {
        //返回按钮
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
        backBtn.backgroundColor = [UIColor clearColor];
        [backBtn setImage:CREATE_IMG(@"back@2x") forState:UIControlStateNormal];
        [backBtn setImage:CREATE_IMG(@"back_1@2x") forState:UIControlStateSelected];
        [backBtn addTarget:self action:@selector(backToPreControl:) forControlEvents:UIControlEventTouchUpInside];
        UIView *backView = [[UIView alloc] initWithFrame:backBtn.bounds];
        [backView addSubview:backBtn];
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, backBarButtonItem];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [rightView setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *rigBtn = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        UIBarButtonItem *negativeSpacer2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer2.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer2,rigBtn];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

/**
 *	@brief	空按钮，保证标题居中
 *
 *	@param 	showClearRightBut 	是否显示
 */
- (void)setShowClearRightBut:(BOOL)showClearRightBut
{
    if (showClearRightBut) {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
        [rightView setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

/**
 *	@brief	返回事件，子类可复写
 *
 *	@param 	sender 	按钮
 */
- (void)backToPreControl:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *	@brief	状态栏样式，子类复写
 *
 *	@return	样式类型
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        
        CGRect leftViewbounds = ((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView.bounds;
        CGRect rightViewbounds = ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.bounds;
        CGFloat maxWidth = leftViewbounds.size.width > rightViewbounds.size.width ? leftViewbounds.size.width : rightViewbounds.size.width;
        maxWidth += 15;//leftview 左右都有间隙，左边是5像素，右边是8像素，加2个像素的阀值 5 ＋ 8 ＋ 2
        
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - maxWidth * 2, 24)];
        [_titleLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0]];
        [_titleLable setTextAlignment:1];
        [_titleLable setTextColor:[UIColor blackColor]];
        [_titleLable setBackgroundColor:[UIColor clearColor]];
        self.navigationItem.titleView = _titleLable;
    }
    
    return _titleLable;
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
