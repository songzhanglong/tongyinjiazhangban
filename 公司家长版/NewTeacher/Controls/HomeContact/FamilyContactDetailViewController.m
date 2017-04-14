//
//  FamilyContactDetailViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyContactDetailViewController.h"
#import "DJTPieChart.h"
#import "EditFamilyViewController.h"
#import "FamilyLeaveCell.h"
#import "FamilyEditCell.h"
#import "FamilyEditHeaderCell.h"
#import "FamilyEditFooterCell.h"
#import "FamilyDetailModel.h"
#import "Toast+UIView.h"
#import "EditTextView.h"
#import "NSString+Common.h"
//#import "FamilyNoPiechartDetailViewController.h"

#define PCColor1 CreateColor(225, 143, 143)
#define PCColor2 CreateColor(243, 217, 58)
#define PCColor3 CreateColor(98, 168, 246)
#define PCColor4 CreateColor(195, 242, 65)
#define PCColor5 CreateColor(157, 235, 233)

@interface FamilyContactDetailViewController () <DJTPieChartDataSource,DJTPieChartDelegate,EditTextViewDelegate,FamilyLeaveCellDelegate,UIAlertViewDelegate>
{
    NSMutableArray *_slices;
    NSMutableArray *_sliceColors;
    NSMutableArray *_replysArray;
    NSMutableArray *_optionsArray;
    UIView *_downView;
    NSString *_voiceUrl;
    NSString *_score_id;
    EditTextView *_editTextView;
    UIView *_fullView;
    ReplysItem *_indexItem;
    BOOL _is_likes;
    UIButton *_playBtn;
}
@end

@implementation FamilyContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"家园联系";
    
    if ([[DJTGlobalManager shareInstance].userInfo.userid isEqualToString:_listItem.student_id]) {
        [self createRightButton];
    }
    
    _slices = [NSMutableArray array];
    _sliceColors = [NSMutableArray array];
    _replysArray = [NSMutableArray array];
    _optionsArray = [NSMutableArray array];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"school_id":manager.userInfo.school_id,@"class_id":manager.userInfo.class_id,@"grade_id":manager.userInfo.grade_id ?: @"",@"student_id":manager.userInfo.userid,@"form_date":_listItem.form_date,@"form_id":_listItem.form_id};
    [self createTableViewAndRequestAction:@"form:school_form_detail" Param:dic Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(235, 235, 240)];
    [self beginRefresh];
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

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        NSDictionary *ret_data = [result valueForKey:@"list"];
        _voiceUrl = [ret_data valueForKey:@"voice_url"];
        _score_id = [ret_data valueForKey:@"score_id"];
        _is_likes = [[ret_data valueForKey:@"is_likes"] isEqualToString:@"1"];
        if (ret_data && [ret_data isKindOfClass:[NSDictionary class]]) {
            NSArray *data = [ret_data valueForKey:@"item_list"];
            data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
            NSMutableArray *indexArray = [NSMutableArray array];
            for (id sub in data) {
                NSError *error;
                FamilyDetailModel *model = [[FamilyDetailModel alloc] initWithDictionary:sub error:&error];
                if (error) {
                    NSLog(@"%@",error.description);
                    continue;
                }
                for (int i = 0; i < [model.item_list count]; i++) {
                    OptionsItem *item = [model.item_list objectAtIndex:i];
                    if ([item.checked_option length] == 0) {
                        item.nIdx = -1;
                    }
                    [item caculateClass_contHei];
                }
                [indexArray addObject:model];
            }
            
            NSArray *replys = [ret_data valueForKey:@"replys"];
            replys = (!replys || [replys isKindOfClass:[NSNull class]]) ? [NSArray array] : replys;
            NSMutableArray *replysArray = [NSMutableArray array];
            for (id sub in replys) {
                NSError *error;
                ReplysItem *model = [[ReplysItem alloc] initWithDictionary:sub error:&error];
                if (error) {
                    NSLog(@"%@",error.description);
                    continue;
                }
                [model caculateClass_contHei];
                [replysArray addObject:model];
            }
            _replysArray = replysArray;
            self.dataSource = indexArray;
        }
        [self createTableHeaderView:ret_data];
        [_tableView reloadData];
    }
}

#pragma mark- play voice
- (void)playVoice:(id)sender
{
    if (!_editTextView) {
        _editTextView = [[EditTextView alloc] init];
    }
    if (_editTextView.audioPlayer !=nil && [_editTextView.audioPlayer isPlaying]) {
        [_editTextView.audioPlayer stop];
        _editTextView.audioPlayer=nil;
        [_playBtn setTitle:@"播放录音" forState:UIControlStateNormal];
    }else{
        [_playBtn setTitle:@"停止" forState:UIControlStateNormal];
        [_editTextView setVoiceUrl:_voiceUrl];
        [_editTextView playVoice:sender];
    }
}

- (CGFloat)caculateContentToHeight:(NSString *)content
{
    CGFloat _contHei = 0;
    if ([content length] == 0) {
        _contHei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat wei = SCREEN_WIDTH - 75;
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [content boundingRectWithSize:CGSizeMake(wei, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        _contHei = MAX(20, lastSize.height + 5);
    }
    
    return _contHei;
}

- (void)createTableHeaderView:(NSDictionary *)dictory
{
    NSString *content = [dictory valueForKey:@"comment"] ?: @"";
    BOOL isShow = ([_voiceUrl length] > 0);
    CGFloat _contHei = [self caculateContentToHeight:content];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 230 + _contHei + (isShow ? 30 : 0))];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView  *headImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_header_bg")];
    [headImgView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 73.5)];
    [headerView addSubview:headImgView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20, 30)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel.layer setCornerRadius:2];
    [titleLabel setText:[dictory valueForKey:@"title"] ?: @""];
    [titleLabel setTextColor:CreateColor(43, 185, 52)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:titleLabel];
    
    float total = 0;
    NSMutableArray *options = [dictory valueForKey:@"options"];
    _optionsArray = options;
    for (NSDictionary *dic in options) {
        NSString *count_option = [dic valueForKey:@"count_option"];
        total += [count_option floatValue];
    }
    NSMutableArray *numbers = [NSMutableArray array];
    for (NSDictionary *dic in options) {
        NSString *count_option = [dic valueForKey:@"count_option"];
        [numbers addObject:[NSNumber numberWithFloat:[count_option floatValue] / total]];
    }
    _slices = numbers;
    
    if ([_sliceColors count] > 0) {
        [_sliceColors removeAllObjects];
    }
    NSArray *arr = @[PCColor1,PCColor2,PCColor3,PCColor4,PCColor5];
    for (int i = 0; i < [options count]; i++)
    {
        [_sliceColors addObject:[arr objectAtIndex:i%arr.count]];
    }
    
    DJTPieChart *pieChartRight = [[DJTPieChart alloc] initWithFrame:CGRectMake(40, 45 + 20, 130, 130)];
    [pieChartRight setDelegate:self];
    [pieChartRight setDataSource:self];
    [pieChartRight setShowPercentage:NO];
    [pieChartRight setLabelColor:[UIColor blackColor]];
    [pieChartRight setShowLabel:NO];
    [headerView addSubview:pieChartRight];
    [pieChartRight reloadData];
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(pieChartRight.frameRight + 40, 45 + 33, SCREEN_WIDTH - pieChartRight.frameRight - 50, 100)];
    [tempView setBackgroundColor:[UIColor clearColor]];
    [tempView setTag:1507];
    [headerView addSubview:tempView];
    
    for (int i = 0; i < [options count]; i++) {
        NSDictionary *dic = [options objectAtIndex:i];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, (tempView.frameHeight - 20 * [options count]) / 2 + 20 * i, SCREEN_WIDTH - pieChartRight.frameRight - 50, 20)];
        [bgView setBackgroundColor:CreateColor(235, 235, 240)];
        [bgView setTag:10 + i];
        [tempView addSubview:bgView];
        
        UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        [colorLabel setBackgroundColor:arr[i]];
        [bgView addSubview:colorLabel];
        
        NSString *str = [NSString stringWithFormat:@"%@：%@项",[dic valueForKey:@"option"],[dic valueForKey:@"count_option"]];
        NSMutableAttributedString *attributring = [[NSMutableAttributedString alloc] initWithString:str];
        NSRange range = [str rangeOfString:[dic valueForKey:@"count_option"]];
        [attributring addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0,[attributring length])];
        [attributring addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0.5, bgView.frameWidth - 5 - 0.5, (i == [options count] - 1) ? 19 : 19.5)];
        [tipLabel setBackgroundColor:[UIColor whiteColor]];
        //[[tipLabel layer] setBorderWidth:0.5];
        //[[tipLabel layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [tipLabel setTextAlignment:NSTextAlignmentCenter];
        [tipLabel setFont:[UIFont systemFontOfSize:12]];
        [tipLabel setAttributedText:attributring];
        [bgView addSubview:tipLabel];
    }
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, pieChartRight.frameBottom + 10, SCREEN_WIDTH, 0.5)];
    [lineLabel setBackgroundColor:CreateColor(235, 235, 240)];
    [headerView addSubview:lineLabel];
    
    UILabel *contLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, lineLabel.frameBottom, SCREEN_WIDTH - 30, _contHei)];
    [contLabel setBackgroundColor:[UIColor clearColor]];
    [contLabel setText:content];
    [contLabel setTextColor:[UIColor lightGrayColor]];
    contLabel.numberOfLines = 0;
    [contLabel setFont:[UIFont systemFontOfSize:12]];
    [headerView addSubview:contLabel];
    
    if (isShow) {
        UIButton *palyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [palyBtn setFrame:CGRectMake(15, contLabel.frameBottom + 5, 176, 26.5)];
        [palyBtn setBackgroundImage:CREATE_IMG(@"contact_play") forState:UIControlStateNormal];
        _playBtn = palyBtn;
        [palyBtn setBackgroundColor:CreateColor(44, 188, 64)];
        [palyBtn.layer setCornerRadius:13];
        [palyBtn setTag:1011];
        [palyBtn setTitle:@"播放录音" forState:UIControlStateNormal];
        [palyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [palyBtn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
        [palyBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [headerView addSubview:palyBtn];
    }
    
//    UILabel *mshowLabel = [[UILabel alloc] initWithFrame:CGRectMake(palyBtn.frameRight + 10, palyBtn.frameY, 40, 26)];
//    [mshowLabel setBackgroundColor:[UIColor clearColor]];
//    [mshowLabel setTextColor:CreateColor(44, 188, 64)];
//    [mshowLabel setText:@"16s"];
//    [mshowLabel setFont:[UIFont systemFontOfSize:10]];
//    [headerView addSubview:mshowLabel];
    
    NSString *create_time = [dictory valueForKey:@"update_time"];
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:create_time.doubleValue];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, headerView.frameHeight - 20, SCREEN_WIDTH - 30, 20)];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor lightGrayColor]];
    [timeLabel setFont:[UIFont systemFontOfSize:10]];
    [timeLabel setText:[NSString stringWithFormat:@"%@  %@老师填写",[NSString stringByDate:@"yyyy/MM/dd HH:mm:ss" Date:updateDate],[dictory valueForKey:@"create_user"] ?: @""]];
    [headerView addSubview:timeLabel];
    
    [_tableView setTableHeaderView:headerView];
}

- (void)createTableFooterView
{
    UIView *footerView = [self setFooterView];
    [_tableView setTableFooterView:footerView];
}

- (UIView *)setFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
    [footerView setTag:10];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    EditTextView *editView = [[EditTextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90) ToFrom:2];
    _editTextView = editView;
    [editView setLoactionPath:@""];
    [editView setVoiceUrl:@""];
    [editView setDelegate:self];
    [editView setLimitCount:200];
    [editView.limitLabel setText:_indexItem ? @"家长回复" : @"家长留言"];
    [editView.placeholderLab setText:_indexItem ? [NSString stringWithFormat:@"回复%@%@：",_indexItem.create_user_name,(([_indexItem.relation length] > 0) ? _indexItem.relation : @"老师")] : @"给老师留言..."];
    [footerView addSubview:editView];

    return footerView;
}

#pragma mark- EditTextView delegate
- (void)showKeyboardEditTextView:(CGFloat)keyboard Height:(CGFloat)height
{
    CGFloat hei = keyboard;
    CGRect homeRect = _fullView.frame;
    __weak typeof(_fullView)weakView = _fullView;
    
    [UIView animateWithDuration:0.35 animations:^{
        [weakView setFrame:CGRectMake(homeRect.origin.x, SCREEN_HEIGHT - _fullView.frameHeight - hei, homeRect.size.width, homeRect.size.height)];
    }];
}

- (void)hideKeyboardEditTextView:(CGFloat)height
{
    CGRect homeRect = _fullView.frame;
    __weak typeof(_fullView)weakView = _fullView;
    [UIView animateWithDuration:0.35 animations:^{
        [weakView setFrame:CGRectMake(homeRect.origin.x, SCREEN_HEIGHT - _fullView.frameHeight, homeRect.size.width, homeRect.size.height)];
    }];
}

- (void)replyTeacher:(EditTextView *)editTextView
{
    if ([[editTextView.textView text] length] <= 0) {
        [self.view.window makeToast:@"留言的内容不能为空" duration:1.0 position:@"center"];
        return;
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *relate_user_name = @"";
    NSString *reply_id = @"0";
    if ([_indexItem.reply_id length] > 0) {
        relate_user_name = [NSString stringWithFormat:@"%@老师",_indexItem.create_user_name];
        reply_id = _indexItem.reply_id;
    }
    NSString *url = [URLFACE stringByAppendingString:@"form:form_reply_save"];
    NSDictionary *dic = @{@"school_id":manager.userInfo.school_id,@"class_id":manager.userInfo.class_id,@"form_id":_listItem.form_id,@"student_id":manager.userInfo.userid,@"content":[editTextView.textView text],@"score_id":_score_id ?: @"",@"relate_id":reply_id,@"relate_user_name":relate_user_name};
    
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf replyFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf replyFinish:NO Data:nil];
    }];
}

- (void)replyFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    if (success) {
        //reply id  relod section
        ReplysItem *model = [[ReplysItem alloc] init];
        model.content = [_editTextView.textView text];
        model.reply_id = [result valueForKey:@"reply_id"];
        model.relation = [result valueForKey:@"relation"];
        model.face_school = [result valueForKey:@"face_school"];
        model.create_user_type = @"1";
        model.create_user_name = [DJTGlobalManager shareInstance].userInfo.uname;
        if (_indexItem) {
             model.relate_user_name = [NSString stringWithFormat:@"%@老师",_indexItem.create_user_name];
        }
        model.create_user = [DJTGlobalManager shareInstance].userInfo.userid;
        model.create_time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        [model caculateClass_contHei];
        [_replysArray insertObject:model atIndex:0];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.dataSource count] + 1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self selectNilBut:nil];
    }
    NSString *tip = [result valueForKey:@"message"];
    [self.view makeToast:tip ?: @"回复失败" duration:1.0 position:@"center"];
}

#pragma mark - create right button
- (void)createRightButton
{
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0, 0, 40, 30)];
    [sendButton setTitle:@"编辑" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [sendButton addTarget:self action:@selector(editFanilyAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
}

- (void)editFanilyAction:(id)sender
{
//    FamilyNoPiechartDetailViewController *editDetailController = [[FamilyNoPiechartDetailViewController alloc] init];
//    editDetailController.listItem = _listItem;
//    editDetailController.score_id = _score_id;
//    [self.navigationController pushViewController:editDetailController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - DJTPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(DJTPieChart *)pieChart
{
    return _slices.count;
}

- (CGFloat)pieChart:(DJTPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[_slices objectAtIndex:index] floatValue];
}

- (UIColor *)pieChart:(DJTPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [_sliceColors objectAtIndex:(index % _sliceColors.count)];
}

#pragma mark - DJTPieChart Delegate
- (void)pieChart:(DJTPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    UIView *tempView = (UIView *)[_tableView.tableHeaderView viewWithTag:1507];
    if (tempView) {
        UIView *bgView = (UIView *)[tempView viewWithTag:10 + index];
        if (bgView) {
            CGRect rec = bgView.frame;
            rec.origin.x += 15;
            [UIView animateWithDuration:0.35 animations:^{
                [bgView setFrame:rec];
            }];
        }
    }
    
    if ([_optionsArray count] > 0) {
        NSDictionary *dic = [_optionsArray objectAtIndex:index];
        NSString *option = [dic valueForKey:@"option"];
        for (int i = 0; i < [self.dataSource count]; i++) {
            FamilyDetailModel *model = [self.dataSource objectAtIndex:i];
            for (OptionsItem *item in model.item_list) {
                if (![item.checked_option isEqualToString:option]) {
                    item.nSeclect = NO;
                }
            }
        }
        [_tableView reloadData];
    }
}
- (void)pieChart:(DJTPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    UIView *tempView = (UIView *)[_tableView.tableHeaderView viewWithTag:1507];
    if (tempView) {
        UIView *bgView = (UIView *)[tempView viewWithTag:10 + index];
        if (bgView) {
            CGRect rec = bgView.frame;
            rec.origin.x -= 15;
            [UIView animateWithDuration:0.35 animations:^{
                [bgView setFrame:rec];
            }];
        }
    }
    
    if ([_optionsArray count] > 0) {
        NSDictionary *dic = [_optionsArray objectAtIndex:index];
        NSString *option = [dic valueForKey:@"option"];
        for (int i = 0; i < [self.dataSource count]; i++) {
            FamilyDetailModel *model = [self.dataSource objectAtIndex:i];
            for (OptionsItem *item in model.item_list) {
                if (![item.checked_option isEqualToString:option]) {
                    item.nSeclect = YES;
                }
            }
        }
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = 0;
    for (FamilyDetailModel *model in self.dataSource) {
        BOOL isFind = NO;
        for (OptionsItem *item in model.item_list) {
            if (!item.nSeclect) {
                isFind = YES;
            }
        }
        if (isFind) {
            count ++;
        }
    }
    return count + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *indexArr = [NSMutableArray array];
    for (FamilyDetailModel *model in self.dataSource) {
        BOOL isFind = NO;
        for (OptionsItem *item in model.item_list) {
            if (!item.nSeclect) {
                isFind = YES;
            }
        }
        if (isFind) {
            [indexArr addObject:model];
        }
    }
    int num = 0;
    if (section == [indexArr count] + 1) {
        num = (int)[_replysArray count];
    }else if (section == [indexArr count]){
        num = 1;
    }else{
        num = 1;
        FamilyDetailModel *model = [indexArr objectAtIndex:section];
        for (OptionsItem *item in model.item_list) {
            if (!item.nSeclect) {
                num ++;
            }
        }
    }
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *indexArr = [NSMutableArray array];
    for (FamilyDetailModel *model in self.dataSource) {
        BOOL isFind = NO;
        for (OptionsItem *item in model.item_list) {
            if (!item.nSeclect) {
                isFind = YES;
            }
        }
        if (isFind) {
            [indexArr addObject:model];
        }
    }
    
    CGFloat hei = 60;
    if (indexPath.section == [indexArr count] + 1) {
        ReplysItem *item = [_replysArray objectAtIndex:indexPath.row];
        hei = MAX(27 + item.class_contHei, 40);
    }else if (indexPath.section == [indexArr count]) {
        hei = 41;
    }else {
        if (indexPath.row != 0) {
            NSMutableArray *tempArr = [NSMutableArray array];
            FamilyDetailModel *model = [indexArr objectAtIndex:indexPath.section];
            for (OptionsItem *item in model.item_list) {
                if (!item.nSeclect) {
                    [tempArr addObject:item];
                }
            }
            OptionsItem *item = [tempArr objectAtIndex:indexPath.row -1];
            hei = item.class_contHei + 5 + 2 + 26;
        }
    }
    return hei;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 10 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId1 = @"FamilyDetailCell1";
    static NSString *cellId2 = @"FamilyDetailCell2";
    static NSString *cellId3 = @"FamilyDetailCell3";
    static NSString *cellId4 = @"FamilyDetailCell4";
    static NSString *cellId5 = @"FamilyDetailCell5";
    
    NSString *cellId = cellId1;
    NSMutableArray *indexArr = [NSMutableArray array];
    for (FamilyDetailModel *model in self.dataSource) {
        BOOL isFind = NO;
        for (OptionsItem *item in model.item_list) {
            if (!item.nSeclect) {
                isFind = YES;
            }
        }
        if (isFind) {
            [indexArr addObject:model];
        }
    }
    NSMutableArray *tempArr = [NSMutableArray array];
    if ((indexPath.section < [indexArr count])) {
        FamilyDetailModel *model = [indexArr objectAtIndex:indexPath.section];
        for (OptionsItem *item in model.item_list) {
            if (!item.nSeclect) {
                [tempArr addObject:item];
            }
        }
        if (indexPath.row == 0) {
            cellId = cellId1;
        }else {
            cellId =  (indexPath.row == [tempArr count]) ? cellId3 : cellId2;
        }
    }else {
        cellId = (indexPath.section == [indexArr count]) ? cellId4 : cellId5;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        if (indexPath.section == [indexArr count] + 1) {
            cell = [[FamilyLeaveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId5];
            [(FamilyLeaveCell *)cell setDelegate:self];
        }else if (indexPath.section == [indexArr count]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId4];
            [cell setBackgroundColor:[UIColor clearColor]];
            UIButton *thanksBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            thanksBtn.selected = NO;
            [thanksBtn setFrame:CGRectMake((SCREEN_WIDTH - 33 - 5 - 333 / 2) / 2, 4, 33, 33)];
            [thanksBtn setImage:CREATE_IMG(@"contact_thanks_1") forState:UIControlStateNormal];
            [thanksBtn setImage:CREATE_IMG(@"contact_thanks") forState:UIControlStateSelected];
            [thanksBtn setTag:20];
            [thanksBtn addTarget:self action:@selector(thanksAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:thanksBtn];
            
            UIButton *leaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [leaveBtn setFrame:CGRectMake(thanksBtn.frameRight + 5, 4, 333 / 2, 33)];
            [leaveBtn setImage:CREATE_IMG(@"contact_leave") forState:UIControlStateNormal];
            [leaveBtn addTarget:self action:@selector(leaveAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:leaveBtn];
        }else{
            if (indexPath.row == 0) {
                cell = [[FamilyEditHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId1];
            }else if (indexPath.row == [tempArr count]) {
                cell = [[FamilyEditFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId3];
            }else {
                cell = [[FamilyEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId2];
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == [indexArr count] + 1) {
        ReplysItem *model = [_replysArray objectAtIndex:indexPath.row];
        [(FamilyLeaveCell *)cell resetFamilyLeaveData:model];
    }else if (indexPath.section == [indexArr count]) {
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:20];
        if (btn) {
            btn.selected = _is_likes;
        }
    }else{
        FamilyDetailModel *model = [indexArr objectAtIndex:indexPath.section];
        if (indexPath.row == 0) {
            [(FamilyEditHeaderCell *)cell resetFamilyEditHeaderData:model];
        }else {
            OptionsItem *item = [tempArr objectAtIndex:indexPath.row - 1];
            if (indexPath.row == [tempArr count]){
                [(FamilyEditFooterCell *)cell resetFamilyEditFooterData:item Options:@[(item.checked_option ?: @"")]];
                [(FamilyEditFooterCell *)cell setIsEdit:YES];
            }else {
                [(FamilyEditCell *)cell resetFamilyEditData:item Options:@[(item.checked_option ?: @"")]];
                [(FamilyEditCell *)cell setIsEdit:YES];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

#pragma mark- FamilyLeaveCell delegate
- (void)replyOrDelMessage:(ReplysItem *)model
{
    _indexItem = model;
    if ([model.create_user_type length] > 0 && [model.create_user_type isEqualToString:@"1"]) {
        //delete
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        if ([manager.userInfo.userid isEqualToString:model.create_user]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您确定删除吗？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
            [alertView show];
        }else{
            [self.view makeToast:@"只能删除自己的留言哦" duration:1.0 position:@"center"];
        }
    }else{
        [self leaveAction:nil];
    }
}

#pragma mark - tableview button action
- (void)thanksAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        [self.view makeToast:@"已经感谢过老师了" duration:1.0 position:@"center"];
        return;
    }
    btn.selected = !btn.selected;
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"form:send_likes"];
    NSDictionary *dic = @{@"school_id":manager.userInfo.school_id,@"class_id":manager.userInfo.class_id,@"form_id":_listItem.form_id,@"student_id":manager.userInfo.userid,@"score_id":_score_id ?: @"",@"title":_listItem.title ?: @""};
    
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf linkFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf linkFinish:NO Data:nil];
    }];
}

- (void)leaveAction:(id)sender
{
    self.navigationController.view.userInteractionEnabled = NO;
    UIView *fullView = [[UIView alloc] initWithFrame:self.navigationController.view.window.bounds];
    _fullView = fullView;
    [fullView setBackgroundColor:rgba(1, 1, 1, 0.5)];
    [self.navigationController.view.window addSubview:fullView];
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, fullView.frameBottom, fullView.frameWidth, 90)];
    [downView setUserInteractionEnabled:YES];
    [downView setBackgroundColor:[UIColor whiteColor]];
    [fullView addSubview:downView];
    _downView = downView;
    UIButton *butNil = [UIButton buttonWithType:UIButtonTypeCustom];
    [butNil setFrame:CGRectMake(0, 0, fullView.frameWidth, fullView.frameHeight - downView.frameHeight)];
    [butNil setBackgroundColor:[UIColor clearColor]];
    [butNil addTarget:self action:@selector(selectNilBut:) forControlEvents:UIControlEventTouchUpInside];
    [fullView addSubview:butNil];
    
    UIView *footerView = [self setFooterView];
    [downView addSubview:footerView];
    
    CGFloat yOri = butNil.frameHeight;
    [UIView animateWithDuration:0.3 animations:^{
        [downView setFrameY:yOri];
    } completion:^(BOOL finished) {
        self.navigationController.view.userInteractionEnabled = YES;
    }];
}

- (void)selectNilBut:(id)sender
{
    _indexItem = nil;
    self.navigationController.view.userInteractionEnabled = NO;
    CGFloat yOri = _downView.frameBottom;
    [UIView animateWithDuration:0.3 animations:^{
        [_downView setFrameY:yOri];
    } completion:^(BOOL finished) {
        [[_downView superview] removeFromSuperview];
        self.navigationController.view.userInteractionEnabled = YES;
    }];
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
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"form:del_form_reply"];
    NSDictionary *dic = @{@"school_id":manager.userInfo.school_id,@"class_id":manager.userInfo.class_id,@"reply_id":_indexItem.reply_id};
    
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
   
    if (success) {
        [_replysArray removeObject:_indexItem];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.dataSource count] + 1] withRowAnimation:UITableViewRowAnimationAutomatic];
        _indexItem = nil;
    }
    NSString *tip = [result valueForKey:@"message"];
    [self.view makeToast:tip ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
}

- (void)linkFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    
    NSString *tip = [result valueForKey:@"message"];
    [self.view makeToast:tip ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
}

@end
