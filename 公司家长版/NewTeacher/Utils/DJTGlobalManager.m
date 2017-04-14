//
//  DJTGlobalManager.m
//  TY
//
//  Created by songzhanglong on 14-5-21.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTGlobalManager.h"
#import "SRWebSocket.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MyMsgModel.h"
#import "NSObject+Reflect.h"
#import "DataBaseOperation.h"
#import "MainViewController.h"
#import "YQSlideMenuController.h"
#import "MyTableBarViewController.h"

@interface DJTGlobalManager ()<SRWebSocketDelegate>
{
    NSTimer *_timer;
    BOOL _refreshMainAfter;
}
@end

@implementation DJTGlobalManager
{
    SRWebSocket *_webSocket;
    BOOL isConnected;
    NSTimeInterval _alertTimeInterval;
}

- (void)dealloc
{
    [_userInfo release];
    [_childrens release];
    
    [self closeWebSocket];
    [self clearTimer];
    
    [super dealloc];
}

+ (DJTGlobalManager *)shareInstance
{
    static DJTGlobalManager *globalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalManager = [[DJTGlobalManager alloc] init];
    });
    
    return globalManager;
}

- (id)init{
    self = [super init];
    if (self) {
        self.qqInfo = @"3492435469";
    }
    return self;
}

/**
 *	@brief	弹出消息
 *
 *	@param 	title 	标题
 *	@param 	msg 	内容
 */
- (void)showAlert:(NSString *)title Msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert release];
}

/**
 *	@brief	查找视图的某个父类
 *
 *	@param 	view 	视图
 *	@param 	father 	类别
 *
 *	@return	查找结果
 */
+ (id)viewController:(UIView *)view Class:(Class)father
{
    if (!view) {
        return nil;
    }
    
    if ([view.nextResponder isKindOfClass:father])
    {
        return view.nextResponder;
    }
    return [DJTGlobalManager viewController:(UIView *)view.nextResponder Class:father];
}


#define mark - SRWebSocket
/**
 *	@brief	链接WebSocket
 */
- (void)startConnectWebSocket
{
    if (isConnected) {
        return;
    }
    
    [self closeWebSocket];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@/websocket",WEBSOCKET_URL]]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

/**
 *	@brief	关闭WebSocket
 */
- (void)closeWebSocket
{
    if (_webSocket) {
        _webSocket.delegate = nil;
        [_webSocket close];
        [_webSocket release];
        _webSocket = nil;
    }
    isConnected = NO;
}

#pragma mark - 心跳
- (void)resetheartbeat
{
    [self clearTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
}

- (void)clearTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

/**
 *	@brief	心跳报文
 */
- (void)timerFire
{

    /*
    NSDictionary *dic = @{@"flag": @"0",@"eachData": @"ping"};
    
    NSDictionary *ofDic = @{@"respData": @[dic]};
    */
    NSArray *dic = @[@{@"flag": @"0",@"eachData": @"ping",@"userCode": [NSString stringWithFormat:@"%@0",_userInfo.userid],@"mobileFlag":@"1"}];
     
    NSData *data1 = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    if (!_webSocket) {
        return;
    }
    if (_webSocket.readyState != SR_CONNECTING) {
        [_webSocket send:str];
    }
    
}



#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    isConnected = YES;

//    [self resetheartbeat];
//    return;
    //发送与管道绑定的信息到服务器
    /*
    NSDictionary *dic = @{@"flag": @"2",@"userCode": [NSString stringWithFormat:@"%@",_userInfo.userid],@"mobileFlag":@"1"};
    NSDictionary *ofDic = @{@"respData": @[dic]};
    */
    
    NSArray *array = @[@{@"flag": @"2",@"userCode": [NSString stringWithFormat:@"%@0",_userInfo.userid],@"mobileFlag":@"1"}];
     
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!_webSocket) {
        return;
    }
    if (_webSocket.readyState != SR_CONNECTING) {
        [webSocket send:str];
    }
    [str release];
    
    
    [self resetheartbeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    [self closeWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    message = [message stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    NSString *decodeMsg = [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //decodeMsg = [decodeMsg stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSData *data = [decodeMsg dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",result);
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result firstObject];
    }
    NSString *eachData = [result valueForKey:@"eachData"];
    if (eachData)
    {
        if ([eachData isEqualToString:@"ok"] || [eachData isEqualToString:@"pong"] || [eachData isEqualToString:@"refuse"])
        {
            
        }
        else
        {
            if ([[result valueForKey:@"status"] integerValue] != 2) {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertAction = @"Ok";
                localNotification.alertBody = eachData;
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                [localNotification release];
                
                //播放震动
                NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
                if (fabs(nowTimeInterval - _alertTimeInterval) > 2)//消息间隔短，不响不震动
                {
                    _alertTimeInterval = nowTimeInterval;
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlaySystemSound(1012);
                }
            }
            
            //数据库插入
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                MyMsgModel *msgModel = [[MyMsgModel alloc] init];
                [msgModel reflectDataFromOtherObject:result];
                if ([msgModel.eachData rangeOfString:@"'"].location != NSNotFound) {
                    msgModel.eachData = [msgModel.eachData stringByReplacingOccurrencesOfString:@"'" withString:@""];
                }
                if (msgModel.eachData && [msgModel.eachData length] > 0) {
                    [[DataBaseOperation shareInstance] insertMyMsg:msgModel];
                }
                
            });
            
            YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
            if ([sideCon isKindOfClass:[YQSlideMenuController class]]) {
                MyTableBarViewController *tabBarCon = (MyTableBarViewController *)sideCon.contentViewController;
                UINavigationController *nav = (UINavigationController *)tabBarCon.selectedViewController;
                UIViewController *rootCon = [nav.viewControllers firstObject];
                if ([rootCon isKindOfClass:[MainViewController class]]) {
                    if (!_refreshMainAfter) {
                        _refreshMainAfter = YES;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self refreshNoticeInfo];
                        });
                    }
                }
                else
                {
                    UINavigationController *mainNav = [tabBarCon.viewControllers firstObject];
                    MainViewController *main = [[mainNav viewControllers] firstObject];
                    main.refreshNotice = YES;
                }
                
            }
        }
    }
}

- (void)refreshNoticeInfo
{
    _refreshMainAfter = NO;
    YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    if ([sideCon isKindOfClass:[YQSlideMenuController class]]) {
        MyTableBarViewController *tabBarCon = (MyTableBarViewController *)sideCon.contentViewController;
        UINavigationController *mainNav = [tabBarCon.viewControllers firstObject];
        MainViewController *main = [[mainNav viewControllers] firstObject];
        main.refreshNotice = NO;
        [main getLatestNotifi];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{

    [self closeWebSocket];
    [self clearTimer];
    
    if (_userInfo != nil && _networkReachabilityStatus >= AFNetworkReachabilityStatusReachableViaWWAN) {
        [self startConnectWebSocket];
    }
}

#pragma mark - 初始化请求参数通用部分
/**
 *	@brief	初始化请求参数通用部分
 *
 *	@param 	ckey 	标记请求
 *
 *	@return	NSMutableDictionary
 */
- (NSMutableDictionary *)requestinitParamsWith:(NSString *)ckey
{
    NSString *nonce = [NSString getRandomNumber:100000 to:1000000];
    NSString *timestamp = [NSString getRandomNumber:1000000000 to:10000000000];    //系统时间
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:ckey,@"ckey",nonce,@"nonce",timestamp,@"timestamp",@"1.0",@"version", @"0",@"is_teacher",app_Version,@"v", nil];;
    if (_userInfo) {
        [dic setObject:_userInfo.token ?: @"" forKey:@"token"];
        [dic setObject:_userInfo.userid ?: @"" forKey:@"userid"];
        [dic setObject:_userInfo.mid ?: @"" forKey:@"mid"];
        [dic setObject:_userInfo.class_id ?: @"" forKey:@"class_id"];
    }
    return dic;
}

#pragma mark - 获取亲友图片
/**
 *	@brief	获取亲友图片
 *
 *	@param 	str 	称呼
 *
 *	@return	图片名
 */
- (NSString *)getFamilyPicture:(NSString *)str
{
    NSString *lastStr = @"w17";
    if (str && [str length] > 0) {
        NSString *lastOne = [str substringFromIndex:[str length] - 1];
        if ([lastOne isEqualToString:@"爸"] || [lastOne isEqualToString:@"叔"] || [lastOne isEqualToString:@"舅"]) {
            lastStr = @"share9_big";
        }
        else if ([lastOne isEqualToString:@"妈"] || [lastOne isEqualToString:@"婶"] || [lastOne isEqualToString:@"姨"] || [lastOne isEqualToString:@"娘"])
        {
            lastStr = @"share6_big";
        }
        else if ([lastOne isEqualToString:@"奶"] || [lastOne isEqualToString:@"婆"])
        {
            lastStr = @"share8";
        }
        else if ([lastOne isEqualToString:@"爷"] || [lastOne isEqualToString:@"公"])
        {
            lastStr = @"share7";
        }
    }
    return lastStr;
}

@end
