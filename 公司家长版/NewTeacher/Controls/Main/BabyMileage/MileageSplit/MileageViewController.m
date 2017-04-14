//
//  MileageViewController.m
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageViewController.h"
#import "SelectChannelView2.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "MileageListViewCell.h"
#import "MileageAllEditView.h"
#import "AddThemeViewController.h"
#import "UIImage+Caption.h"
#import "TeacherManagerViewController.h"
#import "SystemThemeManagerController.h"
#import "ThemeDetailViewController.h"
#import "DJTGlobalManager.h"

@interface MileageViewController ()<MileageListViewCellDelegate,MileageAllEditViewDelegate,UIAlertViewDelegate,ThemeDetailViewControllerDelegate>

@end

@implementation MileageViewController
{
    NSInteger _pageCount,_pageIdx;
    NSMutableDictionary *_dataDic;
    NSArray *_types;
    BOOL _lastPage,_refresh;
    NSIndexPath *_indexPath;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_LICHENT object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageCount = 10;
    _pageIdx = 1;
    _dataDic = [NSMutableDictionary dictionary];
    _types = @[@"0",@"1",@"3",@"2"];
    
    self.useNewInterface = YES;
    [self createTableViewAndRequestAction:@"photo" Param:nil Header:YES Foot:YES];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    SelectChannelView2 *channelView = [[SelectChannelView2 alloc] initWithFrame:CGRectMake((footView.frame.size.width - 200)/ 2, 0, 200, 35) TitleArray:@[@"全部",@"家长",@"推荐",@"班级"]];//●
    [channelView setTag:10];
    channelView.nCurIdx = _nInitIdx;
    __weak typeof(self)weakSelf = self;
    channelView.selectBlock = ^(NSInteger index){
        [weakSelf refreshByType:index];
    };
    [footView addSubview:channelView];
    [_tableView setTableHeaderView:footView];
    [_tableView setBackgroundColor:CreateColor(238, 238, 235)];
    
    [self beginRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshThisList:) name:REFRESH_LICHENT object:nil];
}

- (void)refreshByType:(NSInteger)index
{
    if (self.httpOperation) {
        [self.httpOperation cancel];
    }
    
    id history = [_dataDic valueForKey:_types[index]];
    if (history && [history count] > 0) {
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
        
        self.dataSource = history;
        
        [self createTableFooterView];
        [_tableView reloadData];
    }
    else{
        if (self.isRefreshing) {
            [self startPullRefresh];
        }else{
            [self beginRefresh];
        }
    }
}

- (void)refreshThisList:(NSNotification *)notifi
{
    _refresh = YES;
}

- (void)createTableFooterView{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 170)];
        [headView setBackgroundColor:_tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imgView.frame.origin.y + imgView.frame.size.height + 10, winSize.width - 10, 30)];
        [label setText:@"暂时还没有创建里程主题哦!"];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setBackgroundColor:_tableView.backgroundColor];
        [label setTextAlignment:1];
        [headView addSubview:label];
        
        [_tableView setTableFooterView:headView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_refresh) {
        _refresh = NO;
        [self beginRefresh];
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMileageList"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    SelectChannelView *channelView = (SelectChannelView *)[_tableView.tableHeaderView viewWithTag:10];
    [param setObject:_types[channelView.nCurIdx] forKey:@"type"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
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
    BOOL shouldContinue = self.httpOperation.isCancelled;
    [super requestFinish:success Data:result];
    
    if (shouldContinue) {
        return;
    }
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error;
            MileageModel *mileage = [[MileageModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [mileage caculateNameHei];
            [array addObject:mileage];
        }
        
        self.dataSource = array;
        
        SelectChannelView *channelView = (SelectChannelView *)[_tableView.tableHeaderView viewWithTag:10];
        if (array.count > 0) {
            [_dataDic setObject:array forKey:_types[channelView.nCurIdx]];
        }
        else{
            [_dataDic removeObjectForKey:_types[channelView.nCurIdx]];
        }
    }
    else{
        self.dataSource = nil;
    }
    [self createTableFooterView];
    [_tableView reloadData];
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    BOOL shouldContinue = self.httpOperation.isCancelled;
    [super requestFinish2:success Data:result];
    
    if (shouldContinue) {
        return;
    }
    
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
            MileageModel *mileage = [[MileageModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [mileage caculateNameHei];
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

#pragma mark - ThemeDetailViewControllerDelegate
- (void)deleteThisBatch
{
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        [self.parentViewController.navigationController popToViewController:self.parentViewController animated:YES];
    }
    else if ([self.parentViewController.parentViewController isKindOfClass:[MileageBaseViewController class]])
    {
        [self.parentViewController.parentViewController.navigationController popToViewController:self.parentViewController.parentViewController animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_LICHENT object:nil];
}

#pragma mark - MileageListViewCellDelegate
- (void)beginEditMileageName:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _indexPath = indexPath;
    
    MileageAllEditView *editView = [[MileageAllEditView alloc] initWithFrame:[UIScreen mainScreen].bounds Titles:@[@"修改",@"删除"] NImageNames:@[@"themeChangeN",@"mileage_delete@2x"] HImageNames:@[@"themeChangeH",@"mileage_delete_1@2x"]];
    editView.delegate = self;
    [editView showInView:self.view.window];
}

- (void)selectMileageImage:(UITableViewCell *)cell At:(NSInteger)index
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    MileageModel *model = self.dataSource[indexPath.section];
    MileagePhotoItem *item = [model.photo objectAtIndex:index];
    ThemeBatchModel *batchModel = [[ThemeBatchModel alloc] init];
    batchModel.batch_id = item.batch_id;
    batchModel.album_id = model.album_id;
    batchModel.userid = item.userid;
    batchModel.photos = (NSArray<ThemeBatchItem> *)@[item];
    
    ThemeDetailViewController *detail = [[ThemeDetailViewController alloc] init];
    detail.themeBatch = batchModel;
    detail.titleLable.text = model.name;
    detail.delegate = self;
    [self.parentViewController.navigationController pushViewController:detail animated:YES];
}

- (void)touchColorLump:(UITableViewCell *)cell
{
    _indexPath = [_tableView indexPathForCell:cell];
    MileageModel *model = self.dataSource[_indexPath.section];
    [self checkMileage:model Lump:YES];
}

- (void)touchRightBlock:(UITableViewCell *)cell
{
    _indexPath = [_tableView indexPathForCell:cell];
    MileageModel *model = self.dataSource[_indexPath.section];
    [self checkMileage:model Lump:NO];
}

- (void)checkMileage:(MileageModel *)model Lump:(BOOL)colorLump
{
    switch ([model.mileage_type integerValue]) {
        case 0:
        {
            //全部
        }
            break;
        case 1:
        {
            //我的
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            MyThemeViewController *my = [[MyThemeViewController alloc] init];
            my.view.frame = CGRectMake(0, 30, winSize.width, winSize.height - 30 - 64);
            my.mileage = model;
            ClassmateViewController *classmate = [[ClassmateViewController alloc] init];
            classmate.view.frame = my.view.frame;
            classmate.mileage = model;
            FindPeopleViewController *find = [[FindPeopleViewController alloc] init];
            find.view.frame = my.view.frame;
            find.mileage = model;
            MyThemeManagerController *manager = [[MyThemeManagerController alloc] initWithControls:@[my,classmate,find] Titles:@[@"我的",@"同学",@"发现"] Frame:CGRectMake(0, 0, winSize.width, 30)];
            manager.titleLable.text = model.name;
            manager.indexModel = model;
            [self.parentViewController.navigationController pushViewController:manager animated:YES];
        }
            break;
        case 2:
        {
            //班级
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            TeacherMyViewController *my = [[TeacherMyViewController alloc] init];
            my.view.frame = CGRectMake(0, 30, winSize.width, winSize.height - 30 - 64);
            my.mileage = model;
            TeacherClassViewController *classc = [[TeacherClassViewController alloc] init];
            classc.mileage = model;
            classc.view.frame = my.view.frame;
            TeacherClassmateViewController *classmate = [[TeacherClassmateViewController alloc] init];
            classmate.mileage = model;
            classmate.view.frame = my.view.frame;
            TeacherManagerViewController *manager = [[TeacherManagerViewController alloc] initWithControls:@[my,classc,classmate] Titles:@[@"我的",@"班级",@"同学"] Frame:CGRectMake(0, 0, winSize.width, 30)];
            NSInteger idx = colorLump ? 1 : 0;
            if (!colorLump && ([model.photo count] > 0)) {
                MileagePhotoItem *firstPhoto = model.photo[0];
                if (firstPhoto.is_teacher.integerValue == 1) {
                    idx = 1;
                }
                else{
                    //待增加同学后处理,增加后1改为2
                    idx = [[DJTGlobalManager shareInstance].userInfo.userid isEqualToString:firstPhoto.userid] ? 0 : 2;
                }
            }
            manager.initIdx = idx;
            manager.indexModel = model;
            manager.titleLable.text = model.name;
            [self.parentViewController.navigationController pushViewController:manager animated:YES];
        }
            break;
        case 3:
        {
            //系统
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            SystemMyViewController *my = [[SystemMyViewController alloc] init];
            my.view.frame = CGRectMake(0, 30, winSize.width, winSize.height - 30 - 64);
            my.mileage = model;
            SystemClassmateViewController *classmate = [[SystemClassmateViewController alloc] init];
            classmate.mileage = model;
            classmate.view.frame = my.view.frame;
            SystemClassViewController *classc = [[SystemClassViewController alloc] init];
            classc.mileage = model;
            classc.view.frame = my.view.frame;
            SystemFindViewController *find = [[SystemFindViewController alloc] init];
            find.mileage = model;
            find.view.frame = my.view.frame;
            SystemThemeManagerController *manager = [[SystemThemeManagerController alloc] initWithControls:@[my,classc,classmate,find] Titles:@[@"我的",@"班级",@"同学",@"发现"] Frame:CGRectMake(0, 0, winSize.width, 30)];
            manager.indexModel = model;
            NSInteger idx = 0;
            if (!colorLump && ([model.photo count] > 0)) {
                MileagePhotoItem *firstPhoto = model.photo[0];
                if (firstPhoto.is_teacher.integerValue == 1) {
                    idx = 1;
                }
                else{
                    idx = [[DJTGlobalManager shareInstance].userInfo.userid isEqualToString:firstPhoto.userid] ? 0 : 2;
                }
            }
            manager.initIdx = idx;
            manager.titleLable.text = model.name;
            [self.parentViewController.navigationController pushViewController:manager animated:YES];
        }
            break;
        default:
            break;
    }
}


#pragma mark - MileageAllEditViewDelegate
- (void)selectEditIndex:(NSInteger)index
{
    MileageModel *model = self.dataSource[_indexPath.section];
    if (index == 1) {
        //delete
        if ([model.photo count] <= 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除当前主题吗？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
            [alertView show];
        }else {
            [self.parentViewController.navigationController.view makeToast:@"主题有内容不能删除" duration:1.0 position:@"center"];
        }
        
    }else if (index == 0){
        //edit
        AddThemeViewController *addTheme = [[AddThemeViewController alloc] init];
        addTheme.themeType = MileageThemeEdit;
        addTheme.mileage = model;
        addTheme.delegate = self;
        [self.parentViewController.navigationController pushViewController:addTheme animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteTheme:self.dataSource[_indexPath.section]];
    }
}

#pragma mark - 删除主题
- (void)deleteTheme:(MileageModel *)model {
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    
    NSMutableDictionary *param = [manager requestinitParamsWith:@"deleteAlbum"];
    [param setObject:model.album_id forKey:@"album_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.parentViewController.view makeToastActivity];
    [self.parentViewController.view setUserInteractionEnabled:NO];
    //针对新接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"photo"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf deleteFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf deleteFinish:NO Data:nil];
    }];
}

- (void)deleteFinish:(BOOL)success Data:(id)result
{
    [self.parentViewController.view hideToastActivity];
    [self.parentViewController.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    
    if (success) {
        MileageModel *model  = self.dataSource[_indexPath.section];
        [self.dataSource removeObjectAtIndex:[_indexPath section]];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:_indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        SelectChannelView *channelView = (SelectChannelView *)[_tableView.tableHeaderView viewWithTag:10];
        [_dataDic setObject:self.dataSource forKey:_types[channelView.nCurIdx]];
        if (channelView.nCurIdx == 1) {
            NSArray *array0 = [_dataDic valueForKey:_types[0]];
            if (array0) {
                NSMutableArray *newArr0 = [NSMutableArray arrayWithArray:array0];
                for (MileageModel *item in newArr0) {
                    if ([item.album_id isEqualToString:model.album_id]) {
                        [newArr0 removeObject:item];
                        break;
                    }
                }
                [_dataDic setObject:newArr0 forKey:_types[0]];
            }
        }
        else{
            NSArray *array1 = [_dataDic valueForKey:_types[1]];
            if (array1) {
                NSMutableArray *newArr1 = [NSMutableArray arrayWithArray:array1];
                for (MileageModel *item in newArr1) {
                    if ([item.album_id isEqualToString:model.album_id]) {
                        [newArr1 removeObject:item];
                        break;
                    }
                }
                [_dataDic setObject:newArr1 forKey:_types[1]];
            }
        }
        [self createTableFooterView];
    }
    else{
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.parentViewController.navigationController.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - AddThemeViewControllerDelegate
- (void)editThemeFinish
{
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:_indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addNewTheme:(MileageModel *)model
{
    SelectChannelView *channelView = (SelectChannelView *)[_tableView.tableHeaderView viewWithTag:10];
    NSArray *array0 = [_dataDic valueForKey:_types[0]];
    if (!array0 && (channelView.nCurIdx != 0)) {
        //无选择时，进来刷新
    }
    else
    {
        NSMutableArray *newArr0 = [NSMutableArray arrayWithObject:model];
        if (array0) {
            [newArr0 addObjectsFromArray:array0];
        }
        [_dataDic setObject:newArr0 forKey:_types[0]];
    }
    
    NSArray *array1 = [_dataDic valueForKey:_types[1]];
    if (!array1 && (channelView.nCurIdx != 1)) {
        //无选择时，进来刷新
    }
    else
    {
        NSMutableArray *newArr1 = [NSMutableArray arrayWithObject:model];
        if (array1) {
            [newArr1 addObjectsFromArray:array1];
        }
        [_dataDic setObject:newArr1 forKey:_types[1]];
    }
    
    if (channelView.nCurIdx <= 1) {
        self.dataSource = [_dataDic valueForKey:_types[channelView.nCurIdx]];
        
        [self createTableFooterView];
        
        [_tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

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
    static NSString *mileageCell = @"mileageCellId";
    MileageListViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:mileageCell];
    if (cell == nil) {
        cell = [[MileageListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mileageCell];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    MileageModel *mileage = self.dataSource[indexPath.section];
    [cell resetDataSource:mileage];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MileageModel *mileage = self.dataSource[indexPath.section];
    if ([mileage.photo count] > 0) {
        NSInteger type = mileage.mileage_type.integerValue; //1（我的）  2（教师） 3（推荐）
        BOOL isMe = (type == 1);
        if (!isMe) {
            NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
            MileagePhotoItem *firstPhoto = mileage.photo[0];
            BOOL firstMe = (firstPhoto.is_teacher.integerValue == 0) && ([firstPhoto.userid isEqualToString:userId]);
            if (!firstMe) {
                return 70;
            }
        }
        
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat wei = (winSize.width - 30) / 3;
        return wei;
    }
    
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

@end
