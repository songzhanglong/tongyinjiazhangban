//
//  AddActivityViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/20.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "AddActivityViewController.h"
#import "UIImage+Caption.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "Toast+UIView.h"
#import "CTAssetsPickerController.h"
#import "SendToMotherViewController.h"
#import "UploadManager.h"
#import "NSString+Common.h"
#import "ParentModel.h"
#import "TeacherModel.h"
#import "CommonUtil.h"
#import "NSDate+Common.h"
#import "DJDBOperation.h"
#import "BabyMileageToClassViewController.h"
#import "MileagePermissionsViewController.h"
#import "MileageAllEditView.h"
#import "UIImage+FixOrientation.h"
#import "PlayViewController.h"

#define PLACE_TIP_MSG   @"这一刻的想法..."
#define PLACE_BABY_MSG   @"对孩子里程的寄语"

#pragma mark - 可删除视图
@class DeleteImageView;
@protocol DeleteImageViewDelegate <NSObject>

@optional
- (void)deleteImageView:(DeleteImageView *)imageView;
-(void)clickPhoto:(DeleteImageView *)imageView;
@end

@interface DeleteImageView : UIImageView

@property (nonatomic,assign)id<DeleteImageViewDelegate> delegate;
@property (nonatomic,readonly)UIImageView *videoImg;
@property (nonatomic,readonly) UIButton *clickPhoto;
@end

@implementation DeleteImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        _clickPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clickPhoto setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_clickPhoto setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [_clickPhoto setBackgroundColor:[UIColor clearColor]];
        [_clickPhoto addTarget:self action:@selector(clickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clickPhoto];
        
        UIButton *_deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBut setImage:[UIImage imageNamed:@"closed1.png"] forState:UIControlStateNormal];
        [_deleteBut setFrame:CGRectMake(frame.size.width - 25, 0, 25, 25)];
        [_deleteBut setBackgroundColor:[UIColor clearColor]];
        [_deleteBut addTarget:self action:@selector(deleteSelf:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBut];
        
        
        //video
        _videoImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _videoImg.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
        [_videoImg setImage:CREATE_IMG(@"mileageVideo")];
        _videoImg.hidden = YES;
        [self addSubview:_videoImg];
    }
    return self;
}

-(void)clickPhoto:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickPhoto:)]) {
        [_delegate clickPhoto:self];
    }
    
}

- (void)deleteSelf:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteImageView:)]) {
        [_delegate deleteImageView:self];
    }
    
    [self removeFromSuperview];
}

@end


@interface AddActivityViewController ()<DeleteImageViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,SendToMotherDelegate,UIScrollViewDelegate,UITextViewDelegate,BabyMileageToClassDelegate,MileagePermissionsDelegate,MileageAllEditViewDelegate>

@end

@implementation AddActivityViewController
{
    NSMutableArray *_peoples;           //选择人员
    NSMutableArray *_selectsIndexPath;  //记录选择人员
    
    UITextView *_textView;
    BOOL _isVideo,_isSynCircle;
    UIButton *_addBtn;
    
    UIScrollView *_imageContentScroll;
    NSString *_firstImagePath;
    int _indexType;             //记录选择权限
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = _mileageModel ? _mileageModel.name : @"";
    [self createRightBarButton];    //右侧按钮
    
    _peoples = [NSMutableArray array];
    _selectsIndexPath = [NSMutableArray array];
    
    _isVideo = (_videoPath ? YES : NO);
    _indexType = 3;
    _isSynCircle = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginChange:) name:UITextViewTextDidChangeNotification object:nil];
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [_tableView setSeparatorStyle:(_fromType == 0) ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = rgba(224, 224, 224, 1);
    _tableView.backgroundView = view;

    [self createTableHeadView];
}

- (void)createRightBarButton
{
    //返回按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    sureBtn.backgroundColor = [UIColor clearColor];
    [sureBtn setImage:[UIImage imageNamed:@"gou1.png"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(makeSure:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)createTableHeadView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    [headView setBackgroundColor:[UIColor whiteColor]];
    if (_textView) {
        [_textView removeFromSuperview];
        [_imageContentScroll removeFromSuperview];
        
        [headView addSubview:_textView];
        [headView addSubview:_imageContentScroll];
    }
    else{
        //text
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 60)];
        _textView.text = (_fromType == 0) ? PLACE_TIP_MSG : PLACE_BABY_MSG;
        _textView.delegate = self;
        [headView addSubview:_textView];
        
        _imageContentScroll = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 75, SCREEN_WIDTH , 100)];
        _imageContentScroll.delegate = self;
        [headView addSubview:_imageContentScroll];
        if (_isVideo) {
            [self setVideoPathSubViews];
        }
        else
        {
            [self setImagePathSubViews];
        }
    }
    
    [headView setFrameHeight:_imageContentScroll.frameBottom];
    [_tableView setTableHeaderView:headView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)createVideoPath:(UIImage *)image
{
    if (_firstImagePath) {
        NSFileManager *fileMana = [NSFileManager defaultManager];
        if ([fileMana fileExistsAtPath:_firstImagePath]) {
            [fileMana removeItemAtPath:_firstImagePath error:nil];
        }
    }
    
    NSString *timeStr = [NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",timeStr];
    NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:fileName];
    @autoreleasepool {
        NSData *data = UIImageJPEGRepresentation(image, 1);
        [data writeToFile:filePath atomically:NO];
    }
    _firstImagePath = filePath;
}

#pragma mark - 上传
- (void)uploadImgsOrVideo:(NSString *)url Arr:(NSArray *)array
{
    UploadModel *model = [[UploadModel alloc] init];
    model.uploadUrl = url;
    if (_themeUrl) {
        NSString *original = _themeUrl.path;
        NSString *extension = [original pathExtension];
        NSString *thumbnail = [NSString stringWithFormat:@"%@_290_290.%@",[[original stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"],extension];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:original,@"path",thumbnail,@"thumb", nil];
        model.dataSource = [NSMutableArray arrayWithObject:dic];
    }
    model.imgs = array;
    model.isVideo = _isVideo;
    model.endUrl = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    model.dateTime=[NSString stringWithFormat:@"%.f",[NSDate getTimeIntev:[NSDate  new]]];
    model.account=[USERDEFAULT objectForKey:LOGIN_ACCOUNT];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *endDic = [manager requestinitParamsWith:@"addDynamic"];
    [endDic setObject:@"" forKey:@"tag"];
    [endDic setObject:@"" forKey:@"subject"];
    [endDic setObject:manager.userInfo.userid forKey:@"authorid"];
    [endDic setObject:manager.userInfo.uname forKey:@"author"];
    [endDic setObject:manager.userInfo.class_id forKey:@"class_id"];
    [endDic setObject:(_textView.text ? _textView.text : @"") forKey:@"message"];
    [endDic setObject:_mileageModel ? _mileageModel.album_id : @"0" forKey:@"album_id"];
    [endDic setObject:[NSString stringWithFormat:@"%ld", (long)_indexType] forKey:@"visual_type"];
    [endDic setObject:@"" forKey:@"ip"];
    NSString *type;
    if (_fromType == 0) {
        type = _mileageModel ? @"0" : @"1";
    }else {
        type = _isSynCircle ? @"0" : @"2";
    }
    [endDic setObject:type forKey:@"type"];
    if (_peoples.count > 0) {
        NSMutableArray *ids = [NSMutableArray array];
        for (id subObj in _peoples) {
            if ([subObj isKindOfClass:[TeacherModel class]]) {
                TeacherModel *model = (TeacherModel *)subObj;
                NSDictionary *dic = @{@"member_id":model.teacher_id,@"is_teacher":@"0",@"member_name":model.teacher_name};
                [ids addObject:dic];
            }
            else if ([subObj isKindOfClass:[ParentModel class]])
            {
                ParentModel *parent = (ParentModel *)subObj;
                NSDictionary *dic = @{@"member_id":parent.student_id,@"is_teacher":@"0",@"member_name":parent.name};
                [ids addObject:dic];
            }
            
        }
        NSData *json = [NSJSONSerialization dataWithJSONObject:ids options:NSJSONWritingPrettyPrinted error:nil];
        NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        NSString *notLine = [lstJson stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        notLine = [notLine stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        notLine = [notLine stringByReplacingOccurrencesOfString:@" " withString:@""];
        notLine = [notLine stringByReplacingOccurrencesOfString:@"\\" withString:@""];  //去除反斜杠
        [endDic setObject:notLine forKey:@"member_ids"];
    }
    else
    {
        [endDic setObject:@"[]" forKey:@"member_ids"];
    }
    
    model.endParam = endDic;
    model.froType = [NSString stringWithFormat:@"%ld",(long)_fromType];
    UploadManager *upManger = [UploadManager shareInstance];
    [[DJDBOperation shareInstance] insertNotUploadModel:model];
    [upManger.upModels addObject:model];
    [upManger startNextRequest];
    
    if ([self.navigationController.viewControllers containsObject:self]) {
        [self.view.window makeToast:@"已提交到后台上传队列" duration:1.0 position:@"center"];
        if (_fromType == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
}

- (void)uploadNormalCotent
{
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *endDic = [manager requestinitParamsWith:@"addDynamic"];
    [endDic setObject:@"" forKey:@"tag"];
    [endDic setObject:@"" forKey:@"subject"];
    [endDic setObject:manager.userInfo.userid forKey:@"authorid"];
    [endDic setObject:manager.userInfo.uname forKey:@"author"];
    [endDic setObject:manager.userInfo.class_id forKey:@"class_id"];
    [endDic setObject:_textView.text forKey:@"message"];
    [endDic setObject:_mileageModel ? _mileageModel.album_id :@"0" forKey:@"album_id"];
    [endDic setObject:[NSString stringWithFormat:@"%d", _indexType] forKey:@"visual_type"];
    [endDic setObject:@"" forKey:@"ip"];
    if (_videoPath) {
        NSURL *tmpUrl = [NSURL URLWithString:_videoPath];
        [endDic setObject:tmpUrl.path forKey:@"video"];
    }
    else if (_themeUrl){
        NSString *original = _themeUrl.path;
        NSString *extension = [original pathExtension];
        NSString *thumbnail = [NSString stringWithFormat:@"%@_290_290.%@",[[original stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"],extension];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:original,@"path",thumbnail,@"thumb", nil];
        NSData *json = [NSJSONSerialization dataWithJSONObject:@[dic] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        NSString *notLine = [lstJson stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        notLine = [notLine stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        notLine = [notLine stringByReplacingOccurrencesOfString:@" " withString:@""];
        notLine = [notLine stringByReplacingOccurrencesOfString:@"\\" withString:@""];  //去除反斜杠
        [endDic setObject:notLine forKey:@"img"];
    }
    NSString *type;
    if (_fromType == 0) {
        type = _mileageModel ? @"0" : @"1";
    }else {
        type = _isSynCircle ? @"0" : @"2";
    }
    [endDic setObject:type forKey:@"type"];
    if (_peoples.count > 0) {
        NSMutableArray *ids = [NSMutableArray array];
        for (id subObj in _peoples) {
            if ([subObj isKindOfClass:[TeacherModel class]]) {
                TeacherModel *model = (TeacherModel *)subObj;
                NSDictionary *dic = @{@"member_id":model.teacher_id,@"is_teacher":@"0",@"member_name":model.teacher_name};
                [ids addObject:dic];
            }
            else if ([subObj isKindOfClass:[ParentModel class]])
            {
                ParentModel *parent = (ParentModel *)subObj;
                NSDictionary *dic = @{@"member_id":parent.student_id,@"is_teacher":@"0",@"member_name":parent.name};
                [ids addObject:dic];
            }
            
        }
        NSData *json = [NSJSONSerialization dataWithJSONObject:ids options:NSJSONWritingPrettyPrinted error:nil];
        NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        NSString *notLine = [lstJson stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        notLine = [notLine stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        notLine = [notLine stringByReplacingOccurrencesOfString:@" " withString:@""];
        notLine = [notLine stringByReplacingOccurrencesOfString:@"\\" withString:@""];  //去除反斜杠
        [endDic setObject:notLine forKey:@"member_ids"];
    }
    else
    {
        [endDic setObject:@"[]" forKey:@"member_ids"];
    }
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:endDic];
    [endDic setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.view.userInteractionEnabled = NO;
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:endDic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf completeCommitContent:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf completeCommitContent:NO Data:nil];
    }];
}

- (void)completeCommitContent:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        if (_fromType == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - actions
- (void)makeSure:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    BOOL canCommit = NO;
    if (_isVideo) {
        canCommit = _videoPath ? YES : NO;
    }
    else
    {
        canCommit = ([self.dataSource count] > 0);
    }
    
    if (!canCommit) {
        if (!_textView.text || [_textView.text length] == 0) {
            [self.view makeToast:@"请先编辑内容" duration:1.0 position:@"center"];
            return;
        }
        else
        {
            NSString *newStr = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([newStr length] <= 0) {
                [self.view makeToast:@"不能全部输入空字符" duration:1.0 position:@"center"];
                return;
            }
        }
        
        if ([_textView.text isEqualToString:(_fromType == 0) ? PLACE_TIP_MSG : PLACE_BABY_MSG]) {
            [self.view makeToast:@"请先编辑内容" duration:1.0 position:@"center"];
            return;
        }
    }
    else
    {
        if ([_textView.text isEqualToString:(_fromType == 0) ? PLACE_TIP_MSG : PLACE_BABY_MSG]) {
            _textView.text = @"";
        }
    }
    
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    
    //网络判断
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    if (_isVideo) {
        if (!_videoPath || [_videoPath hasPrefix:@"http"]) {
            //直接提交文本内容
            [self uploadNormalCotent];
        }
        else
        {
            [self uploadImgsOrVideo:[G_UPLOAD_NEWAUDIO stringByAppendingString:[DJTGlobalManager shareInstance].userInfo.userid] Arr:@[_videoPath,_firstImagePath]];
        }
        
    }
    
    else
    {
        if ([self.dataSource count] == 0) {
            //直接提交文本内容
            [self uploadNormalCotent];
        }
        else
        {
            if (([self.dataSource count] == 1) && _themeUrl) {
                [self uploadNormalCotent];
            }
            else
            {
                [self dealwithImgs];
                [self.view.window makeToast:@"已提交到后台上传队列" duration:1.0 position:@"center"];
                if (_fromType == 1) {
                    [self.navigationController popViewControllerAnimated:YES];
                }else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }
    }
    
}

- (void)dealwithImgs
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        NSString *timeStr = [NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]];
        NSString *imageDir = APPTmpDirectory;
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) )
        {
            [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSInteger startIdx = _themeUrl ? 1 : 0;
        
        for (NSInteger i = startIdx; i < [self.dataSource count]; i++)
        {
            @autoreleasepool {
                NSString *fileName = [NSString stringWithFormat:@"%@%ld.jpg",timeStr,(long)i];
                NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:fileName];
                id subObj = self.dataSource[i];
                UIImage *image = nil;
                if ([subObj isKindOfClass:[UIImage class]]) {
                    image = (UIImage *)subObj;
                    if (!_mileageModel) {
                        image = [image scaleToSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
                    }
                }
                else
                {
                    ALAsset *asset = (ALAsset *)subObj;
                    if (!_mileageModel) {
                        image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                    }
                    else{
                        image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                        image = [image fixOrientation];
                    }
                }
            
                NSData *data = UIImageJPEGRepresentation(image, !_mileageModel ? 1 : 0.8);
                [data writeToFile:filePath atomically:NO];
            
                [array addObject:filePath];
            }
        }
        
        
        //图片上传队列
        NSDictionary *dicOne = @{@"id": [NSString stringWithFormat:@"%@",[DJTGlobalManager shareInstance].userInfo.userid],@"type": @"1",@"img": @[@"290,290"]};    //1－图片
        NSData *json = [NSJSONSerialization dataWithJSONObject:dicOne options:NSJSONWritingPrettyPrinted error:nil];
        NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        NSString *gbkStr = [lstJson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlPathImg = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self uploadImgsOrVideo:urlPathImg Arr:array];
        });
    });
}

- (void)addImageView:(id)sender
{
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    
    if (_isVideo) {
        if (_videoPath) {
            [self.view makeToast:@"视频一次最多只能添加一个" duration:1.0 position:@"center"];
            return;
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
            pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSArray * availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
            pickerView.videoMaximumDuration = 40;
            pickerView.delegate = self;
            [self presentViewController:pickerView animated:YES completion:NULL];
        }
    }
    else
    {
        if ([self.dataSource count] >= 9) {
            [self.view makeToast:@"图片一次最多只能添加9张" duration:1.0 position:@"center"];
            return;
        }
        
        if (self.httpOperation) {
            return;
        }
        MileageAllEditView *editView = [[MileageAllEditView alloc] initWithFrame:[UIScreen mainScreen].bounds Titles:@[@"相册",@"拍照"] NImageNames:@[@"s15@2x",@"fb1@2x"] HImageNames:@[@"s15_1@2x",@"fb1_1@2x"]];
        editView.delegate = self;
        [editView showInView:self.view.window];
    }
}

#pragma mark - MileageAllEditViewDelegate
- (void)selectEditIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc]init];
            picker.maximumNumberOfSelection = 9 - [self.dataSource count];
            picker.assetsFilter = [ALAssetsFilter allPhotos];
            
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:NULL];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - privite
/**
 *	@brief	添加一个视频
 *
 *	@param 	path 	视频路径
 */
- (void)addOneVideo:(NSString *)path
{
    if (_videoPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:_videoPath]) {
            [fileManager removeItemAtPath:_videoPath error:nil];
        }
    }
    
    _videoPath = path;
    //有视频的情况下
    DeleteImageView *deleteImg = [[DeleteImageView alloc] initWithFrame:CGRectMake(10, 5, 90, 90)];
    deleteImg.tag = 1;
    deleteImg.delegate = self;
    deleteImg.videoImg.hidden = NO;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage thumbnailImageForVideo:[NSURL fileURLWithPath:_videoPath] atTime:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            [deleteImg setImage:image];
            
            [weakSelf createVideoPath:image];
        });
    });
    [_imageContentScroll addSubview:deleteImg];
    _addBtn.frame = CGRectMake(10, 5, 90.0, 90.0);
}

#pragma mark - 视频，图片初始化
- (void)setVideoPathSubViews
{
    for (UIView *subView in _imageContentScroll.subviews) {
        [subView removeFromSuperview];
    }
    
    if (_videoPath) {
        //有视频的情况下
        DeleteImageView *deleteImg = [[DeleteImageView alloc] initWithFrame:CGRectMake(10, 5, 90, 90)];
        deleteImg.tag = 1;
        deleteImg.delegate = self;
        deleteImg.videoImg.hidden = NO;
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage thumbnailImageForVideo:[_videoPath hasPrefix:@"http"] ? [NSURL URLWithString:_videoPath] : [NSURL fileURLWithPath:_videoPath] atTime:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [deleteImg setImage:image];
                
                [weakSelf createVideoPath:image];
            });
        });
        
        [_imageContentScroll addSubview:deleteImg];
    }
    
    _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addBtn.hidden = _videoPath ? YES : NO;
    _addBtn.frame = CGRectMake(10, 5, 90.0, 90.0);
    _addBtn.backgroundColor = [UIColor clearColor];
    [_addBtn setImage:[UIImage imageNamed:@"+_big.png"] forState:UIControlStateNormal];
    [_addBtn addTarget:self action:@selector(addImageView:) forControlEvents:UIControlEventTouchUpInside];
    [_imageContentScroll addSubview:_addBtn];
}

/**
 *	@brief	图片
 */
- (void)setImagePathSubViews
{
    for (UIView *subView in _imageContentScroll.subviews) {
        [subView removeFromSuperview];
    }
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat margin = (winSize.width - 90 * 3) / 4;
    CGFloat yOri = 5;
    CGFloat xOri = margin;
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        NSInteger col = i % 3;
        
        id subObj = [self.dataSource objectAtIndex:i];
        DeleteImageView *deleteImg = [[DeleteImageView alloc] initWithFrame:CGRectMake((margin + 90) * col + margin, yOri, 90, 90)];
        deleteImg.tag = i + 1;
        deleteImg.delegate = self;
        deleteImg.videoImg.hidden = YES;
        if ([subObj isKindOfClass:[UIImage class]]) {
            [deleteImg setImage:(UIImage *)subObj];
        }
        else if ([subObj isKindOfClass:[ALAsset class]])
        {
            [deleteImg setImage:[UIImage imageWithCGImage:((ALAsset *)subObj).thumbnail]];
        }
        
        [_imageContentScroll addSubview:deleteImg];
        
        if (col == 2) {
            yOri += 90 + 5;
        }
        
        xOri = (margin + 90) * (((col == 2) ? -1 : col) + 1) + margin;
    }
    
    
    _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addBtn.frame = CGRectMake(xOri, yOri, 90.0, 90.0);
    _addBtn.backgroundColor = [UIColor clearColor];
    [_addBtn setImage:[UIImage imageNamed:@"+_big.png"] forState:UIControlStateNormal];
    [_addBtn addTarget:self action:@selector(addImageView:) forControlEvents:UIControlEventTouchUpInside];
    [_imageContentScroll addSubview:_addBtn];
    
    CGFloat rows = [self.dataSource count] / 3 + 1;
    CGRect conRect = _imageContentScroll.frame;
    [_imageContentScroll setFrame:CGRectMake(conRect.origin.x, conRect.origin.y, conRect.size.width, MIN(2, rows) * 95 + 5)];
    _imageContentScroll.contentSize = CGSizeMake(conRect.size.width, MAX(rows * 95 + 5, _imageContentScroll.frame.size.height));
}

- (void)resetSubFrames
{
    CGFloat rows = [self.dataSource count] / 3 + 1;
    CGRect conRect = _imageContentScroll.frame;
    [_imageContentScroll setFrame:CGRectMake(conRect.origin.x, conRect.origin.y, conRect.size.width, MIN(2, rows) * 95 + 5)];
    _imageContentScroll.contentSize = CGSizeMake(conRect.size.width, MAX(rows * 95 + 5, _imageContentScroll.frame.size.height));
    [self createTableHeadView];
}

#pragma mark - BabyMileageToClassDelegate
- (void)synchronizedTheme:(MileageModel *)model PermissionsType:(int)indexType
{
    _mileageModel = model;
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setDesSelectButton
{
    _mileageModel = nil;
    _indexType = 3;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - MileagePermissionsDeleage
- (void)permissionsToSelect:(int)indexType
{
    _indexType = indexType;
    if (_fromType == 0) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:3]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        if (_indexType == 1) {
            _isSynCircle = NO;
        }
        [_tableView reloadData];
    }
}

- (void)sendBtnAction:(UIButton *)sender
{
    _isSynCircle = !_isSynCircle;
    sender.selected = !sender.selected;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    //fromType ＝ 0，是从班级圈选择的
    switch (section) {
        case 0:
        {
            //谁可以看
            count = (_fromType == 0) ? 0 : 1;
        }
            break;
        case 1:
        {
            //同步到班级圈
            count = (_fromType == 0) ? 0 : ((_indexType == 1) ? 0 : 1);
        }
            break;
        case 2:
        {
            //提醒谁看
            count = (_fromType == 0) ? 1 : 0;
        }
            break;
        case 3:
        {
            //同时发布到宝宝里程
            if (_fromType == 0) {
                count = _mileageModel ? 3 : 2;
            }
            else{
                count = 0;
            }
        }
            break;
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifyString = [NSString stringWithFormat:@"addActivityCell%ld",(long)indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifyString];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifyString];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        if (indexPath.section == 0)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 20, 20)];
            imgView.image = CREATE_IMG(@"mileage_see");
            [cell.contentView addSubview:imgView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 10, 7, SCREEN_WIDTH - imgView.frameRight - 40, 30)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont systemFontOfSize:14]];
            label.text = @"谁可以看...";
            [cell.contentView addSubview:label];
        }
        else if (indexPath.section == 1)
        {
            //makeSureButton
            UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
            sendButton.frame = CGRectMake( 20, 7, 30, 30);
            sendButton.layer.masksToBounds = YES;
            sendButton.layer.cornerRadius = 15;
            [sendButton setBackgroundColor:[UIColor clearColor]];
            [sendButton setImage:CREATE_IMG(@"bb2_1@2x") forState:UIControlStateSelected];
            [sendButton setImage:CREATE_IMG(@"bb2@2x") forState:UIControlStateNormal];
            [sendButton setTag:1];
            [sendButton addTarget:self action:@selector(sendBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            sendButton.selected = (_fromType == 0) ? NO : YES;
            //sendButton.enabled = NO;
            [cell.contentView addSubview:sendButton];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(sendButton.frameRight + 10, 7, SCREEN_WIDTH - sendButton.frameRight - 40, 30)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont systemFontOfSize:14]];
            label.text = @"同时发布到班级圈";
            [cell.contentView addSubview:label];
        }
        else if (indexPath.section == 2)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, SCREEN_WIDTH - 190, 30)];
            nameLabel.backgroundColor = [UIColor clearColor];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"@提醒谁看..."];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0] range:NSMakeRange(0,1)];
            //[str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 1)];
            [nameLabel setAttributedText:str];
            nameLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:nameLabel];
            
            for (NSInteger i = 0; i < 4; i++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 20 - 40 - i * (30 + 10), 7, 30, 30)];
                [imageView setTag:i + 1];
                imageView.layer.masksToBounds = YES;
                imageView.layer.cornerRadius = 15;
                [cell.contentView addSubview:imageView];
            }
        }
    }
    
    switch (indexPath.section) {
        case 0:
        {
            cell.detailTextLabel.text = (_indexType == 3) ? @"公开" : ((_indexType == 2) ? @"部分可见" : @"私密");
        }
            break;
        case 1:
        {
            UIButton *sendButton = (UIButton *)[cell.contentView viewWithTag:1];
            sendButton.selected = _isSynCircle;
        }
            break;
        case 2:
        {
            NSInteger count = _peoples.count;
            for (NSInteger i = 0; i < 4; i++) {
                UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:i + 1];
                if (i < count) {
                    imageView.hidden = NO;
                    id subObj = _peoples[i];
                    NSString *str = nil;
                    if ([subObj isKindOfClass:[TeacherModel class]]) {
                        str = ((TeacherModel *)subObj).face;
                    }
                    else if ([subObj isKindOfClass:[ParentModel class]])
                    {
                        str = ((ParentModel *)subObj).face;
                    }
                    NSString *url = [str hasPrefix:@"http"] ? str : [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
                    [imageView setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:CREATE_IMG(@"s21@2x")];
                }
                else{
                    imageView.hidden = YES;
                }
            }
        }
            break;
        case 3:
        {
            cell.accessoryType = (indexPath.row == 0) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = (indexPath.row == 0) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
            NSArray *tips = @[@"同时发布到宝宝里程",@"选择里程主题",@"设置里程权限"];
            cell.textLabel.text = tips[indexPath.row];
            
            if (indexPath.row == 1) {
                cell.detailTextLabel.text = _mileageModel.name;
            }
            else if (indexPath.row == 2){
                cell.detailTextLabel.text = (_indexType == 3) ? @"公开" : ((_indexType == 2) ? @"部分可见" : @"私密");
            }else {
                cell.detailTextLabel.text = @"";
            }

        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            MileagePermissionsViewController *permissor = [[MileagePermissionsViewController alloc] init];
            permissor.indexToType = [NSString stringWithFormat:@"%d",_indexType];
            permissor.delegate = self;
            [self.navigationController pushViewController:permissor animated:YES];
        }
            break;
        case 1:
        {
            _isSynCircle = !_isSynCircle;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case 2:
        {
            SendToMotherViewController *sendTo = [[SendToMotherViewController alloc] init];
            sendTo.delegate = self;
            sendTo.selectIndexArray = _selectsIndexPath;
            [self.navigationController pushViewController:sendTo animated:YES];
        }
            break;
        case 3:
        {
            if (indexPath.row == 1) {
                BabyMileageToClassViewController *controller = [[BabyMileageToClassViewController alloc] init];
                controller.selectModel = _mileageModel;
                controller.delegate = self;
                [self.navigationController pushViewController:controller animated:YES];
            }else if (indexPath.row == 2) {
                MileagePermissionsViewController *permissor = [[MileagePermissionsViewController alloc] init];
                permissor.indexToType = [NSString stringWithFormat:@"%d",_indexType];
                permissor.delegate = self;
                [self.navigationController pushViewController:permissor animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat hei = 0;
    if (_fromType == 0) {
        if (section == 2 || section == 3) {
            hei = 10;
        }
    }
    else{
        if (section == 0) {
            hei = 10;
        }
        else if (section == 1){
            hei = ((_indexType == 1) ? 0 : 10);
        }
    }
    
    return hei;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    switch (section) {
        case 0:
        {
            if (_fromType != 0) {
                view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
                [view setBackgroundColor:rgba(224, 224, 224, 1)];
            }
        }
            break;
        case 1:
        {
            if ((_fromType != 0) && (_indexType != 1)) {
                view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
                [view setBackgroundColor:rgba(224, 224, 224, 1)];
            }
        }
            break;
        case 2:
        case 3:
        {
            if (_fromType == 0) {
                view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
                [view setBackgroundColor:rgba(224, 224, 224, 1)];
            }
        }
            break;
        default:
            break;
    }
    
    return view;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
}

#pragma mark - DeleteImageViewDelegate
- (void)deleteImageView:(DeleteImageView *)imageView
{
    if (_isVideo) {
        if (_videoPath) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:_videoPath]) {
                [fileManager removeItemAtPath:_videoPath error:nil];
            }
            _videoPath = nil;
            _addBtn.hidden = NO;
        }
    }
    else
    {
        if (imageView.tag == 1) {
            _themeUrl = nil;    //主题url删除，图片需要新提交，否则第一个图片提交地址即可
        }
        
        CGRect preRec = imageView.frame;
        NSInteger count = [self.dataSource count];
        [self.dataSource removeObjectAtIndex:imageView.tag - 1];
        for (NSInteger i = imageView.tag + 1; i <= count ; i++) {
            UIView *tempView = [_imageContentScroll viewWithTag:i];
            CGRect nextRec = tempView.frame;
            tempView.frame = preRec;
            tempView.tag -= 1;
            
            preRec = nextRec;
        }
        
        //button
        CGRect butRec = _addBtn.frame;
        [_addBtn setFrame:preRec];
        if (butRec.origin.y != preRec.origin.y) {
            [self resetSubFrames];
        }
    }
}

-(void)clickPhoto:(DeleteImageView *)imageView
{
    if (_isVideo) {
        return;
    }
    _browserPhotos = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < [self.dataSource count]; i++) {
        ALAsset *asset = self.dataSource[i];
        MWPhoto *photo = nil;
        if ([asset isKindOfClass:[UIImage class]]) {
            photo = [MWPhoto photoWithImage:(UIImage *)asset];
        }
        else{
            photo = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
        }
        
        [_browserPhotos addObject:photo];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:imageView.tag - 1];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    //[picker dismissViewControllerAnimated:YES completion:nil];
    NSInteger count = [self.dataSource count];
    //去除重复选择的图片
    BOOL isEx=false;
    NSArray *array = assets;
    for (int i=0; i<[array count]; i++) {
        ALAsset *asset=[array objectAtIndex:i];
        isEx=true;
        NSURL *fileName = [ asset valueForProperty:ALAssetPropertyAssetURL ] ;;
        for(int j=0;j<count;j++){
            ALAsset *_dataAsset=[self.dataSource objectAtIndex:j];
            if (![_dataAsset isKindOfClass:[UIImage class]]) {
                NSURL *dataFileName = [ _dataAsset valueForProperty:ALAssetPropertyAssetURL ] ;
                if ([fileName.absoluteString isEqualToString:dataFileName.absoluteString]) {
                    isEx=false;
                    break;
                }
            }
            
        }
        if (isEx) {
            [self.dataSource addObject:asset];
        }
    }
    [self setImagePathSubViews];
    [self resetSubFrames];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL video = (picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModeVideo);

    if (video) {
        [picker dismissViewControllerAnimated:NO completion:nil];
        //保存视频
        NSString *videoPath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL]path];
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
        PlayViewController *play = [[PlayViewController alloc] init];
        play.fileUrl = [NSURL fileURLWithPath:videoPath];
        __weak typeof(self)weakSelf = self;
        play.playResult = ^(NSString *path){
            [weakSelf addOneVideo:path];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:play];
        [self.navigationController.tabBarController presentViewController:nav animated:YES completion:NULL];
    }else {
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        image = [image fixOrientation];
        [self.dataSource addObject:image];
        [self setImagePathSubViews];
        [self resetSubFrames];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//把视频写入相册回调函数
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    /*
    if(!error){
        [self.view makeToast:@"视频文件保存成功" duration:1.0 position:@"center"];
    }else{
        [self.view makeToast:@"视频文件保存失败" duration:1.0 position:@"center"];
    }
    */
}

#pragma mark - SendToMotherDelegate
- (void)sendToPeople:(NSArray *)people IndexArray:(NSArray *)index
{
    [_selectsIndexPath removeAllObjects];
    [_selectsIndexPath addObjectsFromArray:index];
    
    [_peoples removeAllObjects];
    [_peoples addObjectsFromArray:people];
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:(_fromType == 0) ? PLACE_TIP_MSG : PLACE_BABY_MSG]) {
        textView.text = @"";
    }
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    
//    return YES;
//}

- (void)textViewDidBeginChange:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if (textView != _textView) {
        return;
    }
    
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
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
        [_textView setText:lastStr];
    }
    
}

@end
