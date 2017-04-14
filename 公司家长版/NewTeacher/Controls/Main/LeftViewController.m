//
//  LeftViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/24.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "LeftViewController.h"
#import "YQSlideMenuController.h"
#import "DJTGlobalManager.h"
#import "MyTableBarViewController.h"
#import "GrowAlbumViewController.h"
#import "BabyMileageViewController.h"
#import "NotificationListViewController.h"
#import "MyCalendarViewController.h"
#import "MainViewController1.h"
#import "UIButton+WebCache.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "PhoneAllEditView.h"
#import "SchoolInfoViewController.h"
#import "EditFamilyViewController.h"
#import "DJTOrderViewController.h"
#import "NSString+Common.h"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate,PhoneAllEditViewDelegate>

@end

@implementation LeftViewController
{
    UITableView *_tableView;
    UIButton *_headImg;
    
    PhoneAllEditView *_phoneEditView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_USER_HEADER object:nil];
}

#pragma mark -尾视图
- (UIView *)setFootView:(UIView *)footView{
    footView.backgroundColor = [UIColor clearColor];
    UIButton *vacateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    vacateButton.frame=CGRectMake(40, 5, 200, 40);
    vacateButton.backgroundColor=CreateColor(201, 184, 170);
    [vacateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [vacateButton setTitle:@"请 假" forState:UIControlStateNormal];
    vacateButton.layer.cornerRadius=20;
    vacateButton.layer.borderColor = [UIColor whiteColor].CGColor;
    vacateButton.layer.borderWidth = 1.0;
    vacateButton.layer.masksToBounds=YES;
    [vacateButton addTarget:self action:@selector(telToteacher) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:vacateButton];
    
    return footView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader:) name:CHANGE_USER_HEADER object:nil];
    
    //back
    UIImageView *backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backView.clipsToBounds = YES;
    backView.contentMode = UIViewContentModeScaleAspectFill;
    [backView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s28@2x" ofType:@"png"]]];
    [self.view addSubview:backView];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollEnabled = YES;
    //footView
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 300, SCREEN_WIDTH, 100)];
    [_tableView setTableFooterView:[self setFootView:footView]];
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    //header
    CGFloat yOri = 20;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80 + yOri)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    
    _headImg = [UIButton buttonWithType:UIButtonTypeCustom];
    _headImg .frame =CGRectMake(10, 15 + yOri, 50, 50);
    _headImg.layer.masksToBounds = YES;
    _headImg.layer.cornerRadius = 25;
    [_headImg setImageWithURL:[NSURL URLWithString:user.face ?: @""] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    [_headImg addTarget:self action:@selector(sendNoti:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_headImg];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(70, 15 + yOri, 100, 20)];
    [button setTitle:user.realname forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(sendNoti:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    
    if ([user.school_name length] != 0) {
        CGSize lastSize = CGSizeZero;
        CGFloat wei = [UIScreen mainScreen].bounds.size.width - 70 - 70;
        UIFont *font = [UIFont systemFontOfSize:18];
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [user.school_name boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        UILabel *schoolLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 15 + 24 + yOri, wei, MIN(lastSize.height, 43))];
        [schoolLab setTextColor:[UIColor yellowColor]];
        [schoolLab setFont:font];
        [schoolLab setNumberOfLines:2];
        [schoolLab setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview:schoolLab];
        [schoolLab setText:user.school_name];
    }

    [_tableView setTableHeaderView:headerView];
}

- (void)sendNoti:(id)sender
{
    YQSlideMenuController *deckController = (YQSlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [deckController hideMenu];
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            Class toClass = [SchoolInfoViewController class];
            MyTableBarViewController *tabBarCon = (MyTableBarViewController *)deckController.contentViewController;
            UINavigationController *nav = (UINavigationController *)tabBarCon.selectedViewController;
            BOOL hasFound = NO;
            UIViewController *toCon = nil;
            //判断是否在当前堆栈中
            for (UIViewController *subCon in nav.viewControllers) {
                if ([subCon isKindOfClass:toClass]){
                    hasFound = YES;
                    toCon = subCon;
                    break;
                }
            }
            if (!hasFound) {
                //未在当前堆栈中找到该类
                toCon = [[toClass alloc] init];
                toCon.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:toCon animated:YES];
            }
            else
            {
                //在当前堆栈中，且不是栈顶
                if (![nav.topViewController isKindOfClass:toClass]) {
                    [nav popToViewController:toCon animated:YES];
                }
                
            }
        });
    });
}

- (void)refreshHeader:(NSNotification *)notifi
{
    [_headImg setImageWithURL:[NSURL URLWithString:[DJTGlobalManager shareInstance].userInfo.face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *leftIdentifierBase = @"leftCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:leftIdentifierBase];
    if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftIdentifierBase];
            
            //imageView
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9, 32, 32)];
            [imageView setBackgroundColor:[UIColor clearColor]];
            [imageView setTag:1];
            [cell.contentView addSubview:imageView];
            
            //title sup
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 9, imageView.frame.origin.y, 250, 20)];
            [label setFont:[UIFont systemFontOfSize:18]];
            [label setTextColor:[UIColor blackColor]];
            [label setBackgroundColor:[UIColor clearColor]];
            label.highlightedTextColor = [UIColor whiteColor];
            [label setTag:2];
            [cell.contentView addSubview:label];
            
            //title sub
            label = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y + label.frame.size.height, 250, 14)];
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setTextColor:[UIColor darkGrayColor]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTag:3];
            [cell.contentView addSubview:label];
        }
        //cell.selectionStyle=UITableViewCellSelectionStyleNone;
        NSArray *topTitles = @[@"每日考勤",@"宝宝里程",@"成长档案",@"家园联系",@"通知"];
        NSArray *tipTitles = @[@"记录孩子每天考勤信息",@"来看看宝贝的照片吧~",@"来看看宝贝的成长档案吧~",@"家园共育",@"点击查看园所通知"];
        NSArray *imgs = @[@"s22@2x.png",@"s23@2x.png",@"s24@2x.png",@"s26@2x.png",@"s27@2x.png"];
        
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
        [imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgs[indexPath.row] ofType:nil]]];
        
        UILabel *supTitle = (UILabel *)[cell.contentView viewWithTag:2];
        [supTitle setText:topTitles[indexPath.row]];
        
        UILabel *subTitle = (UILabel *)[cell.contentView viewWithTag:3];
        [subTitle setText:tipTitles[indexPath.row]];
        
        return cell;
}

- (void)telToteacher{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSArray *dataArray = manager.userInfo.teacher_datas;
    if (!dataArray || [dataArray count] <= 0) {
        [self.view makeToast:@"没有关联相关老师" duration:1.0 position:@"center"];
        return;
    }
    if (_phoneEditView) {
        [_phoneEditView removeFromSuperview];
    }
    _phoneEditView = [[PhoneAllEditView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _phoneEditView.delegate = self;
    [_phoneEditView showInView:self.view.window];
}

#pragma mark - PhoneAllEditView delegate
- (void)selectEditIndex:(NSString *)phone
{
    if (phone && [phone length] > 0) {
        UIWebView*callWebview =[[UIWebView alloc] init];
        NSString *url = [NSString stringWithFormat:@"tel:%@",phone];
        NSURL *telURL = [NSURL URLWithString:url];// 貌似tel:// 或者 tel: 都行
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        //记得添加到view上
        [self.view addSubview:callWebview];
    }else{
        [self.view makeToast:@"老师没有登记手机号码" duration:1.0 position:@"center"];
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
        
        YQSlideMenuController *deckController = (YQSlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [deckController hideMenu];
        
        double delayInSeconds = 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                Class toClass = [DJTOrderViewController class];
                if (!toClass) {
                    return;
                }
                MyTableBarViewController *tabBarCon = (MyTableBarViewController *)deckController.contentViewController;
                UINavigationController *nav = (UINavigationController *)tabBarCon.selectedViewController;
                BOOL hasFound = NO;
                UIViewController *toCon = nil;
                //判断是否在当前堆栈中
                for (UIViewController *subCon in nav.viewControllers) {
                    if ([subCon isKindOfClass:toClass]){
                        hasFound = YES;
                        toCon = subCon;
                        break;
                    }
                }
                if (!hasFound) {
                    //未在当前堆栈中找到该类
                    toCon = [[toClass alloc] init];
                    NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/Home/kq/classKqIndex/key/%@/isTeacher/0/type/1.html",value];
                    ((DJTOrderViewController *)toCon).url = url;
                    toCon.hidesBottomBarWhenPushed = YES;
                    [nav pushViewController:toCon animated:YES];
                }
                else
                {
                    //在当前堆栈中，且不是栈顶
                    if (![nav.topViewController isKindOfClass:toClass]) {
                        [nav popToViewController:toCon animated:YES];
                    }
                    
                }
            });
        });
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    if (indexPath.row == 0) {
        [self getCKey];
    }
    else {
        YQSlideMenuController *deckController = (YQSlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [deckController hideMenu];
        
        double delayInSeconds = 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                Class toClass = nil;
                switch (indexPath.row - 1) {
                    case 0:
                    {
                        toClass = [BabyMileageViewController class];
                    }
                        break;
                    case 1:
                    {
                        toClass = [GrowAlbumViewController class];
                    }
                        break;
                    case 2:
                    {
                        toClass = [EditFamilyViewController class];
                    }
                        break;
                    case 3:
                    {
                        toClass = [NotificationListViewController class];
                    }
                        break;
                    default:
                        break;
                }
                
                if (!toClass) {
                    return;
                }
                MyTableBarViewController *tabBarCon = (MyTableBarViewController *)deckController.contentViewController;
                UINavigationController *nav = (UINavigationController *)tabBarCon.selectedViewController;
                BOOL hasFound = NO;
                UIViewController *toCon = nil;
                //判断是否在当前堆栈中
                for (UIViewController *subCon in nav.viewControllers) {
                    if ([subCon isKindOfClass:toClass]){
                        hasFound = YES;
                        toCon = subCon;
                        break;
                    }
                }
                if (!hasFound) {
                    //未在当前堆栈中找到该类
                    if (toClass == [BabyMileageViewController class]) {
                        CGSize winSize = [UIScreen mainScreen].bounds.size;
                        MileagePhotoViewController *photo = [[MileagePhotoViewController alloc] init];
                        photo.view.frame = CGRectMake(0, 155, winSize.width, winSize.height - 155 - 64);
                        MileageViewController *mileage = [[MileageViewController alloc] init];
                        mileage.nInitIdx = 0;
                        mileage.view.frame = photo.view.frame;
                        
                        toCon = [[BabyMileageViewController alloc] initWithControls:@[mileage,photo] Titles:@[@"里程",@"相册"] Frame:CGRectMake(0, 120, winSize.width, 35)];
                    }
                    else{
                        toCon = [[toClass alloc] init];
                    }
                    toCon.hidesBottomBarWhenPushed = YES;
                    [nav pushViewController:toCon animated:YES];
                }
                else
                {
                    //在当前堆栈中，且不是栈顶
                    if (![nav.topViewController isKindOfClass:toClass]) {
                        [nav popToViewController:toCon animated:YES];
                    }
                    
                }
            });
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<6) {
        return 55;
    }else{
        return 120;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

@end
