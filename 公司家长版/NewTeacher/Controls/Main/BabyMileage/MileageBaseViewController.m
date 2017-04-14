//
//  MileageBaseViewController.m
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageBaseViewController.h"

@interface MileageBaseViewController ()

@end

@implementation MileageBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (id)initWithControls:(NSArray *)subControls Titles:(NSArray *)titles Frame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.subControls = subControls;
        
        SelectChannelView *channelView = [[SelectChannelView alloc] initWithFrame:frame TitleArray:titles Line:YES];
        _channelView = channelView;
        __weak typeof(self)weakSelf = self;
        channelView.selectBlock = ^(NSInteger index){
            [weakSelf changeControlToIndex:index];
        };
        [self.view addSubview:channelView];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.currentVC) {
        _channelView.nCurIdx = _initIdx;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.currentVC) {
        self.currentVC = self.subControls[_initIdx];
        [self addChildViewController:self.currentVC];
        [self.view addSubview:self.currentVC.view];
    }
}

- (void)changeControlToIndex:(NSInteger)index{
    [self replaceController:_currentVC newController:self.subControls[index]];
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    /**
     *			着重介绍一下它
     *  transitionFromViewController:toViewController:duration:options:animations:completion:
     *  fromViewController      当前显示在父视图控制器中的子视图控制器
     *  toViewController		将要显示的姿势图控制器
     *  duration				动画时间(这个属性,old friend 了 O(∩_∩)O)
     *  options                 动画效果(渐变,从下往上等等,具体查看API)
     *  animations              转换过程中得动画
     *  completion              转换完成
     */
    
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentVC = newController;
        }
    }];
}

@end
