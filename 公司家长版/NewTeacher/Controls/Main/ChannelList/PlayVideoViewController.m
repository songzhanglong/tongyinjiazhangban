//
//  PlayVideoViewController.m
//  NewTeacher
//
//  Created by szl on 16/4/19.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "MyOpenGLView.h"
#import "MyAudioPlayer.h"
#import "PlayerApi.h"
#import "ChannelListView.h"
#import "Toast+UIView.h"
#import "ChannelModel.h"
#import "NSString+Common.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ChannelListViewController.h"

@interface PlayVideoViewController ()<ChannelListDelegate,UIAlertViewDelegate>

@property (nonatomic) MyOpenGLView *glView;

@end

@implementation PlayVideoViewController
{
    //在viewwillappear、viewwillDisappear中判断若是改变云台速度引起的不stopanimation
    BOOL bToAnimate,mIsPlayVoice;
    ChannelListView *_listView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    bToAnimate = YES;
    mIsPlayVoice = NO;
    
    UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    listBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    [listBtn setImage:CREATE_IMG(@"yssy4") forState:UIControlStateNormal];
    [listBtn setImage:CREATE_IMG(@"yssy4_1") forState:UIControlStateHighlighted];
    [listBtn addTarget:self action:@selector(expandListView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:listBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    screenBounds.size.width = screenBounds.size.height;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [imageView setImage:CREATE_IMG(@"yssy5")];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    
    self.glView = [[MyOpenGLView alloc] initWithFrame:screenBounds];
    [_glView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_glView];
    _glView._landscape = NO;
    
    //处理名称列表
    
    NSArray *controllers = self.navigationController.viewControllers;
    ChannelListViewController *channelList = (ChannelListViewController *)[controllers objectAtIndex:controllers.count - 2];
    @weakify(self);
    [RACObserve(channelList, dataSource) subscribeNext:^(NSArray *x) {
        @strongify(self);
        [self dealWithNameList:x];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startPlayVideo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(exitPlayVideo) object:nil];
    
    [self stopPlayVideo];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - action
- (void)expandListView:(id)sender{
    if (_listView && [_listView isDescendantOfView:self.view]) {
        [_listView hiddenInView];
        _listView = nil;
        return;
    }
    if (!_listView) {
        CGFloat maxHei = MIN(SCREEN_HEIGHT - 64, _nameList.count * 44 + 1);
        _listView = [[ChannelListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) TabHei:maxHei - 1];
        _listView.delegate = self;
        NSMutableArray *array = [NSMutableArray array];
        for (ChannelModel *model in _nameList) {
            [array addObject:model.name];
        }
        _listView.dataSource = array;
    }
    _listView.curIdx = _selectIdx;
    [self.view addSubview:_listView];
    [_listView showInView];
}

#pragma mark - Private Methods
- (BOOL)checkIsOpen:(ChannelModel *)model
{
    int status = model.nodeIdx;
    if (status == 0x1000 || status == 0x1001 || status == 0x1002)
    {
        return NO;
    }
    
    if (model.is_valid.integerValue == 1) {
        if (model.open_time.length > 0) {
            NSArray *array = [model.open_time componentsSeparatedByString:@","];
            NSString *curDate = [NSString stringByDate:@"HH:mm" Date:[NSDate date]];
            for (NSString *str in array) {
                NSArray *tmpArr = [str componentsSeparatedByString:@"-"];
                if (tmpArr.count == 2) {
                    if (([curDate compare:tmpArr[0]] != NSOrderedAscending) && ([curDate compare:tmpArr[1]] == NSOrderedAscending)) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)dealWithNameList:(NSArray *)models
{
    if (_listView && [_listView isDescendantOfView:self.view]) {
        [_listView hiddenInView];
        _listView = nil;
    }
    
    _selectIdx = NSNotFound;
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i = 0;i < models.count;i++){
        ChannelModel *model = models[i];
        if (_iNodeIndex == model.nodeIdx) {
            self.selectIdx = array.count;
        }
        BOOL isOpen = [self checkIsOpen:model];
        if (isOpen) {
            [array addObject:model];
        }
    }
    self.nameList = array;
    
    if (_selectIdx == NSNotFound) {
        //退出
        [self exitPlayVideo];
    }
    else{
        ChannelModel *curModel = _nameList[_selectIdx];
        if (curModel.is_valid.integerValue == 0) {
            //退出
            [self exitPlayVideo];
        }
        else{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(exitPlayVideo) object:nil];
            
            NSArray *array = [curModel.open_time componentsSeparatedByString:@","];
            NSString *curDate = [NSString stringByDate:@"HH:mm" Date:[NSDate date]];
            for (NSString *str in array) {
                NSArray *tmpArr = [str componentsSeparatedByString:@"-"];
                if (tmpArr.count == 2) {
                    if (([curDate compare:tmpArr[0]] != NSOrderedAscending) && ([curDate compare:tmpArr[1]] != NSOrderedDescending)) {
                        NSTimeInterval timeInterval = [self compareTwoStr:curDate Other:tmpArr[1]]; //时间是分钟
                        if (timeInterval < 5) {
                            [self performSelector:@selector(exitPlayVideo) withObject:nil afterDelay:timeInterval * 60];
                        }
                        break;
                    }
                }
            }
        }
    }
}
    
- (NSTimeInterval)compareTwoStr:(NSString *)curDate Other:(NSString *)other
{
    NSArray *curArr = [curDate componentsSeparatedByString:@":"];
    NSArray *otherArr = [other componentsSeparatedByString:@":"];
    NSTimeInterval hour = [[otherArr firstObject] doubleValue] - [[curArr firstObject] doubleValue];
    NSTimeInterval minut = [[otherArr lastObject] doubleValue] - [[curArr lastObject] doubleValue];
    
    return hour * 60 + minut;
}

- (void)exitPlayVideo
{
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"本次播放已结束" delegate:self cancelButtonTitle:@"返回" otherButtonTitles: nil] show];
    
    [self stopPlayVideo];
}

#pragma mark - Video
- (void)stopPlayVideo
{
    if (_glView.isAnimating) {
        [_glView stopAnimation];
    }
}

- (void)startPlayVideo
{
    _iViindex = 0;
    int ret = API_StartPlay(_iNodeIndex, _iViindex);
    if (0 == ret)
    {
        [_glView startAnimation];
        
        //定时器
        ChannelModel *curModel = _nameList[_selectIdx];
        NSArray *array = [curModel.open_time componentsSeparatedByString:@","];
        NSString *curDate = [NSString stringByDate:@"HH:mm" Date:[NSDate date]];
        for (NSString *str in array) {
            NSArray *tmpArr = [str componentsSeparatedByString:@"-"];
            if (tmpArr.count == 2) {
                if (([curDate compare:tmpArr[0]] != NSOrderedAscending) && ([curDate compare:tmpArr[1]] != NSOrderedDescending)) {
                    NSTimeInterval timeInterval = [self compareTwoStr:curDate Other:tmpArr[1]]; //时间是分钟
                    if (timeInterval < 5) {
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(exitPlayVideo) object:nil];
                        [self performSelector:@selector(exitPlayVideo) withObject:nil afterDelay:timeInterval * 60];
                    }
                    break;
                }
            }
        }
    }
    else
    {
        API_StopPlay(_iViindex);
        [self.view makeToast:@"暂时无法打开摄像头,请稍候再试" duration:1.0 position:@"center"];
    }
}

#pragma mark - device control
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait
       ||toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        self.navigationController.navigationBarHidden = NO;
        _glView._landscape = NO;
    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
        _glView._landscape = YES;
        if (_listView && [_listView isDescendantOfView:self.view]) {
            [_listView hiddenInView];
        }
    }
}

#pragma mark - ChannelListDelegate
- (void)channelViewSelectAt:(NSInteger)index
{
    [self stopPlayVideo];
    
    _selectIdx = index;
    ChannelModel *model = self.nameList[index];
    _iNodeIndex = model.nodeIdx;
    self.titleLable.text = model.name;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(exitPlayVideo) object:nil];
    if (![self checkIsOpen:model]) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"本次播放已结束" delegate:self cancelButtonTitle:@"返回" otherButtonTitles: nil] show];
        return;
    }
    
    [self startPlayVideo];
}

@end
