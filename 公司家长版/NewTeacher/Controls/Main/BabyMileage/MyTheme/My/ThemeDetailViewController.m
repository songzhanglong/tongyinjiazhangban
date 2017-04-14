//
//  ThemeDetailViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ThemeDetailViewController.h"
#import "ThemeBatchModel.h"
#import "NSString+Common.h"
#import "ThemeBatchDetailModel.h"
#import "PublicScrollView.h"
#import "UIImage+Caption.h"
#import "Toast+UIView.h"
#import "DigAndComViewCell.h"
#import "ThemeDetailViewCell.h"
#import "MileageAllEditView.h"
#import "DJTShareView.h"
#import "MileageModel.h"

@interface ThemeDetailViewController ()<UITextFieldDelegate,MileageAllEditViewDelegate,DJTShareViewDelegate,UMSocialUIDelegate,PublicScrollViewDelegate,UIAlertViewDelegate>

@end

@implementation ThemeDetailViewController
{
    ThemeBatchDetailModel *_batchDetail;
    UITextField *_textFiled;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showBack = YES;
    self.useNewInterface = YES;
    //self.titleLable.text = _themeBatch.name;
    
    [self createRightButton];

    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getBatchDetail"];
    [param setObject:_themeBatch.batch_id forKey:@"batch_id"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [self createTableViewAndRequestAction:@"photo" Param:param Header:YES Foot:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self createTableHeaderView];
    [self beginRefresh];
    
    //
    _textFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width, 44)];
    [_textFiled setBackgroundColor:rgba(241, 245, 248, 1)];
    _textFiled.delegate = self;
    _textFiled.placeholder = @"写评论，限140字";
    _textFiled.font = [UIFont systemFontOfSize:12];
    _textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textFiled.textColor = [UIColor blackColor];
    _textFiled.returnKeyType = UIReturnKeySend;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    //监视键盘高度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)createRightButton
{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    [moreBtn setImage:CREATE_IMG(@"down4_1@2x") forState:UIControlStateHighlighted];
    [moreBtn setImage:CREATE_IMG(@"down4_2@2x") forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(deleteAndShareBatchDetail:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)deleteAndShareBatchDetail:(id)sender
{
    //此处弹出菜单
    MileageAllEditView *editView = [[MileageAllEditView alloc] initWithFrame:[UIScreen mainScreen].bounds Titles:@[@"删除",@"分享"] NImageNames:@[@"mileage_delete@2x",@"mileage_share@2x"] HImageNames:@[@"mileage_delete_1@2x",@"mileage_share_1@2x"]];
    editView.delegate = self;
    [editView showInView:self.view.window];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233, 233, 233);
    }
}

#pragma mark- MileageAllEditViewDelegate
- (void)selectEditIndex:(NSInteger)index
{
    if (index == 0) {//删除
        
        if (![_themeBatch.userid isEqualToString:[DJTGlobalManager shareInstance].userInfo.userid]) {
            [self.view.window makeToast:@"当前用户没有删除权限!" duration:1.0 position:@"center"];
            return;
        }
        
        if (self.httpOperation) {
            return;
        }
        
        if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
            [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            return;
        }
        
        [self.view.window makeToastActivity];
        _tableView.scrollEnabled = NO;
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        NSMutableDictionary *param = [manager requestinitParamsWith:@"photoBatchDelete"];
        [param setObject:_themeBatch.batch_id forKey:@"batch_id"];
        [param setObject:_themeBatch.album_id forKey:@"album_id"];
        
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
        [param setObject:text forKey:@"signature"];
        __weak typeof(self)weakSelf = self;
        self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"photo"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf deleteFinish:success Data:data];
        } failedBlock:^(NSString *description) {
            [weakSelf deleteFinish:NO Data:nil];
        }];
    }else if (index == 1){ //分享
        
        if (![DJTShareView isCanShareToOtherPlatform]) {
            [self.view.window makeToast:SHARE_TIP_INFO duration:1.0 position:@"center"];
            return;
        }
        
        DJTShareView *shareView = [[DJTShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [shareView setDelegate:self];
        [shareView showInView:self.view.window];
    }
}
#pragma mark - DJTShareViewDelegate
- (void)shareViewTo:(NSInteger)index
{
    NSString *str = [NSString stringWithFormat:@"http://wap.goonbaby.com/batch_share/a%@_b%@.htm",_themeBatch.album_id,_themeBatch.batch_id];
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            
            NSString *shareType = nil;
            if (index == 0) {
                [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
                [UMSocialData defaultData].extConfig.wechatSessionData.url = str;
//                [UMSocialData defaultData].extConfig.title = _themeBatch.name;
//                [UMSocialData defaultData].shareText = @"";
//                [UMSocialData defaultData].shareImage = @"";
                shareType = UMShareToWechatSession;
            }
            else if (index == 1)
            {
                [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = str;
                shareType = UMShareToWechatTimeline;
            }
            else if (index == 2)
            {
                [UMSocialData defaultData].extConfig.qqData.url = str;
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
                shareType = UMShareToQQ;
            }
            else
            {
                [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeMusic url:str];
                shareType = UMShareToSina;
            }
            
            NSString *lastStr = str;
            [[UMSocialControllerService defaultControllerService] setShareText:lastStr shareImage:nil socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:shareType].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        }
            break;
        case 4:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
        case 5:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = str;
        }
            break;
        case 6:
        {
            //[_webView reload];
            NSLog(@"%@",str);
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

- (void)sendMsg:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    if (_textFiled.isFirstResponder) {
        [_textFiled resignFirstResponder];
    }
    if ([_textFiled.text length] == 0) {
        [self.view makeToast:@"请先输入评论内容" duration:1.0 position:@"center"];
        return;
    }
    if ([_textFiled.text length] > 140) {
        [self.view makeToast:@"输入评论内容在140字之内" duration:1.0 position:@"center"];
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view.window makeToastActivity];
    _tableView.scrollEnabled = NO;
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"photoBatchReply"];
    [param setObject:_themeBatch.batch_id forKey:@"batch_id"];
    [param setObject:_themeBatch.album_id forKey:@"album_id"];
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

- (void)createTableHeaderView{
    if ([_themeBatch.photos count] > 0) {
        if ([_themeBatch.photos count] == 1) {
            ThemeBatchItem *item = [_themeBatch.photos firstObject];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 235)];
            [imgView setUserInteractionEnabled:YES];
            [imgView setContentMode:UIViewContentModeScaleAspectFit];
            [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImageView:)]];
            NSString *str = item.path;
            if (![str hasPrefix:@"http"]) {
                str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            if (item.type.integerValue != 0) {
                //video
                UIImageView *video = [[UIImageView alloc] initWithFrame:CGRectMake((imgView.frameWidth - 30) / 2, (imgView.frameHeight - 30) / 2, 30, 30)];
                [video setImage:CREATE_IMG(@"mileageVideo")];
                [imgView addSubview:video];
                BOOL mp4 = [[[item.thumb.lastPathComponent pathExtension] lowercaseString] isEqualToString:@"mp4"];
                if (mp4) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:str] atTime:1];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imgView setImage:image];
                        });
                    });
                }
                else{
                    NSString *tmpStr = item.thumb;
                    if (![tmpStr hasPrefix:@"http"]) {
                        tmpStr = [[G_IMAGE_ADDRESS stringByAppendingString:tmpStr ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    [imgView setImageWithURL:[NSURL URLWithString:tmpStr]];
                }
            }
            else{
                [imgView setImageWithURL:[NSURL URLWithString:str]];
            }
            [_tableView setTableHeaderView:imgView];
        }
        else
        {
            PublicScrollView *public = [[PublicScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 235)];
            public.autoScroll = NO;
            public.tipShow = YES;
            public.delegate = self;
            NSMutableArray *array = [NSMutableArray array];
            for (ThemeBatchItem *item in _themeBatch.photos) {
                [array addObject:item.path];
            }
            [public setImagesArrayFromModel:array];
            [_tableView setTableHeaderView:public];
        }
        
        if (_tableView.tableHeaderView) {
            NSArray *tipN = @[@"diggMileageN",@"commMileageN"];
            NSArray *tipH = @[@"diggMileageH",@"commMileageH"];
            for (NSInteger i = 0; i < 2; i++) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setBackgroundColor:[UIColor clearColor]];
                [button setTag:i + 1];
                [button setImage:CREATE_IMG(tipN[i]) forState:UIControlStateNormal];
                [button setImage:CREATE_IMG(tipH[i]) forState:UIControlStateHighlighted];
                [button setImage:CREATE_IMG(tipH[i]) forState:UIControlStateSelected];
                [button setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 40 - ((i == 0) ? 40 : 0), 198, 30, 30)];
                if (i == 0) {
                    button.selected = (_themeBatch.have_digg.integerValue != 0);
                }
                [button addTarget:self action:@selector(diggAndComm:) forControlEvents:UIControlEventTouchUpInside];
                [_tableView.tableHeaderView addSubview:button];
            }
        }
    }
}

- (void)touchImageAtIndex:(NSInteger)index ScrollView:(PublicScrollView *)pubSro
{
    [self lookImageAtIndex:index];
}
- (void)touchImageView:(UITapGestureRecognizer *)tap{
    [self lookImageAtIndex:0];
}
- (void)lookImageAtIndex:(NSInteger)index
{
    //图片
    _browserPhotos = [NSMutableArray array];
    for (int i = 0; i < _themeBatch.photos.count; i++) {
        ThemeBatchItem *item = _themeBatch.photos[i];
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
        
        if ([_themeBatch.digst length] > 0) {
            photo.caption = _themeBatch.digst;
        }
        [_browserPhotos addObject:photo];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:index];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    browser.canDeleteItem = [_themeBatch.userid isEqualToString:[DJTGlobalManager shareInstance].userInfo.userid];
    browser.showDiggNum = YES;
    [self.navigationController pushViewController:browser animated:YES];
}
//计算点赞人员高度
- (void)calculateDiggPeopleHei
{
    if ([_batchDetail.diggList count] == 0) {
        _batchDetail.diggHei = 0;
    }
    else{
        NSMutableArray *digArr = [NSMutableArray array];
        for (BatchDetailDiggItem *digg in _batchDetail.diggList) {
            [digArr addObject:digg.name];
        }
        
        NSString *strDig = [digArr componentsJoinedByString:@"、"];
        CGSize consize = [NSString calculeteSizeBy:strDig Font:[UIFont systemFontOfSize:12] MaxWei:[UIScreen mainScreen].bounds.size.width - 30 - 30 - 16 - 10];
        _batchDetail.diggHei = MAX(14, consize.height);
    }
}

- (void)diggAndComm:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    switch ([sender tag] - 1) {
        case 0:
        {
            if (_themeBatch.have_digg.integerValue != 0) {
                [self.view.window makeToast:@"您已点过赞" duration:1.0 position:@"center"];
                break;
            }
            
            //点赞
            if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
                [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
                return;
            }
            
            [self.view.window makeToastActivity];
            _tableView.scrollEnabled = NO;
            DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
            NSMutableDictionary *param = [manager requestinitParamsWith:@"photoBatchDigg"];
            [param setObject:_themeBatch.batch_id forKey:@"batch_id"];
            [param setObject:_themeBatch.album_id forKey:@"album_id"];
            
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

#pragma mark - 评论完毕
- (void)commentFinish:(BOOL)suc Data:(id)result
{
    [self.view.window hideToastActivity];
    _tableView.scrollEnabled = YES;
    self.httpOperation = nil;
    if (suc) {
        _themeBatch.replies = [NSNumber numberWithInteger:_themeBatch.replies.integerValue + 1];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        _textFiled.text = @"";
        //[_textFiled resignFirstResponder];
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeDiggAndComment)]) {
            [_delegate changeDiggAndComment];
        }
        [self beginRefresh];
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        [self.view.window makeToast:ret_msg ?: NET_WORK_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - 点赞完毕
- (void)diggestFinish:(BOOL)suc Data:(id)result
{
    _tableView.scrollEnabled = YES;
    [self.view.window hideToastActivity];
    self.httpOperation = nil;
    if (suc) {
        DJTUser *userInfo = [DJTGlobalManager shareInstance].userInfo;
        if (_themeBatch.have_digg.integerValue == 0) {
            _themeBatch.have_digg = [NSNumber numberWithInt:1];
            _themeBatch.digg = [NSNumber numberWithInteger:_themeBatch.digg.integerValue + 1];
            if (!_batchDetail.diggList) {
                [_batchDetail setDiggList:(NSMutableArray<BatchDetailDiggItem> *)[NSMutableArray array]];
            }
            BatchDetailDiggItem *item = [[BatchDetailDiggItem alloc] init];
            item.mid = userInfo.mid;
            item.name = userInfo.realname;
            item.author_id = userInfo.baby_id;
            item.is_teacher = @"0";
            item.face = userInfo.face;
            _batchDetail.digg = _themeBatch.digg;
            [_batchDetail.diggList addObject:item];
        }
        else{
            _themeBatch.have_digg = [NSNumber numberWithInteger:0];
            _themeBatch.digg = [NSNumber numberWithInteger:_themeBatch.digg.integerValue - 1];
            for (BatchDetailDiggItem *item in _batchDetail.diggList) {
                if ([item.author_id isEqualToString:userInfo.baby_id] && [item.mid isEqualToString:userInfo.mid]) {
                    [_batchDetail.diggList removeObject:item];
                    break;
                }
            }
        }
        [self calculateDiggPeopleHei];
        
        UIButton *button = (UIButton *)[_tableView.tableHeaderView viewWithTag:1];
        button.selected = (_themeBatch.have_digg.integerValue != 0);
        
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeDiggAndComment)]) {
            [_delegate changeDiggAndComment];
        }
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        [self.view.window makeToast:ret_msg ?: NET_WORK_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - 删除完毕
- (void)deleteFinish:(BOOL)suc Data:(id)result
{
    [self.view.window hideToastActivity];
    _tableView.scrollEnabled = YES;
    self.httpOperation = nil;
    if (suc) {
        if (_delegate && [_delegate respondsToSelector:@selector(deleteThisBatch)]) {
            [_delegate deleteThisBatch];
        }
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        [self.view.window makeToast:ret_msg ?: NET_WORK_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - 批次详情结果
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSError *error;
        ThemeBatchDetailModel *detail = [[ThemeBatchDetailModel alloc] initWithDictionary:ret_data error:&error];
        if (error) {
            NSLog(@"%@",error.description);
            [self.navigationController.view makeToast:@"此动态已经被删除" duration:1.0 position:@"center"];
            if (_delegate && [_delegate respondsToSelector:@selector(deleteThisBatch)]) {
                [_delegate deleteThisBatch];
            }else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            return;
        }
        
        for (BatchDetailReplyItem *reply in detail.replyList) {
            CGSize consize = [NSString calculeteSizeBy:reply.message Font:[UIFont systemFontOfSize:12] MaxWei:[UIScreen mainScreen].bounds.size.width - 30 - 30];
            reply.contentHei = consize.height;
        }
        _batchDetail = detail;
        _themeBatch.digst = detail.digst;
        _themeBatch.digg = detail.digg;
        _themeBatch.replies = detail.replies;
        _themeBatch.create_time = detail.create_time;
        _themeBatch.create_term = detail.create_term;
        _themeBatch.name = detail.name;
        _themeBatch.face = detail.face;
        _themeBatch.relation = detail.relation;
        _themeBatch.have_digg = [NSNumber numberWithInteger:[detail.have_digg integerValue]];
        CGSize consize = [NSString calculeteSizeBy:_themeBatch.digst Font:[UIFont systemFontOfSize:12] MaxWei:[UIScreen mainScreen].bounds.size.width - 30 - 30];
        _themeBatch.contentHei = consize.height;
        NSString *titleString = @"";
        if (_fromType == DetailFromFound) {
            titleString = [NSString stringWithFormat:@"%@的%@", (([detail.name length] > 0) ? [detail.name stringByReplacingCharactersInRange:NSMakeRange (0, 1) withString:@"*"] : @""), detail.relation ?: @""];
        }else if (_fromType == DetailFromMy || _fromType == DetailFromClassmates) {
            titleString = [NSString stringWithFormat:@"%@的%@",detail.name ?: @"",detail.relation ?: @""];
        }else if (_fromType == DetailFromClass) {
            titleString = [NSString stringWithFormat:@"%@老师",detail.name ?: @""];
        }
        //self.titleLable.text = titleString;
        UIButton *button = (UIButton *)[_tableView.tableHeaderView viewWithTag:1];
        button.selected = (_themeBatch.have_digg.integerValue != 0);
        
        [self calculateDiggPeopleHei];
        
        [_tableView reloadData];
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: NET_WORK_TIP duration:1.0 position:@"center"];
    }
    
}

#pragma mark - MWPhotoBrowserDelegate
- (void)delePicture:(NSInteger)index and:(MWPhotoBrowser *)browser
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"注意：与这张照片同时发布的一组照片都会被删除！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"全部删除", nil];
    [alert show];
}

- (ThemeBatchModel *)checkNumInfo:(NSInteger)index and:(MWPhotoBrowser *)browser
{
    return _themeBatch;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self selectEditIndex:0];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else{
        if (!_batchDetail) {
            return 0;
        }
        else{
            if (section == 1) {
                return ((_batchDetail.digg.integerValue == 0) && (_batchDetail.replies.integerValue == 0)) ? 0 : 1;
            }
            else{
                return _batchDetail.replyList.count;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = (indexPath.section == 0) ? @"preCellId" : ((indexPath.section == 1) ? @"digAndComCellId" : @"preCellId2");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (indexPath.section == 0) {
            cell = [[ThemeDetailViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            ((ThemeDetailViewCell *)cell).backView.backgroundColor = [UIColor whiteColor];
        }
        else if (indexPath.section == 1){
            cell = [[DigAndComViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        else{
            cell = [[ThemeDetailViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            ((ThemeDetailViewCell *)cell).backView.backgroundColor = rgba(236, 236, 236, 1);
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        NSString *timeStr = @"";
        if ([_themeBatch.create_time length] > 0) {
            NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:_themeBatch.create_time.doubleValue];
            timeStr = [NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate];
        }
        
        if ([_themeBatch.create_term length] > 0) {
            timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@" %@",_themeBatch.create_term]];
        }
        NSString *name = @"";
        if ([_themeBatch.is_teacher integerValue] == 1) {
            name = _themeBatch.name ?: @"";
        }else{
            if (_fromType == DetailFromFound) {
                name = [NSString stringWithFormat:@"%@小朋友", (([_themeBatch.name length] > 0) ? [_themeBatch.name stringByReplacingCharactersInRange:NSMakeRange (0, 1) withString:@"*"] : @"")];
            }else if (_fromType == DetailFromMy || _fromType == DetailFromClassmates) {
                name = [NSString stringWithFormat:@"%@的%@",_themeBatch.name ?: @"",_themeBatch.relation ?: @""];
            }
        }
       
        [(ThemeDetailViewCell *)cell resetHead:_themeBatch.face Name:name Time:timeStr Con:_themeBatch.digst Hei:_themeBatch.contentHei];
    }
    else if (indexPath.section == 1) {
        [(DigAndComViewCell *)cell resetDig:_batchDetail.diggList Count:_batchDetail.replies.integerValue Hei:_batchDetail.diggHei];
    }
    else if (indexPath.section == 2){
        [(ThemeDetailViewCell *)cell resetReplyDetail:_batchDetail.replyList[indexPath.row]];
    }
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_textFiled resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 10 + 16 + 10 + ((_themeBatch.contentHei > 0) ? (_themeBatch.contentHei + 10) : 10);
    }
    else if (indexPath.section == 1){
        CGFloat hei = 0;
        if (_batchDetail.diggHei > 0) {
            hei += 10 + _batchDetail.diggHei + 10 + 1;
        }
        if (_batchDetail.replies.integerValue > 0) {
            hei += 10 + 16 + 10;
        }
        return hei;
    }
    else{
        BatchDetailReplyItem *detail = _batchDetail.replyList[indexPath.row];
        return 10 + 16 + 10 + ((detail.contentHei > 0) ? (detail.contentHei + 10) : 10);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length] > 0) {
        [self sendMsg:nil];
    }
    else{
        [textField resignFirstResponder];
    }

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

@end
