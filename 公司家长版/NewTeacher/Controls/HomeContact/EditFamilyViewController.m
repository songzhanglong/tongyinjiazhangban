//
//  EditFamilyViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EditFamilyViewController.h"
#import "FamilyEditListCell.h"
#import "FamilyContactDetailViewController.h"
#import "EditFamilyModel.h"
#import "Toast+UIView.h"
#import "FamilyListModel.h"
#import "CreateFamilyView.h"
#import "EditTextView.h"

@interface EditFamilyViewController () <FamilyEditListCellDelegate,CreateFamilyViewDelegate>
{
    NSIndexPath *_indexPath;
    UIView *_downView;
    EditTextView *_editTextView;
}
@end

@implementation EditFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"家园联系";
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    
    NSDictionary *dic = @{@"school_id":manager.userInfo.school_id ?: @"",@"class_id":manager.userInfo.class_id ?: @"",@"grade_id":manager.userInfo.grade_id ?: @"",@"student_id":manager.userInfo.userid ?: @""};
    [self createTableViewAndRequestAction:@"form:school_form_score" Param:dic Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(221, 221, 221)];
    [self beginRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_editTextView && _editTextView.audioPlayer != nil && [_editTextView.audioPlayer isPlaying]) {
        [_editTextView.audioPlayer stop];
        _editTextView.audioPlayer = nil;
        [_editTextView.playButton setTitle:@"播放录音" forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isRefreshData) {
        [self beginRefresh];
        _isRefreshData = NO;
    }
}

#pragma mark - create right button
- (void)createRightButton
{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"add_play_mileageN" ofType:@"png"]] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"add_play_mileageH" ofType:@"png"]] forState:UIControlStateHighlighted];
    [moreBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];

}

- (void)addAction:(id)sender
{
    UIView *fullView = [[UIView alloc] initWithFrame:self.navigationController.view.window.bounds];
    [fullView setBackgroundColor:rgba(1, 1, 1, 0.5)];
    [self.navigationController.view.window addSubview:fullView];
    
    UIButton *butNil = [UIButton buttonWithType:UIButtonTypeCustom];
    [butNil setFrame:CGRectMake(0, 0, fullView.frameWidth, fullView.frameHeight)];
    [butNil setBackgroundColor:[UIColor clearColor]];
    [butNil addTarget:self action:@selector(selectNilBut:) forControlEvents:UIControlEventTouchUpInside];
    [fullView addSubview:butNil];
    
    CreateFamilyView *createView = [[CreateFamilyView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 301.5) / 2, (SCREEN_HEIGHT - 250) / 2, 301.5, 250)];
    createView.delegate = self;
    [createView setBackgroundColor:[UIColor clearColor]];
    //[createView createTableView:_create_data];
    [fullView addSubview:createView];
    _downView = createView;
}

- (void)selectNilBut:(id)sender
{
    [[_downView superview] removeFromSuperview];
}

#pragma mark- CreateFamilyView delegate
- (void)createToFamilys:(FamilyListModel *)item
{
    [self selectNilBut:nil];
    
//    _listItem.form_id = item.form_id;
//    _listItem.form_date = item.form_date;
//    _listItem.title = item.title;
//    FamilyNoPiechartDetailViewController *controller = [[FamilyNoPiechartDetailViewController alloc] init];
//    controller.listItem = _listItem;
//    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        NSArray *ret_data = [result valueForKey:@"form_list"];
         ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        NSMutableArray *indexArray = [NSMutableArray array];
        for (id sub in ret_data) {
            NSError *error;
            EditFamilyModel *model = [[EditFamilyModel alloc] initWithDictionary:sub error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [model caculateClass_commentHei];
            [indexArray addObject:model];
        }
        self.dataSource = indexArray;
        
        [self createTableFooterView];
        [_tableView reloadData];
    }
    else {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 150)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, footView.frameBottom- 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setText:@"暂无数据"];
        [footView addSubview:label];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        [_tableView setTableFooterView:footView];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hei = 60 + 130 + 10;
    EditFamilyModel *model = [self.dataSource objectAtIndex:indexPath.section];
    if ([model.create_user_type isEqualToString:@"2"]) {
        hei += 0.5 + 5;
        if (model.class_commentHei > 0) {
            hei += model.class_commentHei + 10;
        }
        if ([model.voice_url length] > 0) {
            hei += 26.5 + 10;
        }
    }
    hei += 20 + 6;
    return hei;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"FamilyEditListCell";
    
    FamilyEditListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[FamilyEditListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.delegate = self;
    }
    EditFamilyModel *model = [self.dataSource objectAtIndex:indexPath.section];
    [cell resetFamilyEditListData:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //FamilyStudentModel
    EditFamilyModel *model = [self.dataSource objectAtIndex:indexPath.section];
    FamilyStudentModel *item = [[FamilyStudentModel alloc] init];
    item.form_id = model.form_id;
    item.form_date = model.form_date;
    item.title = model.title;
    FamilyContactDetailViewController *detailController = [[FamilyContactDetailViewController alloc] init];
    detailController.listItem = item;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

#pragma mark- FamilyEditListCell delegate
- (void)deleteSection:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _indexPath = indexPath;
    EditFamilyModel *model = [self.dataSource objectAtIndex:indexPath.section];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if ([manager.userInfo.userid isEqualToString:model.create_user]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您确定删除吗？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alertView show];
    }else{
        [self.view makeToast:@"只能删除自己创建的联系表哦" duration:1.0 position:@"center"];
    }
}

- (void)playRecording:(UITableViewCell *)cell AtBtn:(id)sender
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    EditFamilyModel *model = [self.dataSource objectAtIndex:indexPath.section];
    if (!_editTextView) {
        _editTextView = [[EditTextView alloc] init];
    }
    if (_editTextView.audioPlayer !=nil && [_editTextView.audioPlayer isPlaying]) {
        [_editTextView.audioPlayer stop];
        _editTextView.audioPlayer = nil;
        [sender setTitle:@"播放录音" forState:UIControlStateNormal];
    }else {
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        
        [_editTextView setVoiceUrl:model.voice_url];
        [_editTextView playVoice:sender];
    }
}

#pragma mark- UIAlertView  delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self sendDeleteRequest];
    }
}

- (void)sendDeleteRequest
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    
    EditFamilyModel *model = [self.dataSource objectAtIndex:_indexPath.section];
    NSString *url = [URLFACE stringByAppendingString:@"form:del_form"];
    NSDictionary *dic = @{@"school_id":manager.userInfo.school_id,@"class_id":manager.userInfo.class_id,@"grade_id":manager.userInfo.grade_id ?: @"",@"student_id":model.student_id,@"score_id":model.id};
    __weak __typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf deleteFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf deleteFinish:NO Data:nil];
    }];
    
}

- (void)deleteFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    NSString *tip = nil;
    if (success) {
//        for (id controller in self.navigationController.viewControllers) {
//            if ([controller isKindOfClass:[FamilyViewController class]]) {
//                [controller setIsRefreshStudentData:YES];
//            }
//        }
        tip = [result valueForKey:@"message"];
        [self.dataSource removeObjectAtIndex:_indexPath.section];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:_indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        tip = @"删除失败";
    }
    [self.view makeToast:tip duration:1.0 position:@"center"];
}

@end
