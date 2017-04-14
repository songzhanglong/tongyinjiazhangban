//
//  SystemClassViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SystemClassViewController.h"
#import "NSString+Common.h"
#import "MileageModel.h"
#import "ClassFoundBabyViewController.h"
#import "SystemClass2ViewController.h"
#import "Toast+UIView.h"
#import "MyThemeManagerController.h"
#import "ThemeDetailViewController.h"
#import "FindMyBabyViewController.h"

@interface SystemClassViewController ()<ClassNotFoundViewControllerDelegate,ThemeDetailViewControllerDelegate,FindMyBabyViewControllerDelegate>

@end

@implementation SystemClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)changeTypeByParent
{
    [(MyThemeManagerController *)self.parentViewController changeRightType:2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.childViewControllers count] > 0) {
        for (UIViewController *subCon in self.childViewControllers) {
            if ([subCon isKindOfClass:[ClassFoundBabyViewController class]]) {
                [subCon.view removeFromSuperview];
                [subCon willMoveToParentViewController:nil];
                [subCon removeFromParentViewController];
                break;
            }
        }
    }
}

#pragma mark - 重载
- (void)beginToFindBaby
{
    [super beginToFindBaby];
    [self findPeople:nil];
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getClassPhotoList"];
    [param setObject:self.mileage.album_id ?: @"" forKey:@"album_id"];
    [param setObject:self.mileage.mileage_type forKey:@"mileage_type"];
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
            [self myInitTableHeadView];
        }
    }
    else{
        [_tableView setTableHeaderView:nil];
    }
    
}

- (void)myInitTableHeadView
{
    BOOL check = [USERDEFAULT boolForKey:@"checkBefore"];
    if (check) {
        return;
    }
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 10 + 57 + 10 + 14 + 10)];
    [headView setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [refresh setFrame:CGRectMake((headView.frameWidth - 57) / 2, 10, 57, 57)];
    [refresh setImage:CREATE_IMG(@"refreshBabyN") forState:UIControlStateNormal];
    [refresh setImage:CREATE_IMG(@"refreshBabyH") forState:UIControlStateHighlighted];
    [refresh addTarget:self action:@selector(findPeople:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:refresh];
    
    UIFont *font = [UIFont systemFontOfSize:10];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, refresh.frameBottom + 10, winSize.width, 14)];
    [label1 setTextColor:[UIColor darkGrayColor]];
    [label1 setFont:font];
    [label1 setText:@"您可以通过点击"];
    [label1 sizeToFit];
    [headView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:label1.frame];
    [label2 setTextColor:[UIColor darkGrayColor]];
    [label2 setFont:font];
    [label2 setText:@"将“班级”中的照片或小视频加入到“我的”中。"];
    [label2 sizeToFit];
    [headView addSubview:label2];
    
    UIImageView *addView = [[UIImageView alloc] initWithFrame:CGRectMake(0, label1.frameY - 3, 20, 20)];
    [addView setImage:CREATE_IMG(@"refreshTopN")];
    [headView addSubview:addView];
    [label1 setFrameX:(winSize.width - label1.frameWidth - label2.frameWidth - addView.frameWidth) / 2];
    [addView setFrameX:label1.frameRight];
    [label2 setFrameX:addView.frameRight];
    
    [_tableView setTableHeaderView:headView];
}

- (void)findPeople:(id)sender
{
    if ([self.childViewControllers count] > 0) {
        for (UIViewController *subCon in self.childViewControllers) {
            if ([subCon isKindOfClass:[ClassFoundBabyViewController class]]) {
                return;
            }
        }
    }
    
    [_tableView setTableHeaderView:[[UIView alloc] init]];
    [USERDEFAULT setBool:YES forKey:@"checkBefore"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (ThemeBatchModel *themeBatch in self.dataSource) {
        [array addObjectsFromArray:themeBatch.photos];
    }
    
    if ([array count] == 0) {
        [self.view makeToast:@"还未添加图片，无法查找" duration:1.0 position:@"center"];
        return;
    }
    
    ClassFoundBabyViewController *mateCla = [[ClassFoundBabyViewController alloc] init];
    mateCla.mileage = self.mileage;
    mateCla.delegate = self;
    mateCla.pageCount = _pageCount;
    mateCla.pageIdx = _pageIdx;
    mateCla.lastPage = _lastPage;
    mateCla.dataSource = array;
    mateCla.view.frame = self.view.bounds;
    [self addChildViewController:mateCla];
    [self.view addSubview:mateCla.view];
}

- (void)createTableFooterView{
    
}

#pragma mark - ClassNotFoundViewControllerDelegate
- (void)foundBabyFinish:(UIViewController *)controller Param:(NSDictionary *)param Items:(NSArray *)items
{
    [controller.view removeFromSuperview];
    [controller willMoveToParentViewController:nil];
    [controller removeFromParentViewController];
    
    FindMyBabyViewController *find = [[FindMyBabyViewController alloc] init];
    find.delegate = self;
    find.themeItems = items;
    find.reqParam = param;
    [self.parentViewController.navigationController pushViewController:find animated:YES];
}

#pragma mark - FindMyBabyViewControllerDelegate
- (void)findMyBabyFininsh:(UIViewController *)controller
{
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
    [self.parentViewController.navigationController.view makeToast:@"同步成功" duration:1.0 position:@"center"];
    MyThemeViewController *firstTheme = [[(MyThemeManagerController *)self.parentViewController subControls] firstObject];
    firstTheme.shouldRefresh = YES;
}

#pragma mark - 请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if ([self.dataSource count] == 0) {
        SystemClass2ViewController *class2 = [[SystemClass2ViewController alloc] init];
        class2.mileage = self.mileage;
        class2.view.frame = self.view.bounds;
        [self addChildViewController:class2];
        [self.view addSubview:class2.view];
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
    [secondLab setText:theme.name ?: @""];
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
    detail.fromType = DetailFromClass;
    detail.delegate = self;
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        [self.parentViewController.navigationController pushViewController:detail animated:YES];
    }
    else{
        [self.parentViewController.parentViewController.navigationController pushViewController:detail animated:YES];
    }
}
@end
