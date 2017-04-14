//
//  ClassActivityViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassActivityViewController.h"
#import "MileageModel.h"
#import "ClassSelectedViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "ThemeBatchModel.h"
#import "ClassActivityNewCell.h"
#import "MakeGrowController.h"

@interface ClassActivityViewController ()<ClassSelectedDelegate,UIAlertViewDelegate>

@end

@implementation ClassActivityViewController
{
    NSMutableArray *_dataArray,*_selectAlbums,*_changeArr,*_downImgs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.showBack = YES;
    self.titleLable.text = @"班级里程";
    self.useNewInterface = YES;
    
    _dataArray = [[NSMutableArray alloc] init];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMileageAlbums"];
    [param setObject:@"2" forKey:@"mileage_type"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [self createTableViewAndRequestAction:@"photo" Param:param Header:YES Foot:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self beginRefresh];
}

- (void)backToPreControl:(id)sender
{
    if ([_selectAlbums count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否将图片导入模板？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSMutableArray *array = [NSMutableArray array];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        for (id subDic in ret_data) {
            NSError *error;
            MileageThumbItem *model = [[MileageThumbItem alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            if (!model.up_time || (model.up_time.doubleValue == 0)) {
                continue;
            }
            [array addObject:model];
        }
        
        self.dataSource = array;
    }
    else{
        self.dataSource = nil;
    }
    [_tableView reloadData];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        _changeArr = [NSMutableArray array];
        _downImgs = [NSMutableArray array];
        for (ThemeBatchItem *item in _selectAlbums) {
            NSString *url = item.path;
            if (![url hasPrefix:@"http"]) {
                url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
            }
            if ([url rangeOfString:@"{"].location != NSNotFound) {
                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [_changeArr addObject:url];
        }
        
        [self.view makeToastActivity];
        self.view.userInteractionEnabled = NO;
        ((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).enabled = NO;
        [self beginDownLoadImgs];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 图片下载
- (void)beginDownLoadImgs
{
    @try {
        NSString *url = [_changeArr firstObject];
        [_changeArr removeObject:url];
        __weak typeof(self)weakSelf= self;
        __weak typeof(_changeArr)weakImgs = _changeArr;
        __weak typeof(_downImgs)weakDownImgs = _downImgs;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [weakSelf downFinish:NO];
                }
                else
                {
                    [weakDownImgs addObject:image];
                    if (weakImgs.count == 0) {
                        [weakSelf downFinish:YES];
                    }
                    else
                    {
                        [weakSelf beginDownLoadImgs];
                    }
                }
            });
            
        }];
    } @catch (NSException *e) {
        [self downFinish:NO];
    }
}

- (void)downFinish:(BOOL)suc
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    ((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).enabled = YES;
    if (suc) {
        [self selectClass:_downImgs];
    }
    else
    {
        [self.view makeToast:@"原始图片下载异常" duration:1.0 position:@"center"];
    }
}

#pragma mark - ClassSelectedDelegate
- (void)selectClass:(NSArray *)array
{
    if (array.count <= 0) {
        if ([_delegate isKindOfClass:[MakeGrowController class]]) {
            [self.navigationController popToViewController:(MakeGrowController *)_delegate animated:YES];
        }
        return;
    }
    
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:array];
    
    [_delegate selectClassActivity:_dataArray];
    if ([_delegate isKindOfClass:[MakeGrowController class]]) {
        [self.navigationController popToViewController:(MakeGrowController *)_delegate animated:YES];
    }
}

- (void)selectAlbumsFromPre:(NSArray *)array
{
    if (!_selectAlbums) {
        _selectAlbums = [NSMutableArray array];
    }
    [_selectAlbums addObjectsFromArray:array];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *activityNewCell = @"classActivityNewCell";
    
    ClassActivityNewCell *cell = [tableView dequeueReusableCellWithIdentifier:activityNewCell];
    if (cell == nil)
    {
        cell = [[ClassActivityNewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:activityNewCell];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell resetClassActivityData:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MileageThumbItem *activity = self.dataSource[indexPath.row];

    ClassSelectedViewController *select = [[ClassSelectedViewController alloc] init];
    select.nMaxCount = _maxCount - [_selectAlbums count];
    select.otherArr = _selectAlbums;
    select.delegate = self;
    select.photoItem = activity;
    [self.navigationController pushViewController:select animated:YES];
    
}

@end
