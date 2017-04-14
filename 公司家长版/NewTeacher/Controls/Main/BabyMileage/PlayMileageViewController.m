//
//  PlayMileageViewController.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/10.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "PlayMileageViewController.h"
#import "SegmentOfThemeView.h"
#import "NSString+Common.h"
#import "PlayMileageModel.h"
#import "DJTOrderViewController.h"

@interface PlayMileageViewController ()
{
    int _currType;
    NSMutableDictionary *_dataDic;
}
@end

@implementation PlayMileageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currType = 0;
    _dataDic = [NSMutableDictionary dictionary];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [bgView setImage:CREATE_IMG(@"mileage_playbg")];
    [bgView setUserInteractionEnabled:YES];
    [self.view addSubview:bgView];
    
    [self customSegment];
    
    CGFloat yOri = 20;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, yOri + 7, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:CREATE_IMG(@"backL@2x") forState:UIControlStateNormal];
    [backBtn setImage:CREATE_IMG(@"back_1") forState:UIControlStateSelected];
    [backBtn addTarget:self action:@selector(backToPreControl:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    self.useNewInterface = YES;
    
    [self createTableViewAndRequestAction:@"photo" Param:nil Header:YES Foot:NO];
    [_tableView setFrame:CGRectMake(0, yOri + 44 + 10, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    _tableView.backgroundColor = [UIColor clearColor];
    
    [self beginRefresh];
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMyPhoto"];
    [param setObject:(_currType == 0) ? @"term" : @"album" forKey:@"type"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        NSArray *ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        NSMutableArray *array = [NSMutableArray array];
        for (id subDic in ret_data) {
            NSError *error;
            PlayMileageModel *playModel = [[PlayMileageModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:playModel];
        }
        if (array.count > 0) {
            [_dataDic setObject:array forKey:[NSString stringWithFormat:@"request_%d",_currType]];
        }
        self.dataSource = array;
    }
    else{
        self.dataSource = nil;
    }
    [_tableView reloadData];
}

- (void)backToPreControl:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)customSegment
{
    CGFloat yOri = 20;
    NSArray *items = @[@"学期",@"主题"];
    SegmentOfThemeView *segment = [[SegmentOfThemeView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 118) / 2, yOri + (44 - 29) / 2, 118, 29) TitleArray:items];
    __weak typeof(self)weakSelf = self;
    segment.selectBlock = ^(NSInteger index){
        [weakSelf changeThemeType:index];
    };
    [self.view addSubview:segment];
}

- (void)changeThemeType:(NSInteger)index
{
    _currType = (int)index;
    
    id history = [_dataDic valueForKey:[NSString stringWithFormat:@"request_%ld",(long)index]];
    if (history && [history count] > 0) {
        self.dataSource = history;
        [_tableView reloadData];
    }
    else{
        [self beginRefresh];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
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
    static NSString *mileageCell = @"playMileageCellId";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:mileageCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mileageCell];
    }
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:10];
    if (!imgView) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 292) / 2, 0, 292, 55)];
        imgView.image = CREATE_IMG(@"play_cell_bg");
        [imgView setTag:10];
        [cell.contentView addSubview:imgView];
    }
    
    PlayMileageModel *model = [self.dataSource objectAtIndex:indexPath.section];
    UIImageView *playImgView = (UIImageView *)[cell.contentView viewWithTag:20];
    if (!playImgView) {
        playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + 10, (imgView.frame.size.height - 35) / 2, 35, 35)];
        [playImgView setTag:20];
        [cell.contentView addSubview:playImgView];
    }
    playImgView.image = [model.have_pic isEqualToString:@"0"] ? CREATE_IMG(@"play35_1") : CREATE_IMG(@"play35");
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:30];
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(playImgView.frame.size.width + playImgView.frame.origin.x + 10, 0, SCREEN_WIDTH - playImgView.frame.size.width - playImgView.frame.origin.x - 20, 55)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [nameLabel setTag:30];
        [cell.contentView addSubview:nameLabel];
    }
    nameLabel.textColor = [model.have_pic isEqualToString:@"0"] ? [UIColor grayColor] : CreateColor(50, 164, 198);
    nameLabel.text = model.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlayMileageModel *model = [self.dataSource objectAtIndex:indexPath.section];
    if (![model.have_pic isEqualToString:@"0"]) {        
//        DJTOrderViewController *order = [[DJTOrderViewController alloc] init];
//        order.url = model.url;
//        [self.navigationController pushViewController:order animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.url ?: @""]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
