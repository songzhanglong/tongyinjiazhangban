//
//  MainViewController1.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/4/16.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MainViewController1.h"
#import "MobClick.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "ClassCircleModel.h"
#import "ClassReplyDetailController.h"
#import "UIImage+Caption.h"
#import "DynamicViewCell1.h"
#import <AVFoundation/AVFoundation.h>
#import "NSDate+Common.h"

@interface MainViewController1 ()<ClassReplyDetailDelegate,DynamicViewCell1Delegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation MainViewController1
{
    NSInteger       _pageIndex;
    NSIndexPath     *_indexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"个人消息列表";
    self.useNewInterface = YES;
    _pageIndex = 1;
    
    //表格＋网络
    [self createTableViewAndRequestAction:@"dynamic" Param:nil Header:YES Foot:YES];
    [_tableView registerClass:[DynamicViewCell1 class] forCellReuseIdentifier:@"dynamicCell"];
    [self beginRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [MobClick beginLogPageView:@"classCircle"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"classCircle"];
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"myDynamic"];
    [param setObject:_activityModel.class_id forKey:@"class_id"];
    [param setObject:_activityModel.authorid forKey:@"userid"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIndex] forKey:@"page"];
    [param setObject:@"10" forKey:@"pageSize"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)startPullRefresh
{
    _pageIndex = 1;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    NSInteger count = 0;
    for (id subObject in self.dataSource) {
        count += [subObject count];
    }
    
    if ((count % 10) > 0) {
        [self.view makeToast:@"已到最后一页" duration:1.0 position:@"center"];
        
        //isStopRefresh
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
    }
    else
    {
        _pageIndex = count / 10 + 1;
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSMutableArray *tmpArr = (array.count > 0) ? [array lastObject] : [NSMutableArray array];
            NSError *error;
            ClassCircleModel *circle = [[ClassCircleModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [circle calculateGroupCircleRects];
            
            if (tmpArr.count > 0) {
                ClassCircleModel *preCir = [tmpArr lastObject];
                if ([NSString compareSameDay:preCir.dateline Other:circle.dateline]) {
                    [tmpArr addObject:circle];
                }
                else
                {
                    [array addObject:[NSMutableArray arrayWithObject:circle]];
                }
            }
            else
            {
                //第一个
                [tmpArr addObject:circle];
                [array addObject:tmpArr];
            }
        }
        
        self.dataSource = array;
        [_tableView reloadData];
    }
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSMutableArray *array = self.dataSource;
        if (!array) {
            array = [NSMutableArray array];
            self.dataSource = array;
        }
        for (id subDic in data) {
            NSError *error;
            ClassCircleModel *circle = [[ClassCircleModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            
            [circle calculateGroupCircleRects];
            
            NSMutableArray *tmpArr = (array.count > 0) ? [array lastObject] : [NSMutableArray array];
            if (tmpArr.count > 0) {
                ClassCircleModel *preCir = [tmpArr lastObject];
                if ([NSString compareSameDay:preCir.dateline Other:circle.dateline]) {
                    [tmpArr addObject:circle];
                }
                else
                {
                    [array addObject:[NSMutableArray arrayWithObject:circle]];
                }
            }
            else
            {
                //第一个
                [tmpArr addObject:circle];
                [array addObject:tmpArr];
            }
        }
        
        [_tableView reloadData];
    }
}

#pragma mark - 视频播放
/**
 *	@brief	视频播放
 *
 *	@param 	filePath 	视频路径
 */
- (void)playVideo:(NSString *)filePath
{
    if (![filePath hasPrefix:@"http"]) {
        filePath = [G_IMAGE_ADDRESS stringByAppendingString:filePath ?: @""];
    }
    NSURL *movieURL = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    self.movieController.scalingMode = MPMovieScalingModeAspectFill;
    [self.movieController prepareToPlay];
    [self.view addSubview:self.movieController.view];//设置写在添加之后   // 这里是addSubView
    self.movieController.shouldAutoplay=YES;
    [self.movieController setControlStyle:MPMovieControlStyleDefault];
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

#pragma mark - DynamicViewCell1Delegate
- (void)selectImgView:(UITableViewCell *)cell At:(NSInteger)idx
{
    if (idx < 100) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        //检测视频
        ClassCircleModel *circle = self.dataSource[indexPath.section][indexPath.row];
        NSArray *pics = [circle.picture componentsSeparatedByString:@"|"];
        NSArray *thumbs = [circle.picture_thumb componentsSeparatedByString:@"|"];
        
        //图片
        _browserPhotos = [NSMutableArray array];
        for (int i = 0; i < pics.count; i++) {
            NSString *path = pics[i];
            if (![path hasPrefix:@"http"]) {
                path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
            }
            
            MWPhoto *photo = nil;
            NSString *name = [path lastPathComponent];
            if ([[[name pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
                NSString *tmpThumb = thumbs[i];
                if ([[[tmpThumb pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
                    photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                }
                else
                {
                    if (![tmpThumb hasPrefix:@"http"]) {
                        tmpThumb = [G_IMAGE_ADDRESS stringByAppendingString:tmpThumb ?: @""];
                    }
                    photo = [MWPhoto photoWithURL:[NSURL URLWithString:tmpThumb]];
                }
                photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                photo.isVideo = YES;
            }
            else
            {
                CGFloat scale_screen = [UIScreen mainScreen].scale;
                NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
                path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
            [_browserPhotos addObject:photo];
        }
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        [browser setCurrentPhotoIndex:idx];
        browser.displayActionButton = NO;
        browser.displayNavArrows = YES;
        
        [self.navigationController pushViewController:browser animated:YES];
    }
}

#pragma mark - ClassReplyDetailDelegate
- (void)changeReplyDetail
{
    [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteThisCircleDetail
{
    [self.navigationController popViewControllerAnimated:YES];
    NSMutableArray *sectionArr = [self.dataSource objectAtIndex:_indexPath.section];
    [sectionArr removeObjectAtIndex:_indexPath.row];
    if (sectionArr.count == 0) {
        [self.dataSource removeObject:sectionArr];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:_indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [_tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (_indexPath.row == 0) {
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:_indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [self.dataSource count];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [self.dataSource objectAtIndex:section];
    
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"dynamicCell";
    
    DynamicViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self;
    cell.firstIdx = (indexPath.row == 0);
    [cell resetClassGroupData:self.dataSource[indexPath.section][indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassCircleModel *model = self.dataSource[indexPath.section][indexPath.row];
    return MAX(model.butYori2, 38);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.httpOperation) {
        [self.view makeToast:@"数据正在加载，请稍候" duration:1.0 position:@"center"];
        return;
    }
    
    _indexPath = indexPath;
    ClassReplyDetailController *reply = [[ClassReplyDetailController alloc] init];
    reply.delegate = self;
    ClassCircleModel *circle = self.dataSource[indexPath.section][indexPath.row];
    reply.circleId = circle.tid;
    reply.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:reply animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    } else if (scrollView.contentOffset.y >=sectionHeaderHeight ) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
    
}

@end
