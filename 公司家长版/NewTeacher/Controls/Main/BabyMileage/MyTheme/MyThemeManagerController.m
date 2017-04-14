//
//  MyThemeManagerController.m
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyThemeManagerController.h"
#import "CTAssetsPickerController.h"
#import "Toast+UIView.h"
#import <AVFoundation/AVFoundation.h>
#import "AddActivityViewController.h"
#import "UIImage+FixOrientation.h"
#import "MileageAllEditView.h"
#import "UIImage+Caption.h"
#import "PlayViewController.h"
#import "NSString+Common.h"

@interface MyThemeManagerController ()<MWPhotoBrowserDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,UIAlertViewDelegate,MileageAllEditViewDelegate>

@end

@implementation MyThemeManagerController
{
    UIImageView *navBarHairlineImageView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_LICHENT object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showNewBack = YES;
    
    UIColor *color = CreateColor(0, 0, 180);
    _channelView.lineColor = color;
    _channelView.titleColor = color;
    [_channelView setBackgroundColor:CreateColor(244, 244, 244)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMeileage:) name:REFRESH_LICHENT object:nil];
}

- (void)refreshMeileage:(NSNotification*) notification
{
    NSString *noti = [notification object];
    if ([noti length] > 0) {
        if (_channelView.nCurIdx == 0) {
            [(MyThemeViewController *)self.currentVC startRefreshToCurrController];
        }else {
            MyThemeViewController *controller = self.subControls[0];
            controller.shouldRefresh = YES;
        }
    }
}


- (void)addTheme:(id)sender{
    if (self.httpOperation) {
        return;
    }
    MileageAllEditView *editView = [[MileageAllEditView alloc] initWithFrame:[UIScreen mainScreen].bounds Titles:@[@"相册",@"拍照",@"小视频"] NImageNames:@[@"s15@2x",@"fb1@2x",@"s13@2x"] HImageNames:@[@"s15_1@2x",@"fb1_1@2x",@"s13_1@2x"]];
    editView.delegate = self;
    [editView showInView:self.view.window];
}

#pragma mark - MileageAllEditViewDelegate
- (void)selectEditIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.maximumNumberOfSelection = 9;
            picker.combine = YES;
            picker.assetsFilter = [ALAssetsFilter allAssets];
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:NULL];
            
        }
            break;
        case 2:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
                pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
                NSArray * availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
                pickerView.videoMaximumDuration = 40;
                pickerView.delegate = self;
                pickerView.allowsEditing = YES;
                [self presentViewController:pickerView animated:YES completion:NULL];
            }
        }
            break;
        default:
            break;
    }
}

- (void)backToPreControl:(id)sender
{
    if ([self.currentVC.childViewControllers count] > 0) {
        UIViewController *child = [self.currentVC.childViewControllers lastObject];
        if ([child isKindOfClass:NSClassFromString(@"SystemClass2ViewController")] || [child isKindOfClass:NSClassFromString(@"SystemClassmate2ViewController")]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [child.view removeFromSuperview];
            [child willMoveToParentViewController:nil];
            [child removeFromParentViewController];
            
            [self.currentVC viewDidAppear:NO];
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)findBaby:(id)sender
{
    if ([self.currentVC isKindOfClass:[MyThemeViewController class]]) {
        [(MyThemeViewController *)self.currentVC beginToFindBaby];
    }
}

#pragma mark - 选择右边按钮类型
- (void)changeRightType:(NSInteger)type
{
    switch (type) {
        case 1:
        {
            UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            moreBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
            [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"addMileageN" ofType:@"png"]] forState:UIControlStateNormal];
            [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"addMileageH" ofType:@"png"]] forState:UIControlStateHighlighted];
            [moreBtn addTarget:self action:@selector(addTheme:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            negativeSpacer.width = -10;//这个数值可以根据情况自由变化
            self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
        }
            break;
        case 2:
        {
            UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            moreBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
            [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"refreshTopN" ofType:@"png"]] forState:UIControlStateNormal];
            [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"refreshTopN" ofType:@"png"]] forState:UIControlStateHighlighted];
            [moreBtn addTarget:self action:@selector(findBaby:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            negativeSpacer.width = -10;//这个数值可以根据情况自由变化
            self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
        }
            break;
        default:
        {
            UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
            [rightView setBackgroundColor:[UIColor clearColor]];
            UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            negativeSpacer.width = -10;//这个数值可以根据情况自由变化
            self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
        }
            break;
    }
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = _channelView.backgroundColor;
    }
    else
    {
        navBar.tintColor = _channelView.backgroundColor;
    }
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233, 233, 233);
    }
    
    navBarHairlineImageView.hidden = NO;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL video = (picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModeVideo);
    
    if (video) {
        [picker dismissViewControllerAnimated:NO completion:NULL];
        NSString *videoPath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL]path];
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
        PlayViewController *play = [[PlayViewController alloc] init];
        play.fileUrl = [NSURL fileURLWithPath:videoPath];
        __weak typeof(self)weakSelf = self;
        play.playResult = ^(NSString *path){
            [weakSelf videoCompressedFinish:path];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:play];
        [self.navigationController.tabBarController presentViewController:nav animated:YES completion:NULL];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        image = [image fixOrientation];
        [self uploadImgs:@[image]];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count > 0) {
        id firstItem = [assets firstObject];
        if ([firstItem isKindOfClass:[NSString class]]) {
            [self videoCompressedFinish:(NSString *)firstItem];
        }
        else{
            [self uploadImgs:assets];
        }
    }
}

//把视频写入相册回调函数
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    /*
    if(!error){
        [self.view makeToast:@"视频文件保存成功" duration:1.0 position:@"center"];
    }else{
        [self.view makeToast:@"视频文件保存失败" duration:1.0 position:@"center"];
    }
     */
}

#pragma mark - 页面切换
- (void)videoCompressedFinish:(NSString *)videoPath
{
    AddActivityViewController *add = [[AddActivityViewController alloc] init];
    add.videoPath = videoPath;
    add.dataSource = [NSMutableArray arrayWithObject:videoPath];
    add.fromType = 1;
    add.mileageModel = _indexModel;
    add.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:add animated:YES];
}

#pragma mark - 上传图片
- (void)uploadImgs:(NSArray *)array
{
    AddActivityViewController *add = [[AddActivityViewController alloc] init];
    add.dataSource = [NSMutableArray arrayWithArray:array];
    add.fromType = 1;
    add.mileageModel = _indexModel;
    add.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:add animated:YES];
}

@end
