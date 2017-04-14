//
//  PlayMileageListController.m
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "PlayMileageListController.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "MileagePlayModel.h"
#import "PlayMileageTableViewCell.h"
#import "CreatePlayMileageView.h"
#import "SelectMileageViewController.h"
#import "SelectPhotosMileageViewController.h"
#import "CreatePlayMileageViewController.h"
#import "GrowAlbumListItem.h"
#import "DJTOrderViewController.h"
#import "DJTShareView.h"

@interface PlayMileageListController ()<CreatePlayMileageViewDelegate,PlayMileageTableViewCellDelegate,DJTShareViewDelegate,UMSocialUIDelegate,UIAlertViewDelegate>

@end

@implementation PlayMileageListController
{
    NSInteger _pageCount,_pageIdx;
    BOOL _lastPage,_refresh;
    CreatePlayMileageView *_createMileageView;
    NSIndexPath *_indexPath;
    int _editType;
    UIImage *_shareImage;
    UIView *_fullView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"动态里程";
    _pageCount = 10;
    _pageIdx = 1;
    
    self.view.backgroundColor = CreateColor(221, 221, 221);
    
    [self createRightButton];
    
    self.useNewInterface = YES;
    [self createTableViewAndRequestAction:@"mileage" Param:nil Header:YES Foot:YES];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [self beginRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_refresh) {
        _refresh = NO;
        [self beginRefresh];
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

- (void)isRefresh
{
    _refresh = YES;
}

- (void)createTableFooterView{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 181)];
        [headView setBackgroundColor:_tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imgView.frame.origin.y + imgView.frame.size.height + 10, winSize.width - 10, 20)];
        [label setText:@"暂无内容"];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:[UIColor blackColor]];
        [label setBackgroundColor:_tableView.backgroundColor];
        [label setTextAlignment:1];
        [headView addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(label.frameX, label.frameBottom + 5, label.frameWidth, 16)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setText:@"快点击“＋”创建一个吧"];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setBackgroundColor:_tableView.backgroundColor];
        [headView addSubview:label];
        
        [_tableView setTableFooterView:headView];
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMileagePlay"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)createRightButton{
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"add_play_mileageN" ofType:@"png"]] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"add_play_mileageH" ofType:@"png"]] forState:UIControlStateHighlighted];
    [moreBtn addTarget:self action:@selector(addPlayMileage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)addPlayMileage:(id)sender
{
    self.view.userInteractionEnabled = NO;
    UIView *fullView = [[UIView alloc] initWithFrame:self.view.window.bounds];
    _fullView = fullView;
    [fullView setBackgroundColor:rgba(1, 1, 1, 0.5)];
    [self.view.window addSubview:fullView];
    
    _createMileageView = [[CreatePlayMileageView alloc] initWithFrame:CGRectMake(50, (SCREEN_HEIGHT - 292) / 2, SCREEN_WIDTH - 100, 292)];
    [_createMileageView setDelegate:self];
    [fullView addSubview:_createMileageView];
    
    [UIView animateWithDuration:0.1 animations:^{
        _createMileageView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        _createMileageView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark- CreatePlayMileageView delegate
- (void)selectCreateIndex:(NSInteger)type
{
    self.view.userInteractionEnabled = YES;
    [_fullView removeFromSuperview];
    if (type == 1) {
        SelectMileageViewController *mileageController = [[SelectMileageViewController alloc] init];
        [self.navigationController pushViewController:mileageController animated:YES];
    }else {
        SelectPhotosMileageViewController *photosController = [[SelectPhotosMileageViewController alloc] init];
        photosController.album_id = @"0";
        [self.navigationController pushViewController:photosController animated:YES];
    }
}

- (void)cancelToView:(CreatePlayMileageView *)view
{
    self.view.userInteractionEnabled = YES;
    [_fullView removeFromSuperview];
    [view removeFromSuperview];
    [self createTableFooterView];
}

- (void)startPullRefresh
{
    _pageIdx = 1;
    _lastPage = NO;
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
        if ([self.dataSource count] > 0) {
            _pageIdx++;
        }
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"data"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error;
            MileagePlayModel *mileage = [[MileagePlayModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:mileage];
        }
        
        self.dataSource = array;
    }
    else{
        self.dataSource = nil;
    }
    [self createTableFooterView];
    [_tableView reloadData];
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];

    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSMutableArray *array = [NSMutableArray array];
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        NSInteger count = [self.dataSource count];
        for (id subDic in data) {
            NSError *error;
            MileagePlayModel *mileage = [[MileagePlayModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:mileage];
            [set addIndex:count++];
        }
        
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        [self.dataSource addObjectsFromArray:array];
        [_tableView insertSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    else
    {
        if (_pageIdx > 1) {
            _pageIdx -= 1;
        }
    }
}

- (void)getPhotosRequest:(NSIndexPath *)indexPath
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    MileagePlayModel *model = [self.dataSource objectAtIndex:indexPath.section];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSString *methods = @"getMileagePlayById";
    NSMutableDictionary *param = [manager requestinitParamsWith:methods];
    [param setObject:model.id forKey:@"id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    //针对新接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"mileage"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getPlayFinish:success Data:data IndexPath:indexPath];
    } failedBlock:^(NSString *description) {
        [weakSelf getPlayFinish:NO Data:nil IndexPath:indexPath];
    }];
}

#pragma mark - network getMileagePlayById
- (void)getPlayFinish:(BOOL)suc Data:(id)result IndexPath:(NSIndexPath *)indexPath
{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    if (suc) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSArray *data = [ret_data valueForKey:@"detail"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSMutableArray *array = [NSMutableArray array];
        for (id subDic in data) {
            NSError *error;
            GrowAlbumListItem *mileage = [[GrowAlbumListItem alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:mileage];
        }
        if (_editType == 1) {
            MileagePlayModel *model = [self.dataSource objectAtIndex:indexPath.section];
            CreatePlayMileageViewController *createController = [[CreatePlayMileageViewController alloc] init];
            createController.album_id = model.album_id;
            createController.theme_id = model.id;
            createController.createType = 1;
            createController.selectDataArray = array;
            createController.editTitle = [ret_data valueForKey:@"title"];
            [self.navigationController pushViewController:createController animated:YES];
        }else {
            MileagePlayModel *model = [self.dataSource objectAtIndex:indexPath.section];
            SelectPhotosMileageViewController *photosController = [[SelectPhotosMileageViewController alloc] init];
            photosController.album_id = model.album_id;
            photosController.theme_id = model.id;
            photosController.editType = 2;
            photosController.otherArr = array;
            photosController.editTitle = [ret_data valueForKey:@"title"];
            [self.navigationController pushViewController:photosController animated:YES];
        }
    }
    else{
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
    }
}


#pragma mark - PlayMileageTableViewCell delegate
- (void)sharePlayMileage:(PlayMileageTableViewCell *)cell ShareImage:(UIImage *)image
{
    if (![DJTShareView isCanShareToOtherPlatform]) {
        [self.view.window makeToast:SHARE_TIP_INFO duration:1.0 position:@"center"];
        return;
    }
    _shareImage = image;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _indexPath = indexPath;
    DJTShareView *shareView = [[DJTShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [shareView setDelegate:self];
    [shareView showInView:self.view.window];
}

- (void)editPlayMileage:(PlayMileageTableViewCell *)cell
{
    _editType = 2;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [self getPhotosRequest:indexPath];
}

- (void)changePlayMileage:(PlayMileageTableViewCell *)cell
{
    _editType = 1;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [self getPhotosRequest:indexPath];
}

- (void)deletePlayMileage:(PlayMileageTableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _indexPath = indexPath;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除当前里程视频吗？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    [alertView show];
}

#pragma mark - network
- (void)deleteFinish:(BOOL)suc Data:(id)result
{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    if (suc) {
        [self.dataSource removeObjectAtIndex:_indexPath.section];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:_indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.navigationController.view makeToast:@"动态里程删除成功" duration:1.0 position:@"center"];
        _indexPath = nil;
    }
    else{
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - UIAlertView deleage
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
            [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            return;
        }
        
        MileagePlayModel *model = [self.dataSource objectAtIndex:_indexPath.section];
        
        __weak __typeof(self)weakSelf = self;
        
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        NSString *methods = @"deleteMileagePlay";
        NSMutableDictionary *param = [manager requestinitParamsWith:methods];
        [param setObject:model.id forKey:@"id"];
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
        [param setObject:text forKey:@"signature"];
        
        [self.view makeToastActivity];
        [self.view setUserInteractionEnabled:NO];
        //针对新接口
        NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"mileage"];
        self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf deleteFinish:success Data:data];
        } failedBlock:^(NSString *description) {
            [weakSelf deleteFinish:NO Data:nil];
        }];
    }
}

#pragma mark - DJTShareViewDelegate
- (void)shareViewTo:(NSInteger)index
{
    MileagePlayModel *model = [self.dataSource objectAtIndex:_indexPath.section];
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            
            NSString *shareType = nil;
            if (index == 0) {
                [UMSocialData defaultData].extConfig.wechatSessionData.title = @"童印里程分享";
                [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
                [UMSocialData defaultData].extConfig.wechatSessionData.url = model.url;
                shareType = UMShareToWechatSession;
            }
            else if (index == 1)
            {
                [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"童印里程分享";
                [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = model.url;
                shareType = UMShareToWechatTimeline;
            }
            else if (index == 2)
            {
                [UMSocialData defaultData].extConfig.qqData.title = @"童印里程分享";
                [UMSocialData defaultData].extConfig.qqData.url = model.url;
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
                shareType = UMShareToQQ;
            }
            else
            {
                [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeMusic url:model.url];
                shareType = UMShareToSina;
            }
            
            NSString *lastStr = [NSString stringWithFormat:@"我制作了“%@”，快来看看！",model.name];
            [[UMSocialControllerService defaultControllerService] setShareText:lastStr shareImage:_shareImage ?: CREATE_IMG(@"icon") socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:shareType].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        }
            break;
        case 4:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.url]];
        }
            break;
        case 5:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = model.url;
        }
            break;
        case 6:
        {
            //[_webView reload];
            NSLog(@"%@",model.url);
        }
            break;
        default:
            break;
    }
}

#pragma mark - UMSocialUIDelegate
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess) {
        NSLog(@"分享成功！");
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mileageCell = @"PlayMileageCellId";
    PlayMileageTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:mileageCell];
    if (cell == nil) {
        cell = [[PlayMileageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mileageCell];
        [cell setDelegate:self];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    MileagePlayModel *model = [self.dataSource objectAtIndex:indexPath.section];
    [cell resetDataSource:model];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MileagePlayModel *model = [self.dataSource objectAtIndex:indexPath.section];
    DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
    order.url = model.url ?: @"";
    [self.navigationController pushViewController:order animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}
@end
