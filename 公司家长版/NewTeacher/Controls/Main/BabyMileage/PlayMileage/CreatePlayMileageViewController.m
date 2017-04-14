//
//  CreatePlayMileageViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "CreatePlayMileageViewController.h"
#import "GrowAlbumListItem.h"
#import "NSString+Common.h"
#import "PublicScrollView.h"
#import "Toast+UIView.h"
#import "PlayMileageListController.h"
#import "SaveOrShareViewController.h"
#import "SelectPhotosMileageViewController.h"

@interface CreatePlayMileageViewController () <UITextFieldDelegate,PublicScrollViewDelegate,PublicScrollViewDelegate>

@end

@implementation CreatePlayMileageViewController
{
    UITextField *_nameField;
    NSInteger _maxLength;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.showBack = YES;
    [self createLeftBut];
    if (_createType > 0) {
        self.titleLable.text = @"编辑主题";
    }else{
        self.titleLable.text = @"确定照片/小视频";
    }
    self.view.backgroundColor = CreateColor(199, 200, 202);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    //bg
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    headView.backgroundColor = [UIColor whiteColor];
    headView.userInteractionEnabled = YES;
    [self.view addSubview:headView];
    
    //fields
    for (int i = 0; i < 2; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20 + 35 * i, 50, 30)];
        [label setBackgroundColor:[UIColor clearColor]];
        label.font = [UIFont systemFontOfSize:16];
        label.text = (i == 0) ? @"标题：" : @"内容：";
        [label setTextColor:[UIColor darkGrayColor]];
        [headView addSubview:label];
        
        if (i == 0) {
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(label.frameRight, 20, SCREEN_WIDTH - (label.frameRight + 5) - 20, 30)];
            [bgView setBackgroundColor:[UIColor clearColor]];
            [[bgView layer] setBorderWidth:1.0];
            [[bgView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
            [[bgView layer]setCornerRadius:15.0];
            [bgView.layer setMasksToBounds:YES];
            [headView addSubview:bgView];
            
            UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightBtn setImage:CREATE_IMG(@"play_edit") forState:UIControlStateNormal];
            [rightBtn setFrame:CGRectMake(0, 5, 20, 20)];
            UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, bgView.frameWidth - 20, 30)];
            textFiled.autocorrectionType = UITextAutocorrectionTypeNo;
            textFiled.contentVerticalAlignment = 0 ;
            textFiled.returnKeyType = UIReturnKeyDone;
            textFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textFiled.font = [UIFont systemFontOfSize:12];
            [textFiled setClearButtonMode:UITextFieldViewModeWhileEditing];
            textFiled.delegate = self;
            [textFiled setText:_editTitle ?: @""];
            [textFiled setTextColor:[UIColor darkTextColor]];
            textFiled.rightView = rightBtn;
            textFiled.rightViewMode = UITextFieldViewModeAlways;
            [bgView addSubview:textFiled];
            _nameField = textFiled;
            [textFiled setPlaceholder:@"和小伙伴去郊游"];
        }
        else{
            int count = 0;
            for (GrowAlbumListItem *model in _selectDataArray) {
                if (model.type.integerValue != 0) {
                    count++;
                }
            }
            UILabel *contLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.frameRight, 20 + 35, SCREEN_WIDTH - (label.frameRight + 5) - 20, 30)];
            [contLabel setBackgroundColor:[UIColor clearColor]];
            contLabel.font = [UIFont systemFontOfSize:14];
            contLabel.text = [NSString stringWithFormat:@"已经添加了%ld张照片/%ld个视频",(long)_selectDataArray.count - count,(long)count];
            [contLabel setTextColor:[UIColor darkGrayColor]];
            [headView addSubview:contLabel];
        }
    }
    
    [self addPublicImage:headView.frameBottom];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 42, SCREEN_WIDTH, 42)];
    [saveButton setBackgroundColor:CreateColor(240, 145, 26)];
    [saveButton setTitle:@"确定保存" forState:UIControlStateNormal];
    [saveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
}

- (void)createLeftBut
{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_1.png"] forState:UIControlStateSelected];
    [backBtn addTarget:self action:@selector(backToFather:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backBarButtonItem];
    
}

- (void)backToFather:(id)sender
{
    if (_createType == 3) {
        for (id controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[SelectPhotosMileageViewController class]]) {
                SelectPhotosMileageViewController *createController = (SelectPhotosMileageViewController *)controller;
                createController.theme_id = _theme_id;
                createController.album_id = _album_id;
                createController.editType = 3;
                createController.editTitle = [_nameField text];
                [self.navigationController popToViewController:createController animated:YES];
            }
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addPublicImage:(CGFloat)height
{
    //mileageVideo
    PublicScrollView *public = [[PublicScrollView alloc] initWithFrame:CGRectMake(0, height, SCREEN_WIDTH, SCREEN_HEIGHT - 42 - 64 - height)];
    public.autoScroll = NO;
    public.tipShow = YES;
    public.delegate = self;
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *types = [NSMutableArray array];
    for (GrowAlbumListItem *item in _selectDataArray) {
        if (item.type.integerValue != 0) {
            [array addObject:item.thumb];
            [types addObject:[NSNumber numberWithBool:YES]];
        }
        else
        {
            [array addObject:item.path];
            [types addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [public setCheckArr:types];
    [public setImagesArrayFromModel:array];
    [self.view addSubview:public];
}

#pragma mark - PublicScrollViewDelegate
- (void)playVideoAtIndex:(NSInteger)index ScrollView:(PublicScrollView *)pubSro
{
    GrowAlbumListItem *item = _selectDataArray[index];
    NSString *filePath = item.path;
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

- (void)saveAction:(id)sender
{
    if ([_nameField.text length] > 7 || [_nameField.text length] <= 0) {
        [self.view.window makeToast:@"请输入7个汉字" duration:1.0 position:@"center"];
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    if (_nameField.isFirstResponder){
        [_nameField resignFirstResponder];
    }
    __weak __typeof(self)weakSelf = self;
    
    NSMutableArray *ids = [NSMutableArray array];
    for (GrowAlbumListItem *item in _selectDataArray) {
        [ids addObject:item.photo_id];
    }
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSString *methods = (_createType > 0) ? @"updateMileagePlay" : @"createMileagePlay";
    NSMutableDictionary *param = [manager requestinitParamsWith:methods];
    [param setObject:_album_id forKey:@"album_id"];
    [param setObject:_nameField.text forKey:@"title"];
    if (_createType > 0) {
        [param setObject:_theme_id forKey:@"id"];
    }
    [param setObject:[ids componentsJoinedByString:@","] forKey:@"photo_ids"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    //针对新接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"mileage"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf submitFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf submitFinish:NO Data:nil];
    }];
}

#pragma mark - network
- (void)submitFinish:(BOOL)suc Data:(id)result{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    if (suc) {
        [self.navigationController.view makeToast:(_createType > 0) ? @"动态里程修改成功" : @"动态里程添加成功" duration:1.0 position:@"center"];
        id ret_data = [result valueForKey:@"ret_data"];
        //ret_data = (!ret_data || [ret_data isKindOfClass:[NSDictionary class]]) ? [NSDictionary dictionary] : ret_data;
        SaveOrShareViewController *shareController = [[SaveOrShareViewController alloc] init];
        shareController.shareUrl = [ret_data valueForKey:@"url"];
        shareController.album_id = [ret_data valueForKey:@"album_id"];
        shareController.theme_id = [ret_data valueForKey:@"id"];
        shareController.shareName = [_nameField text];
        shareController.albumItem = _selectDataArray[0];
        [self.navigationController pushViewController:shareController animated:YES];
    }
    else{
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - UITextFieldTextDidChangeNotification
- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField == _nameField) {
        _maxLength = 7;
    }
    else{
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
        if (_maxLength == 7) {
            [_nameField setText:lastStr];
        }
    }
    
    if ([lastStr length] > _maxLength) {
        lastStr = [lastStr substringToIndex:_maxLength];
        if (_maxLength == 7) {
            [_nameField setText:lastStr];
        }
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
