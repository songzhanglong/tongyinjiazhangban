//
//  MainViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MainViewController.h"
#import "YQSlideMenuController.h"
#import "MobClick.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "ClassCircleModel.h"
#import "ClassReplyDetailController.h"
#import "StudentAlbumsViewController.h"
#import "UIImage+Caption.h"
#import "DynamicViewCell.h"
#import "ClickViewCell.h"
#import "ClockViewCell.h"
#import "LatestPhotoCell.h"
#import "TumblrLikeMenu.h"
#import "CTAssetsPickerController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+FixOrientation.h"
#import "AddActivityViewController.h"
#import "MyCalendarViewController.h"
#import "LastPhotoModel.h"
#import "DataBaseOperation.h"
#import "MyMsgModel.h"
#import "MyMsgViewController.h"
#import "UploadManager.h"
#import "CommonUtil.h"
#import "NSDate+Common.h"
#import "ClassHeaderView.h"
#import "MainViewController1.h"
#import "AdModel.h"
#import "DJTOrderViewController.h"
#import "PublicScrollView.h"
#import "StudentAlbums2ViewController.h"
#import "WeatherViewController.h"
#import "PlayViewController.h"

#define CITY_NAME       @"city_name"
#define WEALTHY_DATA    @"weatherData"
#define WEALTHY         @"weather"
#define DAY_IMG         @"day_img"
#define NIGHT_IMG       @"night_img"
#define WEAL_TIME       @"wealTime"
#define LOWEST          @"lowest"


@interface MainViewController ()<ClassReplyDetailDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,PublicScrollViewDelegate,DynamicViewCellDelegate>

@end

@implementation MainViewController
{
    UILabel     *_tipLabel,*_addressLabel,*_wealLabel,*_lowLabel;
    UIImageView *_wealImage;
    NSInteger   _pageCount;
    
    BOOL        _lastPage,_refreshAds,_isFirst,_firstReq;
    
    NSIndexPath *_indexPath;
    BOOL        _takePicture; //拍照
    
    NSString *_curId,*_curName;
    AFHTTPRequestOperation *_myOreration;
    
    UILabel     *_mainTipLab;
    UIImageView *_mainTipView;
    
    int _pmDeviceType;
    BOOL _requestWealthy;
}

- (void)dealloc
{
    if (_myOreration && (!_myOreration.isCancelled && !_myOreration.isFinished)) {
        [_myOreration cancel];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STOP_SCROLL_ENABLE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_MAIN_HEADVIEW object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.useNewInterface = YES;
    _pageCount = 10;
    _isFirst = YES;
    _pmDeviceType = 1;
    
    //表格＋网络
    [self createTableViewAndRequestAction:@"dynamic" Param:nil Header:YES Foot:YES];
    [_tableView setTableHeaderView:[self createTableHeaderView]];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"adsCellId"];
    [_tableView registerClass:[DynamicViewCell class] forCellReuseIdentifier:@"dynamicCell"];
    [_tableView registerClass:[LatestPhotoCell class] forCellReuseIdentifier:@"lastestCell"];
    [_tableView registerClass:[ClockViewCell class] forCellReuseIdentifier:@"clockCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableSampleIdentifier"];
    [_tableView registerClass:[ClickViewCell class] forCellReuseIdentifier:@"clickCell"];
    [self beginRefresh];
    
    //左右两button
    for (NSInteger i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat xOri = (i == 0) ? 10 : ([UIScreen mainScreen].bounds.size.width - 10 - 40);
        [button setFrame:CGRectMake(xOri, 20, 40, 40)];
        [button setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:(i == 0) ? @"s1@2x" : @"sy3@2x" ofType:@"png"]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:(i == 0) ? @"s1@2x" : @"sy3_1@2x" ofType:@"png"]] forState:UIControlStateNormal];
        if (i == 0) {
            YQSlideMenuController *deckController = (YQSlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
            
            [button addTarget:deckController action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [button addTarget:self action:@selector(publicDynamic:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:button];
    }
    
    //数量提示
    _mainTipView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) / 2, 80, 200, 29)];
    _mainTipView.hidden = YES;
    _mainTipView.userInteractionEnabled = YES;
    [_mainTipView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"futiao" ofType:@"png"]]];
    [self.view addSubview:_mainTipView];
    _mainTipLab = [[UILabel alloc] initWithFrame:_mainTipView.bounds];
    [_mainTipLab setTextAlignment:1];
    [_mainTipLab setTextColor:[UIColor whiteColor]];
    [_mainTipLab setBackgroundColor:[UIColor clearColor]];
    [_mainTipLab setFont:[UIFont systemFontOfSize:14]];
    [_mainTipView addSubview:_mainTipLab];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadView:) name:REFRESH_MAIN_HEADVIEW object:nil];
}

- (void)refreshHeadView:(id)sendr
{
    [_tableView reloadData];
    
}

- (UIView *)createTableHeaderView
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    //imageview
    UIImage *titleImg = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"s6@2x" ofType:@"png"]];
    CGSize imgSize = titleImg.size;
    CGFloat hei = self.view.frame.size.width * imgSize.height / imgSize.width;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:titleImg];
    imageView.userInteractionEnabled = YES;
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, hei)];
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weatherAction:)]];
    //wealthy
    NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
    UIImageView *wealthy = [[UIImageView alloc] init];
    NSString *day_img = [userDef objectForKey:[DAY_IMG stringByAppendingString:userId]];
    if (day_img) {
        [wealthy setImageWithURL:[NSURL URLWithString:day_img]];
    }
    _wealImage = wealthy;
    [wealthy setFrame:CGRectMake((self.view.frame.size.width - 75) / 2, 30, 75, 65)];
    [imageView addSubview:wealthy];
    
    //lowest
    _lowLabel = [[UILabel alloc] initWithFrame:CGRectMake(wealthy.frame.origin.x + wealthy.frame.size.width + 5, wealthy.frame.origin.y + 5, 100, 16)];
    [_lowLabel setTextColor:[UIColor whiteColor]];
    [_lowLabel setFont:[UIFont systemFontOfSize:14]];
    [_lowLabel setBackgroundColor:[UIColor clearColor]];
    NSString *lowest = [userDef objectForKey:[LOWEST stringByAppendingString:userId]];
    if (![lowest hasPrefix:@"~"]) {
        [_lowLabel setText:lowest];
    }
    [imageView addSubview:_lowLabel];
    
    //tip
    UIImageView *tipView = [[UIImageView alloc] initWithFrame:CGRectMake(5, imageView.frame.size.height - 10 - 25, 25, 25)];
    [tipView setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"s3@2x" ofType:@"png"]]];
    [imageView addSubview:tipView];
    
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(tipView.frame.origin.x * 2 + tipView.frame.size.width, tipView.frame.origin.y - 1, self.view.frame.size.width - (tipView.frame.origin.x * 2 + tipView.frame.size.width + 15 + 55 + 1), 28)];
    _tipLabel = tipLab;
    [tipLab setFont:[UIFont systemFontOfSize:11]];
    [tipLab setTextColor:[UIColor whiteColor]];
    [tipLab setNumberOfLines:2];
    [tipLab setBackgroundColor:[UIColor clearColor]];
    [tipLab setText:[userDef objectForKey:[WEALTHY_DATA stringByAppendingString:userId]]];
    [imageView addSubview:tipLab];
    
    //虚线
    UIImageView *xuxian = [[UIImageView alloc] initWithFrame:CGRectMake(tipLab.frame.size.width + tipLab.frame.origin.x + 5 , tipLab.frame.origin.y + (tipLab.frame.size.height - 23.5) / 2, 1, 23.5)];
    [xuxian setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xuxian" ofType:@"png"]]];
    [imageView addSubview:xuxian];
    
    //address
    UIImageView *addressImg = [[UIImageView alloc] initWithFrame:CGRectMake(imageView.frame.size.width - 5 - 16, tipLab.frame.origin.y, 16, 16)];
    [addressImg setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"s2@2x" ofType:@"png"]]];
    [imageView addSubview:addressImg];
    
    UILabel *addressLab = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width - 5 - 55, addressImg.frame.origin.y, 39, 16)];
    _addressLabel = addressLab;
    [addressLab setFont:[UIFont systemFontOfSize:15]];
    [addressLab setTextColor:[UIColor whiteColor]];
    [addressLab setBackgroundColor:[UIColor clearColor]];
    [addressLab setText:[userDef objectForKey:[CITY_NAME stringByAppendingString:userId]]];
    [imageView addSubview:addressLab];
    
    UILabel *wealLab = [[UILabel alloc] initWithFrame:CGRectMake(addressLab.frame.origin.x, addressLab.frame.origin.y + addressLab.frame.size.height, 55, 12)];
    _wealLabel = wealLab;
    [wealLab setFont:[UIFont systemFontOfSize:11]];
    [wealLab setTextColor:[UIColor whiteColor]];
    [wealLab setBackgroundColor:[UIColor clearColor]];
    [wealLab setText:[userDef objectForKey:[WEALTHY stringByAppendingString:userId]]];
    [imageView addSubview:wealLab];
    
    return imageView;
}

- (void)weatherAction:(id)sender
{
    if (_pmDeviceType == 2) {
        WeatherViewController *weatherController = [[WeatherViewController alloc] init];
        weatherController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:weatherController animated:YES];
    }else if (_pmDeviceType <= 1){
        [self requestPMDevice];
    }
}
#pragma mark is PM2.5 device
- (void)requestPMDevice
{
    if (_requestWealthy) {
        [self.view makeToast:@"天气数据正在请求" duration:1.0 position:@"center"];
        return;
    }
    
    //api/client.php?action=weather:getdevice {"class_id":"班级id","teacher_id":"教师id","mobile":"登陆手机号"}
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    _requestWealthy = YES;
    
    __weak __typeof(self)weakSelf = self;
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSString *url = [URLFACE stringByAppendingString:@"weather:getdevice"];
    NSDictionary *dic = @{@"class_id":user.class_id,@"mid":user.mid,@"mobile":[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_ACCOUNT]};
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf pm25DeviceFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf pm25DeviceFinish:NO Data:nil];
    }];
}

- (void)pm25DeviceFinish:(BOOL)success Data:(id)result
{
    _requestWealthy = NO;
    if (success) {
        NSDictionary *dic = [result valueForKey:@"data"];
        if (dic && ![dic isKindOfClass:[NSNull class]]) {
            _pmDeviceType = 2;
            WeatherViewController *weatherController = [[WeatherViewController alloc] init];
            weatherController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:weatherController animated:YES];
        }else {
            _pmDeviceType = 3;
        }
    }
    else
    {
        NSString *str = [result objectForKey:@"message"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
}

- (void)reloadSection:(NSInteger)section
{
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    [MobClick beginLogPageView:@"classCircle"];
    
    YQSlideMenuController *side = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    side.needSwipeShowMenu = YES;
    
    if (_refreshNotice) {
        _refreshNotice = NO;
        //通知消息查询
        [self getLatestNotifi];
    }
    
    [self refreshTipInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    YQSlideMenuController *side = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    side.needSwipeShowMenu = NO;
    
    [MobClick endLogPageView:@"classCircle"];
    _refreshNotice = NO;
}

- (void)publicDynamic:(id)sender
{
    if ([DJTGlobalManager shareInstance].userInfo.dynamic_open.integerValue != 1) {
        [self.view makeToast:@"暂无发布班级圈的权限" duration:1.0 position:@"center"];
        return;
    }
    
    TumblrLikeMenuItem *menuItem0 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s15@2x" ofType:@"png"]] highlightedImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s15_@2x" ofType:@"png"]] text:@"相册"];
    
    TumblrLikeMenuItem *menuItem1 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fb1@2x" ofType:@"png"]] highlightedImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fb1_1@2x" ofType:@"png"]]  text:@"拍照"];
    
    TumblrLikeMenuItem *menuItem2 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s13@2x" ofType:@"png"]] highlightedImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s13_1@2x" ofType:@"png"]] text:@"小视频"];
    
    NSMutableArray *menus = [NSMutableArray arrayWithObjects:menuItem0,menuItem1,menuItem2, nil];
    TumblrLikeMenu *menu = [[TumblrLikeMenu alloc] initWithFrame:self.view.window.bounds subMenus:menus tip:@"取消"];
    __weak typeof(self)weakSelf = self;
    menu.selectBlock = ^(NSUInteger index) {
        if (index == 0) {
            //照片
            [weakSelf callImagePicker];
        }
        else if (index == 1)
        {
            //拍照
            [weakSelf takeOnePhoto];
        }
        else if (index == 2)
        {
            //视频
            [weakSelf takeViedeo];
        }
    };
    [menu show];
}

#pragma mark - 获取资讯列表
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"search"];
    [param setObject:manager.userInfo.class_id forKey:@"class_id"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    if (!_firstReq && [self.dataSource count] > 0) {
        ClassCircleModel *lastOne = [self.dataSource lastObject];
        [param setObject:lastOne.dateline forKey:@"dateline"];
    }
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)startPullRefresh
{
    _lastPage = NO;
    _firstReq = YES;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    if (_lastPage) {
        [self.view makeToast:@"已到最后一页" duration:1.0 position:@"center"];
        
        //isStopRefresh
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
    }
    else
    {
        _firstReq = NO;
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error;
            ClassCircleModel *circle = [[ClassCircleModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [circle calculateGroupCircleRects];
            
            [array addObject:circle];
        }
        
        _lastPage = ([array count] < _pageCount);
        
        self.dataSource = array;
        [_tableView reloadData];
        
        //考勤
        [self requestWorkRecord];
        
        //最新相册
        [self requestLatestPhoto];
        
        //天气请求
        [self startWealthyRequest];
        
        [self requestAds];
        
        if (_isFirst) {
            _isFirst = NO;
            //通知消息查询
            [self getLatestNotifi];
        }
    }
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger count = [self.dataSource count];
        NSInteger section = [_tableView numberOfSections] - 1;
        for (id subDic in data) {
            NSError *error;
            ClassCircleModel *circle = [[ClassCircleModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            
            [circle calculateGroupCircleRects];
            
            [array addObject:circle];
            [indexPaths addObject:[NSIndexPath indexPathForRow:count++ inSection:section]];
        }
        
        _lastPage = ([array count] < _pageCount);
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        [self.dataSource addObjectsFromArray:array];
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

#pragma mark - 点赞
- (void)diggRequest:(NSString *)tid
{
    if (self.httpOperation) {
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    _tableView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"digg"];
    [param setObject:tid forKey:@"tid"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    [param setObject:@"0" forKey:@"is_teacher"];  //0-家长,1-老师 2-园长
    [param setObject:manager.userInfo.uname forKey:@"user_name"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf diggComplete:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf diggComplete:NO Data:nil];
    }];
}

- (void)diggComplete:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        ClassCircleModel *cricle = [self.dataSource objectAtIndex:_indexPath.row];
        cricle.have_digg = [NSNumber numberWithInt:1];
        DiggItem *item = [[DiggItem alloc] init];
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        item.face = user.face;
        item.is_teacher = @"0";
        item.name = user.uname;
        item.userid = user.userid;
        if (!cricle.digg) {
            [cricle setDigg:(NSMutableArray<DiggItem> *)[NSMutableArray array]];
        }
        [cricle.digg addObject:item];
        cricle.digg_count = [NSNumber numberWithInteger:cricle.digg_count.integerValue + 1];
        [cricle calculateGroupCircleRects];
        
        [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 广告
- (void)requestAds
{
    if (_refreshAds) {
        return;
    }
    
    _refreshAds = YES;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *dic = [manager requestinitParamsWith:@"getAd"];
    [dic setObject:@"1" forKey:@"position_id"];
    [dic setObject:manager.userInfo.school_id ?: @"" forKey:@"school_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"ad"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestAdsFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestAdsFinish:NO Data:nil];
    }];
}

- (void)requestAdsFinish:(BOOL)success Data:(id)result
{
    _refreshAds = NO;
    NSMutableArray *array = [NSMutableArray array];
    if (success) {
        NSArray *ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        for (NSDictionary *subDic in ret_data) {
            NSError *error;
            AdModel *adModel = [[AdModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:adModel];
        }
    }
    
    DJTUser *user = [[DJTGlobalManager shareInstance] userInfo];
    if (![array isEqualToArray:user.adsSource] && [array count] > 0) {
        [user setAdsSource:array];
        [_tableView reloadData];
    }
}

#pragma mark - 考勤
- (void)requestWorkRecord
{
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"getAttenceByStudentId"];
    [dic setObject:[DJTGlobalManager shareInstance].userInfo.userid forKey:@"userid"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"calendar"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestWorkRecordFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestWorkRecordFinish:NO Data:nil];
    }];
}

- (void)requestWorkRecordFinish:(BOOL)success Data:(id)result
{
    if (success) {
        //0-未考勤,1-到勤,2-缺勤
        NSDictionary *dic = [result valueForKey:@"ret_data"];
        id status = [dic valueForKey:@"status"];
        if (!status) {
            [DJTGlobalManager shareInstance].userInfo.status = @"1";
        }
        else
        {
            NSString *strState = [status isKindOfClass:[NSNumber class]] ? [(NSNumber *)status stringValue] : status;
            [DJTGlobalManager shareInstance].userInfo.status = strState;
        }
    }
    else
    {
        [DJTGlobalManager shareInstance].userInfo.status = @"3";
    }
    
    [_tableView reloadData];
    
}

#pragma mark - 获取相册最新内容
- (void)requestLatestPhoto
{
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"getLastPhoto"];
    [dic setObject:[DJTGlobalManager shareInstance].userInfo.album_id forKey:@"album_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"photo"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestLatestPhotoFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestLatestPhotoFinish:NO Data:nil];
    }];
}

- (void)requestLatestPhotoFinish:(BOOL)success Data:(id)result
{
    if (success) {
        NSError *error;
        LastPhotoModel *model = [[LastPhotoModel alloc] initWithDictionary:result error:&error];
        if (error) {
            NSLog(@"%@",error.description);
        }
        else
        {
            [DJTGlobalManager shareInstance].userInfo.photoModel = model;
            [_tableView reloadData];
        }
        
    }
    else
    {
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
}

#pragma mark - 天气
- (void)startWealthyRequest
{
    //天气请求
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
    NSString *str = [userDef objectForKey:[WEAL_TIME stringByAppendingString:userId]];
    if (str && [str isEqualToString:[NSString stringByDate:@"yyyyMMdd" Date:[NSDate date]]]) {
        //[self requestWealthy];
    }
    else
    {
        NSLog(@"天气请求");
        //天气请求
        [self requestWealthy];
    }
}

- (void)requestWealthy
{
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"weather"];
    [dic setObject:[DJTGlobalManager shareInstance].userInfo.class_id forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"weather"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestWealthyFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestWealthyFinish:NO Data:nil];
    }];
}

- (NSString *)getStr:(NSString *)key Dic:(id)result
{
    NSString *lastStr = [result valueForKey:key];
    if ([lastStr isKindOfClass:[NSNull class]]) {
        lastStr = @"";
    }
    return lastStr;
}

- (void)requestWealthyFinish:(BOOL)success Data:(id)result
{
    if (success) {
        NSDictionary *dic = [result valueForKey:@"ret_data"];
        NSString *weather = [self getStr:@"weather" Dic:dic];
        NSString *weatherData = [self getStr:@"weatherData" Dic:dic];
        NSString *city_name = [self getStr:@"city_name" Dic:dic];
        
        NSString *today = [NSString stringByDate:@"yyyyMMdd" Date:[NSDate date]];
        [_addressLabel setText:city_name];
        [_wealLabel setText:weather];
        [_tipLabel setText:weatherData];
        
        NSString *day_img = [self getStr:@"day_img" Dic:dic];
        NSString *night_img = [self getStr:@"night_img" Dic:dic];
        [_wealImage setImageWithURL:[NSURL URLWithString:day_img]];
        
        NSString *lowest = [self getStr:@"lowest" Dic:dic];
        NSString *hightest = [self getStr:@"hightest" Dic:dic];
        NSString *lowToHigh = [lowest stringByAppendingString:[NSString stringWithFormat:@"~%@°C",hightest]];
        if (![lowToHigh hasPrefix:@"~"]) {
            [_lowLabel setText:lowToHigh];
        }
        
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
        [userDef setObject:weatherData forKey:[WEALTHY_DATA stringByAppendingString:userId]];
        [userDef setObject:weather forKey:[WEALTHY stringByAppendingString:userId]];
        [userDef setObject:city_name forKey:[CITY_NAME stringByAppendingString:userId]];
        [userDef setObject:today forKey:[WEAL_TIME stringByAppendingString:userId]];
        [userDef setObject:day_img forKey:[DAY_IMG stringByAppendingString:userId]];
        [userDef setObject:night_img forKey:[NIGHT_IMG stringByAppendingString:userId]];
        [userDef setObject:lowToHigh forKey:[LOWEST stringByAppendingString:userId]];
        [userDef synchronize];
    }
    else
    {
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
}

#pragma mark - 上传进度
- (void)refreshTipInfo
{
    UploadManager *manager = [UploadManager shareInstance];
    _mainTipView.hidden = (manager.totalCount == 0);
    if (!_mainTipView.hidden) {
        [_mainTipLab setText:[NSString stringWithFormat:@"当前图片上传进度:%ld/%ld",(long)manager.curCount,(long)manager.totalCount]];
    }
}

#pragma mark - 通知消息
- (void)getLatestNotifi
{
    if (_isFirst) {
        return;
    }
    
    NSArray *array = [[DataBaseOperation shareInstance] selectMyMsgByDateAsc:NO];
    BOOL hasNoti = array.count > 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:array.count];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (hasNoti) {
        
        MyMsgModel *model = [array firstObject];
        manager.userInfo.mainTipNum = [NSString stringWithFormat:@"%ld",(long)array.count];
        
        if (![_curId isEqualToString:model.sender]) {
            _curId = model.sender;
            
            NSMutableDictionary *param = [manager requestinitParamsWith:@"getMemberFace"];
            [param setObject:_curId forKey:@"userids"];
            NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
            [param setObject:text forKey:@"signature"];
            
            __weak __typeof(self)weakSelf = self;
            NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"member"];
            _myOreration = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
                [weakSelf endRefresh:success Data:data Model:model];
                
            } failedBlock:^(NSString *description) {
                [weakSelf endRefresh:NO Data:nil Model:model];
            }];
        }
        else if(_curName != nil)
        {
            manager.userInfo.mainTipStr = [_curName stringByAppendingString:[self getStringBy:model]];
            [self reloadSection:3];
        }
    }
    else
    {
        _curId = nil;
        _curName = nil;
        manager.userInfo.mainTipStr = nil;
        manager.userInfo.mainTipNum = nil;
        manager.userInfo.mainFace = nil;
        [self reloadSection:3];
    }
}

- (NSString *)getStringBy:(MyMsgModel *)model
{
    NSString *tipStr = @"发信息了";
    switch (model.mdFlag.integerValue) {
        case 6:
        {
            tipStr = @"园长消息通知";
        }
            break;
        case 7:
        {
            tipStr = @"点赞了你";
        }
            break;
        case 8:
        {
            tipStr = @"评论了你";
        }
            break;
        case 9:
        {
            tipStr = @"回复了你";
        }
            break;
        case 10:
        {
            tipStr = @"园所通知你";
        }
            break;
        case 11:
        {
            tipStr = @"提醒你关注";
        }
            break;
        case 12:
        {
            tipStr = @"完成了考勤";
        }
            break;
        case 13:
        {
            tipStr = @"成长手册更新";
        }
            break;
        case 99:
        {
            tipStr = @"活动通知提醒";
        }
            break;
        default:
            break;
    }
    
    return tipStr;
}

- (void)endRefresh:(BOOL)suc Data:(id)result Model:(MyMsgModel *)msgModel
{
    if (suc) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSDictionary *dic = ret_data;
        if ([ret_data isKindOfClass:[NSArray class]]) {
            dic = [ret_data firstObject];
        }
        NSDictionary *keyValue = [[dic allValues] firstObject];
        NSString *url = [keyValue valueForKey:@"face"] ?: @"";
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        _curName = [keyValue valueForKey:@"name"];
        NSString *tipStr = [self getStringBy:msgModel];
        [DJTGlobalManager shareInstance].userInfo.mainTipStr = [_curName stringByAppendingString:tipStr];
        [DJTGlobalManager shareInstance].userInfo.mainFace = url;
        [self reloadSection:3];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 视频播放
/**
 *	@brief	视频播放
 *
 *	@param 	filePath 	视频路径
 */
- (void)playVideo:(NSString *)filePath
{
    if (![filePath hasPrefix:@"http"]) {
        filePath = [G_IMAGE_ADDRESS stringByAppendingString:filePath ?: @""];
    }
    NSURL *movieURL = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    [self.movieController prepareToPlay];
    [self.view addSubview:self.movieController.view];//设置写在添加之后   // 这里是addSubView
    self.movieController.shouldAutoplay=YES;
    [self.movieController setControlStyle:MPMovieControlStyleDefault];
    self.movieController.scalingMode = MPMovieScalingModeAspectFill;
    [self.movieController setFullscreen:YES];
    [self.movieController.view setFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
}

- (void)movieFinishedCallback:(NSNotification*)notify {
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [theMovie.view removeFromSuperview];
    
    self.movieController = nil;
}

#pragma mark - DynamicViewCellDelegate
- (void)diggAndCommentCell:(UITableViewCell *)cell At:(NSInteger)idx
{
    _indexPath = [_tableView indexPathForCell:cell];
    ClassCircleModel *cricle = [self.dataSource objectAtIndex:_indexPath.row];
    if ([cricle isNotUpload]) {
        return;
    }
    
    if (idx == 0) {
        if ([cricle.have_digg integerValue] == 1) {
            [self.view makeToast:@"不可重复点赞" duration:1.0 position:@"center"];
        }
        else
        {
            [self diggRequest:cricle.tid];
        }
    }
    else
    {
        ClassReplyDetailController *reply = [[ClassReplyDetailController alloc] init];
        reply.delegate = self;
        reply.circleModel = self.dataSource[_indexPath.row];
        reply.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:reply animated:YES];
    }
}

- (void)touchImageCell:(UITableViewCell *)cell At:(NSInteger)idx
{
    if (idx < 100) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        //检测视频
        ClassCircleModel *circle = self.dataSource[indexPath.row];
        NSArray *pics = [circle.picture componentsSeparatedByString:@"|"];
        NSArray *thumbs = [circle.picture_thumb componentsSeparatedByString:@"|"];
        
        //图片
        _browserPhotos = [NSMutableArray array];
        for (int i = 0; i < pics.count; i++) {
            NSString *path = pics[i];
            if (![path hasPrefix:@"http"]) {
                path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
            }
            
            MWPhoto *photo = nil;
            NSString *name = [path lastPathComponent];
            if ([[[name pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
                NSString *tmpThumb = thumbs[i];
                if ([[[tmpThumb pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
                    photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                }
                else
                {
                    if (![tmpThumb hasPrefix:@"http"]) {
                        tmpThumb = [G_IMAGE_ADDRESS stringByAppendingString:tmpThumb ?: @""];
                    }
                    photo = [MWPhoto photoWithURL:[NSURL URLWithString:tmpThumb]];
                }
                
                photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                photo.isVideo = YES;
            }
            else
            {
                CGFloat scale_screen = [UIScreen mainScreen].scale;
                NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
                path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
            [_browserPhotos addObject:photo];
        }
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        [browser setCurrentPhotoIndex:idx];
        browser.displayActionButton = NO;
        browser.displayNavArrows = YES;
        
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (void)selectListByPeople:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    ClassCircleModel *circleModel = self.dataSource[indexPath.row];
    MainViewController1 *main1 = [[MainViewController1 alloc]init];
    main1.activityModel = circleModel;
    main1.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:main1 animated:YES];
}

#pragma mark - PublicScrollViewDelegate
- (void)touchImageAtIndex:(NSInteger)index ScrollView:(PublicScrollView *)pubSro
{
    AdModel *model = [DJTGlobalManager shareInstance].userInfo.adsSource[index];
    DJTOrderViewController *adverDetail = [[DJTOrderViewController alloc]init];
    adverDetail.url = model.url;
    adverDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:adverDetail animated:YES];
}

#pragma mark - ClassReplyDetailDelegate
- (void)changeReplyDetail
{
    [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteThisCircleDetail
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.dataSource removeObjectAtIndex:_indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - 选择照片与拍照
- (void)callImagePicker
{
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc]init];
    picker.maximumNumberOfSelection = 9;
    picker.combine = YES;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
}
/**
 *  拍照
 */
- (void)takeOnePhoto
{
    _takePicture = YES;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;//设置类型
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takeViedeo
{
    _takePicture = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray * availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        pickerView.videoMaximumDuration = 40;
        pickerView.delegate = self;
        [self presentViewController:pickerView animated:YES completion:NULL];
    }
}

#pragma mark - 页面切换
- (void)videoCompressedFinish:(NSString *)videoPath
{
    AddActivityViewController *add = [[AddActivityViewController alloc] init];
    add.videoPath = videoPath;
    add.dataSource = [NSMutableArray arrayWithObject:videoPath];
    add.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:add animated:YES];
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
            AddActivityViewController *add = [[AddActivityViewController alloc] init];
            add.dataSource = [NSMutableArray arrayWithArray:assets];
            add.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:add animated:YES];
        }
    }
    
}
//照片保存回调
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    /*
    if(!error){
        [self.view makeToast:@"图片保存成功" duration:1.0 position:@"center"];
    }else{
        [self.view makeToast:@"图片保存失败" duration:1.0 position:@"center"];
    }
     */
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    /*
    if(!error){
        [self.view makeToast:@"视频文件保存成功" duration:1.0 position:@"center"];
    }else{
        [self.view makeToast:@"视频文件保存失败" duration:1.0 position:@"center"];
    }
    */
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (_takePicture) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        image = [image fixOrientation];//把图片已正确的位置保存
        AddActivityViewController *add = [[AddActivityViewController alloc] init];
        add.dataSource = [NSMutableArray arrayWithObject:image];
        add.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:add animated:YES];
        return;
    }
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    //保存视频
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0:
        {
            DJTUser *user = [[DJTGlobalManager shareInstance] userInfo];
            count = ([user.adsSource count] > 0) ? 1 : 0;
        }
            break;
        case 1:
        {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            BOOL isAttendance = [userDefault boolForKey:LOGIN_ATTENDANCE];
            count = isAttendance ? 0 : 1;
        }
            break;
        case 2:
        {
            LastPhotoModel *model = [DJTGlobalManager shareInstance].userInfo.photoModel;
            count = (model && model.photos.count > 0) ? 1 : 0;
        }
            break;
        case 3:
        {
            NSString *tipStr = [DJTGlobalManager shareInstance].userInfo.mainTipNum;
            count = (tipStr && [tipStr length] > 0) ? 1 : 0;
        }
            break;
        case 4:
        {
            count = 1;
        }
            break;
        case 5:
        {
            count = [self.dataSource count];
        }
            break;
        default:
            break;
    }
    
    return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = nil;
    if (indexPath.section == 0)
    {
        cellId = @"adsCellId";
    }
    else if (indexPath.section == 1) {
        cellId = @"clockCell";
    }
    else if (indexPath.section == 2)
    {
        cellId = @"lastestCell";
    }
    else if (indexPath.section == 3)
    {
        cellId = @"clickCell";
    }
    else if(indexPath.section == 4){
        cellId = @"TableSampleIdentifier";
    }
    else
        
    {
        cellId = @"dynamicCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
        {
            DJTUser *user = [[DJTGlobalManager shareInstance] userInfo];
            NSMutableArray *array = [NSMutableArray array];
            for (AdModel *model in user.adsSource) {
                [array addObject:model.picture];
            }
            PublicScrollView *subView = (PublicScrollView *)[cell.contentView viewWithTag:1];
            if (!subView) {
                CGSize winSize = [UIScreen mainScreen].bounds.size;
                CGFloat hei = winSize.width * 8 / 64.0;
                PublicScrollView *scrollView = [[PublicScrollView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, hei)];
                scrollView.delegate = self;
                [scrollView setTag:1];
                [scrollView setImagesArrayFromModel:array];
                [cell.contentView addSubview:scrollView];
            }
            else{
                [subView reloadArr:array];
            }
        }
            break;
        case 1:
        {
            NSString *state = [DJTGlobalManager shareInstance].userInfo.status;
            UILabel *label = ((ClockViewCell *)cell).tipLab;
            UIImageView *imageView = ((ClockViewCell *)cell).midImage;
            if ([DJTGlobalManager shareInstance].userInfo.hasTimeCard) {
                [label setFrame:CGRectMake(10, 20, 160, 24)];
                [imageView setFrame:CGRectMake(175, 17, 30, 30)];
                [label setText:@"点击查看今日考勤"];
                [imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s12_2@2x" ofType:@"png"]]];
            }else{
                if ([state isEqualToString:@"0"])
                {
                    [label setText:@"今日未考勤"];
                }
                else if([state isEqualToString:@"1"])
                {
                    [label setText:@"今日到勤"];
                    [imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s12_2@2x" ofType:@"png"]]];
                }
                else if([state isEqualToString:@"2"])
                {
                    [label setText:@"今日缺勤"];
                    [imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s12_3@2x" ofType:@"png"]]];
                }
                else if([state isEqualToString:@"3"])
                {
                    [label setText:@"考勤信息加载失败"];
                }
            }
        }
            break;
        case 2:
        {
            [(LatestPhotoCell *)cell resetDataSource:[DJTGlobalManager shareInstance].userInfo.photoModel];
        }
            break;
        case 3:
        {
            ClickViewCell *clickCell = (ClickViewCell *)cell;
            NSString *tipStr = [DJTGlobalManager shareInstance].userInfo.mainTipStr;
            DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
            [clickCell.faceImg setImageWithURL:[NSURL URLWithString:[user.mainFace stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s5_big.png"]];
            clickCell.tipLab.text = tipStr;
            clickCell.numLab.text = ([user.mainTipNum integerValue] < 10) ? user.mainTipNum : @"n";
        }
            break;
        case 4:
        {
            UILabel *label = (UILabel *)[cell.contentView viewWithTag:111];
            if (!label) {
                label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
                label.text = @"  班级动态";
                [label setTag:111];
                label.textColor = CreateColor(163, 163, 163);
                label.backgroundColor = CreateColor(238, 239, 239);
                [cell.contentView setBackgroundColor:[UIColor clearColor]];
                [cell.contentView addSubview:label];
            }
        }
            break;
        case 5:
        {
            [(DynamicViewCell *)cell resetClassGroupData:self.dataSource[indexPath.row]];
            [(DynamicViewCell *)cell setDelegate:self];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat lastHei = 0;
    switch (indexPath.section) {
        case 0:
        {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            lastHei = winSize.width * 8 / 64.0;
        }
            break;
        case 1:
        {
            lastHei = 65;
        }
            break;
        case 2:
        {
            CGFloat margin = 2.0;
            CGFloat imgWei = roundf(([UIScreen mainScreen].bounds.size.width - margin * 5) / 4);
            lastHei = imgWei + 45;
        }
            break;
        case 3:
        {
            lastHei = 75;
        }
            break;
        case 4:
        {
            lastHei = 30;
        }
            break;
        case 5:
        {
            ClassCircleModel *model = self.dataSource[indexPath.row];
            CGFloat hei = 18 + model.butYori + 24 + 10 + model.replyBackRect.size.height;
            if (model.diggRect.size.height > 0) {
                hei += model.diggRect.size.height + 5;
            }
            if (model.contentRect.size.height > 60) {
                hei -= (model.contentRect.size.height - 60);
            }
            lastHei = hei;
        }
            break;
        default:
            break;
    }
    
    return lastHei;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    
    if (self.httpOperation) {
        [self.view makeToast:@"数据正在加载，请稍候" duration:1.0 position:@"center"];
        return;
    }
    
    _indexPath = indexPath;
    switch (indexPath.section - 1) {
        case 0:
        {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setBool:YES forKey:LOGIN_ATTENDANCE];
            [userDefault synchronize];
            
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self getCKey];
//            MyCalendarViewController *detail=[[MyCalendarViewController alloc]init];
//            detail.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:detail animated:YES];
        }
            break;
        case 1:
        {
            StudentAlbums2ViewController *activity = [[StudentAlbums2ViewController alloc] init];
            activity.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:activity animated:YES];
        }
            break;
        case 2:
        {
            MyMsgViewController *myMsg = [[MyMsgViewController alloc] init];
            myMsg.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myMsg animated:YES];
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            
            ClassCircleModel *circleModel = self.dataSource[indexPath.row];
            if([circleModel isNotUpload]){
                return;
            }
            
            ClassReplyDetailController *reply = [[ClassReplyDetailController alloc] init];
            reply.delegate = self;
            reply.circleModel = circleModel;
            reply.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:reply animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 获取密钥
- (void)getCKey
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getKey"];
    [param setObject:@"parent" forKey:@"from"];
    [param setObject:manager.userInfo.class_id forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"token"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getKeyFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf getKeyFinish:NO Data:nil];
    }];
}

- (void)getKeyFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    if (!suc) {
        NSString *str = [result valueForKey:@"ret_msg"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        //用户数据处理
        id ret_data = [result valueForKey:@"ret_data"];
        if ([ret_data isKindOfClass:[NSNull class]]) {
            ret_data = [ret_data lastObject];
        }
        
        NSString *value = [ret_data valueForKey:@"key"];
        DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
        NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/Home/kq/classKqIndex/key/%@/isTeacher/0/type/1.html",value];
        order.url = url;
        order.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:order animated:YES];
    }
}

@end
