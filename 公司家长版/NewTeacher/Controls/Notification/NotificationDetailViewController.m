//
//  NotificationDetailViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/2/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationDetailViewController.h"
#import "DJTGlobalDefineKit.h"
#import "NotificationListModel.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "NotificationCommentCell.h"
#import "NotificationCommentCell2.h"
#import "NotificationCommentModel.h"
#import "InputBar.h"
#import "MileageAllEditView.h"

@interface NotificationDetailViewController ()<NotificationCommentCellDelegate,InputBarDelegate,MileageAllEditViewDelegate>
{
    InputBar *_inputBar;
    NSIndexPath *_indexPath;
    NSString    *_content;
    UILabel  *_tipLab;
    NSInteger _segmentIndex;
}
@end

@implementation NotificationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBack = YES;
    self.titleLable.text = @"通知详情";
    self.useNewInterface = YES;
    
    _segmentIndex = 100;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMessageInfo"];
    [param setObject:_listModel.message_id forKey:@"message_id"];
    [param setObject:manager.userInfo.baby_id forKey:@"baby_id"];
    //baby_id
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [self createTableViewAndRequestAction:@"message" Param:param Header:YES Foot:NO];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44)];
    [_tableView registerClass:[NotificationCommentCell class] forCellReuseIdentifier:@"notificationCommentCellId"];
    [_tableView registerClass:[NotificationCommentCell2 class] forCellReuseIdentifier:@"notificationCommentCellId2"];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setTableHeaderView:[self createTableHeaderView]];
    
    [_tableView setBackgroundColor:CreateColor(227, 225, 226)];
    [self beginRefresh];
    
    //input
    _inputBar = [[InputBar alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height, _tableView.frame.size.width, 44)];
    _inputBar.delegate = self;
    [_inputBar setBackgroundColorToType];
    [self.view addSubview:_inputBar];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 表头
- (UIView *)createTableHeaderView
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat yOri = 10.0;
    CGFloat imgHei = 40,imgWei = 40;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = [UIColor whiteColor];
    //head
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, yOri, imgWei, imgHei)];
    headImg.layer.masksToBounds = YES;
    headImg.layer.cornerRadius = 20;
    [headerView addSubview:headImg];
    NSString *url = _listModel.face;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [headImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    
    //time
    UILabel *_timeLab = [[UILabel alloc] initWithFrame:CGRectMake(winSize.width - 10 - 200, yOri + 5, 200, 20)];
    [_timeLab setFont:[UIFont systemFontOfSize:15]];
    [_timeLab setTextAlignment:2];
    [_timeLab setTextColor:[UIColor darkGrayColor]];
    [_timeLab setText:[NSString calculateTimeDistance:_listModel.ctime]];
    [headerView addSubview:_timeLab];
    
    //name
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(10 + imgWei + 10, yOri + 5, 170, 20)];
    [nameLab setBackgroundColor:[UIColor clearColor]];
    [nameLab setTextColor:CreateColor(68, 138, 167)];
    [nameLab setFont:[UIFont systemFontOfSize:17]];
    [nameLab setText:_listModel.teacher_name];
    [headerView addSubview:nameLab];
    
    yOri += imgHei;
    
    //conte
    UILabel *conLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.frame.origin.x, imgHei, winSize.width - 32 - 40 - 10, _listModel.conSize.height)];
    [conLab setNumberOfLines:0];
    [conLab setFont:[UIFont systemFontOfSize:17]];
    [conLab setText:_listModel.content];
    [headerView addSubview:conLab];
    
    yOri += _listModel.conSize.height + 10;
    
    //success
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:@"发送成功" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    button.userInteractionEnabled = NO;
//    [button setFrame:CGRectMake(winSize.width - 70 - 10, yOri, 70, 25)];
//    [button setBackgroundColor:CreateColor(43, 210, 67)];
//    button.layer.masksToBounds = YES;
//    button.layer.cornerRadius = 2.0;
//    [headerView addSubview:button];
//    
//    yOri += 20 + 10;
    
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0, yOri, SCREEN_WIDTH, 6)];
    [lineLab setBackgroundColor:CreateColor(227, 225, 226)];
    [headerView addSubview:lineLab];
    
    yOri += 6;
    
    [headerView setFrame:CGRectMake(0, 0, winSize.width, yOri)];
    
    return headerView;
}

#pragma mark - 网络请求结束
/**
 *	@brief	数据请求结果
 *
 *	@param 	success 	yes－成功
 *	@param 	result 	服务器返回数据
 */
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSError *error = nil;
        NotificationCommentModel *model = [[NotificationCommentModel alloc] initWithDictionary:ret_data error:&error];
        if (error) {
            NSLog(@"%@",error.description);
            return;
        }
        
        NSMutableArray *teachers = [NSMutableArray array];
        NSMutableArray *parents = [NSMutableArray array];
        NSMutableArray *teachers1 = [NSMutableArray array];
        NSMutableArray *parents1 = [NSMutableArray array];
        for (NotificationReader *reader in model.reader) {
            if ([reader.real_name length] == 0) {
                continue;
            }
            if ([reader.receiver_type integerValue] == 0) {
                [parents addObject:reader.real_name];
            }
            else
            {
                [teachers addObject:reader.real_name];
            }
        }

        for (NotificationUnReader *reader in model.unreader) {
            if ([reader.real_name length] == 0) {
                continue;
            }
            if ([reader.receiver_type integerValue] == 0) {
                [parents1 addObject:reader.real_name];
            }
            else
            {
                [teachers1 addObject:reader.real_name];
            }
        }
        
        NSMutableArray *lastArr = [NSMutableArray array];
        NSMutableArray *teaTempArray = [NSMutableArray array];
        ObjectModel *teaModel = [[ObjectModel alloc] init];
        //teaModel.showAll = YES;
        teaModel.content = [teachers componentsJoinedByString:@"、"];
        if ([teaModel.content length] > 0) {
            [teaModel calculeteConSize:[UIScreen mainScreen].bounds.size.width - 55 Font:[UIFont systemFontOfSize:14]];
        }
        [teaTempArray addObject:teaModel];
        
        ObjectModel *teaModel1 = [[ObjectModel alloc] init];
        //teaModel.showAll = YES;
        teaModel1.content = [teachers1 componentsJoinedByString:@"、"];
        if ([teaModel1.content length] > 0) {
            [teaModel1 calculeteConSize:[UIScreen mainScreen].bounds.size.width - 55 Font:[UIFont systemFontOfSize:14]];
        }
        [teaTempArray addObject:teaModel1];
        
        [lastArr addObject:teaTempArray];
        
        NSMutableArray *parTempArray = [NSMutableArray array];
        ObjectModel *parModel = [[ObjectModel alloc] init];
        parModel.content = [parents componentsJoinedByString:@"、"];
        parModel.parents = parents;
        if ([parModel.content length] > 0) {
            [parModel calculeteConSize:[UIScreen mainScreen].bounds.size.width - 55 Font:[UIFont systemFontOfSize:14]];
        }
        [parTempArray addObject:parModel];
        
        ObjectModel *parModel1 = [[ObjectModel alloc] init];
        parModel1.content = [parents1 componentsJoinedByString:@"、"];
        parModel1.parents = parents1;
        if ([parModel1.content length] > 0) {
            [parModel1 calculeteConSize:[UIScreen mainScreen].bounds.size.width - 55 Font:[UIFont systemFontOfSize:14]];
        }
        [parTempArray addObject:parModel1];
        
        [lastArr addObject:parTempArray];
        
        NSMutableArray *itemArr = [NSMutableArray array];
        for (NotificationCommentItem *item in model.comment) {
            if ([item.content length] > 0) {
                [itemArr addObject:item];
                [item calculeteConSize:[UIScreen mainScreen].bounds.size.width - 20 Font:[UIFont systemFontOfSize:16]];
            }
        }
        [lastArr addObject:itemArr];
        
        self.dataSource = lastArr;
        [_tableView reloadData];
    }
    
}

#pragma mark - InputBarDelegate
- (void)changeViewHeight:(CGFloat)height
{
    CGRect barRect = _inputBar.frame;
    CGRect tabRect = _tableView.frame;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    [_inputBar setFrame:CGRectMake(barRect.origin.x, winSize.height - height - barRect.size.height - 64, barRect.size.width, barRect.size.height)];
    [_tableView setFrame:CGRectMake(tabRect.origin.x, -height, tabRect.size.width, tabRect.size.height)];
}

- (void)cancelIndexPath
{
//    if (_indexPath) {
//        _indexPath = nil;
//    }
//    if (_inputBar.textField.isFirstResponder) {
//        [_inputBar.textField resignFirstResponder];
//        _inputBar.textField.text = @"";
//        UIColor *color = [UIColor blackColor];
//        _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
//    }
}

- (void)sendComment:(NSString *)content
{
    if (content && ([content length] >= 1 && [content length] <= 500)) {
        NSString *newStr = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([newStr length] == 0) {
            [self.view.window makeToast:@"不能全部输入空字符串" duration:1.0 position:@"other"];
            
        }
        else
        {
            [self replyContent:content];
            _inputBar.textField.text = @"";
            UIColor *color = [UIColor blackColor];
            _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
        }
    }
    else
    {
        [self.view.window makeToast:@"请输入1-500的文本长度内容" duration:1.0 position:@"other"];
    }
}

#pragma mark - 回复
- (void)replyContent:(NSString *)content
{
    if (self.httpOperation) {
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:@"请检查网络状态" duration:1.0 position:@"center"];
        return;
    }
    
    _content = content;
    _tableView.userInteractionEnabled = NO;
    _inputBar.userInteractionEnabled = NO;
    
    //
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"messageComment"];
    [param setObject:_listModel.message_id forKey:@"message_id"];
    [param setObject:manager.userInfo.userid forKey:@"author_id"];
    [param setObject:manager.userInfo.uname forKey:@"author_name"];
    [param setObject:content forKey:@"content"];
    if (_indexPath) {
        NSArray *array = self.dataSource[_indexPath.section];
        NotificationCommentItem *item = array[_indexPath.row];
        [param setObject:item.author_id forKey:@"reply_id"];
        [param setObject:item.author_name forKey:@"reply_name"];
    }
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"message"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf finishReplyContent:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf finishReplyContent:NO Data:nil];
    }];
}

- (void)finishReplyContent:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    _inputBar.userInteractionEnabled = YES;
    if (suc) {
        id ret_data = [result valueForKey:@"ret_msg"];
        NSString *comment_id = [ret_data valueForKey:@"comment_id"];
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        NotificationCommentItem *newItem = [[NotificationCommentItem alloc] init];
        newItem.author_name = user.uname;
        newItem.author_id = user.userid;
        newItem.content = _content;
        newItem.id = comment_id;
        newItem.message_id = _listModel.message_id;
        newItem.create_time = [NSString stringByDate:@"yyyy-MM-dd HH:mm:ss" Date:[NSDate date]];
        if (_indexPath) {
            NSArray *array = self.dataSource[_indexPath.section];
            NotificationCommentItem *item = array[_indexPath.row];
            newItem.reply_id = item.author_id;
            newItem.reply_name = item.author_name;
        }
        [newItem calculeteConSize:[UIScreen mainScreen].bounds.size.width - 20 Font:[UIFont systemFontOfSize:16]];
        
        
        NSMutableArray *array = [self.dataSource objectAtIndex:2];
        if (!array) {
            array = [NSMutableArray array];
        }
        if ([array count] > 0) {
            [array insertObject:newItem atIndex:0];
            [_tipLab setText:[NSString stringWithFormat:@"一共%ld条回复",(unsigned long)[array count]]];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [array insertObject:newItem atIndex:0];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else
    {
        NSString *str = @"评论失败";
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:ret_msg duration:1.0 position:@"center"];
    }
    _indexPath = nil;
}

#pragma mark - BaseTableModelDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _indexPath = nil;
    if (_inputBar.textField.isFirstResponder) {
        [_inputBar.textField resignFirstResponder];
        _inputBar.textField.text = @"";
        UIColor *color = [UIColor blackColor];
        _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
    }
}

#pragma mark - NotificationCommentCellDelegate
- (void)expandAndDrawback:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSArray *tempArr = [self.dataSource objectAtIndex:indexPath.section];
    ObjectModel *parModel = [tempArr objectAtIndex:_segmentIndex - 100];
    parModel.isAllShow = !parModel.isAllShow;
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteReplyContent:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        NSMutableArray *array = [self.dataSource objectAtIndex:_indexPath.section];
        if (!array) {
            array = [NSMutableArray array];
        }
        [array removeObjectAtIndex:_indexPath.row];
        if ([array count] > 0) {
            [_tipLab setText:[NSString stringWithFormat:@"一共%ld条回复",(unsigned long)[array count]]];
            [_tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else
    {
        NSString *str = @"删除失败";
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:ret_msg duration:1.0 position:@"center"];
    }
    _indexPath = nil;
}

#pragma mark - MileageAllEditViewDelegate
- (void)selectEditIndex:(NSInteger)index
{
    NSArray *array = [self.dataSource objectAtIndex:_indexPath.section];
    NotificationCommentItem *item = [array objectAtIndex:_indexPath.row];
    switch (index) {
        case 0:
        {
            //删除
            if (self.httpOperation) {
                return;
            }
            
            if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
                [self.view makeToast:@"请检查网络状态" duration:1.0 position:@"center"];
                return;
            }
            
            _tableView.userInteractionEnabled = NO;
            if (_inputBar.textField.isFirstResponder) {
                [_inputBar.textField resignFirstResponder];
            }
            [self.view makeToastActivity];
            //
            DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
            NSMutableDictionary *param = [manager requestinitParamsWith:@"deleteMessageComment"];
            [param setObject:item.id forKey:@"comment_id"];
            NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
            [param setObject:text forKey:@"signature"];
            
            __weak __typeof(self)weakSelf = self;
            NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"message"];
            self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
                [weakSelf deleteReplyContent:success Data:data];
            } failedBlock:^(NSString *description) {
                [weakSelf deleteReplyContent:NO Data:nil];
            }];
        }
            break;
        case 1:
        {
            if (!_inputBar.textField.isFirstResponder) {
                [_inputBar.textField becomeFirstResponder];
            }
            UIColor *color = [UIColor blackColor];
            _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"回复%@:",item.author_name] attributes:@{NSForegroundColorAttributeName: color}];
        }
            break;
        default:
            break;
    }
}

- (void)cancelEditIndex
{
    _indexPath = nil;
    if (_inputBar.textField.isFirstResponder) {
        [_inputBar.textField resignFirstResponder];
    }
    _inputBar.textField.text = @"";
    UIColor *color = [UIColor blackColor];
    _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        NSArray *array = [self.dataSource objectAtIndex:section];
        return [array count];
    }else {
        NSArray *temArr = self.dataSource[section];
        ObjectModel *model = temArr[_segmentIndex - 100];
        if ([model.content length] > 0) {
            return 1;
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = nil;
    if (indexPath.section == 2)
    {
        cellId = @"notificationCommentCellId2";
    }
    else {
        cellId = @"notificationCommentCellId";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (indexPath.section == 2) {
        NSArray *array = self.dataSource[indexPath.section];
        [(NotificationCommentCell2 *)cell resetNotificationDetailData:array[indexPath.row]];
    }else{
        NSArray *temArr = self.dataSource[indexPath.section];
        ObjectModel *model = temArr[_segmentIndex - 100];
        NotificationCommentCell *commentCell = (NotificationCommentCell *)cell;
        commentCell.delegate = self;
        
        commentCell.tipLab.text = (indexPath.section == 0) ? @"老师:" : @"家长:";
        [commentCell resetNotificationDetailData:model];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        _indexPath = indexPath;
        NSArray *array = [self.dataSource objectAtIndex:indexPath.section];
        NotificationCommentItem *item = [array objectAtIndex:indexPath.row];
        if ([item.author_name isEqualToString:[DJTGlobalManager shareInstance].userInfo.uname]) {
            if (_inputBar.textField.isFirstResponder) {
                [_inputBar.textField resignFirstResponder];
            }
            MileageAllEditView *editView = [[MileageAllEditView alloc] initWithFrame:[UIScreen mainScreen].bounds Titles:@[@"删除"]];
            editView.delegate = self;
            [editView showInView:self.view.window];
        }
        else
        {
            if (!_inputBar.textField.isFirstResponder) {
                [_inputBar.textField becomeFirstResponder];
            }
            UIColor *color = [UIColor blackColor];
            _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"回复%@:",item.author_name] attributes:@{NSForegroundColorAttributeName: color}];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        NSArray *array = [self.dataSource objectAtIndex:indexPath.section];
        NotificationCommentItem *model = array[indexPath.row];
        return (model.conSize.height + 20);
    }else{
        NSArray *temArr = self.dataSource[indexPath.section];
        ObjectModel *model = temArr[_segmentIndex - 100];
        if ([model.content length] > 0) {
            if (model.showAll) {
                return MAX(model.contentSize.height + 13 + 13, 44);
            }
            else
            {
                if (model.contentSize.height > 34) {
                    return (model.isAllShow ? model.contentSize.height : 34) + 13 + 13 + 25;
                }
                else
                {
                    return MAX(model.contentSize.height + 13 + 13, 44);
                }
            }
            
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return 50;
    }else if (section == 2){
        NSArray *array = [self.dataSource objectAtIndex:section];
        return ([array count] > 0) ? 30 : 0;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [headView setBackgroundColor:[UIColor whiteColor]];
        [headView setUserInteractionEnabled:YES];
        
        NSMutableArray *tempArr = [NSMutableArray array];
        
        NSInteger read_num = 0;
        NSInteger unread_num = 0;
        for (int i = 0; i < 2; i++) {
            NSArray *array = [self.dataSource objectAtIndex:i];
            ObjectModel *item1 = array.firstObject;
            if (item1.content.length > 0) {
                NSArray *indexArr1 = [item1.content componentsSeparatedByString:@"、"];
                read_num += [indexArr1 count];
            }
            
            ObjectModel *item2 = array.lastObject;
            if (item2.content.length > 0) {
                NSArray *indexArr2 = [item2.content componentsSeparatedByString:@"、"];
                unread_num += [indexArr2 count];
            }
        }
        for (int i = 0; i < 2; i++) {
            if (i == 0) {
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld人已读", (long)read_num]];
                NSRange range1 = [[NSString stringWithFormat:@"%ld人已读", (long)read_num] rangeOfString:[NSString stringWithFormat:@"%ld",(long)read_num]];
                NSRange range2 = [[NSString stringWithFormat:@"%ld人已读", (long)read_num] rangeOfString:@"人已读"];
                [attr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range1];
                [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:range1];
                [attr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range2];
                [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:range2];
                [tempArr addObject:attr];
            }
            else {
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld人未读", (long)unread_num]];
                NSRange range1 = [[NSString stringWithFormat:@"%ld人未读", (long)unread_num] rangeOfString:[NSString stringWithFormat:@"%ld",(long)unread_num]];
                NSRange range2 = [[NSString stringWithFormat:@"%ld人未读", (long)unread_num] rangeOfString:@"人未读"];
                [attr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range1];
                [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:range1];
                [attr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range2];
                [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:range2];
                [tempArr addObject:attr];
            }
        }
        
        for (int i = 0; i < 2; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(SCREEN_WIDTH / 2 * i, 0, SCREEN_WIDTH / 2, 50)];
            [btn setTag:i + 100];
            //[btn setTitle:(i == 0) ? @"已读" : @"未读" forState:UIControlStateNormal];
            [btn setAttributedTitle:tempArr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:(i + 100 == _segmentIndex) ? [UIColor whiteColor] : CreateColor(245, 245, 247)];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btn addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventTouchUpInside];
            [headView addSubview:btn];
            
            if (i + 100 == _segmentIndex) {
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.frameWidth, 3)];
                [lineLabel setBackgroundColor:CreateColor(109, 132, 167)];
                [btn addSubview:lineLabel];
            }
        }
        
        return headView;
    }else if (section == 2){
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        [subView setBackgroundColor:[UIColor whiteColor]];
        //line
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        [lineView setBackgroundColor:CreateColor(215, 217, 218)];
        [subView addSubview:lineView];
        
        //button
        UIImageView *heartImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        [heartImg setImage:[UIImage imageNamed:@"s32.png"]];
        [subView addSubview:heartImg];
        //tip
        NSArray *array = [self.dataSource objectAtIndex:section];
        UILabel *subLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, SCREEN_WIDTH - 35, 20)];
        _tipLab = subLab;
        [subLab setFont:[UIFont systemFontOfSize:16]];
        [subLab setTextColor:CreateColor(160, 160, 160)];
        [subLab setBackgroundColor:[UIColor clearColor]];
        [subLab setText:[NSString stringWithFormat:@"一共%ld条回复",(unsigned long)[array count]]];
        [subView addSubview:subLab];
        
        return ([array count] > 0) ? subView : nil;
    }
    
    return nil;
}

- (void)segmentAction:(UIButton *)sender
{
    if (sender.tag == _segmentIndex) {
        return;
    }
    
    [sender setBackgroundColor:[UIColor whiteColor]];
    UIButton *lastBtn = (UIButton *)[sender.superview viewWithTag:_segmentIndex];
    if (lastBtn) {
        [lastBtn setBackgroundColor:CreateColor(245, 245, 247)];
    }
    
    _segmentIndex = sender.tag;
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
