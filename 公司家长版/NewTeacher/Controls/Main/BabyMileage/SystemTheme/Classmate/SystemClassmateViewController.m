//
//  SystemClassmateViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SystemClassmateViewController.h"
#import "NSString+Common.h"
#import "MileageModel.h"
#import "SegmentOfMileageView.h"
#import "SystemClassmate2ViewController.h"
#import "SystemThemeManagerController.h"

@interface SystemClassmateViewController ()

@end

@implementation SystemClassmateViewController
{
    NSString *_sortType;
    NSMutableDictionary *_dataDic;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sortType = @"1";
    _dataDic = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view.
    /*
    该系统主题下如无内容：
    1、	当同学其他系统主题有内容时，提示用户去查看有内容的系统主题，按照发布时间倒序排序，采用时间+发送人的展示方式，按批次倒序显示；。
    2、	当同学其他系统主题无内容时，提示无内容和广告图。
     */
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

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getClassmatePhotoList"];
    [param setObject:self.mileage.album_id ?: @"" forKey:@"album_id"];
    [param setObject:self.mileage.mileage_type.stringValue forKey:@"mileage_type"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
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
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if ([self.dataSource count] == 0) {
        [_dataDic removeObjectForKey:_sortType];
        
        SystemClassmate2ViewController *mateCla = [[SystemClassmate2ViewController alloc] init];
        mateCla.mileage = self.mileage;
        mateCla.view.frame = self.view.bounds;
        [self addChildViewController:mateCla];
        [self.view addSubview:mateCla.view];
    }
    else
    {
        [_dataDic setObject:self.dataSource forKey:_sortType];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *firstLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
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
    [secondLab setText:[NSString stringWithFormat:@"%@小朋友", theme.name ?: @""]];
    [headerView addSubview:secondLab];
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:theme.create_time.doubleValue];
    [firstLab setText:[NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate]];
    
    return headerView;
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

@end
