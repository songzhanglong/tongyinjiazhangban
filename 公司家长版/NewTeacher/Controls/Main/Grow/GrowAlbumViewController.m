//
//  GrowAlbumViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/29.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "GrowAlbumViewController.h"
#import "DJTGlobalManager.h"
#import "NSObject+Reflect.h"
#import "Toast+UIView.h"
#import "MobClick.h"
#import "NSString+Common.h"
#import "GrowTermModel.h"
#import "MakeGrowController.h"
#import "GrowNewCell.h"
#import "DJTOrderViewController.h"
#import "DJTOrderViewController.h"

@interface GrowAlbumViewController ()<MakeGrowControllerDelegate,GrowNewCellDelegate>

@end

@implementation GrowAlbumViewController
{
    NSIndexPath *_indexPath,*_collectIndexPath;//组中某一项
}

- (void)dealloc
{
    [MobClick endEvent:@"growup"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MobClick beginEvent:@"growup"];
    self.showBack = YES;
    self.titleLable.text = @"成长档案";
    [self.titleLable setTextColor:[UIColor whiteColor]];
    self.view.backgroundColor = CreateColor(236, 235, 243);
    
    UIButton *rigBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [rigBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [rigBut setFrame:CGRectMake(0, 0, 40, 30)];

    //right
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"?" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(checkTipInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];

    NSDictionary *param = @{@"student_id":manager.userInfo.userid,@"mid":manager.userInfo.mid};
    [self createTableViewAndRequestAction:@"grow:data_hb_stu_v3" Param:param Header:YES Foot:NO];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    [self beginRefresh];
}

- (void)checkTipInfo:(id)sender
{
    DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
    order.url = @"http://h5v2.goonbaby.com/v-U702US52AS";
    [self.navigationController pushViewController:order animated:YES];

}

- (void)findCollectionIndex:(GrowTermModel *)termModel At:(NSInteger)index
{
    NSInteger count = 0;
    for (NSInteger i = 0; i < termModel.album_list.count; i++) {
        GrowExtendModel *extend = termModel.album_list[i];
        count += extend.list.count;
        if (count > index) {
            _collectIndexPath = [NSIndexPath indexPathForItem:index - (count - extend.list.count) inSection:i];
            break;
        }
    }
}

#pragma mark - UI
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setBarTintColor:CreateColor(67, 154, 215)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setBarTintColor:[UIColor whiteColor]];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 制作页
- (void)beginReMakeAt:(NSIndexPath *)indexPath
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.navigationController.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    GrowTermModel *term = self.dataSource[_indexPath.section];
    GrowExtendModel *extend = term.album_list[indexPath.section];
    GrowAlbumModel *growAlbum = extend.list[indexPath.item];
    NSString *url = growAlbum.template_path_edit;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_GROW_ADDRESS stringByAppendingString:url ?: @""];
    }
    NSURL *downUrl = [NSURL URLWithString:url];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = nil;
    if (manager.cacheKeyFilter) {
        key = manager.cacheKeyFilter(downUrl);
    }
    else {
        key = [downUrl absoluteString];
    }
    
    if (!key) {
        [self.navigationController.view makeToast:@"图片地址异常" duration:1.0 position:@"center"];
        return;
    }
    
    UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:key];
    if (image) {
        //无需下载
        [self downloadTemplate:YES Data:image];
        return;
    }
    else
    {
        UIImage *diskImage = [manager.imageCache imageFromDiskCacheForKey:key];
        if (diskImage) {
            //无需下载
            [self downloadTemplate:YES Data:diskImage];
            return;
        }
    }
    
    //下载
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity];
    @try {
        __weak typeof(self)weakSelf = self;
        [manager downloadWithURL:downUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [weakSelf downloadTemplate:NO Data:nil];
                }
                else
                {
                    [weakSelf downloadTemplate:YES Data:image];
                }
            });
            
        }];
    } @catch (NSException *e) {
        [self downloadTemplate:NO Data:nil];
    }
}

- (void)downloadTemplate:(BOOL)suc Data:(UIImage *)img
{
    self.navigationController.view.userInteractionEnabled = YES;
    [self.navigationController.view hideToastActivity];
    if (!suc) {
        [self.navigationController.view makeToast:@"模板下载失败" duration:1.0 position:@"center"];
        return;
    }
    else
    {
        //[self.navigationController.view makeToast:@"模板下载成功" duration:1.0 position:@"center"];
    }

    GrowTermModel *term = self.dataSource[_indexPath.section];
    GrowExtendModel *extend = term.album_list[_collectIndexPath.section];
    GrowAlbumModel *growAlbum = extend.list[_collectIndexPath.item];

    MakeGrowController *makeGrow = [[MakeGrowController alloc] init];
    makeGrow.isSmallPicLimit = ([growAlbum.allow_nonhd integerValue] == 1);
    makeGrow.growAlbum = growAlbum;
    makeGrow.targerImg = img;
    makeGrow.album_id = extend.album_id;
    makeGrow.album_title = extend.album_title;
    makeGrow.growId = term.grow_id;
    makeGrow.templist_id = term.templist_id;
    makeGrow.tpl_width = term.tpl_width;
    makeGrow.tpl_height = term.tpl_height;
    makeGrow.delegate = self;
    [self.navigationController pushViewController:makeGrow animated:YES];
}

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (!success) {
        NSString *tip = @"数据请求失败";
        if (result && [result valueForKey:@"message"]) {
            tip = [result valueForKey:@"message"];
        }
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        NSArray *dataList = [result valueForKey:@"data"];
        if (dataList && [dataList isKindOfClass:[NSArray class]]) {
            self.dataSource = [GrowTermModel arrayOfModelsFromDictionaries:dataList error:nil];
        }
        else{
            self.dataSource = nil;
        }
        [_tableView reloadData];
    }
}

#pragma mark - videoArr + isVideo
- (NSArray *)getGalleryArrayBy:(GrowAlbumModel *)growAlbum
{
    NSMutableArray *galleryArray = [NSMutableArray array];
    NSString *url = growAlbum.play_url ?: @"";
    
    for (NSInteger i = 0; i < growAlbum.src_gallery_list.count; i++) {
        NSArray *subArr = growAlbum.src_gallery_list[i];
        if ([subArr count] > 1) {
            NSString *curUrl = [url stringByAppendingString:[NSString stringWithFormat:@"?i=%ld",(long)i]];
            [galleryArray addObject:curUrl];
        }
        else{
            [galleryArray addObject:@""];
        }
    }
    
    return galleryArray;
}

- (NSArray *)getVideoArrayBy:(GrowAlbumModel *)growAlbum
{
    NSMutableArray *videoArr = [NSMutableArray array];
    NSInteger maxCount = MAX(growAlbum.src_h5_list.count, growAlbum.src_video_list.count);
    for (NSInteger nm = 0; nm < maxCount; nm++) {
        if (growAlbum.src_h5_list && [growAlbum.src_h5_list count] > nm) {
            NSString *h5Str = growAlbum.src_h5_list[nm];
            if (h5Str.length > 0) {
                if (![h5Str hasPrefix:@"http"]) {
                    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
                    h5Str = [user.h5_url stringByAppendingString:h5Str];
                }
                [videoArr addObject:h5Str];
            }
            else if (growAlbum.src_video_list && [growAlbum.src_video_list count] > nm){
                NSString *videoStr = growAlbum.src_video_list[nm];
                [videoArr addObject:videoStr];
            }
            else{
                [videoArr addObject:@""];
            }
        }
        else if (growAlbum.src_video_list && [growAlbum.src_video_list count] > nm){
            NSString *videoStr = growAlbum.src_video_list[nm];
            [videoArr addObject:videoStr];
        }
        else{
            [videoArr addObject:@""];
        }
    }
    return videoArr;
}

- (BOOL)checkIsVideo:(GrowAlbumModel *)growAlbum
{
    BOOL isVideo = NO;
    for (NSString *subStr in growAlbum.src_video_list) {
        if ([subStr length] > 0) {
            isVideo = YES;
            break;
        }
    }
    if (!isVideo) {
        for (NSString *subStr in growAlbum.src_h5_list) {
            if ([subStr length] > 0) {
                isVideo = YES;
                break;
            }
        }
    }
    
    return isVideo;
}

- (BOOL)checkIsGallery:(GrowAlbumModel *)growAlbum
{
    BOOL isGallery = NO;
    for (NSArray *array in growAlbum.src_gallery_list) {
        if ([array count] > 1) {
            isGallery = YES;
            break;
        }
    }
    return isGallery;
}

- (NSArray *)getVoiceArrayBy:(GrowAlbumModel *)growAlbum
{
    NSMutableArray *voiceArr = [NSMutableArray array];
    NSInteger count = growAlbum.src_txt_list.count;
    for (NSInteger i = 0; i < count; i++) {
        NSString *str = growAlbum.src_txt_list[i];
        if (str.length > 0) {
            if ([str hasPrefix:@"["] && [str rangeOfString:@"]"].location != NSNotFound) {
                NSRange range = [str rangeOfString:@"]"];
                NSString * url = [str substringWithRange:NSMakeRange(1,range.location - 1)];
                if (![url hasPrefix:@"http"]) {
                    url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                }
                [voiceArr addObject:url];
            }
            else{
                [voiceArr addObject:@""];
            }
        }
        else{
            [voiceArr addObject:@""];
        }
    }
    
    return voiceArr;
}

- (BOOL)checkIsAudio:(GrowAlbumModel *)growAlbum
{
    BOOL isAudio = NO;
    for (NSString *subStr in growAlbum.src_txt_list) {
        if ([subStr hasPrefix:@"["] && [subStr rangeOfString:@"]"].location != NSNotFound) {
            isAudio = YES;
            break;
        }
    }
    
    return isAudio;
}

#pragma mark - GrowNewCellDelegate
- (void)startToPrint:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    GrowTermModel *term = self.dataSource[indexPath.section];
    if (term.print_flag.integerValue != 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"使用提示" message:term.print_tip ?: @"" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }else {
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        NSString *url = [NSString stringWithFormat:@"http://mall.goonbaby.com/moblie/member/printTy?userid=%@&mid=%@&product_id=0&grow_id=%@",user.userid,user.mid,term.grow_id];
        DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
        order.url = url;
        [self.navigationController pushViewController:order animated:YES];
    }
}

#pragma mark - MakeGrowControllerDelegate
- (void)makeFinishImg:(NSString *)imgPath Data:(id)data url:(NSString *)url
{
    MWPhotoBrowser *browser = nil;
    NSArray *viewControls = self.navigationController.viewControllers;
    for (UIViewController *control in viewControls) {
        if ([control isKindOfClass:[MWPhotoBrowser class]]) {
            browser = (MWPhotoBrowser *)control;
            break;
        }
    }
    
    //数据处理
    GrowTermModel *term = self.dataSource[_indexPath.section];
    GrowExtendModel *extend = term.album_list[_collectIndexPath.section];
    GrowAlbumModel *album = extend.list[_collectIndexPath.item];
    album.image_thumb = imgPath;
    album.image_path = url;
    album.src_image_list = [data valueForKey:@"src_image_list"];
    album.src_gallery_list = [data valueForKey:@"src_gallery_list"];
    album.src_txt_list = [data valueForKey:@"src_txt_list"];
    album.image_detail_list = [data valueForKey:@"image_detail_list"];
    album.deco_detail_list = [data valueForKey:@"deco_detail_list"];
    album.src_deco_list = [data valueForKey:@"src_deco_list"];
    album.src_deco_txt_list = [data valueForKey:@"src_deco_txt_list"];
    
    if (browser) {
        NSInteger curIdx = _collectIndexPath.item;
        for (NSInteger i = 0; i < _collectIndexPath.section; i++) {
            GrowExtendModel *tmpExtend = term.album_list[i];
            curIdx += [tmpExtend.list count];
        }
        BOOL isGallery = [self checkIsGallery:album];
        BOOL isVoice = [self checkIsAudio:album];
        NSString *str = album.image_path;
        NSString *preStr = G_IMAGE_GROW_ADDRESS;
        if ((str && ![str isKindOfClass:[NSNull class]]) && ([str length] > 2)) {
            NSString *bigStr = [str hasPrefix:@"http"] ? str : [preStr stringByAppendingString:str];
            MWPhoto *bigPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:bigStr]];
            if (isGallery) {
                bigPhoto.isVideo = YES;
                NSArray *galleryArray = [self getGalleryArrayBy:album];
                bigPhoto.videoPaths = galleryArray;
            }
            else if ([self checkIsVideo:album]) {
                bigPhoto.isVideo = YES;
                NSArray *videoArr = [self getVideoArrayBy:album];
                bigPhoto.videoPaths = videoArr;
            }
            if (isVoice) {
                bigPhoto.isVoice = YES;
                bigPhoto.voicePaths = [self getVoiceArrayBy:album];
            }
            [_browserPhotos replaceObjectAtIndex:curIdx withObject:bigPhoto];
        }
        else
        {
            
            NSString *temStr = [album.template_path hasPrefix:@"http"] ? album.template_path : [preStr stringByAppendingString:album.template_path];
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:temStr]];
            if (isGallery) {
                photo.isVideo = YES;
                NSArray *galleryArray = [self getGalleryArrayBy:album];
                photo.videoPaths = galleryArray;
            }
            else if ([self checkIsVideo:album]){
                photo.isVideo = YES;
                NSArray *videoArr = [self getVideoArrayBy:album];
                photo.videoPaths = videoArr;
            }
            if (isVoice) {
                photo.isVoice = YES;
                photo.voicePaths = [self getVoiceArrayBy:album];
            }
            [_browserPhotos replaceObjectAtIndex:curIdx withObject:photo];
        }
        
        NSString *smallStr = (album.image_thumb && ![album.image_thumb isKindOfClass:[NSNull class]]) ? album.image_thumb : album.template_path_thumb;
        smallStr = [smallStr hasPrefix:@"http"] ? smallStr : [preStr stringByAppendingString:smallStr];
        [browser.imgSource replaceObjectAtIndex:curIdx withObject:smallStr];
        [browser reloadData];
        [self.navigationController popToViewController:browser animated:YES];
    }
    else{
        [self.navigationController popToViewController:self animated:YES];
    }
}

#pragma mark - MWPhotoBrowserDelegate
- (NSInteger)shouldEditTouch:(NSInteger)index and:(MWPhotoBrowser *)browser
{
    //0-不可编辑，1-可编辑，但未编辑，2-可编辑，已编辑过
    GrowTermModel *termModel = self.dataSource[_indexPath.section];
    [self findCollectionIndex:termModel At:index];
    GrowExtendModel *extend = termModel.album_list[_collectIndexPath.section];
    
    GrowAlbumModel *album = extend.list[_collectIndexPath.item];
    NSInteger retCode = 0;
    if (!([termModel.edit_flag length] > 0 && [termModel.edit_flag integerValue] == 0)) {
        if ([album.allow_parent integerValue] != 0) {
            if ([album.image_path isKindOfClass:[NSString class]] && (album.image_path.length > 2)) {
                retCode = 2;
            }
            else{
                retCode = 1;
            }
        }
    }
    
    return retCode;
    
}

- (void)changeToMakeGrowed:(NSInteger)index
{
    GrowTermModel *termModel = self.dataSource[_indexPath.section];
    [self findCollectionIndex:termModel At:index];
    [self beginReMakeAt:_collectIndexPath];
}

- (CGRect)calculateFrameAt:(NSInteger)index Source:(NSInteger)sIdx
{
    GrowTermModel *termModel = self.dataSource[_indexPath.section];
    [self findCollectionIndex:termModel At:index];
    GrowExtendModel *extend = termModel.album_list[_collectIndexPath.section];
    GrowAlbumModel *album = extend.list[_collectIndexPath.item];
    
    id image_coor = [album.template_detail valueForKey:@"image_coor"];
    if (image_coor && [image_coor count] > 0 && [image_coor count] > sIdx) {
        NSDictionary *dic = [image_coor objectAtIndex:sIdx];
        NSString *xValue = [dic valueForKey:@"x"];
        NSString *yValue = [dic valueForKey:@"y"];
        if ((!xValue || [xValue isKindOfClass:[NSNull class]] || [xValue isEqualToString:@""]) || (!yValue || [yValue isKindOfClass:[NSNull class]] || [yValue isEqualToString:@""])) {
            return CGRectZero;
        }
        NSArray *x = [xValue componentsSeparatedByString:@","];
        NSArray *y = [yValue componentsSeparatedByString:@","];
        return CGRectMake([x[0] floatValue], [x[1] floatValue], ([y[0] floatValue] - [x[0] floatValue]), ([y[1] floatValue] - [x[1] floatValue]));
    }
    return CGRectZero;
}

- (CGRect)calculateFrameAt:(NSInteger)index SourceVoice:(NSInteger)sIdx
{
    GrowTermModel *termModel = self.dataSource[_indexPath.section];
    [self findCollectionIndex:termModel At:index];
    GrowExtendModel *extend = termModel.album_list[_collectIndexPath.section];
    GrowAlbumModel *album = extend.list[_collectIndexPath.item];
    
    id word_coor = [album.template_detail valueForKey:@"word_coor"];
    if (word_coor && [word_coor count] > 0 && [word_coor count] > sIdx) {
        NSDictionary *dic = [word_coor objectAtIndex:sIdx];
        NSString *xValue = [dic valueForKey:@"x"];
        NSString *yValue = [dic valueForKey:@"y"];
        if ((!xValue || [xValue isKindOfClass:[NSNull class]] || [xValue isEqualToString:@""]) || (!yValue || [yValue isKindOfClass:[NSNull class]] || [yValue isEqualToString:@""])) {
            return CGRectZero;
        }
        NSArray *x = [xValue componentsSeparatedByString:@","];
        NSArray *y = [yValue componentsSeparatedByString:@","];
        return CGRectMake([x[0] floatValue], [x[1] floatValue], ([y[0] floatValue] - [x[0] floatValue]), ([y[1] floatValue] - [x[1] floatValue]));
    }
    return CGRectZero;
}

- (void)changePhotoIdx:(NSInteger)index and:(MWPhotoBrowser *)browser{
    GrowTermModel *termModel = self.dataSource[_indexPath.section];
    NSString *str = [NSString stringWithFormat:@"%@%@%@",EDIT_INDEX,termModel.grow_id,termModel.templist_id];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:str];
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
    static NSString *growAlbumCell = @"GrowAlbumCell";
    
    GrowNewCell *cell = [tableView dequeueReusableCellWithIdentifier:growAlbumCell];
    if (cell == nil) {
        cell = [[GrowNewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:growAlbumCell];
        cell.delegate = self;
    }
    
    [cell resetDataSource:self.dataSource[indexPath.section]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _indexPath = indexPath;
    
    GrowTermModel *term = self.dataSource[_indexPath.section];
    
    _browserPhotos = [NSMutableArray array];
    
    NSString *preStr = G_IMAGE_GROW_ADDRESS;
    NSMutableArray *tmpSource = [NSMutableArray array];
    
    NSInteger totalCount = 0;
    for (NSInteger i = 0; i < term.album_list.count; i++) {
        GrowExtendModel *extend = term.album_list[i];
        totalCount += extend.list.count;
        
        for (NSInteger j = 0; j < extend.list.count; j++) {
            GrowAlbumModel *growAlbum = extend.list[j];
            BOOL isGallery = [self checkIsGallery:growAlbum];
            BOOL isVoice = [self checkIsAudio:growAlbum];
            NSString *str = growAlbum.image_path;
            if ((str && ![str isKindOfClass:[NSNull class]]) && ([str length] > 2)) {
                NSString *bigStr = [str hasPrefix:@"http"] ? str : [preStr stringByAppendingString:str];
                MWPhoto *bigPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:bigStr]];
                if (isGallery) {
                    bigPhoto.isVideo = YES;
                    NSArray *galleryArray = [self getGalleryArrayBy:growAlbum];
                    bigPhoto.videoPaths = galleryArray;
                }
                else if ([self checkIsVideo:growAlbum]) {
                    bigPhoto.isVideo = YES;
                    NSArray *videoArr = [self getVideoArrayBy:growAlbum];
                    bigPhoto.videoPaths = videoArr;
                }
                if (isVoice) {
                    bigPhoto.isVoice = YES;
                    bigPhoto.voicePaths = [self getVoiceArrayBy:growAlbum];
                }
                [_browserPhotos addObject:bigPhoto];
            }
            else
            {
                NSString *temStr = [growAlbum.template_path hasPrefix:@"http"] ? growAlbum.template_path : [preStr stringByAppendingString:growAlbum.template_path];
                MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:temStr]];
                if (isGallery) {
                    photo.isVideo = YES;
                    NSArray *galleryArray = [self getGalleryArrayBy:growAlbum];
                    photo.videoPaths = galleryArray;
                }
                else if ([self checkIsVideo:growAlbum]){
                    photo.isVideo = YES;
                    NSArray *videoArr = [self getVideoArrayBy:growAlbum];
                    photo.videoPaths = videoArr;
                }
                if (isVoice) {
                    photo.isVoice = YES;
                    photo.voicePaths = [self getVoiceArrayBy:growAlbum];
                }
                [_browserPhotos addObject:photo];
                
            }
            
            NSString *smallStr = (growAlbum.image_thumb && ![growAlbum.image_thumb isKindOfClass:[NSNull class]]) ? growAlbum.image_thumb : growAlbum.template_path_thumb;
            smallStr = [smallStr hasPrefix:@"http"] ? smallStr : [preStr stringByAppendingString:smallStr];
            [tmpSource addObject:smallStr];
        }
    }

    if ([tmpSource count] == 0) {
        [self.view makeToast:@"没有模板数据哦" duration:1.0 position:@"center"];
        return;
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    NSString *str = [NSString stringWithFormat:@"%@%@%@",EDIT_INDEX,term.grow_id,term.templist_id];
    NSInteger curIndex = [[NSUserDefaults standardUserDefaults] integerForKey:str];
    if (curIndex > totalCount - 1) {
        curIndex = 0;
    }
    [browser setCurrentPhotoIndex:curIndex];
    browser.displayActionButton = NO;
    browser.canEditItem = ([term.edit_flag length] > 0 && [term.edit_flag integerValue] == 0) ? 2 : 1;
    browser.displayNavArrows = NO;
    browser.imgSource = tmpSource;
    [self.navigationController pushViewController:browser animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:_tableView.backgroundColor];
}

@end
