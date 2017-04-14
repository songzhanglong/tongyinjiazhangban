//
//  MyThemeViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyThemeViewController.h"
#import "MileageModel.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "ThemeBatchViewCell.h"
#import "ThemeDetailViewController.h"
#import "UIImage+Caption.h"
#import "MyThemeManagerController.h"

@interface MyThemeViewController ()<ThemeBatchViewCellDelegate,ThemeDetailViewControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate>

@end

@implementation MyThemeViewController
{
    UITextField *_textFiled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *backColor = CreateColor(231, 231, 231);
    self.view.backgroundColor = backColor;
    
    self.useNewInterface = YES;
    _pageCount = 10;
    [self startRequestData];
    
    //
    _textFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, self.view.frameHeight, self.view.frameWidth, 44)];
    [_textFiled setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [_textFiled setBackgroundColor:rgba(241, 245, 248, 1)];
    _textFiled.delegate = self;
    _textFiled.placeholder = @"写评论，限140字";
    _textFiled.font = [UIFont systemFontOfSize:12];
    _textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textFiled.textColor = [UIColor blackColor];
    _textFiled.returnKeyType = UIReturnKeyDone;
    _textFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:_textFiled];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _textFiled.frameWidth, 1)];;
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [_textFiled addSubview:lineView];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12 + 55, 44)];
    [rightView setBackgroundColor:_textFiled.backgroundColor];
    UIButton *sendBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBut setFrame:CGRectMake(6, 8.5, 54, 27)];
    [sendBut addTarget:self action:@selector(sendMsg:) forControlEvents:UIControlEventTouchUpInside];
    [sendBut setTitle:@"发送" forState:UIControlStateNormal];
    [sendBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendBut.titleLabel.font = [UIFont systemFontOfSize:14];
    [sendBut setBackgroundColor:rgba(0, 122, 255, 1)];
    sendBut.layer.masksToBounds = YES;
    sendBut.layer.cornerRadius = 3;
    [rightView addSubview:sendBut];
    [_textFiled setRightView:rightView];
    [_textFiled setRightViewMode:UITextFieldViewModeAlways];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
    leftView.backgroundColor = [UIColor clearColor];
    [_textFiled setLeftView:leftView];
    [_textFiled setLeftViewMode:UITextFieldViewModeAlways];
    
}

- (void)changeTypeByParent
{
    [(MyThemeManagerController *)self.parentViewController changeRightType:1];
}

- (void)startRefreshToCurrController
{
    [self beginRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self changeTypeByParent];
    
    if (_shouldRefresh) {
        _shouldRefresh = NO;
        [self beginRefresh];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    //监视键盘高度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)startRequestData
{
    [self createTableViewAndRequestAction:nil Param:nil Header:YES Foot:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    [self beginRefresh];
}

- (void)beginToFindBaby
{
    if ([self isRefreshing]) {
        return;
    }
    NSLog(@"开始找宝宝");
}

- (void)sendMsg:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    if (_textFiled.isFirstResponder) {
        [_textFiled resignFirstResponder];
    }
    
    UINavigationController *nav = nil;
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        nav = self.parentViewController.navigationController;
    }
    else{
        nav = self.parentViewController.parentViewController.navigationController;
    }
    
    if ([_textFiled.text length] == 0) {
        [nav.view makeToast:@"请先输入评论内容" duration:1.0 position:@"center"];
        return;
    }
    if ([_textFiled.text length] > 140) {
        [nav.view makeToast:@"输入评论内容在140字之内" duration:1.0 position:@"center"];
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [nav.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [nav.view makeToastActivity];
    nav.view.userInteractionEnabled = NO;
    ThemeBatchModel *batch = self.dataSource[_indexPath.section];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"photoBatchReply"];
    [param setObject:batch.batch_id forKey:@"batch_id"];
    [param setObject:batch.album_id forKey:@"album_id"];
    [param setObject:_textFiled.text forKey:@"message"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"photo"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf commentFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf commentFinish:NO Data:nil];
    }];
}

#pragma mark - 评论完毕
- (void)commentFinish:(BOOL)suc Data:(id)result
{
    UINavigationController *nav = nil;
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        nav = self.parentViewController.navigationController;
    }
    else{
        nav = self.parentViewController.parentViewController.navigationController;
    }
    [nav.view hideToastActivity];
    nav.view.userInteractionEnabled = YES;
    self.httpOperation = nil;
    if (suc) {
        ThemeBatchModel *batch = self.dataSource[_indexPath.section];
        batch.replies = [NSNumber numberWithInteger:batch.replies.integerValue + 1];
        [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        _textFiled.text = @"";
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        [nav.view makeToast:ret_msg ?: NET_WORK_TIP duration:1.0 position:@"center"];
    }
}


#pragma mark - ClassmateViewController,FindPeopleViewController重载
- (void)createTableHeaderView{
    
    if ([_mileage.digst length] > 0) {
        if (!_tableView.tableHeaderView) {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            
            UIFont *font = [UIFont systemFontOfSize:12];
            CGSize textSize = [NSString calculeteSizeBy:_mileage.digst Font:font MaxWei:winSize.width - 50];
            CGFloat textHei = MAX(14, textSize.height);
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 20 + textHei + 8 + 8)];
            [headView setBackgroundColor:_tableView.backgroundColor];
            
            UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, winSize.width, 20 + textHei)];
            [midView setBackgroundColor:[UIColor whiteColor]];
            [headView addSubview:midView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, winSize.width - 50, textHei)];
            [label setText:_mileage.digst];
            [label setFont:font];
            [label setNumberOfLines:0];
            [midView addSubview:label];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29.5, 22.5)];
            [imgView setBackgroundColor:[UIColor clearColor]];
            [imgView setImage:CREATE_IMG(@"leftTrangle")];
            [midView addSubview:imgView];
            UILabel *myLay = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
            [myLay setBackgroundColor:[UIColor clearColor]];
            [myLay setTextAlignment:1];
            [myLay setFont:[UIFont systemFontOfSize:10]];
            [myLay setText:([_mileage.mileage_type integerValue] == 1) ? @"我" : (([_mileage.mileage_type integerValue] == 2) ?@"班" : @"荐")];
            [myLay setTextColor:CreateColor(82, 78, 128)];
            [midView addSubview:myLay];
            
            [_tableView setTableHeaderView:headView];
        }
    }
    else{
        [_tableView setTableHeaderView:nil];
    }
    
}

- (void)createTableFooterView{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 30 + 100 + 30 + 18 + 15 + 14 + 15 + 14 + 30)];
        [footView setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 30, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:@"无照片或小视频"];
        [footView addSubview:label];
        
        UIFont *font = [UIFont systemFontOfSize:10];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, label.frameBottom + 15, winSize.width, 14)];
        [label1 setTextColor:[UIColor darkGrayColor]];
        [label1 setFont:font];
        [label1 setText:@"您可以通过点击  "];
        [label1 sizeToFit];
        [footView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:label1.frame];
        [label2 setTextColor:[UIColor darkGrayColor]];
        [label2 setFont:font];
        [label2 setText:@"  添加照片或小视频"];
        [label2 sizeToFit];
        [footView addSubview:label2];
        
        UIImageView *addView = [[UIImageView alloc] initWithFrame:CGRectMake(0, label1.frameY - 3, 20, 20)];
        [addView setImage:CREATE_IMG(@"addMileageN")];
        [footView addSubview:addView];
        [label1 setFrameX:(winSize.width - label1.frameWidth - label2.frameWidth - addView.frameWidth) / 2];
        [addView setFrameX:label1.frameRight];
        [label2 setFrameX:addView.frameRight];
        
        UILabel *lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(label1.frameX, label1.frameBottom + 15, winSize.width - label1.frameX * 2, 14)];
        [lastLabel setTextColor:[UIColor darkGrayColor]];
        [lastLabel setFont:font];
        [lastLabel setText:@"记录宝贝成长每一步"];
        [lastLabel setTextAlignment:1];;
        [footView addSubview:lastLabel];
        
        [_tableView setTableFooterView:footView];
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAlbumPhotos"];
    [param setObject:_mileage.album_id ?: @"" forKey:@"album_id"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
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
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error;
            ThemeBatchModel *themeBatch = [[ThemeBatchModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:themeBatch];
        }
        
        self.dataSource = array;
    }
    else{
        self.dataSource = nil;
    }
    [_tableView reloadData];
    [self createTableHeaderView];
    [self createTableFooterView];
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
            ThemeBatchModel *themeBatch = [[ThemeBatchModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:themeBatch];
            [set addIndex:count++];
        }
        
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        [self.dataSource addObjectsFromArray:array];
        [_tableView insertSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if ([self.dataSource count] == array.count) {
            [self createTableHeaderView];
        }
        
        [self createTableFooterView];
    }
    else{
        if (_pageIdx > 1) {
            _pageIdx -= 1;
        }
    }
}

#pragma mark - ThemeBatchViewCellDelegate
- (void)selectThemeBatchCell:(UITableViewCell *)cell At:(NSInteger)index
{
    if ([self isRefreshing]) {
        [self.view.window makeToast:@"网络正在刷新,请稍候" duration:1.0 position:@"center"];
        return;
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _indexPath = indexPath;
    //图片
    _browserPhotos = [NSMutableArray array];
    ThemeBatchModel *model = self.dataSource[indexPath.section];
    for (int i = 0; i < model.photos.count; i++) {
        ThemeBatchItem *item = model.photos[i];
        NSString *path = item.path;
        if (![path hasPrefix:@"http"]) {
            path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
        }
        MWPhoto *photo = nil;
        
        if (item.type.integerValue != 0) {
            BOOL mp4 = [[[[item.thumb lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
            if (mp4) {
                photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:path]]];
            }
            else{
                NSString *tmpStr = item.thumb;
                if (![tmpStr hasPrefix:@"http"]) {
                    tmpStr = [G_IMAGE_ADDRESS stringByAppendingString:tmpStr ?: @""];
                }
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:tmpStr]];
            }
            photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo.isVideo = YES;
        }
        else
        {
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
            NSURL *url = [NSURL URLWithString:path];
            photo = [MWPhoto photoWithURL:url];
        }
        if ([model.digst length] > 0) {
            photo.caption = model.digst;
        }
        
        [_browserPhotos addObject:photo];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:index];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    browser.canDeleteItem = [model.userid isEqualToString:[DJTGlobalManager shareInstance].userInfo.userid];
    browser.showDiggNum = [self showDiggAndCommentNum];
    
    [self.parentViewController.navigationController pushViewController:browser animated:YES];
}

- (BOOL)showDiggAndCommentNum
{
    return YES;
}

- (void)selectThemeBatchCell:(UITableViewCell *)cell Dig:(NSInteger)index
{
    if ([self isRefreshing]) {
        [self.view.window makeToast:@"网络正在刷新,请稍候" duration:1.0 position:@"center"];
        return;
    }
    
    _indexPath = [_tableView indexPathForCell:cell];
    
    switch (index) {
        case 0:
        {
            //点赞
            UINavigationController *nav = nil;
            if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
                nav = self.parentViewController.navigationController;
            }
            else{
                nav = self.parentViewController.parentViewController.navigationController;
            }
            if ([self isRefreshing]) {
                [nav.view makeToast:@"网络正在刷新,请稍候" duration:1.0 position:@"center"];
                return;
            }
            
            if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
                [nav.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
                return;
            }
            
            ThemeBatchModel *batch = self.dataSource[_indexPath.section];
            if (batch.have_digg.integerValue != 0) {
                [nav.view makeToast:@"已点过赞" duration:1.0 position:@"center"];
                break;
            }
            
            [nav.view makeToastActivity];
            nav.view.userInteractionEnabled = NO;
            
            DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
            NSMutableDictionary *param = [manager requestinitParamsWith:@"photoBatchDigg"];
            [param setObject:batch.batch_id forKey:@"batch_id"];
            [param setObject:batch.album_id forKey:@"album_id"];
            
            NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
            [param setObject:text forKey:@"signature"];
            __weak typeof(self)weakSelf = self;
            self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"photo"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
                [weakSelf diggestFinish:success Data:data];
            } failedBlock:^(NSString *description) {
                [weakSelf diggestFinish:NO Data:nil];
            }];
        }
            break;
        case 1:
        {
            //评论
            [_textFiled becomeFirstResponder];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 点赞完毕
- (void)diggestFinish:(BOOL)suc Data:(id)result
{
    UINavigationController *nav = nil;
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        nav = self.parentViewController.navigationController;
    }
    else{
        nav = self.parentViewController.parentViewController.navigationController;
    }
    nav.view.userInteractionEnabled = YES;
    [nav.view hideToastActivity];
    self.httpOperation = nil;
    if (suc) {
        ThemeBatchModel *batch = self.dataSource[_indexPath.section];
        batch.have_digg = [NSNumber numberWithInteger:1];
        batch.digg = [NSNumber numberWithInteger:batch.digg.integerValue + 1];
        [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        [nav.view makeToast:ret_msg ?: NET_WORK_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - ThemeDetailViewControllerDelegate
- (void)changeDiggAndComment
{
    [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteThisBatch
{
    [self.dataSource removeObjectAtIndex:_indexPath.section];
    [_tableView deleteSections:[NSIndexSet indexSetWithIndex:_indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    if ([self.dataSource count] == 0) {
        [self finishRefresh];
        [self createTableFooterView];
    }
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        [self.parentViewController.navigationController popToViewController:self.parentViewController animated:YES];
    }
    else if ([self.parentViewController.parentViewController isKindOfClass:[MileageBaseViewController class]])
    {
        [self.parentViewController.parentViewController.navigationController popToViewController:self.parentViewController.parentViewController animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_LICHENT object:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *themeBatchId = @"themeBatchCell";
    ThemeBatchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:themeBatchId];
    if (cell == nil) {
        cell = [[ThemeBatchViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:themeBatchId];
        cell.delegate = self;
    }
    
    [cell resetDataSource:self.dataSource[indexPath.section]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = _tableView.backgroundColor;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ThemeBatchModel *theme = self.dataSource[indexPath.section];
    CGFloat hei = 10 + 5 + 16 + 10;
    if ([theme.digst length] > 0) {
        hei += 16 + 5;
    }
    if ([theme.photos count] > 0) {
        NSInteger count = MIN(9, theme.photos.count);
        NSInteger row = (count - 1) / 3 + 1;
        CGFloat imgWei = ([UIScreen mainScreen].bounds.size.width - 50 - 10) / 3;
        hei += row * (imgWei + 5) - 5;
    }
    
    return hei;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 18;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *firstLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
    [firstLab setTextAlignment:1];
    [firstLab setBackgroundColor:CreateColor(82, 78, 128)];
    [firstLab setTextColor:[UIColor whiteColor]];
    [firstLab setFont:[UIFont systemFontOfSize:12]];
    [headerView addSubview:firstLab];
    
    DJTUser *userInfo = [DJTGlobalManager shareInstance].userInfo;
    UILabel *secondLab = [[UILabel alloc] initWithFrame:CGRectMake(firstLab.frameRight, 0, userInfo.class_nameWei, 18)];
    [secondLab setTextColor:firstLab.backgroundColor];
    [secondLab setFont:[UIFont systemFontOfSize:12]];
    [secondLab setTextAlignment:1];
    [secondLab setBackgroundColor:CreateColor(212, 213, 215)];
    [secondLab setText:[NSString stringWithFormat:@"%@ %@",userInfo.grade_name,userInfo.class_name]];
    [headerView addSubview:secondLab];
    
    ThemeBatchModel *theme = self.dataSource[section];
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:theme.create_time.doubleValue];
    [firstLab setText:[NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate]];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isRefreshing]) {
        [self.view.window makeToast:@"网络正在刷新,请稍候" duration:1.0 position:@"center"];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexPath = indexPath;
    
    ThemeBatchModel *theme = self.dataSource[indexPath.section];
    CGSize consize = [NSString calculeteSizeBy:theme.digst Font:[UIFont systemFontOfSize:12] MaxWei:[UIScreen mainScreen].bounds.size.width - 30 - 30];
    theme.contentHei = consize.height;
    ThemeDetailViewController *detail = [[ThemeDetailViewController alloc] init];
    detail.themeBatch = theme;
    detail.titleLable.text = self.mileage.name;
    detail.delegate = self;
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        [self.parentViewController.navigationController pushViewController:detail animated:YES];
    }
    else{
        [self.parentViewController.parentViewController.navigationController pushViewController:detail animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_textFiled resignFirstResponder];
}

#pragma mark - MWPhotoBrowserDelegate
- (void)delePicture:(NSInteger)index and:(MWPhotoBrowser *)browser
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"注意：与这张照片同时发布的一组照片都会被删除！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"全部删除", nil];
    [alert show];
}

- (ThemeBatchModel *)checkNumInfo:(NSInteger)index and:(MWPhotoBrowser *)browser
{
    ThemeBatchModel *model = self.dataSource[_indexPath.section];
    return model;
}

- (void)checkDetailInfo:(NSInteger)index and:(MWPhotoBrowser *)browser
{
    [self tableView:_tableView didSelectRowAtIndexPath:_indexPath];
}

#pragma mark - 删除完毕
- (void)deleteFinish:(BOOL)suc Data:(id)result
{
    UINavigationController *nav = nil;
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        nav = self.parentViewController.navigationController;
    }
    else{
        nav = self.parentViewController.parentViewController.navigationController;
    }
    nav.view.userInteractionEnabled = YES;
    [nav.view hideToastActivity];
    self.httpOperation = nil;
    if (suc) {
        [self deleteThisBatch];
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        [nav.view makeToast:ret_msg ?: NET_WORK_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UINavigationController *nav = nil;
        if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
            nav = self.parentViewController.navigationController;
        }
        else{
            nav = self.parentViewController.parentViewController.navigationController;
        }
        if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
            [nav.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            return;
        }
        
        
        nav.view.userInteractionEnabled = NO;
        [nav.view makeToastActivity];
        
        ThemeBatchModel *theme = self.dataSource[_indexPath.section];
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        NSMutableDictionary *param = [manager requestinitParamsWith:@"photoBatchDelete"];
        [param setObject:theme.batch_id forKey:@"batch_id"];
        [param setObject:theme.album_id forKey:@"album_id"];
        
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
        [param setObject:text forKey:@"signature"];
        __weak typeof(self)weakSelf = self;
        self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"photo"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf deleteFinish:success Data:data];
        } failedBlock:^(NSString *description) {
            [weakSelf deleteFinish:NO Data:nil];
        }];
    }
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    [_textFiled setFrameY:_tableView.frameBottom - 44 - keyboardRect.size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    [_textFiled setFrameY:_tableView.frameBottom];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField != _textFiled) {
        return;
    }
    
    NSString *toBeString = textField.text;
    NSString *lang = textField.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            [self emojiStrSplit:toBeString];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        [self emojiStrSplit:toBeString];
    }
}

- (void)emojiStrSplit:(NSString *)str
{
    int emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        int lenght = emoji % 10000;
        int location = emoji / 10000;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        if ([lastStr length] > 140) {
            lastStr = [lastStr substringToIndex:140];
        }
        [_textFiled setText:lastStr];
    }
    
}

@end
