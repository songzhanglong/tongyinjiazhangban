//
//  PlayViewController.m
//  NewTeacher
//
//  Created by szl on 16/3/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "PlayViewController.h"
#import "UIImage+Caption.h"
#import "ProgressCircleView.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+Common.h"

@interface PlayViewController ()

@property (nonatomic,strong)AVAssetExportSession *assetExportSession;
@property (nonatomic,strong)AVPlayer *player;

@end

@implementation PlayViewController
{
    ProgressCircleView *_progressCircle;
    UIButton *_videoBut;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = CreateColor(33.0, 27.0, 25.0);
    self.titleLable.text = @"视频预览";
    [self.titleLable setTextColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self setupViews];
}

- (void)setupViews
{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backBarButtonItem];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [rightView setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rigBtn = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    UIBarButtonItem *negativeSpacer2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer2.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer2,rigBtn];
    
    //bottom
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.frameWidth, 44)];
    [bottomView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:bottomView];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(bottomView.frameRight - 65 , 11.5, 55, 21)];
    [rightBut setBackgroundColor:rgba(25, 161, 86, 1)];
    [rightBut setTitle:@"下一步" forState:UIControlStateNormal];
    [rightBut.titleLabel setFont:[UIFont systemFontOfSize:12]];
    rightBut.layer.masksToBounds = YES;
    rightBut.layer.cornerRadius = 4;
    [rightBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [rightBut addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rightBut];
    
    //player
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:_fileUrl options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 44 - 64 - 56.5 - 20);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    self.player = player;
    
    UIButton *fullBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullBut setBackgroundColor:[UIColor clearColor]];
    [fullBut setFrame:playerLayer.bounds];
    [self.view addSubview:fullBut];
    [fullBut addTarget:self action:@selector(pauseVideo) forControlEvents:UIControlEventTouchUpInside];
    
    _videoBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [_videoBut setFrame:CGRectMake(0, 0, 30, 30)];
    [_videoBut setCenter:fullBut.center];
    [_videoBut setImage:CREATE_IMG(@"mileageVideo") forState:UIControlStateNormal];
    [_videoBut setHidden:YES];
    [_videoBut addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_videoBut];
    
    //img
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 280) / 2, fullBut.frameBottom + 10, 280, 56.5)];
    [imgView setImage:CREATE_IMG(@"preVideo")];
    [self.view addSubview:imgView];
    
    // Loading indicator
    _progressCircle = [[ProgressCircleView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) / 2, (SCREEN_HEIGHT - 64 - 120) / 2, 120, 120)];
    _progressCircle.hidden = YES;
    [self.view addSubview:_progressCircle];
}

- (void)backButton{
    if (self.assetExportSession) {
        NSString *outFile = self.assetExportSession.outputURL.resourceSpecifier;
        [self.assetExportSession cancelExport];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:outFile]) {
            [fileManager removeItemAtPath:outFile error:nil];
        }
    }
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)nextStep:(id)sender
{
    if (self.assetExportSession) {
        return;
    }
    
    [self.player pause];
    _videoBut.hidden = YES;
    
    [_progressCircle.loadingIndicator setProgress:0];
    [_progressCircle.progressLab setText:@"视频处理中0/100"];
    [_progressCircle setHidden:NO];
    
    self.view.userInteractionEnabled = NO;
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *mp4Path = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"output-%@.mp4", [formater stringFromDate:[NSDate date]]]];
    __weak typeof(self)weakSelf = self;
    self.assetExportSession = [UIImage converVideoDimissionWithFilePath:self.fileUrl andOutputPath:mp4Path withCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf compressVideoFinish:mp4Path Error:error];
        });
    } To:self Sel:@selector(compressProgressRefresh)];
}

- (void)playVideo{
    
    [self.player play];
    [_videoBut setHidden:YES];
}

- (void)pauseVideo{
    
    [self.player pause];
    [_videoBut setHidden:NO];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor blackColor];
    }
    else
    {
        navBar.tintColor = [UIColor blackColor];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.player play];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)compressProgressRefresh{
    if (!self.assetExportSession) {
        return;
    }
    
    [_progressCircle.loadingIndicator setProgress:self.assetExportSession.progress];
    [_progressCircle.progressLab setText:[NSString stringWithFormat:@"视频处理中%.0f/100",self.assetExportSession.progress * 100]];
}

#pragma mark - 压缩视频
- (void)compressVideoFinish:(NSString *)file Error:(NSError *)error
{
    self.assetExportSession = nil;
    self.view.userInteractionEnabled = YES;
    [_progressCircle setHidden:YES];
    if (!error) {
        self.myPath = file;
        if (self.playResult) {
            self.playResult(self.myPath);
        }
        if (self.navigationController.presentingViewController) {
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }
    else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error.description message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:file]) {
            [fileManager removeItemAtPath:file error:nil];
        }
    }
}

@end
