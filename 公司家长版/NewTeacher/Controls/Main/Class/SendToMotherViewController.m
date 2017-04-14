//
//  SendToMotherViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SendToMotherViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "ParentModel.h"
#import "TeacherModel.h"
#import "NSObject+Reflect.h"

@interface SendToMotherViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SendToMotherViewController
{
    UITableView *_myTableView;
    NSMutableArray *_selectedArr;
    
    NSMutableArray *_teacherSource,*_parentSource;
    UILabel *_rightLab;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"选择联系人";
    _selectedArr = [NSMutableArray array];
    _teacherSource = [NSMutableArray array];
    _parentSource = [NSMutableArray array];
    
    if (_selectIndexArray && [_selectIndexArray count] > 0) {
        [_selectedArr addObjectsFromArray:_selectIndexArray];
    }
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64.0) style:UITableViewStylePlain];
    _myTableView = tableView;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.dataSource = self;
    tableView.delegate = self;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setTableFooterView:footView];
    [self.view addSubview:tableView];
    
    [self createRightBarButton];
    
    [self requestParent];
}

- (void)createRightBarButton
{
    //返回按钮
    _rightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    [_rightLab setUserInteractionEnabled:YES];
    [_rightLab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToPreControl:)]];
    [_rightLab setTextAlignment:2];
    [_rightLab setTextColor:[UIColor greenColor]];
    [_rightLab setBackgroundColor:[UIColor clearColor]];
    [_rightLab setText:@"完成"];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightLab];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}
#pragma mark - 重载
- (void)backToPreControl:(id)sender
{
    if (_selectedArr.count > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(sendToPeople:IndexArray:)]) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSIndexPath *indexPath in _selectedArr) {
                if (indexPath.section == 0) {
                    TeacherModel *tea = _teacherSource[indexPath.row];
                    [array addObject:tea];
                }
                else
                {
                    ParentModel *par = _parentSource[indexPath.row];
                    [array addObject:par];
                }
            }
            [_delegate sendToPeople:array IndexArray:_selectedArr];
        }
    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 学生家长列表请求
- (void)requestParent
{
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"member"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *endDic = [manager requestinitParamsWith:@"getSchoolMember"];
    [endDic setObject:manager.userInfo.class_id forKey:@"class_id"];   //0家长 1老师  2园长
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:endDic];
    [endDic setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.view.userInteractionEnabled = NO;
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:endDic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestParentFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestParentFinish:NO Data:nil];
    }];
}

- (void)requestParentFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSArray *student = [ret_data valueForKey:@"student"];
        student = (!student || [student isKindOfClass:[NSNull class]]) ? [NSArray array] : student;
        for (id subDic in student) {
            ParentModel *parent = [[ParentModel alloc] init];
            [parent reflectDataFromOtherObject:subDic];
            [_parentSource addObject:parent];
        }
        NSArray *teacher = [ret_data valueForKey:@"teacher"];
        for (id subDic in teacher) {
            TeacherModel *teModel = [[TeacherModel alloc] init];
            [teModel reflectDataFromOtherObject:subDic];
            [_teacherSource addObject:teModel];
        }
        [_rightLab setText:[NSString stringWithFormat:@"完成%ld/%ld",(long)[_selectedArr count],(long)[_parentSource count]+[_teacherSource count]]];
        [_myTableView reloadData];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _teacherSource.count;
    }
    return _parentSource.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *selectParentIdentify = @"selectParentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selectParentIdentify];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectParentIdentify];
        
        //image
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 18, 24, 24)];
        [tipImg setTag:1];
        [cell.contentView addSubview:tipImg];
        
        //head
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(64, 10, 40, 40)];
        headImg.clipsToBounds = YES;
        [headImg setContentMode:UIViewContentModeScaleAspectFill];
        headImg.layer.masksToBounds = YES;
        headImg.layer.cornerRadius = 20;
        [headImg setTag:2];
        [cell.contentView addSubview:headImg];
        
        //name
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(124, 20, [UIScreen mainScreen].bounds.size.width - 124 - 20, 20)];
        [nameLab setBackgroundColor:[UIColor clearColor]];
        [nameLab setTag:3];
        [cell.contentView addSubview:nameLab];
    }

    UIImageView *tipImg = (UIImageView *)[cell.contentView viewWithTag:1];
    UIImageView *headImg = (UIImageView *)[cell.contentView viewWithTag:2];
    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:3];
    [tipImg setImage:[_selectedArr containsObject:indexPath] ? [UIImage imageNamed:@"bb2_1.png"] : [UIImage imageNamed:@"bb2.png"]];
    
    NSString *face = nil;
    NSString *name = nil;
    if (indexPath.section == 0) {
        TeacherModel *tea = _teacherSource[indexPath.row];
        face = tea.face;
        name = tea.teacher_name;
    }
    else
    {
        ParentModel *par = _parentSource[indexPath.row];
        name = par.name;
        face = par.face;
    }
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [headImg setImageWithURL:[NSURL URLWithString:[face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    [nameLab setText:name];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *tipImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if ([_selectedArr containsObject:indexPath]) {
        [_selectedArr removeObject:indexPath];
        [tipImg setImage:[UIImage imageNamed:@"bb2.png"]];
    }
    else
    {
//        if (_selectedArr.count >= 8) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"小豆派派提醒您" message:@"最多选择8位联系人" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            [alert show];
//            return;
//        }
        [_selectedArr addObject:indexPath];
        [tipImg setImage:[UIImage imageNamed:@"bb2_1.png"]];
        
    }
    [_rightLab setText:[NSString stringWithFormat:@"完成%ld/%ld",(long)_selectedArr.count,(long)[_parentSource count]+(long)[_teacherSource count]]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"教师";
    }
    else
    {
        return @"家长";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.origin.x, 0, tableView.frame.size.width, 25)];
    titleLabel.backgroundColor=CreateColor(247, 247, 247);
    
    if (section == 0) {
        titleLabel.text= @"  教师";
    }
    else
    {
        titleLabel.text= @"  家长";
    }
    return titleLabel;
}

@end
