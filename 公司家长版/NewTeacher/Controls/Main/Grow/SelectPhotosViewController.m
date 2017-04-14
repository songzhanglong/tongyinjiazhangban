//
//  SelectPhotosViewController.m
//  NewTeacher
//
//  Created by szl on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectPhotosViewController.h"
#import "UIImage+Caption.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "HorizontalButton.h"
#import "CTAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+FixOrientation.h"
#import "GrowAlbumItem.h"
#import "SelectMileageView.h"
#import "GrowAlbumListItem.h"
#import "UIImage+Caption.h"
#import "SelectPhotosCell.h"
#import "SelectPhotosModel.h"
#import "PlayViewController.h"
#import "MakeGrowController.h"
#import "MWPhotoBrowser.h"
#import "ProgressCircleView.h"
#import "PhotoSource.h"
#import "YLZHoledView.h"

@interface SelectPhotosViewController ()<CTAssetsPickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,SelectMileageViewDelegate,UIAlertViewDelegate,MWPhotoBrowserDelegate,SelectPhotosCellDelegate,PhotoSourceDelegate>

@property (nonatomic, strong) YLZHoledView *holedView;

@end

@implementation SelectPhotosViewController
{
    BOOL _lastPage;
    NSInteger _pageIdx,_pageCount,_dealCount;
    
    NSMutableArray *_albumsList,*_imgsArr;
    HorizontalButton *_horiBut;
    UIView *_bottomView,*_tipView;
    
    //视频录制进度控制
    ProgressCircleView *_progressView;
    NSIndexPath *_indexPath;
    NSInteger _requestTime;
    UIButton *_rightBut;
    
    PhotoSource *_photoSource;
    
}

- (void)dealloc{
    [_photoSource.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.useNewInterface = YES;
    self.titleLable.text = [DJTGlobalManager shareInstance].userInfo.uname;
    self.titleLable.textColor = [UIColor whiteColor];
    
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    
    self.view.backgroundColor = CreateColor(33.0, 27.0, 25.0);
    
    _pageCount = 30;
    
    NSMutableArray *sourceArr = [NSMutableArray array];
    _browserPhotos = [NSMutableArray array];
    if ([_selectArray count] > 0) {
        for (SelectPhotosModel *item in _selectArray) {
            SelectPhotosModel *newItem = [item itemCopy];
            [sourceArr addObject:newItem];
        }
    }
    
    _photoSource = [[PhotoSource alloc] init];
    _photoSource.isSmallPicLimit = _isSmallPicLimit;
    _photoSource.resource = sourceArr;
    _photoSource.delegate = self;
    _photoSource.minWei = _minWei;
    _photoSource.minHei = _minHei;
    [_photoSource createCollectionViewTo:self.view];
    [_photoSource.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 26);
    [self createCollectionViewLayout:flowLayout Action:@"photo" Param:nil Header:YES Foot:YES];
    [_collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [_collectionView setFrame:CGRectMake(0, _photoSource.collectionView.contentSize.height, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44 - _photoSource.collectionView.contentSize.height)];
    [_collectionView registerClass:[SelectPhotosCell class] forCellWithReuseIdentifier:@"selectAlbumItem2"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"selectHeadCell"];
    [_collectionView setBackgroundColor:self.view.backgroundColor];
    _collectionView.alwaysBounceVertical = NO;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.frameWidth, 44)];
    _bottomView = bottomView;
    [bottomView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:bottomView];
    
    _horiBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
    _horiBut.leftText = YES;
    _horiBut.hidden = YES;
    _horiBut.imgSize = CGSizeMake(30, 30);
    [_horiBut addTarget:self action:@selector(selectAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [_horiBut setImage:CREATE_IMG(@"selectAlbum") forState:UIControlStateNormal];
    [_horiBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_horiBut.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_horiBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [bottomView addSubview:_horiBut];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBut = rightBut;
    [rightBut setFrame:CGRectMake(SCREEN_WIDTH - 75, 11.5, 65, 21)];
    [rightBut setBackgroundColor:rgba(25, 161, 86, 1)];
    [rightBut setTitle:[NSString stringWithFormat:@"完成(%ld/9)",(long)[_photoSource.resource count]] forState:UIControlStateNormal];
    [rightBut.titleLabel setFont:[UIFont systemFontOfSize:12]];
    rightBut.layer.masksToBounds = YES;
    rightBut.layer.cornerRadius = 2;
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut addTarget:self action:@selector(savePressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rightBut];
    
    if (_album_id) {
        _collectionView.alwaysBounceVertical = YES;
        [self beginRefresh];
        [self setLeftButtonTitle];
    }
    
    [self requestAlbumsList];
}

#pragma mark - Key-Value Observing methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [_collectionView setFrame:CGRectMake(0, _photoSource.collectionView.contentSize.height, SCREEN_WIDTH, SCREEN_HEIGHT - _photoSource.collectionView.contentSize.height - 64 - 44)];
    }
}

- (void)savePressed:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    if (_photoSource.resource.count == 0) {
        [self.view makeToast:@"您还未选择照片或视频" duration:1.0 position:@"center"];
    }
    else{
        [self finishSelect];
    }
}

- (void)createTipView
{
    if ([self.dataSource count] == 0 && self.httpOperation == nil) {
        if (!_tipView) {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, winSize.width, 128)];
            [_tipView setCenter:_collectionView.center];
            [_tipView setBackgroundColor:_collectionView.backgroundColor];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 0, 100, 100)];
            [imageView setImage:CREATE_IMG(@"contact_a")];
            [imageView setBackgroundColor:_tipView.backgroundColor];
            [_tipView addSubview:imageView];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frameBottom + 10, _tipView.frameWidth, 18)];
            [label1 setFont:[UIFont systemFontOfSize:14]];
            [label1 setTextColor:[UIColor whiteColor]];
            [label1 setBackgroundColor:_tipView.backgroundColor];
            [label1 setTextAlignment:NSTextAlignmentCenter];
            [label1 setText:@"对应里程中无照片或视频..."];
            [_tipView addSubview:label1];
        }
        [self.view addSubview:_tipView];
    }
    else{
        [_tipView removeFromSuperview];
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(33.0, 27.0, 25.0);
    }
    else
    {
        navBar.tintColor = CreateColor(33.0, 27.0, 25.0);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 上传视频
- (void)addVodeoPath:(NSString *)path
{
    self.view.userInteractionEnabled = NO;
    NSString *url = [G_UPLOAD_NEWAUDIO stringByAppendingString:[DJTGlobalManager shareInstance].userInfo.userid];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:url parameters:nil filePath:path ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf singleFinish:data Suc:success Path:path];
    } failedBlock:^(NSString *description) {
        [weakSelf singleFinish:nil Suc:NO Path:nil];
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [weakSelf uploadProgress:(CGFloat)totalBytesRead / totalBytesExpectedToRead tip:@"视频上传中..."];
    }];
}

- (void)singleFinish:(id)result Suc:(BOOL)suc Path:(NSString *)path
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    [_progressView removeFromSuperview];
    
    if (suc) {
        //视频不用处理宽高
        SelectPhotosModel *photoModel = [[SelectPhotosModel alloc] init];
        photoModel.videoFileStr = path;
        photoModel.videoStr = [result valueForKey:@"original"];
        photoModel.type = 1;
        photoModel.state = 2;
        [_photoSource.resource addObject:photoModel];
        [_rightBut setTitle:[NSString stringWithFormat:@"完成(%ld/9)",(long)[_photoSource.resource count]] forState:UIControlStateNormal];
        if ([_photoSource.resource count] > 0) {
            [self showTip];
        }
        [_photoSource.collectionView reloadData];
    }
    else{
        [self.view makeToast:@"视频上传失败" duration:1.0 position:@"center"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
    }
}

- (void)uploadProgress:(CGFloat)progress tip:(NSString *)tipStr
{
    if (!_progressView) {
        _progressView = [[ProgressCircleView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) / 2, (SCREEN_HEIGHT - 64 - 120) / 2, 120, 120)];
    }
    if (![_progressView isDescendantOfView:self.view]) {
        [self.view addSubview:_progressView];
    }
    [_progressView.loadingIndicator setProgress:progress animated:YES];
    [_progressView.progressLab setText:tipStr];
}

#pragma mark - 图片上传
- (void)uploadImgResource:(NSString *)filePath
{
    self.view.userInteractionEnabled = NO;
    NSDictionary *imageParam = @{@"id": [NSString stringWithFormat:@"%@",[DJTGlobalManager shareInstance].userInfo.userid],@"type": @"1"};    //1－图片
    NSData *json = [NSJSONSerialization dataWithJSONObject:imageParam options:NSJSONWritingPrettyPrinted error:nil];
    NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSString *gbkStr = [lstJson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
    __weak typeof(self)weakSelf = self;
    
    self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:url parameters:nil filePath:filePath ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf dealWithImageFinish:success Data:data Path:filePath];
    } failedBlock:^(NSString *description) {
        [weakSelf dealWithImageFinish:NO Data:nil Path:filePath];
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [weakSelf uploadProgress:(CGFloat)totalBytesRead / totalBytesExpectedToRead tip:@"图片上传中..."];
    }];
}

- (void)dealWithImageFinish:(BOOL)suc Data:(id)result Path:(NSString *)path
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    [_progressView removeFromSuperview];
    if (suc) {
        BOOL isFind = NO;
        for (SelectPhotosModel *sel_item in _photoSource.resource) {
            if (sel_item.isCover) {
                isFind = YES;
                break;
            }
        }
        SelectPhotosModel *photoModel = [[SelectPhotosModel alloc] init];
        photoModel.imageFileStr = path;
        photoModel.imgStr = [result valueForKey:@"original"];
        photoModel.type = 0;
        @autoreleasepool {
            UIImage *img = [UIImage imageWithContentsOfFile:path];
            CGSize imgSize = img.size;
            photoModel.width = [NSNumber numberWithFloat:imgSize.width];
            photoModel.height = [NSNumber numberWithFloat:imgSize.height];
        }
        photoModel.state = 2;
        photoModel.isCover = !isFind && (_isSmallPicLimit || (photoModel.width.floatValue >= _minWei && photoModel.height.floatValue >= _minHei));
        [_photoSource.resource addObject:photoModel];
        [_rightBut setTitle:[NSString stringWithFormat:@"完成(%ld/9)",(long)[_photoSource.resource count]] forState:UIControlStateNormal];
        if ([_photoSource.resource count] > 0) {
            [self showTip];
        }
        [_photoSource.collectionView reloadData];
    }
    else{
        [self.view makeToast:@"图片上传失败" duration:1.0 position:@"center"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
    }
}

- (void)convertImg:(UIImage *)img{
    self.view.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [img fixOrientation];
        NSString *imgPath = [NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]];
        imgPath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",imgPath]];
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        [data writeToFile:imgPath atomically:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf uploadImgResource:imgPath];
        });
    });
}

#pragma mark - actions
- (void)selectAlbum:(id)sender
{
    CGFloat hei = MIN(_albumsList.count * 60 + 38, SCREEN_HEIGHT - 64);
    SelectMileageView *mileageView = [[SelectMileageView alloc] initWithFrame:[UIScreen mainScreen].bounds Hei:hei];
    mileageView.selectedAlbumId = _album_id;
    mileageView.dataSource = _albumsList;
    mileageView.delegate = self;
    [mileageView showInView:self.view.window];
}

- (void)finishSelect{
    if (!self.view.userInteractionEnabled) {
        return;
    }
    
    if (_photoSource.resource.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    BOOL isFind = NO;
    for (NSInteger i = 0;i < _photoSource.resource.count;i++) {
        SelectPhotosModel * item = _photoSource.resource[i];
        if (item.isCover) {
            isFind = YES;
            if (item.imageFileStr.length == 0) {
                //下载
                NSString *url = item.imgStr;
                if (![url hasPrefix:@"http"]) {
                    url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                }
                [self downImageViewWith:url At:i];
                return;
            }
            else{
                //返回
                @autoreleasepool {
                    UIImage *img = [UIImage imageWithContentsOfFile:item.imageFileStr];
                    CGSize imgSize = img.size;
                    if (!_isSmallPicLimit && (imgSize.width < _minWei || imgSize.height < _minHei)) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您需要选择1张高清图片作为封面用于打印" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
                        [alertView show];
                    }
                    else{
                        [self dealWithFinish];
                    }
                }
                
                return;
            }
            break;
        }
    }
    
    [self.view makeToast:@"您需要选择1张高清照片作为封面用于打印" duration:1.0 position:@"center"];
}

- (void)setLeftButtonTitle{
    _horiBut.hidden = NO;
    
    _horiBut.textSize = [NSString calculeteSizeBy:_buttonTitle Font:_horiBut.titleLabel.font MaxWei:150];
    [_horiBut setFrame:CGRectMake(10, 7, 30 + _horiBut.textSize.width, 30)];
    [_horiBut setTitle:_buttonTitle forState:UIControlStateNormal];
}

- (void)backToPreControl:(id)sender
{
    BOOL shouldDown = NO;
    if ([_photoSource.resource count] == [_selectArray count]) {
        for (int i = 0; i < [_photoSource.resource count]; i++) {
            SelectPhotosModel *sel_item = [_photoSource.resource objectAtIndex:i];
            SelectPhotosModel *old_item = [_selectArray objectAtIndex:i];
            if (sel_item.type == 0) {
                if (![sel_item.imgStr isEqualToString:old_item.imgStr] || sel_item.isCover != old_item.isCover) {
                    shouldDown = YES;
                    break;
                }
            }else {
                if (![sel_item.videoStr isEqualToString:old_item.videoStr]) {
                    shouldDown = YES;
                    break;
                }
            }
        }
    }else {
        shouldDown = YES;
    }
    if (shouldDown && [_photoSource.resource count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否确定将图片导入模板？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 图片下载
- (void)downImageViewWith:(NSString *)url At:(NSInteger)index
{
    self.navigationController.view.userInteractionEnabled = NO;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [self uploadProgress:0 tip:@"图片正在下载..."];
    __weak typeof(self)weakSelf = self;
    @try {
        [manager downloadWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            CGFloat progress = 0;
            if (expectedSize > 0) {
                progress = receivedSize / (CGFloat)expectedSize;
            }
            [weakSelf uploadProgress:progress tip:@"图片正在下载..."];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [weakSelf downSingleFinish:NO Data:nil At:index];
                }
                else
                {
                    [weakSelf downSingleFinish:YES Data:image At:index];
                }
            });
        }];
    } @catch (NSException *e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf downSingleFinish:NO Data:nil At:index];
        });
    }
}

//下载
- (void)downSingleFinish:(BOOL)suc Data:(id)result At:(NSInteger)index{
    self.navigationController.view.userInteractionEnabled = YES;
    [_progressView removeFromSuperview];
    if (suc) {
        NSString *timeStr = [NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]];
        NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%ld.jpg",timeStr,(long)index]];
        NSData *data = UIImageJPEGRepresentation(result, 1);
        [data writeToFile:filePath atomically:NO];
        SelectPhotosModel *photoModel = _photoSource.resource[index];
        photoModel.imageFileStr = filePath;
        
        CGSize imgSize = ((UIImage *)result).size;
        if (!_isSmallPicLimit && (imgSize.width < _minWei || imgSize.height < _minHei)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您需要选择1张高清图片作为封面用于打印" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
            [alertView show];
        }
        else{
            [self dealWithFinish];
        }
    }
    else{
        [self.view makeToast:@"图片下载异常,请稍候重试" duration:1.0 position:@"center"];
    }
}

#pragma mark - 数据处理完毕
- (void)dealWithFinish{
    if ((_delegate && [_delegate respondsToSelector:@selector(selectPhotosImages:)])) {
        [_delegate selectPhotosImages:_photoSource.resource];
    }
    else{
        for (UIViewController *control in self.navigationController.viewControllers) {
            if ([control isKindOfClass:[MakeGrowController class]]) {
                [self.navigationController popToViewController:control animated:YES];
                return;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 200) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstPrompt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        if (buttonIndex == 1) {
            [self finishSelect];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 相册列表
- (void)requestAlbumsList
{
    if (!_collectionView.alwaysBounceVertical) {
        [self.view makeToastActivity];
        [_bottomView setUserInteractionEnabled:NO];
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getGrowAlbum"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"photo"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf albumsListFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf albumsListFinish:NO Data:nil];
    }];
}

- (void)albumsListFinish:(BOOL)suc Data:(id)result{
    [_bottomView setUserInteractionEnabled:YES];
    if (suc) {
        _albumsList = [NSMutableArray array];
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            NSArray *array = [GrowAlbumItem arrayOfModelsFromDictionaries:ret_data error:nil];
            [_albumsList addObjectsFromArray:array];
            if ([array count] > 0) {
                GrowAlbumItem *item = [[GrowAlbumItem alloc] init];
                item.album_id = @"0";
                item.name = @"全部里程";
                NSInteger pic_num = 0;
                NSInteger video_num = 0;
                for (GrowAlbumItem *model in _albumsList) {
                    pic_num += [model.pic_num integerValue];
                    video_num += [model.video_num integerValue];
                }
                item.pic_num = [NSNumber numberWithInteger:pic_num];
                item.video_num = [NSNumber numberWithInteger:video_num];
                GrowAlbumItem *model = _albumsList[0];
                item.thumb = model.thumb;
                item.type = model.type;
                item.path = model.path;
                [_albumsList insertObject:item atIndex:0];
            }
        }
        
        if ([_albumsList count] > 0 && !_collectionView.alwaysBounceVertical) {
            _collectionView.alwaysBounceVertical = YES;
            GrowAlbumItem *firstItem = [_albumsList firstObject];
            self.album_id = firstItem.album_id;
            self.buttonTitle = firstItem.name;
            [self startPullRefresh];
            [self setLeftButtonTitle];
        }
        else{
            [self.view hideToastActivity];
        }
    }
    else{
        [self.view hideToastActivity];
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getPhotoList3"];
    [param setObject:(_requestTime == 1) ? @"0" : _album_id forKey:@"album_id"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
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

- (void)ihaveKnown:(id)sender
{
    [_holedView removeHoles];
    [_holedView removeFromSuperview];
    _holedView = nil;
}

- (UIView *)customView{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 170)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 34)];
    [lab setText:@"没有找到需要的照片？切换到［所有里程］试试看吧～"];
    [lab setFont:[UIFont fontWithName:@"DFPShaoNvW5" size:14]];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setNumberOfLines:2];
    [lab setTextColor:[UIColor whiteColor]];
    [backView addSubview:lab];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"我知道了" forState:UIControlStateNormal];
    [button.titleLabel setFont:lab.font];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ihaveKnown:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(100, 40, 72, 20)];
    [backView addSubview:button];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((200 - 27) / 2, 60, 27, 52)];
    [imgView setImage:CREATE_IMG(@"cusArrow")];
    [backView addSubview:imgView];
    
    return backView;
}

- (void)startPullRefresh2
{
    if (_lastPage) {
        [self.view makeToast:@"已到最后一页" duration:1.0 position:@"center"];
        
        BOOL tip = [[NSUserDefaults standardUserDefaults] boolForKey:CHECKMORE_PICTURE];
        if (!tip && (_horiBut.frameHeight != 0)) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CHECKMORE_PICTURE];
            _holedView = [[YLZHoledView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [_holedView addHCustomView:[self customView] onRect:CGRectMake((SCREEN_WIDTH - 200) / 2, SCREEN_HEIGHT - 38 - 115, 200, 115)];
            [self.view.window addSubview:_holedView];
            CGFloat alpha = _holedView.alpha;
            [_holedView setAlpha:0];
            [UIView animateWithDuration:0.35 animations:^{
                [_holedView setAlpha:alpha];
            } completion:^(BOOL finished) {
                CGRect rect = CGRectMake(_horiBut.frameX, _bottomView.frameY + _horiBut.frameY + 64, _horiBut.frameWidth, _horiBut.frameHeight);
                [_holedView addHoleRoundedRectOnRect:rect withCornerRadius:0];
            }];
            
            
        }
        
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
    _requestTime++;
    if (_requestTime != 1) {
        [super requestFinish:success Data:result];
    }
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        if (data && [data isKindOfClass:[NSArray class]]) {
            array = [GrowAlbumListItem arrayOfModelsFromDictionaries:data error:nil];
        }

        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        //时间排序
        for (GrowAlbumListItem *item in array) {
            NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:item.create_time.doubleValue];
            NSString *key = [NSString stringByDate:@"yyyyMMdd" Date:updateDate];
            NSMutableArray *tmpArr = [dataDic valueForKey:key];
            if (!tmpArr) {
                tmpArr = [NSMutableArray array];
                [dataDic setObject:tmpArr forKey:key];
            }
            [tmpArr addObject:item];
        }

        NSArray *sortArr = [[dataDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj2 compare:obj1];
        }];
        NSMutableArray *lastArr = [NSMutableArray array];
        for (NSInteger i = 0; i < sortArr.count; i++) {
            NSArray *dicArr = [dataDic valueForKey:sortArr[i]];
            [lastArr addObject:dicArr];
        }
        self.dataSource = lastArr;

        if ([self.dataSource count] == 0 && _requestTime == 1) {
            self.album_id = @"0";
            self.buttonTitle = @"全部里程";
            [self setLeftButtonTitle];
            [self startPullRefresh];
        }else {
            if (_requestTime == 1) {
                _requestTime++;
                [super requestFinish:success Data:result];
            }
        }
    }
    else{
        self.dataSource = nil;
        if (_requestTime == 1) {
            _requestTime++;
            [super requestFinish:success Data:result];
        }
    }
    
    [_collectionView reloadData];
    
    [self createTipView];
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSArray *data = [ret_data valueForKey:@"list"];
        NSMutableArray *array = [NSMutableArray array];
        if (data && [data isKindOfClass:[NSArray class]]) {
            array = [GrowAlbumListItem arrayOfModelsFromDictionaries:data error:nil];
        }
        
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        //时间排序
        for (GrowAlbumListItem *item in array) {
            NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:item.create_time.doubleValue];
            NSString *key = [NSString stringByDate:@"yyyyMMdd" Date:updateDate];
            NSMutableArray *tmpArr = [dataDic valueForKey:key];
            if (!tmpArr) {
                tmpArr = [NSMutableArray array];
                [dataDic setObject:tmpArr forKey:key];
            }
            [tmpArr addObject:item];
        }
        
        NSArray *sortArr = [[dataDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj2 compare:obj1];
        }];
        NSMutableArray *lastArr = [NSMutableArray array];
        for (NSInteger i = 0; i < sortArr.count; i++) {
            NSArray *dicArr = [dataDic valueForKey:sortArr[i]];
            [lastArr addObject:dicArr];
        }
        
        if (!self.dataSource) {
            self.dataSource = lastArr;
        }
        else{
            if ([self.dataSource count] > 0) {
                NSMutableArray *preLastArr = [self.dataSource lastObject];
                GrowAlbumListItem *preItem = [preLastArr firstObject];
                NSMutableArray *firstArr = [lastArr firstObject];
                GrowAlbumListItem *curItem = [firstArr firstObject];
                NSDate *preDate = [NSDate dateWithTimeIntervalSince1970:preItem.create_time.doubleValue];
                NSString *preDay = [NSString stringByDate:@"yyyyMMdd" Date:preDate];
                NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:curItem.create_time.doubleValue];
                NSString *curDay = [NSString stringByDate:@"yyyyMMdd" Date:curDate];
                if ([curDay isEqualToString:preDay]) {
                    [preLastArr addObjectsFromArray:firstArr];
                    [lastArr removeObjectAtIndex:0];
                }
                [self.dataSource addObjectsFromArray:lastArr];
            }
            else{
                [self.dataSource addObjectsFromArray:lastArr];
            }
        }
        
        [_collectionView reloadData];
    }
    else
    {
        if (_pageIdx > 1) {
            _pageIdx -= 1;
        }
    }
    
    [self createTipView];
}

#pragma mark - SelectMileageViewDelegate
- (void)selectMileageAt:(NSInteger)index
{
    GrowAlbumItem *item = _albumsList[index];
    if ([item.album_id isEqualToString:_album_id]) {
        return;
    }
    else if(self.httpOperation){
        [self.view makeToast:@"里程数据正在刷新，请稍候再试" duration:1.0 position:@"center"];
        return;
    }
    
    self.dataSource = nil;
    [_collectionView reloadData];
    
    self.album_id = item.album_id;
    self.buttonTitle = item.name;
    [self setLeftButtonTitle];
    [self beginRefresh];
}

- (void)selectButtonAt:(NSInteger)index
{
    if ([_photoSource.resource count] >= _nMaxCount) {
        [self.view makeToast:[NSString stringWithFormat:@"最多选择%ld张,请取消所选项后再试",(long)_nMaxCount] duration:1.0 position:@"center"];
        return;
    }
    
    switch (index) {
        case 2:
        {
            if (_nMaxCount - [_photoSource.resource count] == 1) {
                BOOL isFind = NO;
                for (NSInteger i = 0;i < _photoSource.resource.count;i++) {
                    SelectPhotosModel * item = _photoSource.resource[i];
                    if (item.isCover) {
                        isFind = YES;
                        break;
                    }
                }
                if (!isFind) {
                    [self.view makeToast:@"您需要选择1张高清照片作为封面用于打印" duration:1.0 position:@"center"];
                    return;
                }
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
                pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
                NSArray * availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
                pickerView.videoMaximumDuration = 40;
                pickerView.delegate = self;
                pickerView.allowsEditing = YES;
                [self presentViewController:pickerView animated:YES completion:NULL];
            }
        }
            break;
        case 1:
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = sourceType;
                [self presentViewController:picker animated:YES completion:NULL];
            }
        }
            break;
        case 0:
        {
            BOOL isFind = NO;
            for (NSInteger i = 0;i < _photoSource.resource.count;i++) {
                SelectPhotosModel * item = _photoSource.resource[i];
                if (item.isCover) {
                    isFind = YES;
                    break;
                }
            }
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc]init];
            picker.maximumNumberOfSelection = _nMaxCount - [_photoSource.resource count];
            picker.assetsFilter = [ALAssetsFilter allAssets];
            picker.selectAll = YES;
            picker.hasCover = isFind;
            picker.minWei = _minWei;
            picker.minHei = _minHei;
            picker.isSmallPicLimit = _isSmallPicLimit;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - SelectPhotosCell delegate
- (void)checkItemToController:(UICollectionViewCell *)cell
{
    if (((SelectPhotosCell *)cell).contentImg.image) {
        NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
        _indexPath = indexPath;
        [self selectItem:indexPath.item];
    }
    
}

#pragma mark - 是否已选
- (SelectPhotosModel *)checkSelectItem:(GrowAlbumListItem *)item{
    for (SelectPhotosModel *sel_item in _photoSource.resource) {
        if ([item.photo_id isEqualToString:sel_item.photoId]) {
            return sel_item;
        }
    }
    return nil;
}

- (BOOL)canSelectItem:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:_indexPath.section];
    NSArray *array = self.dataSource[indexPath.section];
    GrowAlbumListItem *item = array[indexPath.item];
    SelectPhotosModel *checkPhoeo = [self checkSelectItem:item];
    if (checkPhoeo) {
        return YES;
    }
    
    if (_photoSource.resource.count >= _nMaxCount) {
        [self.navigationController.view makeToast:[NSString stringWithFormat:@"最多选择%ld张,请取消所选项后再试",(long)_nMaxCount] duration:1.0 position:@"center"];
        return NO;
    }
    
    if (_isSmallPicLimit) {
        return YES;
    }
    
    BOOL isFind = NO;
    for (SelectPhotosModel *sel_item in _photoSource.resource) {
        if (sel_item.isCover) {
            isFind = YES;
            break;
        }
    }
    
    if (!isFind && (_photoSource.resource.count == _nMaxCount - 1) && (item.width.floatValue < _minWei || item.height.floatValue < _minHei)) {
        [self.navigationController.view makeToast:@"您需要选择1张高清照片作为封面用于打印" duration:1.0 position:@"center"];
        return NO;
    }
    
    return YES;
}

- (void)selectItem:(NSInteger)index{
    
    if (![self canSelectItem:index]) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:_indexPath.section];
    SelectPhotosCell *currCell = (SelectPhotosCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    
    NSArray *array = self.dataSource[indexPath.section];
    GrowAlbumListItem *item = array[indexPath.item];
    SelectPhotosModel *checkPhoeo = [self checkSelectItem:item];
    BOOL isFind = NO;
    for (SelectPhotosModel *sel_item in _photoSource.resource) {
        if (sel_item.isCover) {
            isFind = YES;
            break;
        }
    }
    
    currCell.checkBtn.selected = !currCell.checkBtn.selected;
    currCell.bgView.hidden = !currCell.checkBtn.selected;
    
    if (checkPhoeo == nil) {
        SelectPhotosModel *photoM = [[SelectPhotosModel alloc] init];
        photoM.type = item.type.integerValue;
        photoM.photoId = item.photo_id;
        if (photoM.type == 1) {
            photoM.videoStr = item.path;
            photoM.thumb = item.thumb;
        }
        else{
            photoM.imgStr = item.path;
            photoM.thumb = item.thumb;
            photoM.isCover = (!isFind && (_isSmallPicLimit || (item.width.floatValue >= _minWei && item.height.floatValue >= _minHei)));
        }
        photoM.width = item.width;
        photoM.height = item.height;
        [_photoSource.resource addObject:photoM];
        
        if ([_photoSource.resource count] > 0) {
            [self showTip];
        }
    }
    else{
        [_photoSource.resource removeObject:checkPhoeo];
        if (checkPhoeo.isCover) {
            for (SelectPhotosModel *tmpModel in _photoSource.resource) {
                if ((tmpModel.type == 0) && (_isSmallPicLimit || (tmpModel.width.floatValue >= _minWei && tmpModel.height.floatValue >= _minHei))) {
                    tmpModel.isCover = YES;
                    break;
                }
            }
        }
    }
    
    [_rightBut setTitle:[NSString stringWithFormat:@"完成(%ld/9)",(long)[_photoSource.resource count]] forState:UIControlStateNormal];
    [_photoSource.collectionView reloadData];
}

- (void)showTip
{
    SelectPhotosModel *item = _photoSource.resource[0];
    if ((item.type == 1 || [_photoSource.resource count] > 1) && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstPrompt"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"使用提示" message:@"当您添加视频或多张图片时，模板页会自动生成一个二维码，保存后即可查看到。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView setTag:200];
        [alertView show];
    }
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margin = 10,midMargin = 5;
    CGFloat count = 4;
    
    CGFloat itemWei = (SCREEN_WIDTH - margin * 2 - midMargin * (count - 1)) / count,itemHei = itemWei;
    return CGSizeMake(itemWei, itemHei);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.dataSource[section];
    
    return [array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SelectPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectAlbumItem2" forIndexPath:indexPath];
    [cell.fromLab setHidden:YES];
    [cell.checkBtn setHidden:NO];
    
    NSArray *array = self.dataSource[indexPath.section];
    GrowAlbumListItem *item = array[indexPath.item];
    cell.checkBtn.selected = ([self checkSelectItem:item] != nil);
    cell.bgView.hidden = !cell.checkBtn.selected;
    [cell setDelegate:self];
    [cell resetDataSource:item];
    [cell.hdImg setHidden:(item.type.integerValue != 0) || (item.width.floatValue < _minWei || item.height.floatValue < _minHei)];
    
    return cell;
}

#pragma mark - 头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"selectHeadCell" forIndexPath:indexPath];
    [view setBackgroundColor:collectionView.backgroundColor];
    
    UILabel *timeLab = (UILabel *)[view viewWithTag:1];
    if (!timeLab) {
        timeLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 16)];
        [timeLab setBackgroundColor:view.backgroundColor];
        [timeLab setTag:1];
        [timeLab setFont:[UIFont systemFontOfSize:12]];
        [timeLab setTextColor:[UIColor whiteColor]];
        [view addSubview:timeLab];
    }
    
    NSArray *array = self.dataSource[indexPath.section];
    GrowAlbumListItem *item = array[indexPath.item];
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:item.create_time.doubleValue];
    NSString *day = [NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate];
    [timeLab setText:day];

    return view;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self isRefreshing]) {
        [self.view makeToast:@"数据正在刷新,请稍候再试" duration:1.0 position:@"center"];
        return;
    }
    
    _indexPath = indexPath;
    
    if ([_browserPhotos count] > 0) {
        [_browserPhotos removeAllObjects];
    }
    
    NSArray *array = self.dataSource[indexPath.section];
    NSInteger count = [array count];
    for (int i = 0; i < count; i++) {
        GrowAlbumListItem *item = array[i];
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
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:[tmpStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
            photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo.isVideo = YES;
        }
        else
        {
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
            NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo = [MWPhoto photoWithURL:url];
        }
        [_browserPhotos addObject:photo];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:indexPath.item];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    browser.totalCount = _nMaxCount;
    browser.selectedCount = _photoSource.resource.count;
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate
- (BOOL)shouldSelectItemAt:(NSInteger)index
{
    NSArray *array = self.dataSource[_indexPath.section];
    GrowAlbumListItem *item = array[index];
    return ([self checkSelectItem:item] != nil);
}

- (BOOL)isCanSelectItemAt:(NSInteger)index browser:(MWPhotoBrowser *)browser
{
    return [self canSelectItem:index];
}

- (void)cancelSelectedItemAt:(NSInteger)index Should:(BOOL)sel
{
    [self selectItem:index];
}

- (void)finishPreView:(NSInteger)index
{
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - PhotoSourceDelegate
- (void)actionDidIndex:(NSInteger)index PhotoModel:(SelectPhotosModel *)photoModel
{
    //0-查看大图，1－删除,2-设为封面
    switch (index) {
        case 0:
        {
            if ([_browserPhotos count] > 0) {
                [_browserPhotos removeAllObjects];
            }
            NSInteger count = [_photoSource.resource count];
            for (int i = 0; i < count; i++) {
                SelectPhotosModel *item = _photoSource.resource[i];
                MWPhoto *photo = nil;
                NSURL *videoURL = nil;
                if (item.videoFileStr.length > 0) {
                    videoURL = [NSURL fileURLWithPath:item.videoFileStr];
                }
                else{
                    NSString *path = item.videoStr;
                    if (![path hasPrefix:@"http"]) {
                        path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
                    }
                    videoURL = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                if (item.type == 1) {
                    if (item.imageFileStr.length > 0) {
                        photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:item.imageFileStr]];
                    }
                    else if (item.imgStr.length > 0) {
                        NSString *url = item.imgStr;
                        if (![url hasPrefix:@"http"]) {
                            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                        }
                        CGFloat scale_screen = [UIScreen mainScreen].scale;
                        NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
                        url = [NSString getPictureAddress:@"2" width:width height:@"0" original:url];
                        photo = [MWPhoto photoWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    else if (item.thumbImg){
                        photo = [MWPhoto photoWithImage:item.thumbImg];
                    }
                    else if (item.thumb.length > 0){
                        NSString *url = item.thumb;
                        if (![url hasPrefix:@"http"]) {
                            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                        }
                        photo = [MWPhoto photoWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    else{
                        photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:videoURL]];
                    }
                    
                    photo.videoUrl = videoURL;
                    photo.isVideo = YES;
                }
                else{
                    if (item.imageFileStr) {
                        photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:item.imageFileStr]];
                    }
                    else{
                        NSString *path = item.imgStr;
                        if (![path hasPrefix:@"http"]) {
                            path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
                        }
                        CGFloat scale_screen = [UIScreen mainScreen].scale;
                        NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
                        path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
                        photo = [MWPhoto photoWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                        
                    }
                }
                [_browserPhotos addObject:photo];
            }
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            NSInteger curIdx = [_photoSource.resource indexOfObject:photoModel];
            if (curIdx == NSNotFound) {
                curIdx = 0;
            }
            [browser setCurrentPhotoIndex:curIdx];
            browser.displayNavArrows = YES;
            browser.displayActionButton = NO;
            [self.navigationController pushViewController:browser animated:YES];
        }
            break;
        case 1:
        {
            NSIndexPath *indexPath = nil;
            for (NSInteger i = 0; i < [self.dataSource count]; i++) {
                NSMutableArray *array = [self.dataSource objectAtIndex:i];
                BOOL hasFound = NO;
                for (NSInteger j = 0; j < array.count; j++) {
                    GrowAlbumListItem *item = [array objectAtIndex:j];
                    if ([item.photo_id isEqualToString:photoModel.photoId]) {
                        indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                        hasFound = YES;
                        break;
                    }
                }
                if (hasFound) {
                    break;
                }
            }
            
            [_rightBut setTitle:[NSString stringWithFormat:@"完成(%ld/9)",(long)[_photoSource.resource count]] forState:UIControlStateNormal];
            if (indexPath) {
                SelectPhotosCell *currCell = (SelectPhotosCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                currCell.bgView.hidden = YES;
                [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count == 0) {
        return;
    }
    
    BOOL isFind = NO;
    for (SelectPhotosModel *sel_item in _photoSource.resource) {
        if (sel_item.isCover) {
            isFind = YES;
            break;
        }
    }
    
    NSArray *imgAssets = assets[0],*fileArr = assets[1],*netSour = assets[2];
    for (NSInteger i = 0; i < imgAssets.count; i++) {
        ALAsset *tmpAsset = (ALAsset *)imgAssets[i];
        SelectPhotosModel *photo = [[SelectPhotosModel alloc] init];
        photo.state = 2;
        photo.thumbImg = [UIImage imageWithCGImage:tmpAsset.defaultRepresentation.fullScreenImage];
        CGSize size = tmpAsset.defaultRepresentation.dimensions;
        photo.width = [NSNumber numberWithFloat:size.width];
        photo.height = [NSNumber numberWithFloat:size.height];
        NSString *netStr = netSour[i];
        NSString *fileStr = fileArr[i];
        if ([fileStr hasSuffix:@"mp4"]) {
            photo.type = 1;
            photo.videoStr = netStr;
            photo.videoFileStr = fileStr;
        }
        else{
            photo.type = 0;
            photo.imgStr = netStr;
            photo.imageFileStr = fileStr;
            if (!isFind && (_isSmallPicLimit || (size.width >= _minWei && size.height >= _minHei))) {
                isFind = YES;
                photo.isCover = YES;
            }
        }
        [_photoSource.resource addObject:photo];
    }
    if ([imgAssets count] > 0) {
        if (!isFind && ([_photoSource.resource count] == _nMaxCount)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"使用提示" message:@"当前图集无可供打印的高清图片作为封面，您可以删除一个图片或视频，并重新选择一张高清图片作为打印封面" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else if([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstPrompt"]){
            [self.view makeToast:@"*您本地上传的照片或视频将会以班级的形式同步到您的宝宝里程中!" duration:1.0 position:@"center"];
        }
        else{
            [self showTip];
        }
    }
    [_rightBut setTitle:[NSString stringWithFormat:@"完成(%ld/9)",(long)[_photoSource.resource count]] forState:UIControlStateNormal];
    [_photoSource.collectionView reloadData];
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL video = (picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModeVideo);
    
    if (video) {
        [picker dismissViewControllerAnimated:NO completion:nil];
        //保存视频
        NSString *videoPath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        PlayViewController *play = [[PlayViewController alloc] init];
        play.fileUrl = [NSURL fileURLWithPath:videoPath];
        __weak typeof(self)weakSelf = self;
        play.playResult = ^(NSString *path){
            [weakSelf addVodeoPath:path];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:play];
        [self presentViewController:nav animated:YES completion:NULL];
    }else {
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        [self uploadProgress:0 tip:@"图片上传中..."];
        [self convertImg:image];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
