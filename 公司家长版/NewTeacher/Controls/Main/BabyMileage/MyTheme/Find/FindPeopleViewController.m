//
//  FindPeopleViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "FindPeopleViewController.h"
#import "NSString+Common.h"
#import "SegmentOfMileageView.h"
#import "ThemeDetailViewController.h"
#import "MileageBaseViewController.h"
#import "MileageModel.h"

@interface FindPeopleViewController ()<ThemeDetailViewControllerDelegate>

@end

@implementation FindPeopleViewController
{
    NSString *_sortType;
    NSMutableDictionary *_dataDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sortType = @"1";
    _dataDic = [NSMutableDictionary dictionary];
}

- (void)changeSortType:(NSInteger)index
{
    _sortType = (index == 0) ? @"1" : @"2";
    NSArray *array = [_dataDic valueForKey:_sortType];
    if (array && [array isKindOfClass:[NSArray class]]) {
        self.dataSource = [NSMutableArray arrayWithArray:array];
        [_tableView reloadData];
    }
    else{
        [self beginRefresh];
    }
}

#pragma mark - 重载
- (void)createTableHeaderView{
    if ([self.dataSource count] > 0) {
        if (!_tableView.tableHeaderView) {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 64)];
            [headView setBackgroundColor:_tableView.backgroundColor];
            
            SegmentOfMileageView *seg = [[SegmentOfMileageView alloc] initWithFrame:CGRectMake((winSize.width - 113) / 2, 10, 113, 20) TitleArray:@[@"按时间",@"按热度"]];
            __weak typeof(self)weakSelf = self;
            seg.selectBlock = ^(NSInteger index){
                [weakSelf changeSortType:index];
            };
            [headView addSubview:seg];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, seg.frameBottom + 10, winSize.width - 10, 14)];
            [label setText:@"还有很多其他幼儿园的小朋友上传了很多新照片一起来看看吧～"];
            [label setFont:[UIFont systemFontOfSize:10]];
            [label setTextColor:CreateColor(84, 128, 215)];
            [label setBackgroundColor:_tableView.backgroundColor];
            [label setTextAlignment:1];
            [headView addSubview:label];
            
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
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 100)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, footView.frameBottom- 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setText:@"咦，暂时还没有任何发现哦!"];
        [footView addSubview:label];
        [_tableView setTableFooterView:footView];
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getFoundPhotoList"];
    [param setObject:_sortType forKey:@"sort"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if ([self.dataSource count] > 0) {
        [_dataDic setObject:self.dataSource forKey:_sortType];
    }
    else
    {
        [_dataDic removeObjectForKey:_sortType];
    }
}

#pragma mark - ThemeDetailViewControllerDelegate
- (void)deleteThisBatch
{
    [super deleteThisBatch];
    if ([self.dataSource count] == 0) {
        [_dataDic removeObjectForKey:_sortType];
    }
    else{
        [_dataDic setObject:self.dataSource forKey:_sortType];
    }
}

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *firstLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 18)];
    [firstLab setTextAlignment:1];
    [firstLab setBackgroundColor:CreateColor(82, 78, 128)];
    [firstLab setTextColor:[UIColor whiteColor]];
    [firstLab setFont:[UIFont systemFontOfSize:12]];
    [headerView addSubview:firstLab];
    
    ThemeBatchModel *theme = self.dataSource[section];
    UILabel *secondLab = [[UILabel alloc] initWithFrame:CGRectMake(firstLab.frameRight, 0, 95, 18)];
    [secondLab setTextColor:firstLab.backgroundColor];
    [secondLab setFont:[UIFont systemFontOfSize:12]];
    [secondLab setTextAlignment:1];
    [secondLab setBackgroundColor:CreateColor(212, 213, 215)];
    [secondLab setText:[NSString stringWithFormat:@"%@小朋友", (([theme.name length] > 0) ? [theme.name stringByReplacingCharactersInRange:NSMakeRange (0, 1) withString:@"*"] : @"")]];
    [headerView addSubview:secondLab];
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:theme.create_time.doubleValue];
    [firstLab setText:[NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate]];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexPath = indexPath;
    
    ThemeBatchModel *theme = self.dataSource[indexPath.section];
    CGSize consize = [NSString calculeteSizeBy:theme.digst Font:[UIFont systemFontOfSize:12] MaxWei:[UIScreen mainScreen].bounds.size.width - 30 - 30];
    theme.contentHei = consize.height;
    ThemeDetailViewController *detail = [[ThemeDetailViewController alloc] init];
    detail.themeBatch = theme;
    detail.titleLable.text = self.mileage.name;
    detail.fromType = DetailFromFound;
    detail.delegate = self;
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        [self.parentViewController.navigationController pushViewController:detail animated:YES];
    }
    else{
        [self.parentViewController.parentViewController.navigationController pushViewController:detail animated:YES];
    }
}

@end
