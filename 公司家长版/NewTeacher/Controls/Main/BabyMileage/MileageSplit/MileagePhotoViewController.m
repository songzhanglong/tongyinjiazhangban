//
//  MileagePhotoViewController.m
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileagePhotoViewController.h"
#import "NSString+Common.h"

@interface MileagePhotoViewController ()

@end

@implementation MileagePhotoViewController
{
    BOOL _canAddTheme;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)changeTypeByParent
{
    
}

#pragma mark - 重载
- (BOOL)showDiggAndCommentNum
{
    ThemeBatchModel *model = self.dataSource[_indexPath.section];
    //点击图片才会响应，故photos必有内容
    ThemeBatchItem *item = model.photos[0];
    _canAddTheme = [item.album_id isEqualToString:[DJTGlobalManager shareInstance].userInfo.album_id];
    return !_canAddTheme;
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getPhotoList2"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
}

#pragma mark - MWPhotoBrowserDelegate
- (BOOL)canJoinInTheme:(NSInteger)index and:(MWPhotoBrowser *)browser
{
    return _canAddTheme;
}

#pragma mark - ClassmateViewController,FindPeopleViewController重载
- (void)createTableHeaderView
{

}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 100)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, footView.frameBottom- 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setText:@"你还没有发布过照片或视频哦!"];
        [footView addSubview:label];
        [_tableView setTableFooterView:footView];
    }
}

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    ThemeBatchModel *theme = self.dataSource[section];
    NSInteger type = theme.mileage_type.integerValue; //1（我的）  2（教师） 3（推荐）
    UIColor *topColor = (type == 1) ? CreateColor(46, 150, 150) : (type == 2 ? CreateColor(23, 72, 142) : CreateColor(91, 147, 45));
    UILabel *firstLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
    [firstLab setTextAlignment:1];
    [firstLab setBackgroundColor:topColor];
    [firstLab setTextColor:[UIColor whiteColor]];
    [firstLab setFont:[UIFont systemFontOfSize:12]];
    [headerView addSubview:firstLab];
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:theme.create_time.doubleValue];
    [firstLab setText:[NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate]];
    
    return headerView;
}

@end
