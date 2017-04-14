//
//  AppDelegate.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MyTableBarViewController.h"
#import "YQSlideMenuController.h"
#import "LeftViewController.h"
#import "DJTGlobalDefineKit.h"
#import "MobClick.h"
#import <sys/xattr.h>
#import "MyMsgViewController.h"
#import "UMSocial.h"
#import "UMSocialSinaSSOHandler.h"          //新浪SSO登录
#import "UMSocialWechatHandler.h"           //微信SSO免登录
#import "UMSocialQQHandler.h"               //QQ空间和QQ SSO面认证
#import "CommonUtil.h"
#import "Toast+UIView.h"
#import "DataBaseOperation.h"
#import "NSString+Common.h"
#import "ChildrenListView.h"
#import "DJTHttpClient.h"
#import "UploadManager.h"
#import <JSPatch/JPEngine.h>
#import "NSString+Common.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "SchoolYardViewController.h"

#define BUGLY_APP_ID @"900027388"
@interface AppDelegate ()<UIAlertViewDelegate>

@property (nonatomic,retain)AFHTTPRequestOperation *httpOperation;

@end

@implementation AppDelegate
{
    dispatch_queue_t    _quitQueue;
    NSDictionary  *_updataDic;
}

#pragma mark - 防止文件备份到iCloud和iTunes
/**
 *	防止文件备份到iCloud和iTunes
 *
 *	@param 	aFilePath 	文件路径
 *
 *	@return	bool变量
 */
- (BOOL)addSkipBackupAttributeToFileAtPath:(NSString *)aFilePath
{
    assert([[NSFileManager defaultManager] fileExistsAtPath:aFilePath]);
    
    NSError *error = nil;
    BOOL success = NO;
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] >= 5.1f)
    {
        success = [[NSURL fileURLWithPath:aFilePath] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    }
    else if ([systemVersion isEqualToString:@"5.0.1"])
    {
        const char* filePath = [aFilePath fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        success = (result == 0);
    }
    else
    {
        //NSLog(@"Can not add 'do no back up' attribute at systems before 5.0.1");
    }
    
    if(!success)
    {
        //NSLog(@"Error excluding %@ from backup %@", [aFilePath lastPathComponent], error);
    }
    
    return success;
}

#pragma mark - 友盟配置
- (void)umengTrack {
    [MobClick setAppVersion:XcodeAppVersion];
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    [MobClick  setCrashReportEnabled:NO];
    [MobClick setLogEnabled:NO];
    [MobClick updateOnlineConfig];  //在线参数配置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}

- (void)configUMShare{
    //设置友盟社会化组件APPKEY
    [UMSocialData setAppKey:UMENG_APPKEY];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType =UMSocialQQMessageTypeImage;
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeImage;
    
    //打开调开关
    //[UMSocialData openLog:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wx834553fb43cfb017" appSecret:@"4da3d761efd4e607981dbdbddd24d6e8" url:@"http://www.goonbaby.com"];
    
    //打开新浪微博的SSO开关
    //[UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://www.goonbaby.com"];
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"1678027945"
                                              secret:@"383b917f3a2e76920a29e8d6665a9629"
                                         RedirectURL:@"http://www.goonbaby.com"];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"1104505900" appKey:@"jGaZuytOS1gmDNsr" url:@"http://www.goonbaby.com"];
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    NSString *tip = @"童印家长版";
    [UMSocialData defaultData].extConfig.qzoneData.title = tip;
    [UMSocialData defaultData].extConfig.qqData.title = tip;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = tip;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = tip;
}

#pragma mark - push 切换
/**
 *	@brief	退出到登录
 */
- (void)popToLoginViewController
{
    //停止数据上传
    [self stopUpload];
    //移除上传队列
    [[UploadManager shareInstance].upModels removeAllObjects];
    [[UploadManager shareInstance] setNetWorking:NO];
    //pop
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    
    [self.window.layer addAnimation:transition forKey:nil];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"" forKey:LOGIN_PASSWORD];
    [userDefault setBool:YES forKey:LOGIN_REMBER];
    [userDefault synchronize];
    
    LoginViewController *login = [[LoginViewController alloc] init];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
    [self.window setRootViewController:loginNav];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    [manager setChildrens:nil];
    [manager setUserInfo:nil];
    [manager setHomeCardArr:nil];
    [manager setWeekList:nil];
    [manager setWeekIdx:0];
    [manager closeWebSocket];
}

/**
 *	@brief	鉴权失败，退出登录
 */
- (void)failToLgoin
{
    __weak typeof(self)weakSelf = self;
    dispatch_sync(_quitQueue, ^{
        if ([weakSelf.window.rootViewController isKindOfClass:[YQSlideMenuController class]]) {
            [weakSelf popToLoginViewController];
            [weakSelf.window makeToast:@"账号鉴权失败" duration:1.0 position:@"center"];
        }
        else if ([weakSelf.window.rootViewController isKindOfClass:[UINavigationController class]])
        {
            [(UINavigationController *)weakSelf.window.rootViewController popToRootViewControllerAnimated:YES];
            [weakSelf.window.rootViewController.view hideToastActivity];
            [weakSelf.window hideToastActivity];
            [weakSelf.window makeToast:@"账号鉴权失败" duration:1.0 position:@"center"];
        }
    });
}

#pragma mark - 选择登录用户索引
- (void)selectLoginChildIdx:(NSInteger)index
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    DJTUser *curUser = manager.childrens[index];
    [manager setUserInfo:curUser];
    
    //多个孩子登录
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:manager.userInfo.school_name ?: @"" forKey:LOGIN_SCHOOL];
    
    UIViewController *newRoot = nil;
    BOOL showTab = ![curUser.show_type isEqualToString:@"office"];
    if (showTab) {
        MyTableBarViewController *tabBar = [[MyTableBarViewController alloc] init];
        LeftViewController *left = [[LeftViewController alloc] init];
        YQSlideMenuController *deckController = [[YQSlideMenuController alloc] initWithContentViewController:tabBar leftMenuViewController:left];
        deckController.backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s28@2x" ofType:@"png"]];
        newRoot = deckController;
    }
    else{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[SchoolYardViewController alloc] init]];
        newRoot = nav;
    }
    
    //数据库
    NSString *dbPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",manager.userInfo.userid]];
    [[DataBaseOperation shareInstance] openDataBase:dbPath];
    [[DataBaseOperation shareInstance] createTableByType:kTableMyMsg];
    
    //账号切换的情况
    [manager closeWebSocket];
    [manager setHomeCardArr:nil];
    [manager setWeekList:nil];
    [manager setWeekIdx:0];
    UploadManager *upManager = [UploadManager shareInstance];
    [upManager.upModels removeAllObjects];
    [upManager setNetWorking:NO];
    //连接推送服务器
    [manager startConnectWebSocket];
    
    //启动上传数据
    [self startUpload];
    [self getPowerOfClassCircle];
    [self checkDevice];
    BOOL animal = YES;
    if ([_window.rootViewController isKindOfClass:[YQSlideMenuController class]]) {
        animal = NO;
    }
    else if([_window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *rootNav = (UINavigationController *)_window.rootViewController;
        for (UIViewController *subCon in rootNav.viewControllers) {
            if ([subCon isKindOfClass:[SchoolYardViewController class]]) {
                animal = NO;
                break;
            }
        }
    }
    
    if (animal) {
        //push
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        
        [self.window.layer addAnimation:transition forKey:nil];
    }

    [self.window setRootViewController:newRoot];
}

#pragma mark - 班级圈权限获取
- (void)getPowerOfClassCircle
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    
    __weak typeof(manager)weakManager = manager;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"class"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"open_power"];
    [param setObject:manager.userInfo.class_id forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        if (success) {
            id ret_data = [data valueForKey:@"ret_data"];
            NSString *dynamic_open = [ret_data valueForKey:@"dynamic_open"];
            NSString *home_comment_open = [ret_data valueForKey:@"home_comment_open"];
            weakManager.userInfo.dynamic_open = [NSNumber numberWithInteger:[dynamic_open integerValue]];
            weakManager.userInfo.home_comment_open = [NSNumber numberWithInteger:[home_comment_open integerValue]];
        }
    } failedBlock:^(NSString *description) {
        
    }];
}

- (void)isForcedToUpdate
{
    __weak __typeof(self)weakSelf = self;//URLFACE
    NSString *url = [URLFACE stringByAppendingString:@"center:version"];
    NSDictionary *dic = @{@"client":@"personal",@"tag":@"ios"};
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf updataFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf updataFinish:NO Data:nil];
    }];
}

- (void)updataFinish:(BOOL)success Data:(id)result
{
    if (success) {
        _updataDic = result;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *currentSystemVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *is_force = [result valueForKey:@"is_force"];
        NSString *version = [result valueForKey:@"version"];
        if ([currentSystemVersion compare:version] == NSOrderedAscending) {
            NSString *title = [result valueForKey:@"title"];
            NSString *bt1 = [result valueForKey:@"bt1"];
            NSString *bt2 = [result valueForKey:@"bt2"];
            if ([is_force integerValue] == 1) {
                NSString *force_update_content = [result valueForKey:@"force_update_content"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title ?: @"" message:force_update_content ?: @"" delegate:self cancelButtonTitle:bt2 otherButtonTitles:nil, nil];
                [alertView setTag:100];
                [alertView show];
            }else{
                NSString *update_content = [result valueForKey:@"update_content"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title ?: @"" message:update_content ?: @"" delegate:self cancelButtonTitle:bt1 otherButtonTitles:bt2, nil];
                [alertView setTag:200];
                [alertView show];
            }
        }
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 200 && buttonIndex == 0) {
        
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_updataDic valueForKey:@"down_url"] ?: @""]];
        
        if ([alertView tag] == 100) {
            NSString *title = [_updataDic valueForKey:@"title"];
            NSString *bt2 = [_updataDic valueForKey:@"bt2"];
            NSString *force_update_content = [_updataDic valueForKey:@"force_update_content"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title ?: @"" message:force_update_content ?: @"" delegate:self cancelButtonTitle:bt2 otherButtonTitles:nil, nil];
            [alert setTag:100];
            [alert show];
        }
    }
}

#pragma mark - 验证园所是否绑定考勤机设备
- (void)checkDevice
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.userInfo.hasTimeCard) {
        return;
    }
    
    __weak typeof(manager)weakManager = manager;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"attence"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"checkDevice"];
    [param setObject:manager.userInfo.school_id forKey:@"school_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        if (success) {
            id ret_data = [data valueForKey:@"ret_data"];
            if (ret_data) {
                NSString *have_device = [ret_data valueForKey:@"have_device"];  //0未绑定   1绑定
                if (have_device) {
                    weakManager.userInfo.hasTimeCard = ([have_device integerValue] == 1);
                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_MAIN_HEADVIEW object:nil];
                }
            }
        }
    } failedBlock:^(NSString *description) {
        
    }];
}

#pragma mark - 孩子选择
- (void)popSelectedChildrenView
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    ChildrenListView *listView = [[ChildrenListView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    listView.alpha = 0;
    listView.userInteractionEnabled = NO;
    [_window addSubview:listView];
    
    __weak typeof(listView)weakList = listView;
    [UIView animateWithDuration:0.3 animations:^{
        weakList.alpha = 1;
    } completion:^(BOOL finished) {
        listView.userInteractionEnabled = YES;
    }];
    
}

#pragma mark - 离线上传相关操作
/*
 *切换账号停止上传操作
 */
-(void)stopUpload
{
    if (time!=nil) {
        [time invalidate];
        time=nil;
    }
}

/*
 *未上传数据续传
 */

-(void)startUpload
{
    //定时器  定时提交未成功保存的数据
    if (time!=nil) {
        [time invalidate];
        time=nil;
    }
    time=  [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(loadUnSave) userInfo:nil repeats:YES];
}



/*
 *3分钟定时提交数据
 *
 */

-(void)loadUnSave
{
    if ([[UploadManager shareInstance].upModels count] > 0) {
        //当前有文件正在上传，避免重复
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN){
        return;
    }
    
    NSArray *valueArray = [[CommonUtil shareInstance] readFile];
    
    if (valueArray!=nil) {
        for (id uploadModel in valueArray) {
            if ([uploadModel isKindOfClass:[UploadModel class]]) {
                UploadModel *model = (UploadModel *)uploadModel;
                UploadManager *upManger = [UploadManager shareInstance];
                //只执行当前用户未上传数据的续传
                if (![model.account isEqualToString:[USERDEFAULT objectForKey:LOGIN_ACCOUNT]]) {
                    continue;
                }
                
                DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
                NSString *token = [model.endParam valueForKey:@"token"];
                if (token && ![token isEqualToString:user.token]) {
                    continue;
                }
                BOOL iscx = false;
                for(UploadModel *uploadObj in upManger.upModels){
                    if ([uploadObj.dateTime floatValue] == [model.dateTime floatValue]) {
                        iscx=true;
                        break;
                    }
                }
                if (!iscx) {
                    if ([upManger.upModels count] > 0) {
                        return;
                    }
                    [upManger.upModels addObject:model];
                    [upManger startNextRequest];
                }
                
            }else if([uploadModel isKindOfClass:[NSDictionary class]]){
                NSString *url=[uploadModel objectForKey:@"url"];
                NSDictionary *endDic=[uploadModel objectForKey:@"endDict"];
                
                // NSLog(@"%@",uploadModel);
                __weak typeof(self)weakSelf = self;
                self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:endDic successBlcok:^(BOOL success, id data, NSString *msg) {
                    [weakSelf completeCommitContent:success Data:data];
                    [[CommonUtil shareInstance] removeObject:uploadModel];
                } failedBlock:^(NSString *description) {
                    NSLog(@"%@",description);
                    [weakSelf completeCommitContent:NO Data:nil];
                }];
            }
        }
    }
}

- (void)completeCommitContent:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    if (suc) {
        [self.window.rootViewController.view makeToast:@"班级圈有新的动态，下拉刷新" duration:1.0 position:@"center"];
    }
}

#pragma mark - 错误处理
- (void)dealWithError
{
    if (_window) {
        if ([DJTGlobalManager shareInstance].networkReachabilityStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
            [self performSelector:@selector(dealWithError) withObject:nil afterDelay:5];
            return;
        }
    }
    else{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app版本
        NSString *app_Version = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
        NSString *jsPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.js",JS_FILE_NAME,app_Version]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:jsPath]) {
            [JPEngine evaluateScriptWithPath:jsPath];
        }
    }
    
    //网络请求
    NSMutableDictionary *param = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"getJs"];
    [param setObject:@"2" forKey:@"from_type"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"iphonejs"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf dealWithErrorFinish:success Data:data];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf dealWithErrorFinish:NO Data:nil];
        });
    }];
}

- (void)dealWithErrorFinish:(BOOL)suc Data:(id)result
{
    if (suc) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSString class]]) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            // app版本
            NSString *app_Version = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
            NSString *jsPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.js",JS_FILE_NAME,app_Version]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:jsPath]) {
                NSString *jsContent = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
                if (![jsContent isEqualToString:ret_data]) {
                    [ret_data writeToFile:jsPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    [JPEngine evaluateScriptWithPath:jsPath];
                }
                [self tipUserInfo];
            }
            else{
                [ret_data writeToFile:jsPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                [JPEngine evaluateScriptWithPath:jsPath];
                [self tipUserInfo];
            }
        }
    }
    else{
        [self performSelector:@selector(dealWithError) withObject:nil afterDelay:5];
    }
}

- (void)tipUserInfo{
    
}

#pragma mark - 客服信息
- (void)getQQAccountInfo{
    if ([QQApiInterface isQQInstalled]) {
        //网络请求
        NSMutableDictionary *param = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"qq"];
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
        [param setObject:text forKey:@"signature"];
        __weak typeof(self)weakSelf = self;
        [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"qq"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf QQAcountFinish:success Data:data];
        } failedBlock:^(NSString *description) {
            [weakSelf QQAcountFinish:NO Data:nil];
        }];
    }
}

- (void)QQAcountFinish:(BOOL)suc Data:(id)data{
    if (suc) {
        id ret_data = [data valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSDictionary class]]) {
            NSString *qq = [ret_data valueForKey:@"qq"];
            if ([qq length]) {
                [[DJTGlobalManager shareInstance] setQqInfo:qq];
            }
        }
    }
}

#pragma mark - 程序启动
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [JPEngine startEngine];
    [self dealWithError];
    [self isForcedToUpdate];
    [self getQQAccountInfo];
    //背景色
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:   [UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:20.0], NSFontAttributeName,nil]];
    
    //UITabBarItem字体
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] } forState:UIControlStateHighlighted];
    
    //推送新策略
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
        
    {
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |UIUserNotificationTypeAlert |UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication]registerForRemoteNotifications];
    }
    else{
        //注册启用push
        [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeBadge)];
        
    }
    
    _quitQueue = dispatch_queue_create([[NSString stringWithFormat:@"quit.%@", self] UTF8String], NULL);
    
    //防止文件备份
    [self addSkipBackupAttributeToFileAtPath:APPCacheDirectory];
    [self umengTrack];  //友盟统计配置
    [self configUMShare];   //友盟分享配置

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    LoginViewController *vc = [[LoginViewController alloc] init];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window setRootViewController:loginNav];
    
    [self.window makeKeyAndVisible];
    
    NSArray *notUploadArray = [[CommonUtil shareInstance] readFile];
    if ([notUploadArray count] == 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:APPTmpDirectory error:nil];
            for (NSString *file in fileList) {
                NSString *fileType = [[file pathExtension] uppercaseString];
                if ([fileType isEqualToString:@"JPG"] || [fileType isEqualToString:@"PNG"]) {
                    NSString *path = [APPTmpDirectory stringByAppendingPathComponent:file];
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                }
            }
        });
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[DJTGlobalManager shareInstance] setDeviceToken:token];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //程序进入后台后保持程序运行一段时间，不阻塞
    __block UIBackgroundTaskIdentifier background_task;
    //Create a task object
    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
        [self hold];
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
}

- (void)hold
{
//    while (true) {
//        [NSThread sleepForTimeInterval:1];
//        /** clean the runloop for other source */
//        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
//    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    __weak typeof(DJTGlobalManager *)manager = [DJTGlobalManager shareInstance];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        [manager setNetworkReachabilityStatus:status];
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
            {
                [manager showAlert:nil Msg:NET_WORK_TIP];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                if (manager.userInfo != nil) {
                    [manager startConnectWebSocket];
                }
            }
                break;
            default:
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    if (manager.userInfo) {
        [manager startConnectWebSocket];
    }
    //这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [UMSocialSnsService handleOpenURL:url];
}

@end
