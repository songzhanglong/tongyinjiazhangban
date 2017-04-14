//
//  MyTableViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MyTableBarViewController.h"
#import "MainViewController.h"
#import "MessageViewController.h"
#import "MoreViewController.h"
#import "SchoolYardViewController.h"
#import "MyTableBar.h"

@interface MyTableBarViewController ()<MyTableBarDelegate>

@end

@implementation MyTableBarViewController
{
    MyTableBar *_tabBarView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MainViewController *main = [[MainViewController alloc] init];
    //main.navigationController.navigationBarHidden = YES;
    SchoolYardViewController *schoolYard = [[SchoolYardViewController alloc]init];
    //schoolYard.navigationController.navigationBarHidden = YES;
    MessageViewController *message = [[MessageViewController alloc] init];
    message.hidesBottomBarWhenPushed = YES;
    //message.navigationController.navigationBarHidden = YES;
    MoreViewController *more = [[MoreViewController alloc] init];
    
    UINavigationController *navMain = [[UINavigationController alloc] initWithRootViewController:main];
    navMain.navigationBarHidden = YES;
    UINavigationController *navSch = [[UINavigationController alloc]initWithRootViewController:schoolYard];
    navSch.navigationBarHidden = YES;
    UINavigationController *navMsg = [[UINavigationController alloc] initWithRootViewController:message];
    navMsg.navigationBarHidden = YES;
    UINavigationController *navMore = [[UINavigationController alloc] initWithRootViewController:more];
    
    NSArray *controls = @[navMain,navSch,navMsg,navMore];
    self.viewControllers = controls;

    _tabBarView = [[MyTableBar alloc] initWithFrame:self.tabBar.bounds];
    _tabBarView.delegate = self;
    [self.tabBar addSubview:_tabBarView];
}

#pragma mark - MyTableBarDelegate
- (void)selectTableIndex:(NSInteger)index
{
    self.selectedIndex = index;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    _tabBarView.nSelectedIndex = selectedIndex;
}

/**
 *	@brief	状态栏样式，子类复写
 *
 *	@return	样式类型
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.selectedViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.selectedViewController.prefersStatusBarHidden;
}

- (BOOL)shouldAutorotate
{
    return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.selectedViewController.supportedInterfaceOrientations;
}

@end
