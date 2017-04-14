//
//  SchoolYardViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/20.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SchoolYardViewController.h"
#import "SchoolYardCell.h"
#import "UIButton+WebCache.h"
#import "MyCalendarViewController.h"
#import "GrowAlbumViewController.h"
#import "NotificationListViewController.h"
#import "CookbookViewController.h"
#import "PersonalInfoViewController.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "BabyMileageViewController.h"
#import "DJTOrderViewController.h"
#import "ChannelListViewController.h"
#import "NSString+Common.h"
#import "EditFamilyViewController.h"

@interface SchoolYardViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    UICollectionView *_collectionView;
    UIButton *_headerBtn;
    NSMutableArray *_dataArray;
}

@end

@implementation SchoolYardViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_USER_HEADER object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader:) name:CHANGE_USER_HEADER object:nil];
    
    [self initData];
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIImage *headImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"gn1" ofType:@"png"]];
    CGFloat imageViewHei = headImg.size.height / headImg.size.width  * self.view.frame.size.width;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWei = 60,itemHei = 85;
    CGFloat margin = (winSize.width - 4 * itemWei) / (4 + 1);
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, 10, margin);
    layout.headerReferenceSize = CGSizeMake(winSize.width, imageViewHei + 30);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[SchoolYardCell class] forCellWithReuseIdentifier:@"SchoolYardCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SchoolYardCellHeader"];
    [self.view addSubview:_collectionView];
}

- (void)initData{
    _dataArray = [[NSMutableArray alloc] initWithCapacity:10];
    if ([DJTGlobalManager shareInstance].userInfo.button.count > 0) {
        [_dataArray addObjectsFromArray:[DJTGlobalManager shareInstance].userInfo.button];
    }
    else{
        NSArray *titleArray = @[@"考勤请假",@"宝宝里程",@"成长档案",@"家园联系",@"园所通知",@"每日食谱"];
        NSArray *imgArray = @[@"gn2.png",@"gn3.png",@"gn4.png",@"gn6.png",@"gn10.png",@"gn8.png"];
        NSArray *keyArray = @[@"attence",@"mileage",@"grow",@"card",@"message",@"recipes"];
        for (int i = 0 ; i < [titleArray count]; i++) {
            DJTButton *model = [[DJTButton alloc]init];
            model.fromDef = YES;
            model.b_key = keyArray[i];
            model.b_name = titleArray[i];
            model.b_picture = imgArray[i];
            [_dataArray addObject:model];
        }
    }
}

- (void)refreshHeader:(NSNotification *)notifi
{
    [_headerBtn setImageWithURL:[NSURL URLWithString:[DJTGlobalManager shareInstance].userInfo.face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
}

- (void) pushToDetail:(UIButton *)sender{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.childrens.count <= 1) {
        [self.view makeToast:@"您只关联了一个孩子!" duration:1.0 position:@"center"];
        return;
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popSelectedChildrenView];
}

- (void)checkPersonInfo:(id)sender
{
    PersonalInfoViewController *person = [[PersonalInfoViewController alloc] init];
    person.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:person animated:YES];
}

#pragma mark - 视眼
- (void)checkThirdAPI:(NSArray *)powers
{
    [self.view makeToastActivity];
    self.tabBarController.view.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int initLib = API_InitLibInstance();
        if (initLib < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tabBarController.view.userInteractionEnabled = YES;
                [weakSelf.view hideToastActivity];
                [weakSelf.view makeToast:@"视眼初始化异常，请联系园所管理员" duration:1.0 position:@"center"];
            });
        }
        else{
            DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
            if (user.device_ip.length <= 0 ||
                user.device_account.length <= 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.tabBarController.view.userInteractionEnabled = YES;
                    [weakSelf.view hideToastActivity];
                    [weakSelf.view makeToast:@"视眼暂时失明，请联系园所管理员" duration:1.0 position:@"center"];
                });
                return ;
            }
            const char *ip = [user.device_ip cStringUsingEncoding:NSUTF8StringEncoding];
            int port = user.device_port.intValue;
            const char *usr = [user.device_account cStringUsingEncoding:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingGB_18030_2000)];
            const char *pwd = [user.device_pwd cStringUsingEncoding:NSUTF8StringEncoding];
            if (API_RequestLogin(ip, port, usr, pwd) < 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.tabBarController.view.userInteractionEnabled = YES;
                    [weakSelf.view hideToastActivity];
                    [weakSelf.view makeToast:@"视眼暂时失明，请联系园所管理员" duration:1.0 position:@"center"];
                });
            }
            else{
                int i;
                int everyArrayNum[3];
                int CamStatusArray[MAX_NODE_NUM];       //存储节点状态:是否摄像头，是否在线
                int SWinStatusArray[MAX_INPUT_IO_NUM];
                int SWoutStatusArray[MAX_OUTPUT_IO_NUM];
                
                char **CamStrArray;
                CamStrArray = (char **)malloc(MAX_NODE_NUM * sizeof(char *));
                for(i = 0; i < MAX_NODE_NUM; i++){
                    CamStrArray[i] = (char *)malloc(64 * sizeof(char));
                }
                
                API_GetDeviceList(everyArrayNum, CamStatusArray, SWinStatusArray, SWoutStatusArray, CamStrArray);
                NSMutableArray *videoArr = [NSMutableArray array];
                for (i = 0; i < everyArrayNum[0]; i++) {
                    NSString *stringName =  [NSString stringWithCString:CamStrArray[i] encoding:NSUTF8StringEncoding];
                    if ([stringName hasPrefix:@"["] && [stringName hasSuffix:@"]"]) {
                        stringName = [[stringName substringToIndex:stringName.length - 1] substringFromIndex:1];
                    }
                    ChannelModel *model = [[ChannelModel alloc] init];
                    model.name = stringName;
                    model.nodeIdx = CamStatusArray[i];
                    [videoArr addObject:model];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.tabBarController.view.userInteractionEnabled = YES;
                    [weakSelf.view hideToastActivity];
                    ChannelListViewController *channelist = [[ChannelListViewController alloc] init];
                    channelist.powerList = powers;
                    channelist.deviceList = videoArr;
                    channelist.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:channelist animated:YES];
                });
                
            }
        }
    });
}

#pragma mark - 园所视眼开放权限接口
- (void)getOpenPower
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    DJTUser *user = [manager userInfo];
    NSMutableDictionary *dic = [manager requestinitParamsWith:@"getMonitorList"];
    [dic setObject:user.school_id forKey:@"school_id"];
    [dic setObject:@"1" forKey:@"type"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    self.tabBarController.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"monitor"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getOpenPowerFinish:success Data:data];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getOpenPowerFinish:NO Data:nil];
        });
    }];
}

- (void)getOpenPowerFinish:(BOOL)success Data:(id)result
{
    self.httpOperation = nil;
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            NSMutableArray *powerArr = [PowerOpen arrayOfModelsFromDictionaries:ret_data error:nil];
            if (!powerArr || ([powerArr count] == 0)) {
                self.tabBarController.view.userInteractionEnabled = YES;
                [self.view hideToastActivity];
                [self.view makeToast:@"该园所暂未开放园所视眼权限" duration:1.0 position:@"center"];
            }
            else{
                [self checkThirdAPI:powerArr];
            }
        }else{
            self.tabBarController.view.userInteractionEnabled = YES;
            [self.view hideToastActivity];
            [self.view makeToast:@"该园所暂未开放园所视眼权限" duration:1.0 position:@"center"];
        }
    }
    else
    {
        self.tabBarController.view.userInteractionEnabled = YES;
        [self.view hideToastActivity];
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
}

#pragma mark - 头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SchoolYardCellHeader" forIndexPath:indexPath];
    
    UIImage *headImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"gn1" ofType:@"png"]];
    CGFloat imageViewHei = headImg.size.height / headImg.size.width  * self.view.frame.size.width;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, imageViewHei)];
    imageView.image = headImg;
    [view addSubview:imageView];
    
    UILabel *schLab = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.size.width - 155, imageView.frame.size.height - 25, 150, 20)];
    schLab.text = [DJTGlobalManager shareInstance].userInfo.school_name;
    schLab.font = [UIFont systemFontOfSize:14];
    schLab.textAlignment = 2;
    schLab.backgroundColor = [UIColor clearColor];
    schLab.textColor = [UIColor whiteColor];
    [view addSubview:schLab];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    UIButton *headerView = [UIButton buttonWithType:UIButtonTypeCustom];
    _headerBtn = headerView;
    [headerView setFrame:CGRectMake(30, imageView.frame.size.height - 30, 60, 60)];
    [headerView setImageWithURL:[NSURL URLWithString:user.face ?: @""] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    headerView.layer.masksToBounds = YES;
    headerView.layer.cornerRadius = 30;
    [headerView addTarget:self action:@selector(checkPersonInfo:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:headerView];
    
    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(headerView.frame.origin.x + headerView.frame.size.width +10, imageView.frame.origin.y + imageView.frame.size.height + 5, 80, 20)];
    nameLab.text = user.uname;
    CGSize bigSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: nameLab.font};
    bigSize = [user.uname sizeWithAttributes:attribute];
    nameLab.textAlignment = 1;
    nameLab.textColor = [UIColor blackColor];
    nameLab.frame = CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y, bigSize.width, nameLab.frame.size.height);
    [view addSubview:nameLab];
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(nameLab.frame.origin.x + nameLab.frame.size.width + 5 , nameLab.frame.origin.y, 24, 24);
    [but setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"gn11" ofType:@"png"]] forState:UIControlStateNormal];
    but.imageEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    but.layer.masksToBounds = YES;
    but.layer.cornerRadius = 12;
    [but addTarget:self action:@selector(pushToDetail:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:but];
    return view;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SchoolYardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SchoolYardCell" forIndexPath:indexPath];
    
    DJTButton *btnModel = _dataArray[indexPath.item];
    if (btnModel.fromDef) {
        [cell.faceImageView setImage:[UIImage imageNamed:btnModel.b_picture]];
    }
    else{
        [cell.faceImageView setImageWithURL:[NSURL URLWithString:btnModel.b_picture]];
    }
    cell.nameLabel.text = btnModel.b_name;

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DJTButton *model = [_dataArray objectAtIndex:indexPath.item];
    NSString *b_key = model.b_key;

    if ([b_key isEqualToString:@"attence"]) {
        //考勤请假
        [self getCKey:1];
//        MyCalendarViewController *myCalendar = [[MyCalendarViewController alloc]init];
//        myCalendar.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:myCalendar animated:YES];
    }else if ([b_key isEqualToString:@"mileage"]){
        //宝宝里程
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        MileagePhotoViewController *photo = [[MileagePhotoViewController alloc] init];
        photo.view.frame = CGRectMake(0, 155, winSize.width, winSize.height - 155 - 64);
        MileageViewController *mileage = [[MileageViewController alloc] init];
        mileage.nInitIdx = 0;
        mileage.view.frame = photo.view.frame;
        
        BabyMileageViewController *baby = [[BabyMileageViewController alloc] initWithControls:@[mileage,photo] Titles:@[@"里程",@"相册"] Frame:CGRectMake(0, 120, winSize.width, 35)];
        baby.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:baby animated:YES];
    }else if ([b_key isEqualToString:@"grow"]){
        //成长档案
        GrowAlbumViewController *grow = [[GrowAlbumViewController alloc]init];
        grow.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:grow animated:YES];
    }else if ([b_key isEqualToString:@"card"]){
        //家园联系
        EditFamilyViewController *home = [[EditFamilyViewController alloc]init];
        home.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else if ([b_key isEqualToString:@"message"]){
        //园所通知
        NotificationListViewController *notif = [[NotificationListViewController alloc]init];
        notif.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:notif animated:YES];
    }else if ([b_key isEqualToString:@"recipes"]){
        //每日食谱
        [self getCKey:2];
//        CookbookViewController *cookbook = [[CookbookViewController alloc] init];
//        cookbook.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:cookbook animated:YES];
    }else if ([b_key isEqualToString:@"monitor"]){
        //视频监控
        [self getOpenPower];
    }else{
        if ([model.type isEqualToString:@"2"]) {
            DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
            order.url = model.b_url;
            order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:order animated:YES];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
}

- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 1;
}

#pragma mark - 获取密钥
- (void)getCKey:(NSInteger)type
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
        [weakSelf getKeyFinish:success Data:data Type:type];
    } failedBlock:^(NSString *description) {
        [weakSelf getKeyFinish:NO Data:nil Type:type];
    }];
}

- (void)getKeyFinish:(BOOL)suc Data:(id)result Type:(NSInteger)type
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
        switch (type - 1) {
            case 0:
            {
                DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
                NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/Home/kq/classKqIndex/key/%@/isTeacher/0/type/1.html",value];
                order.url = url;
                order.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:order animated:YES];
            }
                break;
            case 1:
            {
                DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
                NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/dailydiet/recipesIndex/key/%@/from/parent.html",value];
                order.url = url;
                order.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:order animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}

@end
