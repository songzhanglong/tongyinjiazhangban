//
//  SaveOrShareViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/4/1.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SaveOrShareViewController.h"
#import "UMSocial.h"
#import "PlayMileageListController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "CreatePlayMileageViewController.h"
#import "UIImage+Caption.h"

@interface SaveOrShareViewController ()<UMSocialUIDelegate>
{
    UIImage *_shareImage;
}
@end
@implementation SaveOrShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.showBack = YES;
    self.titleLable.text = @"保存/分享";
    self.view.backgroundColor = CreateColor(217, 217, 217);
    
    [self createLeftBut];
    UIView *_headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 115)];
    [_headView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_headView];
    
    UIImageView *_saveImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"mileage_save")];
    [_saveImgView setFrame:CGRectMake((_headView.frameWidth - 50) / 2, (_headView.frameHeight - 50 -20) / 2, 50, 50)];
    [_headView addSubview:_saveImgView];
    
    UILabel *_saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(_saveImgView.frame.origin.x, _saveImgView.frameBottom, 50, 20)];
    [_saveLabel setBackgroundColor:[UIColor clearColor]];
    [_saveLabel setTextColor:[UIColor darkGrayColor]];
    [_saveLabel setText:@"已保存"];
    [_saveLabel setFont:[UIFont systemFontOfSize:14]];
    [_saveLabel setTextAlignment:NSTextAlignmentCenter];
    [_headView addSubview:_saveLabel];
    
    UIView *_midView = [[UIView alloc] initWithFrame:CGRectMake(0, _headView.frameBottom + 10, SCREEN_WIDTH, 100)];
    [_midView setBackgroundColor:[UIColor whiteColor]];
    [_midView setUserInteractionEnabled:YES];
    [self.view addSubview:_midView];

    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake((SCREEN_WIDTH - 84) / 3 + ((SCREEN_WIDTH - 84) / 3 + 42) * i , 20, 42, 42)];
        [button setImage:CREATE_IMG((i == 0) ? @"mileage_make" : @"mileage_home") forState:UIControlStateNormal];
        [button setTag:i + 1];
        [button addTarget:self action:@selector(buttonPressad:) forControlEvents:UIControlEventTouchUpInside];
        [_midView addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x - 10, button.frameBottom, 62, 20)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setText:(i == 0) ? @"继续制作" : @"返回首页"];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [_midView addSubview:label];
    }
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, _midView.frameBottom + 15, SCREEN_WIDTH - 50, 30)];
    [tipLabel setBackgroundColor:[UIColor clearColor]];
    [tipLabel setTextColor:[UIColor darkGrayColor]];
    [tipLabel setText:@"分享至："];
    [tipLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:tipLabel];
    
    NSMutableArray *shareName = [NSMutableArray array];
    NSMutableArray *tags = [NSMutableArray array];
    NSMutableArray *shareImage = [NSMutableArray array];
    if ([WXApi isWXAppInstalled]) {
        [shareName addObjectsFromArray:@[@"微信好友",@"微信朋友圈"]];
        [shareImage addObjectsFromArray:@[@"share1",@"share2"]];
        [tags addObjectsFromArray:@[@"1",@"2"]];
    }
    if ([QQApiInterface isQQInstalled]) {
        [shareName addObject:@"手机QQ"];
        [shareImage addObject:@"share4"];
        [tags addObject:@"3"];
    }
    if ([WeiboSDK isWeiboAppInstalled]) {
        [shareName addObject:@"新浪微博"];
        [shareImage addObject:@"share5"];
        [tags addObject:@"4"];
    }
    
    for (int i = 0; i < [shareImage count]; i++) {
        UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 50 * 4) / 5 + ((SCREEN_WIDTH - 50 * 4) / 5 + 50) * i, tipLabel.frameBottom + 15, 50, 50)];
        [shareBtn setImage:CREATE_IMG(shareImage[i]) forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(sharePressad:) forControlEvents:UIControlEventTouchUpInside];
        [shareBtn setTag:[tags[i] integerValue]];
        [self.view addSubview:shareBtn];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(shareBtn.frame.origin.x - 5, shareBtn.frameBottom, 60, 20)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setText:shareName[i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:12]];
        [self.view addSubview:label];
    }
    
    [self downloadImage];
}

- (void)downloadImage
{
    NSString *imgUrl = _albumItem.thumb;
    if (![imgUrl hasPrefix:@"http"]) {
        imgUrl = [[G_IMAGE_ADDRESS stringByAppendingString:imgUrl ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if ([imgUrl hasSuffix:@"mp4"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:imgUrl] atTime:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                _shareImage = image;
            });
        });
    }
    else{
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        @try {
            [manager downloadWithURL:[NSURL URLWithString:imgUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _shareImage = image;
                });
            }];
        } @catch (NSException *e) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString *tip = @"童印家长版";
    [UMSocialData defaultData].extConfig.qzoneData.title = tip;
    [UMSocialData defaultData].extConfig.qqData.title = tip;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = tip;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = tip;
}

- (void)createLeftBut
{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_1.png"] forState:UIControlStateSelected];
    [backBtn addTarget:self action:@selector(backToFather:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backBarButtonItem];
    
}

- (void)backToFather:(id)sender
{
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[CreatePlayMileageViewController class]]) {
            CreatePlayMileageViewController *createController = (CreatePlayMileageViewController *)controller;
            createController.theme_id = _theme_id;
            createController.album_id = _album_id;
            createController.createType = 3;
            [self.navigationController popToViewController:createController animated:YES];
        }
    }
}

- (void)buttonPressad:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch ([btn tag] - 1) {
        case 0:
        {
            for (id controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[PlayMileageListController class]]) {
                    [(PlayMileageListController *)controller isRefresh];
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
        }
            break;
        case 1:
        {
            NSArray *controllers = self.navigationController.viewControllers;
            [self.navigationController popToViewController:controllers[1] animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - ShareViewDelegate
- (void)sharePressad:(id)sender
{
    NSString *shareType = nil;
    UIButton *btn = (UIButton *)sender;
    switch ([btn tag] - 1) {
        case 0:
        {
            [UMSocialData defaultData].extConfig.wechatSessionData.title = @"童印里程分享";
            [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
            [UMSocialData defaultData].extConfig.wechatSessionData.url = _shareUrl ?: @"";
            shareType = UMShareToWechatSession;
        }
            break;
        case 1:
        {
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"童印里程分享";
            [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = _shareUrl ?: @"";
            shareType = UMShareToWechatTimeline;
        }
            break;
        case 2:
        {
            [UMSocialData defaultData].extConfig.qqData.title = @"童印里程分享";
            [UMSocialData defaultData].extConfig.qqData.url = _shareUrl ?: @"";
            [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
            shareType = UMShareToQQ;
        }
            break;
        case 3:
        {
            [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeMusic url:_shareUrl ?: @""];
            shareType = UMShareToSina;
        }
            break;
        default:
            break;
    }
    
    NSString *lastStr = [NSString stringWithFormat:@"我制作了“%@”，快来看看！",_shareName];
    [[UMSocialControllerService defaultControllerService] setShareText:lastStr shareImage:_shareImage ?: CREATE_IMG(@"icon") socialUIDelegate:self];        //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:shareType].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
}

#pragma mark - UMSocialUIDelegate
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess) {
        NSLog(@"分享成功！");
    }
}

@end
