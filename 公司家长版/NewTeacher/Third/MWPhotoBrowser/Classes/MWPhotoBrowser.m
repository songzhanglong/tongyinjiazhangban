//
//  MWPhotoBrowser.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MWCommon.h"
#import "MWPhotoBrowser.h"
#import "MWPhotoBrowserPrivate.h"
#import "SDImageCache.h"
#import "Toast+UIView.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DJTHttpClient.h"
#import "NSString+Common.h"
#import "MileageModel.h"
#import "AddActivityViewController.h"
#import "ThemeBatchModel.h"
#import "DJTOrderViewController.h"
#import <AVFoundation/AVFoundation.h>

#define PADDING                  10
#define ACTION_SHEET_OLD_ACTIONS 2000
#import "UMSocial.h"
#import "DJTShareImageView.h"
#import "HorizontalButton.h"

@interface MWPhotoBrowser ()<AVAudioPlayerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,DJTShareImageViewDelegate,UIActionSheetDelegate>

@property (nonatomic,strong)MPMoviePlayerController *movieController;

@end

@implementation MWPhotoBrowser
{
    NSMutableArray *_themeArr;
    UIButton *_horiBut,*_numBut;
    AVAudioPlayer *_audioPlayer;
}
#pragma mark - Init

- (id)init {
    if ((self = [super init])) {
        [self _initialisation];
    }
    return self;
}

- (id)initWithDelegate:(id <MWPhotoBrowserDelegate>)delegate {
    if ((self = [self init])) {
        _delegate = delegate;
	}
	return self;
}

- (id)initWithPhotos:(NSArray *)photosArray {
	if ((self = [self init])) {
		_depreciatedPhotoData = photosArray;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder])) {
        [self _initialisation];
	}
	return self;
}

- (void)_initialisation {
    
    // Defaults
    NSNumber *isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isVCBasedStatusBarAppearanceNum) {
        _isVCBasedStatusBarAppearance = isVCBasedStatusBarAppearanceNum.boolValue;
    } else {
        _isVCBasedStatusBarAppearance = YES; // default
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if (SYSTEM_VERSION_LESS_THAN(@"7")) self.wantsFullScreenLayout = YES;
#endif
    self.hidesBottomBarWhenPushed = YES;
    _hasBelongedToViewController = NO;
    _photoCount = NSNotFound;
    _previousLayoutBounds = CGRectZero;
    _currentPageIndex = 0;
    _previousPageIndex = NSUIntegerMax;
    _displayActionButton = YES;
    _displayNavArrows = NO;
    _zoomPhotosToFill = YES;
    _performingLayout = NO; // Reset on view did appear
    _rotating = NO;
    _viewIsActive = NO;
    _enableGrid = YES;
    _startOnGrid = NO;
    _enableSwipeToDismiss = YES;
    _delayToHideElements = 5;
    _visiblePages = [[NSMutableSet alloc] init];
    _recycledPages = [[NSMutableSet alloc] init];
    _photos = [[NSMutableArray alloc] init];
    _thumbPhotos = [[NSMutableArray alloc] init];
    _currentGridContentOffset = CGPointMake(0, CGFLOAT_MAX);
    _didSavePreviousStateOfNavBar = NO;
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // Listen for MWPhoto notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                 name:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];
    
}

- (void)dealloc {
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseAllUnderlyingPhotos:NO];
    [[SDImageCache sharedImageCache] clearMemory]; // clear memory
}

- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent {
    // Create a copy in case this array is modified while we are looping through
    // Release photos
    NSArray *copy = [_photos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            if (preserveCurrent && p == [self photoAtIndex:self.currentIndex]) {
                continue; // skip current
            }
            [p unloadUnderlyingImage];
        }
    }
    // Release thumbs
    copy = [_thumbPhotos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            [p unloadUnderlyingImage];
        }
    }
}

- (void)didReceiveMemoryWarning {

	// Release any cached data, images, etc that aren't in use.
    [self releaseAllUnderlyingPhotos:YES];
	[_recycledPages removeAllObjects];
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

#pragma mark - 分享照片
- (void)sharedTo:(id)sender{
    
    if (![DJTShareImageView isCanShareToOtherPlatform]) {
        [self.view.window makeToast:SHARE_TIP_INFO duration:1.0 position:@"center"];
        return;
    }
    
    DJTShareImageView *shareView = [[DJTShareImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [shareView setDelegate:self];
    [shareView showInView:self.view.window];
}


#pragma mark - DJTShareImageViewDelegate
- (void)shareImageViewTo:(NSInteger)index
{
    MWPhoto *photo = (MWPhoto *)[self photoAtIndex:_currentPageIndex];
    BOOL isVideo = (photo.isVideo && photo.videoUrl && [[photo.videoUrl absoluteString] hasPrefix:@"http"]);
    NSString *str = isVideo ? [@"http://wap.goonbaby.com/video?t=" stringByAppendingString:[photo.videoUrl path]] : nil;
    NSString *shareType = nil;
    switch (index) {
        case 0:
        {
            //微信好友
            [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = isVideo ? UMSocialWXMessageTypeWeb : UMSocialWXMessageTypeImage;
            [UMSocialData defaultData].extConfig.wechatSessionData.url = str;
            shareType = UMShareToWechatSession;
        }
            break;
        case 1:
        {
            //微信朋友圈
            [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = isVideo ? UMSocialWXMessageTypeWeb : UMSocialWXMessageTypeImage;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = str;
            shareType = UMShareToWechatTimeline;
        }
            break;
        case 2:
        {
            //手机QQ
            [UMSocialData defaultData].extConfig.qqData.qqMessageType = isVideo ? UMSocialQQMessageTypeDefault : UMSocialQQMessageTypeImage;
            [UMSocialData defaultData].extConfig.qqData.url = str;
            shareType = UMShareToQQ;
        }
            break;
        case 3:
        {
            //QQ空间
            [UMSocialData defaultData].extConfig.qqData.qqMessageType = isVideo ? UMSocialQQMessageTypeDefault : UMSocialQQMessageTypeImage;
            [UMSocialData defaultData].extConfig.qzoneData.url = str;
            shareType = UMShareToQzone;
        }
            break;
        case 4:
        {
            //新浪微博
            [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:isVideo ? UMSocialUrlResourceTypeMusic : UMSocialUrlResourceTypeImage url:nil];
            shareType = UMShareToSina;
        }
            break;
        default:
            break;
    }
    
    if (shareType) {
        [[UMSocialControllerService defaultControllerService] setShareText:str ?: @" " shareImage:[[self photoAtIndex:_currentPageIndex] underlyingImage] socialUIDelegate:self];        //设置分享内容和回调对象
        [UMSocialSnsPlatformManager getSocialPlatformWithName:shareType].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    }
}

#pragma mark - 查看详情
- (void)checkDetailInfo:(id)sender
{
    if ([_delegate respondsToSelector:@selector(checkDetailInfo:and:)]) {
        // State
        _viewIsActive = NO;
        
        // Bar state / appearance
        [self restorePreviousNavBarAppearance:YES];
        [_delegate checkDetailInfo:_currentPageIndex and:self];
    }
}

#pragma mark - 加入猪蹄
- (void)joinInTheme:(id)sender
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    //针对新接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"photo"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMileageAlbums"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [self.navigationController.view makeToastActivity];
    [self.navigationController.view setUserInteractionEnabled:NO];
    [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf joinThemeFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf joinThemeFinish:NO Data:nil];
    }];
}

- (void)joinThemeFinish:(BOOL)success Data:(id)result
{
    [self.navigationController.view hideToastActivity];
    [self.navigationController.view setUserInteractionEnabled:YES];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        _themeArr = [NSMutableArray array];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        if ([ret_data count] == 0) {
            [self.view makeToast:@"暂无可以加入的主题" duration:1.0 position:@"center"];
        }
        else
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择主题" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
            for (id subDic in ret_data) {
                NSError *error;
                MileageThumbItem *model = [[MileageThumbItem alloc] initWithDictionary:subDic error:&error];
                if (error) {
                    NSLog(@"%@",error.description);
                    continue;
                }
                [model caculateNameHei];
                [_themeArr addObject:model];
                [sheet addButtonWithTitle:model.name];
            }
            [sheet addButtonWithTitle:@"取消"];                                                 //取消按钮也是这会再加
            sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
            [sheet showInView:self.navigationController.view];
        }
        
    }
    else
    {
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.numberOfButtons - 1) {
        // State
        _viewIsActive = NO;
        
        // Bar state / appearance
        [self restorePreviousNavBarAppearance:YES];
        MileageThumbItem *model = _themeArr[buttonIndex];
        MileageModel *mileage = [[MileageModel alloc] init];
        mileage.name = model.name;
        mileage.album_id = model.album_id;
        
        AddActivityViewController *add = [[AddActivityViewController alloc] init];
        MWPhoto *photo = (MWPhoto *)[self photoAtIndex:_currentPageIndex];
        if (photo.isVideo) {
            add.videoPath = photo.videoUrl.absoluteString;
            add.dataSource = [NSMutableArray arrayWithObject:photo.videoUrl.absoluteString];
        }
        else{
            UIImage *image = [photo underlyingImage];
            add.dataSource = [NSMutableArray arrayWithObject:image];
            NSString *original = [NSString resetOriginalStr:photo.photoURL.absoluteString];
            add.themeUrl = [NSURL URLWithString:original];
        }
        add.fromType = 1;
        add.mileageModel = mileage;
        add.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:add animated:YES];
    }
}

#pragma mark - 分享回调
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    if (response.responseCode == UMSResponseCodeSuccess) {
        
    }
}
#pragma mark -  点赞
- (void)favourite:(id)sender{
}
#pragma mark -  退出列表
-(BOOL)isDirectShareInIconActionSheet{
    return YES;
}

#pragma mark - View Loading

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"back_1" ofType:@"png"]] forState:UIControlStateSelected];
    [backBtn addTarget:self action:@selector(backToFather:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backBarButtonItem];
    
    // Validate grid settings
    if (_startOnGrid) _enableGrid = YES;
    if (_enableGrid) {
        _enableGrid = [_delegate respondsToSelector:@selector(photoBrowser:thumbPhotoAtIndex:)];
    }
    if (!_enableGrid) _startOnGrid = NO;
	
	// View
	self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
	
	// Setup paging scrolling view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
   // pagingScrollViewFrame.size.height = pagingScrollViewFrame.size.height -44;
	_pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	_pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_pagingScrollView.pagingEnabled = YES;
	_pagingScrollView.delegate = self;
	_pagingScrollView.showsHorizontalScrollIndicator = NO;
	_pagingScrollView.showsVerticalScrollIndicator = NO;
	_pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	[self.view addSubview:_pagingScrollView];
	
    // Toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
    _toolbar.backgroundColor = [UIColor colorWithRed:70/255.0 green:57/255.0 blue:53/255.0 alpha:1];
    _toolbar.tintColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7") ? [UIColor whiteColor] : nil;
    if ([_toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        _toolbar.barTintColor = nil;
    }
    if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
        [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    }
    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    if (_canEditItem != 0) {
        
        //视图
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(60, 80);
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(_toolbar.frame.origin.x, _toolbar.frame.origin.y + _toolbar.frame.size.height - 90, _toolbar.frame.size.width, 90) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"checkItemCell"];
        [self.view addSubview:_collectionView];
        
    }
    
    // Toolbar Items
    if (self.displayNavArrows) {
        NSString *arrowPathFormat;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            arrowPathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemArrowOutline%@.png";
        } else {
            arrowPathFormat = @"MWPhotoBrowser.bundle/images/UIBarButtonItemArrow%@.png";
        }
        _previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:arrowPathFormat, @"Left"]] style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
        _nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:arrowPathFormat, @"Right"]] style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
    }
    if (self.displayActionButton) {
        _actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    }
    else if (_canDeleteItem)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0,30, 30)];
        [button setImage:[UIImage imageNamed:@"sticknotedelete.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteCurItem) forControlEvents:UIControlEventTouchUpInside];
        _actionButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    else if (_canEditItem == 1)
    {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 60, 30)];
        [button setTitle:@"编辑" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(beginMakeGrow:) forControlEvents:UIControlEventTouchUpInside];
        _actionButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        
    }
    
    // Update
    [self reloadData];
    
    // Swipe to dismiss
    if (_enableSwipeToDismiss) {
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doneButtonPressed:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp;
        [self.view addGestureRecognizer:swipeGesture];
    }
    
	// Super
    [super viewDidLoad];
	
}

- (void)backToFather:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)performLayout {
    
    // Setup
    _performingLayout = YES;
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    
	// Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    // Navigation buttons
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        // We're first on stack so show done button
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
        // Set appearance
        if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
            [_doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [_doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [_doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [_doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            [_doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
            [_doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        }
        self.navigationItem.rightBarButtonItem = _doneButton;
    } else {
        // We're not first so show back button
        UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        NSString *backButtonTitle = previousViewController.navigationItem.backBarButtonItem ? previousViewController.navigationItem.backBarButtonItem.title : previousViewController.title;
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:backButtonTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        // Appearance
        if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
            [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        }
        _previousViewControllerBackButton = previousViewController.navigationItem.backBarButtonItem; // remember previous
        previousViewController.navigationItem.backBarButtonItem = newBackButton;
        if (_displayNavArrows && !_displayActionButton) {
            
        }
    }

    // Toolbar items
    BOOL hasItems = NO;
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = 32; // To balance action button
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];

    // Left button - Grid
    if (_enableGrid) {
        hasItems = YES;
        NSString *buttonName = @"UIBarButtonItemGrid";
        if (SYSTEM_VERSION_LESS_THAN(@"7")) buttonName = @"UIBarButtonItemGridiOS6";
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MWPhotoBrowser.bundle/images/%@.png", buttonName]] style:UIBarButtonItemStylePlain target:self action:@selector(showGridAnimated)]];
    } else {
        [items addObject:fixedSpace];
    }

    // Middle - Nav
    if (_previousButton && _nextButton && numberOfPhotos > 0) {
        hasItems = YES;
        [items removeAllObjects];
        if (_totalCount > 0) {
            //相册预览大图
            HorizontalButton *hori = [HorizontalButton buttonWithType:UIButtonTypeCustom];
            _horiBut = hori;
            hori.leftText = YES;
            hori.imgSize = CGSizeMake(30, 30);
            hori.textSize = CGSizeMake(34, 18);
            [hori setFrame:CGRectMake(0, 0, 64, 30)];
            [hori setImage:CREATE_IMG(@"grow_add_check@2x") forState:UIControlStateNormal];
            [hori setImage:CREATE_IMG(@"grow_add_check1@2x") forState:UIControlStateSelected];
            hori.selected = [_delegate respondsToSelector:@selector(shouldSelectItemAt:)] && [_delegate shouldSelectItemAt:_currentPageIndex];
            [hori setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [hori setTitle:@"选择" forState:UIControlStateNormal];
            [hori.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [hori.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [hori addTarget:self action:@selector(cancelSelected:) forControlEvents:UIControlEventTouchUpInside];
            [items addObject:[[UIBarButtonItem alloc] initWithCustomView:hori]];
            [items addObject:flexSpace];
            [items addObject:flexSpace];
            [items addObject:flexSpace];
            [items addObject:flexSpace];
            
            UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
            _numBut = rightBut;
            [rightBut setFrame:CGRectMake(0 , 0, 70, 21)];
            [rightBut setBackgroundColor:rgba(25, 161, 86, 1)];
            [rightBut setTitle:[NSString stringWithFormat:@"完成(%ld/%ld)",(long)_selectedCount,(long)_totalCount] forState:UIControlStateNormal];
            [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [rightBut.titleLabel setFont:[UIFont systemFontOfSize:12]];
            rightBut.layer.masksToBounds = YES;
            rightBut.layer.cornerRadius = 2;
            [rightBut addTarget:self action:@selector(preViewFinish:) forControlEvents:UIControlEventTouchUpInside];
            [items addObject:[[UIBarButtonItem alloc] initWithCustomView:rightBut]];
        }
        else{
            if (_showDiggNum) {
                UIView *firView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
                for (NSInteger i = 0; i < 2; i++) {
                    NSString *imgName = (i == 0) ? @"s29@2x" : @"s30@2x";
                    CGFloat xOri = (i == 0) ? 0 : 45;
                    UIImageView *imaView = [[UIImageView alloc] initWithFrame:CGRectMake(xOri, 5, 20, 20)];
                    [imaView setImage:CREATE_IMG(imgName)];
                    [firView addSubview:imaView];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imaView.frameRight, imaView.frameY, 25, 20)];
                    [label setTextColor:[UIColor whiteColor]];
                    [label setBackgroundColor:[UIColor clearColor]];
                    [label setTag:i + 1];
                    [label setFont:[UIFont systemFontOfSize:14]];
                    [firView addSubview:label];
                }
                
                UIButton *alphaBut = [UIButton buttonWithType:UIButtonTypeCustom];
                //[alphaBut setAlpha:0];
                [alphaBut addTarget:self action:@selector(checkDetailInfo:) forControlEvents:UIControlEventTouchUpInside];
                [alphaBut setFrame:firView.bounds];
                [firView addSubview:alphaBut];
                
                _diggButton = [[UIBarButtonItem alloc] initWithCustomView:firView];
                [items addObject:_diggButton];
            }
            else{
                UIButton *themeBut = [UIButton buttonWithType:UIButtonTypeCustom];
                [themeBut setBackgroundColor:[UIColor clearColor]];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"+加入主题"];
                [att addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 5)];
                [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:NSMakeRange(0, 1)];
                [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(1, 4)];
                NSMutableAttributedString *attH = [[NSMutableAttributedString alloc] initWithString:@"+加入主题"];
                [attH addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, 5)];
                [attH addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:NSMakeRange(0, 1)];
                [attH addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(1, 4)];
                [themeBut setAttributedTitle:att forState:UIControlStateNormal];
                [themeBut setAttributedTitle:attH forState:UIControlStateDisabled];
                [themeBut setFrame:CGRectMake(0, 0, 90, 30)];
                [themeBut addTarget:self action:@selector(joinInTheme:) forControlEvents:UIControlEventTouchUpInside];
                _themeButton = [[UIBarButtonItem alloc] initWithCustomView:themeBut];
                [items addObject:_themeButton];
            }
            
            //[items addObject:flexSpace];
            //[items addObject:flexSpace];
            [items addObject:flexSpace];
            [items addObject:flexSpace];
            [items addObject:flexSpace];
            UIButton *shareBut = [UIButton buttonWithType:UIButtonTypeCustom];
            [shareBut setFrame:CGRectMake(0, 0, 30, 30)];
            [shareBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_1" ofType:@"png"]] forState:UIControlStateNormal];
            [shareBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share" ofType:@"png"]] forState:UIControlStateHighlighted];
            [shareBut addTarget:self action:@selector(sharedTo:) forControlEvents:UIControlEventTouchUpInside];
            _shareButton = [[UIBarButtonItem alloc] initWithCustomView:shareBut];
            [items addObject:_shareButton];
            
            UIButton *downBut = [UIButton buttonWithType:UIButtonTypeCustom];
            [downBut setFrame:CGRectMake(0, 0, 30, 30)];
            [downBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"download" ofType:@"png"]] forState:UIControlStateNormal];
            [downBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"download_1" ofType:@"png"]] forState:UIControlStateHighlighted];
            [downBut addTarget:self action:@selector(downImage:) forControlEvents:UIControlEventTouchUpInside];
            _downButton = [[UIBarButtonItem alloc] initWithCustomView:downBut];
            [items addObject:_downButton];
        }
    } else {
        [items addObject:flexSpace];
    }

    // Right - Action
    if (_actionButton && !(!hasItems && !self.navigationItem.rightBarButtonItem)) {
        //[items addObject:_actionButton];
        self.navigationItem.rightBarButtonItem = _actionButton;
    } else {
        // We're not showing the toolbar so try and show in top right
        if (_actionButton)
            self.navigationItem.rightBarButtonItem = _actionButton;
        //[items addObject:fixedSpace];
    }

    // Toolbar visibility
    [_toolbar setItems:items];
    BOOL hideToolbar = YES;
    for (UIBarButtonItem* item in _toolbar.items) {
        if (item != fixedSpace && item != flexSpace) {
            hideToolbar = NO;
            break;
        }
    }
     
    if (hideToolbar) {
        [_toolbar removeFromSuperview];
    } else {
        [self.view addSubview:_toolbar];
        if (_collectionView) {
            [self.view addSubview:_collectionView];
        }
    }
    
    // Update nav
	[self updateNavigation];
    
    // Content offset
	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
    
}

// Release any retained subviews of the main view.
- (void)viewDidUnload {
	_currentPageIndex = 0;
    _pagingScrollView = nil;
    _visiblePages = nil;
    _recycledPages = nil;
    _toolbar = nil;
    _previousButton = nil;
    _nextButton = nil;
    _progressHUD = nil;
    [super viewDidUnload];
}

- (BOOL)presentingViewControllerPrefersStatusBarHidden {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        if ([presenting isKindOfClass:[UINavigationController class]]) {
            presenting = [(UINavigationController *)presenting topViewController];
        }
    } else {
        // We're in a navigation controller so get previous one!
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            presenting = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        }
    }
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    } else {
        return NO;
    }
}

#pragma mark - Appearance

- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
    
    // Status bar
    if ([UIViewController instancesRespondToSelector:@selector(prefersStatusBarHidden)]) {
        _leaveStatusBarAlone = [self presentingViewControllerPrefersStatusBarHidden];
    } else {
        _leaveStatusBarAlone = [UIApplication sharedApplication].statusBarHidden;
    }
    if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
        // If the frame is zero then definitely leave it alone
        _leaveStatusBarAlone = YES;
    }
    BOOL fullScreen = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if (SYSTEM_VERSION_LESS_THAN(@"7")) fullScreen = self.wantsFullScreenLayout;
#endif
    if (!_leaveStatusBarAlone && fullScreen && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        if (SYSTEM_VERSION_LESS_THAN(@"7")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
#pragma clang diagnostic push
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
        }
    }
    
    // Navigation bar appearance
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    
    // Update UI
	[self hideControlsAfterDelay];
    
    // Initial appearance
    if (!_viewHasAppearedInitially) {
        if (_startOnGrid) {
            [self showGrid:NO];
        }
        _viewHasAppearedInitially = YES;
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (_audioPlayer && [_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    
    // Check that we're being popped for good
    if ([self.navigationController.viewControllers objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        // State
        _viewIsActive = NO;
        
        // Bar state / appearance
        [self restorePreviousNavBarAppearance:animated];
        
    }
    
    // Controls
    [self.navigationController.navigationBar.layer removeAllAnimations]; // Stop all animations on nav bar
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self setControlsHidden:NO animated:NO permanent:YES];
    
    // Status bar
    BOOL fullScreen = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if (SYSTEM_VERSION_LESS_THAN(@"7")) fullScreen = self.wantsFullScreenLayout;
#endif
    if (!_leaveStatusBarAlone && fullScreen && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
	// Super
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
    if (_collectionView) {
        [self scrollCollectionView];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent && _hasBelongedToViewController) {
        [NSException raise:@"MWPhotoBrowser Instance Reuse" format:@"MWPhotoBrowser instances cannot be reused."];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) _hasBelongedToViewController = YES;
}

#pragma mark - Nav Bar Appearance

- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7") ? [UIColor whiteColor] : [UIColor colorWithRed:70/255.0 green:57/255.0 blue:53/255.0 alpha:1];;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor colorWithRed:70/255.0 green:57/255.0 blue:53/255.0 alpha:1];
        navBar.shadowImage = nil;
    }
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)storePreviousNavBarAppearance {
    _didSavePreviousStateOfNavBar = YES;
    if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
        _previousNavBarBarTintColor = self.navigationController.navigationBar.barTintColor;
    }
    _previousNavBarTranslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        _previousNavigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    if (_didSavePreviousStateOfNavBar) {
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.tintColor = _previousNavBarTintColor;
        navBar.translucent = _previousNavBarTranslucent;
        if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
            navBar.barTintColor = _previousNavBarBarTintColor;
        }
        navBar.barStyle = _previousNavBarStyle;
        if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsLandscapePhone];
        }
        // Restore back button if we need to
        if (_previousViewControllerBackButton) {
            UIViewController *previousViewController = [self.navigationController topViewController]; // We've disappeared so previous is now top
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            _previousViewControllerBackButton = nil;
        }
    }
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutVisiblePages];
}

- (void)layoutVisiblePages {
    
	// Flag
	_performingLayout = YES;
	
	// Toolbar
	_toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
    
	// Remember index
	NSUInteger indexPriorToLayout = _currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
    if (!_skipNextPagingScrollViewPositioning) {
        _pagingScrollView.frame = pagingScrollViewFrame;
    }
    _skipNextPagingScrollViewPositioning = NO;
	
	// Recalculate contentSize based on current orientation
	_pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (MWZoomingScrollView *page in _visiblePages) {
        NSUInteger index = page.index;
		page.frame = [self frameForPageAtIndex:index];
        if (page.captionView) {
            page.captionView.frame = [self frameForCaptionView:page.captionView atIndex:index];
        }
        if (page.selectedButton) {
            page.selectedButton.frame = [self frameForSelectedButton:page.selectedButton atIndex:index];
        }
        
        // Adjust scales if bounds has changed since last time
        if (!CGRectEqualToRect(_previousLayoutBounds, self.view.bounds)) {
            // Update zooms for new bounds
            [page setMaxMinZoomScalesForCurrentBounds];
            _previousLayoutBounds = self.view.bounds;
        }

	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	[self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
	// Reset
	_currentPageIndex = indexPriorToLayout;
	_performingLayout = NO;
    
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (_collectionView == nil);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //return (_collectionView == nil) ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
	// Remember page index before rotation
	_pageIndexBeforeRotation = _currentPageIndex;
	_rotating = YES;
    
    // In iOS 7 the nav bar gets shown after rotation, but might as well do this for everything!
    if ([self areControlsHidden]) {
        // Force hidden
        self.navigationController.navigationBarHidden = YES;
    }
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Perform layout
	_currentPageIndex = _pageIndexBeforeRotation;
	
	// Delay control holding
	[self hideControlsAfterDelay];
    
    // Layout
    [self layoutVisiblePages];
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	_rotating = NO;
    // Ensure nav bar isn't re-displayed
    if ([self areControlsHidden]) {
        self.navigationController.navigationBarHidden = NO;
        self.navigationController.navigationBar.alpha = 0;
    }
}

#pragma mark - Data

- (NSUInteger)currentIndex {
    return _currentPageIndex;
}

- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    [self releaseAllUnderlyingPhotos:YES];
    [_photos removeAllObjects];
    [_thumbPhotos removeAllObjects];
    for (int i = 0; i < numberOfPhotos; i++) {
        [_photos addObject:[NSNull null]];
        [_thumbPhotos addObject:[NSNull null]];
    }

    // Update current page index
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    
    // Update layout
    if ([self isViewLoaded]) {
        while (_pagingScrollView.subviews.count) {
            [[_pagingScrollView.subviews lastObject] removeFromSuperview];
        }
        [self performLayout];
        [self.view setNeedsLayout];
    }
    
    if (_collectionView) {
        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currentPageIndex inSection:0]]];
    }
}

- (NSUInteger)numberOfPhotos {
    if (_photoCount == NSNotFound) {
        if ([_delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _photoCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        } else if (_depreciatedPhotoData) {
            _photoCount = _depreciatedPhotoData.count;
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (id<MWPhoto>)photoAtIndex:(NSUInteger)index {
    id <MWPhoto> photo = nil;
    if (index < _photos.count) {
        if ([_photos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
                photo = [_delegate photoBrowser:self photoAtIndex:index];
            } else if (_depreciatedPhotoData && index < _depreciatedPhotoData.count) {
                photo = [_depreciatedPhotoData objectAtIndex:index];
            }
            if (photo) [_photos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_photos objectAtIndex:index];
        }
    }
    return photo;
}

- (id<MWPhoto>)thumbPhotoAtIndex:(NSUInteger)index {
    id <MWPhoto> photo = nil;
    if (index < _thumbPhotos.count) {
        if ([_thumbPhotos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:thumbPhotoAtIndex:)]) {
                photo = [_delegate photoBrowser:self thumbPhotoAtIndex:index];
            }
            if (photo) [_thumbPhotos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_thumbPhotos objectAtIndex:index];
        }
    }
    return photo;
}

- (MWCaptionView *)captionViewForPhotoAtIndex:(NSUInteger)index {
    MWCaptionView *captionView = nil;
    if ([_delegate respondsToSelector:@selector(photoBrowser:captionViewForPhotoAtIndex:)]) {
        captionView = [_delegate photoBrowser:self captionViewForPhotoAtIndex:index];
    } else {
        id <MWPhoto> photo = [self photoAtIndex:index];
        if ([photo respondsToSelector:@selector(caption)]) {
            if ([photo caption]) captionView = [[MWCaptionView alloc] initWithPhoto:photo];
        }
    }
    captionView.alpha = [self areControlsHidden] ? 0 : 1; // Initial alpha
    return captionView;
}

- (BOOL)photoIsSelectedAtIndex:(NSUInteger)index {
    BOOL value = NO;
    if (_displaySelectionButtons) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:isPhotoSelectedAtIndex:)]) {
            value = [self.delegate photoBrowser:self isPhotoSelectedAtIndex:index];
        }
    }
    return value;
}

- (void)setPhotoSelected:(BOOL)selected atIndex:(NSUInteger)index {
    if (_displaySelectionButtons) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:selectedChanged:)]) {
            [self.delegate photoBrowser:self photoAtIndex:index selectedChanged:selected];
        }
    }
}

- (UIImage *)imageForPhoto:(id<MWPhoto>)photo {
	if (photo) {
		// Get image or obtain in background
		if ([photo underlyingImage]) {
			return [photo underlyingImage];
		} else {
            [photo loadUnderlyingImageAndNotify];
		}
	}
	return nil;
}

- (void)loadAdjacentPhotosIfNecessary:(id<MWPhoto>)photo {
    MWZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = page.index;
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                id <MWPhoto> photo = [self photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                    MWLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex-1);
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                // Preload index + 1
                id <MWPhoto> photo = [self photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                    MWLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex+1);
                }
            }
        }
    }
}

#pragma mark - MWPhoto Loading Notification

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <MWPhoto> photo = [notification object];
    MWZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo underlyingImage]) {
            // Successful load
            [page displayImage];
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            // Failed to load
            [page displayImageFailure];
        }
        // Update nav
        [self updateNavigation];
    }
}

#pragma mark - Paging

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = _pagingScrollView.bounds;
	NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	NSInteger iLastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
	
	// Recycle no longer needed pages
    NSInteger pageIndex;
	for (MWZoomingScrollView *page in _visiblePages) {
        pageIndex = page.index;
		if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
			[_recycledPages addObject:page];
            [page.captionView removeFromSuperview];
            [page.selectedButton removeFromSuperview];
            [page prepareForReuse];
			[page removeFromSuperview];
			MWLog(@"Removed page at index %lu", (unsigned long)pageIndex);
		}
	}
	[_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
            
            // Add new page
			MWZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[MWZoomingScrollView alloc] initWithPhotoBrowser:self];
			}
			[_visiblePages addObject:page];
			[self configurePage:page forIndex:index];

			[_pagingScrollView addSubview:page];
			MWLog(@"Added page at index %lu", (unsigned long)index);
            
            // Add caption
            MWCaptionView *captionView = [self captionViewForPhotoAtIndex:index];
            if (captionView) {
                captionView.frame = [self frameForCaptionView:captionView atIndex:index];
                [_pagingScrollView addSubview:captionView];
                page.captionView = captionView;
            }
            
            // Add selected button
            if (self.displaySelectionButtons) {
                UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [selectedButton setImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/ImageSelectedOff.png"] forState:UIControlStateNormal];
                [selectedButton setImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/ImageSelectedOn.png"] forState:UIControlStateSelected];
                [selectedButton sizeToFit];
                selectedButton.adjustsImageWhenHighlighted = NO;
                [selectedButton addTarget:self action:@selector(selectedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                selectedButton.frame = [self frameForSelectedButton:selectedButton atIndex:index];
                [_pagingScrollView addSubview:selectedButton];
                page.selectedButton = selectedButton;
                selectedButton.selected = [self photoIsSelectedAtIndex:index];
            }
            
		}
	}
	
    if (_viewIsActive && _collectionView) {
        [self scrollCollectionView];
    }
}

- (void)scrollCollectionView
{
    NSArray *visiablePaths = [_collectionView indexPathsForVisibleItems];
    NSIndexPath *curPath = [NSIndexPath indexPathForItem:_currentPageIndex inSection:0];
    if (![visiablePaths containsObject:curPath]) {
        [_collectionView scrollToItemAtIndexPath:curPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

#pragma mark - 视频播放
- (BOOL)checkNormalVideo:(NSString *)format{
    return ([format hasSuffix:@"mp4"] ||
            [format hasSuffix:@"mov"] ||
            [format hasSuffix:@"mpeg-1"] ||
            [format hasSuffix:@"mpeg-2"] ||
            [format hasSuffix:@"mpeg-4"] ||
            [format hasSuffix:@"avi"] ||
            [format hasSuffix:@"asf"] ||
            [format hasSuffix:@"wmv"]);
}

/**
 *	@brief	视频播放
 *
 *	@param 	filePath 	视频路径
 */
- (void)playVideo:(NSURL *)movieURL
{
    NSString *url = [movieURL absoluteString];
    NSString *pathExtension = [[url pathExtension] lowercaseString];
    if (![self checkNormalVideo:pathExtension]) {
        _viewIsActive = NO;
        DJTOrderViewController *detail = [[DJTOrderViewController alloc] init];
        detail.url = url;
        [self.navigationController pushViewController:detail animated:YES];
    }
    else{
        self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        [self.movieController prepareToPlay];
        [self.view addSubview:self.movieController.view];//设置写在添加之后   // 这里是addSubView
        self.movieController.shouldAutoplay=YES;
        self.movieController.scalingMode = MPMovieScalingModeAspectFill;
        [self.movieController setControlStyle:MPMovieControlStyleDefault];
        [self.movieController setFullscreen:YES];
        [self.movieController.view setFrame:self.view.bounds];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    }
}
- (void)movieFinishedCallback:(NSNotification*)notify {
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [theMovie.view removeFromSuperview];
    
    self.movieController = nil;
}
- (void)updateVisiblePageStates {
    NSSet *copy = [_visiblePages copy];
    for (MWZoomingScrollView *page in copy) {
        
        // Update selection
        page.selectedButton.selected = [self photoIsSelectedAtIndex:page.index];
        
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (MWZoomingScrollView *page in _visiblePages)
		if (page.index == index) return YES;
	return NO;
}

- (MWZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
	MWZoomingScrollView *thePage = nil;
	for (MWZoomingScrollView *page in _visiblePages) {
		if (page.index == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (MWZoomingScrollView *)pageDisplayingPhoto:(id<MWPhoto>)photo {
	MWZoomingScrollView *thePage = nil;
	for (MWZoomingScrollView *page in _visiblePages) {
		if (page.photo == photo) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (void)configurePage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
    page.index = index;
    page.photo = [self photoAtIndex:index];
}

- (MWZoomingScrollView *)dequeueRecycledPage {
	MWZoomingScrollView *page = [_recycledPages anyObject];
	if (page) {
		[_recycledPages removeObject:page];
	}
	return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    
    if (![self numberOfPhotos]) {
        // Show controls
        [self setControlsHidden:NO animated:YES permanent:YES];
        return;
    }
    
    // Release images further away than +/-1
    NSUInteger i;
    if (index > 0) {
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) { 
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                [photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                MWLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    if (index < [self numberOfPhotos] - 1) {
        // Release anything > index + 1
        for (i = index + 2; i < _photos.count; i++) {
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                [photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                MWLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    id <MWPhoto> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    
    // Notify delegate
    if (index != _previousPageIndex) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:didDisplayPhotoAtIndex:)])
            [_delegate photoBrowser:self didDisplayPhotoAtIndex:index];
        _previousPageIndex = index;
    }
    
    // Update nav
    [self updateNavigation];
    
}

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return CGRectIntegral(frame);
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = _pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 32;
	return CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height));
}

- (CGRect)frameForCaptionView:(MWCaptionView *)captionView atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    CGSize captionSize = [captionView sizeThatFits:CGSizeMake(pageFrame.size.width, 0)];
    CGRect captionFrame = CGRectMake(pageFrame.origin.x,
                                     pageFrame.size.height - captionSize.height - (_toolbar.superview?_toolbar.frame.size.height:0),
                                     pageFrame.size.width,
                                     captionSize.height);
    return CGRectIntegral(captionFrame);
}

- (CGRect)frameForSelectedButton:(UIButton *)selectedButton atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    CGFloat yOffset = 0;
    if (![self areControlsHidden]) {
        UINavigationBar *navBar = self.navigationController.navigationBar;
        yOffset = navBar.frame.origin.y + navBar.frame.size.height;
    }
    CGFloat statusBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if (SYSTEM_VERSION_LESS_THAN(@"7") && !self.wantsFullScreenLayout) statusBarOffset = 0;
#endif
    CGRect captionFrame = CGRectMake(pageFrame.origin.x + pageFrame.size.width - 20 - selectedButton.frame.size.width,
                                     statusBarOffset + yOffset,
                                     selectedButton.frame.size.width,
                                     selectedButton.frame.size.height);
    return CGRectIntegral(captionFrame);
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
    if (scrollView == _collectionView) {
        return;
    }
    
    // Checks
	if (!_viewIsActive || _performingLayout || _rotating) return;
	
	
	// Calculate current page
	CGRect visibleBounds = _pagingScrollView.bounds;
	NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
	NSUInteger previousCurrentPage = _currentPageIndex;
	_currentPageIndex = index;
	if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
        if (_collectionView) {
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:previousCurrentPage inSection:0],[NSIndexPath indexPathForItem:_currentPageIndex inSection:0]]];
            if (_delegate && [_delegate respondsToSelector:@selector(changePhotoIdx:and:)]) {
                [_delegate changePhotoIdx:_currentPageIndex and:self];
            }
        }
        
        if (_horiBut) {
            _horiBut.selected = [_delegate respondsToSelector:@selector(shouldSelectItemAt:)] && [_delegate shouldSelectItemAt:_currentPageIndex];
        }
    }
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (scrollView != _pagingScrollView) {
        [self cancelControlHiding];
        return;
    }
    
	// Hide controls when dragging begins
	[self setControlsHidden:YES animated:YES permanent:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == _collectionView) {
        return;
    }
    
    // Tile pages
    [self tilePages];

    if (scrollView != _pagingScrollView) {
        [self hideControlsAfterDelay];
        return;
    }
    
	// Update nav when page changes
	[self updateNavigation];
}

#pragma mark - Navigation

- (void)updateNavigation {
    
	// Title
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    if (_gridController) {
        if (_gridController.selectionMode) {
            self.title = NSLocalizedString(@"Select Photos", nil);
        } else {
            NSString *photosText;
            if (numberOfPhotos == 1) {
                photosText = NSLocalizedString(@"photo", @"Used in the context: '1 photo'");
            } else {
                photosText = NSLocalizedString(@"photos", @"Used in the context: '3 photos'");
            }
            self.title = [NSString stringWithFormat:@"%lu %@", (unsigned long)numberOfPhotos, photosText];
        }
    } else if (numberOfPhotos > 1) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:titleForPhotoAtIndex:)]) {
            self.title = [_delegate photoBrowser:self titleForPhotoAtIndex:_currentPageIndex];
        } else {
            self.title = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(_currentPageIndex+1), NSLocalizedString(@"of", @"Used in the context: 'Showing 1 of 3 items'"), (unsigned long)numberOfPhotos];
        }
	} else {
		self.title = nil;
	}
	
	// Buttons
	_previousButton.enabled = (_currentPageIndex > 0);
	_nextButton.enabled = (_currentPageIndex < numberOfPhotos - 1);
    BOOL enabled = [[self photoAtIndex:_currentPageIndex] underlyingImage] != nil;
    _actionButton.enabled = enabled;
    _shareButton.enabled = enabled;
    _downButton.enabled = enabled;
    _horiBut.enabled = enabled;
    _numBut.enabled = enabled;
    _themeButton.customView.hidden = !(enabled && ([_delegate respondsToSelector:@selector(canJoinInTheme:and:)] && [_delegate canJoinInTheme:_currentPageIndex and:self]));
    if (_showDiggNum) {
        ThemeBatchModel *item = [_delegate checkNumInfo:_currentPageIndex and:self];
        UIView *firView = [[_toolbar.items firstObject] customView];
        UILabel *label1 = (UILabel *)[firView viewWithTag:1];
        UILabel *label2 = (UILabel *)[firView viewWithTag:2];
        [label1 setText:item.digg.stringValue];
        [label2 setText:item.replies.stringValue];
    }
}

- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
	
	// Change page
	if (index < [self numberOfPhotos]) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
        [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:animated];
		[self updateNavigation];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)gotoPreviousPage {
    [self showPreviousPhotoAnimated:NO];
}
- (void)gotoNextPage {
    [self showNextPhotoAnimated:NO];
}

- (void)showPreviousPhotoAnimated:(BOOL)animated {
    [self jumpToPageAtIndex:_currentPageIndex-1 animated:animated];
}

- (void)showNextPhotoAnimated:(BOOL)animated {
    [self jumpToPageAtIndex:_currentPageIndex+1 animated:animated];
}

#pragma mark - Interactions

- (void)selectedButtonTapped:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    selectedButton.selected = !selectedButton.selected;
    NSUInteger index = NSUIntegerMax;
    for (MWZoomingScrollView *page in _visiblePages) {
        if (page.selectedButton == selectedButton) {
            index = page.index;
            break;
        }
    }
    if (index != NSUIntegerMax) {
        [self setPhotoSelected:selectedButton.selected atIndex:index];
    }
}

#pragma mark - Grid

- (void)showGridAnimated {
    [self showGrid:YES];
}

- (void)showGrid:(BOOL)animated {

    if (_gridController) return;
    
    // Init grid controller
    _gridController = [[MWGridViewController alloc] init];
    _gridController.initialContentOffset = _currentGridContentOffset;
    _gridController.browser = self;
    _gridController.selectionMode = _displaySelectionButtons;
    _gridController.view.frame = self.view.bounds;
    _gridController.view.frame = CGRectOffset(_gridController.view.frame, 0, (self.startOnGrid ? -1 : 1) * self.view.bounds.size.height);

    // Stop specific layout being triggered
    _skipNextPagingScrollViewPositioning = YES;
    
    // Add as a child view controller
    [self addChildViewController:_gridController];
    [self.view addSubview:_gridController.view];
    
    // Hide action button on nav bar if it exists
    if (self.navigationItem.rightBarButtonItem == _actionButton) {
        _gridPreviousRightNavItem = _actionButton;
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    } else {
        _gridPreviousRightNavItem = nil;
    }
    
    // Update
    [self updateNavigation];
    [self setControlsHidden:NO animated:YES permanent:YES];
    
    // Animate grid in and photo scroller out
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^(void) {
        _gridController.view.frame = self.view.bounds;
        CGRect newPagingFrame = [self frameForPagingScrollView];
        newPagingFrame = CGRectOffset(newPagingFrame, 0, (self.startOnGrid ? 1 : -1) * newPagingFrame.size.height);
        _pagingScrollView.frame = newPagingFrame;
    } completion:^(BOOL finished) {
        [_gridController didMoveToParentViewController:self];
    }];
    
}

- (void)hideGrid {
    
    if (!_gridController) return;
    
    // Remember previous content offset
    _currentGridContentOffset = _gridController.collectionView.contentOffset;
    
    // Restore action button if it was removed
    if (_gridPreviousRightNavItem == _actionButton && _actionButton) {
        [self.navigationItem setRightBarButtonItem:_gridPreviousRightNavItem animated:YES];
    }
    
    // Position prior to hide animation
    CGRect newPagingFrame = [self frameForPagingScrollView];
    newPagingFrame = CGRectOffset(newPagingFrame, 0, (self.startOnGrid ? 1 : -1) * newPagingFrame.size.height);
    _pagingScrollView.frame = newPagingFrame;
    
    // Remember and remove controller now so things can detect a nil grid controller
    MWGridViewController *tmpGridController = _gridController;
    _gridController = nil;
    
    // Update
    [self updateNavigation];
    [self updateVisiblePageStates];
    
    // Animate, hide grid and show paging scroll view
    [UIView animateWithDuration:0.3 animations:^{
        tmpGridController.view.frame = CGRectOffset(self.view.bounds, 0, (self.startOnGrid ? -1 : 1) * self.view.bounds.size.height);
        _pagingScrollView.frame = [self frameForPagingScrollView];
    } completion:^(BOOL finished) {
        [tmpGridController willMoveToParentViewController:nil];
        [tmpGridController.view removeFromSuperview];
        [tmpGridController removeFromParentViewController];
        [self setControlsHidden:NO animated:YES permanent:NO]; // retrigger timer
    }];

}

#pragma mark - Control Hiding / Showing

// If permanent then we don't set timers to hide again
// Fades all controls on iOS 5 & 6, and iOS 7 controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    // Force visible
    if (![self numberOfPhotos] || _gridController || _alwaysShowControls)
        hidden = NO;
    
    // Cancel any timers
    [self cancelControlHiding];
    
    // Animations & positions
    BOOL slideAndFade = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7");
    CGFloat animatonOffset = 20;
    CGFloat animationDuration = (animated ? 0.35 : 0);
    // Status bar
    if (!_leaveStatusBarAlone) {
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            
            // iOS 7
            // Hide status bar
            if (!_isVCBasedStatusBarAppearance) {
                
                // Non-view controller based
                [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
                
            } else {
                
                // View controller based so animate away
                _statusBarShouldBeHidden = hidden;
                [UIView animateWithDuration:animationDuration animations:^(void) {
                    [self setNeedsStatusBarAppearanceUpdate];
                } completion:^(BOOL finished) {}];
                
            }

        } else {
            
            // iOS < 7
            // Status bar and nav bar positioning
            BOOL fullScreen = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            if (SYSTEM_VERSION_LESS_THAN(@"7")) fullScreen = self.wantsFullScreenLayout;
#endif
            if (fullScreen) {
                
                // Need to get heights and set nav bar position to overcome display issues
                
                // Get status bar height if visible
                CGFloat statusBarHeight = 0;
                if (![UIApplication sharedApplication].statusBarHidden) {
                    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                    statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
                }
                
                // Status Bar
                [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated?UIStatusBarAnimationFade:UIStatusBarAnimationNone];
                
                // Get status bar height if visible
                if (![UIApplication sharedApplication].statusBarHidden) {
                    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                    statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
                }
                
                // Set navigation bar frame
                CGRect navBarFrame = self.navigationController.navigationBar.frame;
                navBarFrame.origin.y = statusBarHeight;
                //self.navigationController.navigationBar.frame = navBarFrame;
                
            }
            
        }
    }

    // Toolbar, nav bar and captions
    // Pre-appear animation positions for iOS 7 sliding
    if (slideAndFade && [self areControlsHidden] && !hidden && animated) {
        
        // Toolbar
        _toolbar.frame = CGRectOffset([self frameForToolbarAtOrientation:self.interfaceOrientation], 0, animatonOffset);
        
        if (_collectionView) {
            [_collectionView setFrame:CGRectMake(_toolbar.frame.origin.x, _toolbar.frame.origin.y + _toolbar.frame.size.height - 90, _toolbar.frame.size.width, 90)];
        }
        
        // Captions
        for (MWZoomingScrollView *page in _visiblePages) {
            if (page.captionView) {
                MWCaptionView *v = page.captionView;
                // Pass any index, all we're interested in is the Y
                CGRect captionFrame = [self frameForCaptionView:v atIndex:0];
                captionFrame.origin.x = v.frame.origin.x; // Reset X
                v.frame = CGRectOffset(captionFrame, 0, animatonOffset);
            }
        }
        
    }
    [UIView animateWithDuration:animationDuration animations:^(void) {
        
        CGFloat alpha = hidden ? 0 : 1;

        // Nav bar slides up on it's own on iOS 7
        [self.navigationController.navigationBar setAlpha:alpha];
        
        // Toolbar
        if (slideAndFade) {
            _toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
            if (hidden) _toolbar.frame = CGRectOffset(_toolbar.frame, 0, animatonOffset);
            
            if (_collectionView) {
                [_collectionView setFrame:CGRectMake(_toolbar.frame.origin.x, _toolbar.frame.origin.y + _toolbar.frame.size.height - 90, _toolbar.frame.size.width, 90)];
            }
        }
        _toolbar.alpha = alpha;
        
        if (_collectionView) {
            [_collectionView setAlpha:alpha];
            _collectionView.userInteractionEnabled = (alpha == 1);
        }

        // Captions
        for (MWZoomingScrollView *page in _visiblePages) {
            if (page.captionView) {
                MWCaptionView *v = page.captionView;
                if (slideAndFade) {
                    // Pass any index, all we're interested in is the Y
                    CGRect captionFrame = [self frameForCaptionView:v atIndex:0];
                    captionFrame.origin.x = v.frame.origin.x; // Reset X
                    if (hidden) captionFrame = CGRectOffset(captionFrame, 0, animatonOffset);
                    v.frame = captionFrame;
                }
                v.alpha = alpha;
            }
        }
        
        // Selected buttons
        for (MWZoomingScrollView *page in _visiblePages) {
            if (page.selectedButton) {
                UIButton *v = page.selectedButton;
                CGRect newFrame = [self frameForSelectedButton:v atIndex:0];
                newFrame.origin.x = v.frame.origin.x;
                v.frame = newFrame;
            }
        }

    } completion:^(BOOL finished) {}];
    
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	if (!permanent) [self hideControlsAfterDelay];
}

- (BOOL)prefersStatusBarHidden {
    if (!_leaveStatusBarAlone) {
        return _statusBarShouldBeHidden;
    } else {
        return NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (_controlVisibilityTimer) {
		[_controlVisibilityTimer invalidate];
		_controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	if (![self areControlsHidden]) {
        [self cancelControlHiding];
		_controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:self.delayToHideElements target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (BOOL)areControlsHidden { return (_toolbar.alpha == 0); }
- (void)hideControls { [self setControlsHidden:YES animated:YES permanent:NO]; }
- (void)toggleControls { [self setControlsHidden:![self areControlsHidden] animated:YES permanent:NO]; }

#pragma mark - Properties

// Handle depreciated method
- (void)setInitialPageIndex:(NSUInteger)index {
    [self setCurrentPhotoIndex:index];
}

- (void)setCurrentPhotoIndex:(NSUInteger)index {
    // Validate
    NSUInteger photoCount = [self numberOfPhotos];
    if (photoCount == 0) {
        index = 0;
    } else {
        if (index >= photoCount)
            index = [self numberOfPhotos]-1;
    }
    _currentPageIndex = index;
	if ([self isViewLoaded]) {
        
        [self jumpToPageAtIndex:index animated:NO];
        if (!_viewIsActive)
            [self tilePages]; // Force tiling if view is not visible
    }
    
    
}

#pragma mark - Misc

- (void)doneButtonPressed:(id)sender {
    // Only if we're modal and there's a done button
    if (_doneButton) {
        // See if we actually just want to show/hide grid
        if (self.enableGrid) {
            if (self.startOnGrid && !_gridController) {
                [self showGrid:YES];
                return;
            } else if (!self.startOnGrid && _gridController) {
                [self hideGrid];
                return;
            }
        }
        // Dismiss view controller
        if ([_delegate respondsToSelector:@selector(photoBrowserDidFinishModalPresentation:)]) {
            // Call delegate method and let them dismiss us
            [_delegate photoBrowserDidFinishModalPresentation:self];
        } else  {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Actions

#pragma mark -下载缓存图片
- (void)downImage:(id)sender
{
    UIImage *img = [[self photoAtIndex:_currentPageIndex] underlyingImage];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"图片已下载到本地相册" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)deleteCurItem
{
    if (_delegate && [_delegate respondsToSelector:@selector(delePicture:and:)]) {
        [_delegate delePicture:_currentPageIndex and:self];
    }
}

- (void)beginMakeGrow:(id)sender
{
    BOOL canMake = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(shouldEditTouch:and:)]) {
        canMake = ([_delegate shouldEditTouch:_currentPageIndex and:self] != 0);
    }
    
    if (canMake) {
        UIButton *button = (UIButton *)sender;
        button.enabled = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(changeToMakeGrowed:)]) {
            [_delegate changeToMakeGrowed:_currentPageIndex];
        }
        button.enabled = YES;
    }
    else{
        [self cancelControlHiding];
        NSString *tip = @"老师暂时没有将该页开放给家长制作，请与老师联系。";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"使用提示" message:tip delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
        [alert show];
    }
}

- (void)actionButtonPressed:(id)sender {
    if (_actionsSheet) {
        
        // Dismiss
        [_actionsSheet dismissWithClickedButtonIndex:_actionsSheet.cancelButtonIndex animated:YES];
        
    } else {
        
        // Only react when image has loaded
        id <MWPhoto> photo = [self photoAtIndex:_currentPageIndex];
        if ([self numberOfPhotos] > 0 && [photo underlyingImage]) {
            
            // If they have defined a delegate method then just message them
            if ([self.delegate respondsToSelector:@selector(photoBrowser:actionButtonPressedForPhotoAtIndex:)]) {
                
                // Let delegate handle things
                [self.delegate photoBrowser:self actionButtonPressedForPhotoAtIndex:_currentPageIndex];
                
            } else {
                
                // Handle default actions
                if (SYSTEM_VERSION_LESS_THAN(@"6")) {
                    
                    // Old handling of activities with action sheet
                    if ([MFMailComposeViewController canSendMail]) {
                        _actionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil
                                                               otherButtonTitles:NSLocalizedString(@"Save", nil), NSLocalizedString(@"Copy", nil), NSLocalizedString(@"Email", nil), nil];
                    } else {
                        _actionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil
                                                               otherButtonTitles:NSLocalizedString(@"Save", nil), NSLocalizedString(@"Copy", nil), nil];
                    }
                    _actionsSheet.tag = ACTION_SHEET_OLD_ACTIONS;
                    _actionsSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        [_actionsSheet showFromBarButtonItem:sender animated:YES];
                    } else {
                        [_actionsSheet showInView:self.view];
                    }
                    
                } else {
                    
                    // Show activity view controller
                    NSMutableArray *items = [NSMutableArray arrayWithObject:[photo underlyingImage]];
                    if (photo.caption) {
                        [items addObject:photo.caption];
                    }
                    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
                    
                    // Show loading spinner after a couple of seconds
                    double delayInSeconds = 2.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        if (self.activityViewController) {
                            [self showProgressHUDWithMessage:nil];
                        }
                    });

                    // Show
                    typeof(self) __weak weakSelf = self;
                    [self.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
                        weakSelf.activityViewController = nil;
                        [weakSelf hideControlsAfterDelay];
                        [weakSelf hideProgressHUD:YES];
                    }];
                    [self presentViewController:self.activityViewController animated:YES completion:nil];
                    
                }
                
            }
            
            // Keep controls hidden
            [self setControlsHidden:NO animated:YES permanent:YES];

        }
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == ACTION_SHEET_OLD_ACTIONS) {
        // Old Actions
        _actionsSheet = nil;
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                [self savePhoto]; return;
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                [self copyPhoto]; return;	
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
                [self emailPhoto]; return;
            }
        }
    }
    
    //[self hideControlsAfterDelay]; // Continue as normal...
}

#pragma mark - Action Progress

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        // The sample image is based on the
        // work by: http://www.pixelpressicons.com
        // licence: http://creativecommons.org/licenses/by/2.5/ca/
        self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/Checkmark.png"]];
        [self.view addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)hideProgressHUD:(BOOL)animated {
    [self.progressHUD hide:animated];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    if (message) {
        if (self.progressHUD.isHidden) [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1.5];
    } else {
        [self.progressHUD hide:YES];
    }
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _audioPlayer = nil;
}

#pragma mark - 预览
- (void)cancelSelected:(id)sender
{
    if (!_horiBut.selected && (_selectedCount >= _totalCount)) {
        [self.view makeToast:[NSString stringWithFormat:@"非常抱歉，不能选择超过%ld张",(long)_totalCount] duration:1.0 position:@"center"];
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(isCanSelectItemAt:browser:)]) {
        BOOL canChecked = [_delegate isCanSelectItemAt:_currentPageIndex browser:self];
        if (!canChecked){
            return;
        }
    }
    
    _horiBut.selected = !_horiBut.selected;
    if (_horiBut.selected) {
        _selectedCount++;
    }
    else{
        _selectedCount--;
    }
    [_numBut setTitle:[NSString stringWithFormat:@"完成(%ld/%ld)",(long)_selectedCount,(long)_totalCount] forState:UIControlStateNormal];
    if ([_delegate respondsToSelector:@selector(cancelSelectedItemAt:Should:)]) {
        [_delegate cancelSelectedItemAt:_currentPageIndex Should:_horiBut.selected];
    }
}

- (void)preViewFinish:(id)sender{
    if ([_delegate respondsToSelector:@selector(finishPreView:)]) {
        [_delegate finishPreView:_currentPageIndex];
    }
}

#pragma mark - Actions
- (void)playVoice:(NSString *)urlStr
{
    if (_audioPlayer && [_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    
    NSString *fileName = [NSString md5:urlStr];
    NSString *filePath = [[NSString getCachePath:@"Audio"] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
        [_audioPlayer setDelegate:self];
        
        [_audioPlayer play];
        return;
    }
    
    [self.view makeToastActivity];
    _pagingScrollView.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    
    [DJTHttpClient asynchronousRequestWithProgress:urlStr parameters:nil filePath:nil ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf downFinish:YES Data:data file:fileName];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf downFinish:NO Data:nil file:nil];
        });
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
    }];
}

- (void)downFinish:(BOOL)suc Data:(id)data file:(NSString *)name
{
    [self.view hideToastActivity];
    _pagingScrollView.userInteractionEnabled = YES;
    if (suc) {
        NSString *filePath = [[NSString getCachePath:@"Audio"] stringByAppendingPathComponent:name];
        [data writeToFile:filePath options:NSAtomicWrite error:nil];
        
        //播放
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
        [_audioPlayer setDelegate:self];
        
        [_audioPlayer play];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [data valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

- (void)savePhoto {
    id <MWPhoto> photo = [self photoAtIndex:_currentPageIndex];
    if ([photo underlyingImage]) {
        [self showProgressHUDWithMessage:[NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"Saving", @"Displayed with ellipsis as 'Saving...' when an item is in the process of being saved")]];
        [self performSelector:@selector(actuallySavePhoto:) withObject:photo afterDelay:0];
    }
}

- (void)actuallySavePhoto:(id<MWPhoto>)photo {
    if ([photo underlyingImage]) {
        UIImageWriteToSavedPhotosAlbum([photo underlyingImage], self, 
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self showProgressHUDCompleteMessage: error ? NSLocalizedString(@"Failed", @"Informing the user a process has failed") : NSLocalizedString(@"Saved", @"Informing the user an item has been saved")];
    [self hideControlsAfterDelay]; // Continue as normal...
}

- (void)copyPhoto {
    id <MWPhoto> photo = [self photoAtIndex:_currentPageIndex];
    if ([photo underlyingImage]) {
        [self showProgressHUDWithMessage:[NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"Copying", @"Displayed with ellipsis as 'Copying...' when an item is in the process of being copied")]];
        [self performSelector:@selector(actuallyCopyPhoto:) withObject:photo afterDelay:0];
    }
}

- (void)actuallyCopyPhoto:(id<MWPhoto>)photo {
    if ([photo underlyingImage]) {
        [[UIPasteboard generalPasteboard] setData:UIImagePNGRepresentation([photo underlyingImage])
                                forPasteboardType:@"public.png"];
        [self showProgressHUDCompleteMessage:NSLocalizedString(@"Copied", @"Informing the user an item has finished copying")];
        [self hideControlsAfterDelay]; // Continue as normal...
    }
}

- (void)emailPhoto {
    id <MWPhoto> photo = [self photoAtIndex:_currentPageIndex];
    if ([photo underlyingImage]) {
        [self showProgressHUDWithMessage:[NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"Preparing", @"Displayed with ellipsis as 'Preparing...' when an item is in the process of being prepared")]];
        [self performSelector:@selector(actuallyEmailPhoto:) withObject:photo afterDelay:0];
    }
}

- (void)actuallyEmailPhoto:(id<MWPhoto>)photo {
    if ([photo underlyingImage]) {
        MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
        emailer.mailComposeDelegate = self;
        [emailer setSubject:NSLocalizedString(@"Photo", nil)];
        [emailer addAttachmentData:UIImagePNGRepresentation([photo underlyingImage]) mimeType:@"png" fileName:@"Photo.png"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            emailer.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        [self presentViewController:emailer animated:YES completion:nil];
        [self hideProgressHUD:NO];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultFailed) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email", nil)
                                                         message:NSLocalizedString(@"Email failed to send. Please try again.", nil)
                                                        delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
		[alert show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photoCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"checkItemCell" forIndexPath:indexPath];
    
    UIImageView *faceImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!faceImg) {
        faceImg = [[UIImageView alloc]initWithFrame:cell.bounds];
        faceImg.contentMode = UIViewContentModeScaleAspectFill;
        [faceImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        faceImg.clipsToBounds = YES;
        [faceImg setBackgroundColor:CreateColor(220, 220, 221)];
        [faceImg setTag:1];
        [cell.contentView addSubview:faceImg];
        
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frameWidth - 20, 0, 20, 20)];
        [tipImg setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [tipImg setTag:2];
        [cell.contentView addSubview:tipImg];
        
    }
    
    NSString *str = _imgSource[indexPath.item];
    [faceImg setImageWithURL:[NSURL URLWithString:str]];
    faceImg.alpha = (indexPath.item == _currentPageIndex) ? 1.0 : 0.5;
    
    UIImageView *tipImg = (UIImageView *)[cell.contentView viewWithTag:2];
    NSInteger index = [_delegate shouldEditTouch:indexPath.item and:self];
    NSString *tipStr = (index == 0) ? @"icon_no" : ((index == 1) ? @"icon_edit" : @"icon_ok");
    [tipImg setImage:CREATE_IMG(tipStr)];
    tipImg.alpha = faceImg.alpha;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == _currentPageIndex) {
        return;
    }
    NSInteger preIdx = _currentPageIndex;
    _currentPageIndex = indexPath.item;
    [self jumpToPageAtIndex:indexPath.item animated:NO];
    [collectionView reloadItemsAtIndexPaths:@[indexPath,[NSIndexPath indexPathForItem:preIdx inSection:0]]];
    [self didStartViewingPageAtIndex:_currentPageIndex];
    [self tilePages];
    if (_delegate && [_delegate respondsToSelector:@selector(changePhotoIdx:and:)]) {
        [_delegate changePhotoIdx:_currentPageIndex and:self];
    }
}

@end
