//
//  CreateFamilyView.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/12.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "CreateFamilyView.h"
#import "DJTGlobalManager.h"
#import "Toast+UIView.h"
#import "DJTHttpClient.h"
#import "EditFamilyModel.h"

@interface CreateFamilyView () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    UIView *_contView;
    NSMutableArray *_dataSource;
}
@end

@implementation CreateFamilyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSource = [NSMutableArray array];
        
        UIImageView *_bgImgView1 = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_cell_bg1")];
        [_bgImgView1 setFrame:CGRectMake(0, 0, frame.size.width, 60)];
        [self addSubview:_bgImgView1];
        
        UIImageView *_bgImgView2 = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_cell_bg3")];
        [_bgImgView2 setFrame:CGRectMake(_bgImgView1.frameX, _bgImgView1.frameBottom, 0.5, frame.size.height - _bgImgView1.frameHeight - 6)];
        [self addSubview:_bgImgView2];
        
        UIImageView *_bgImgView3 = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_cell_bg3")];
        [_bgImgView3 setFrame:CGRectMake(_bgImgView1.frameRight - 0.5, _bgImgView1.frameBottom, 0.5, frame.size.height - _bgImgView1.frameHeight - 6)];
        [self addSubview:_bgImgView3];
        
        UIImageView *_bgImgView4 = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_cell_bg2")];
        [_bgImgView4 setFrame:CGRectMake(_bgImgView1.frameX, frame.size.height - 6, _bgImgView1.frameWidth, 6)];
        [self addSubview:_bgImgView4];
        
        UIView *contView = [[UIView alloc] initWithFrame:CGRectMake(0, _bgImgView1.frameBottom - 30, frame.size.width, frame.size.height - _bgImgView1.frameHeight - 6 + 30)];
        _contView = contView;
        [contView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:contView];
    }
    return self;
}

- (void)createTableView:(FamilyStudentModel *)model
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _contView.frameWidth, _contView.frameHeight)];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contView addSubview:_tableView];
    
    [self sendRequest:model];
}

- (void)createTableFooterView
{
    if ([_dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frameWidth, 150)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, footView.frameBottom- 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setText:@"暂无数据"];
        [footView addSubview:label];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((_tableView.frameWidth - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        [_tableView setTableFooterView:footView];
    }
}

#pragma mark- FamilyEditListCell delegate
- (void)sendRequest:(FamilyStudentModel *)item
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self makeToastActivity];
    self.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"form:student_form_select"];
    NSDictionary *dic = @{@"school_id":manager.userInfo.school_id,@"class_id":manager.userInfo.class_id,@"grade_id":manager.userInfo.grade_id,@"student_id":item.student_id};
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getDataFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf getDataFinish:NO Data:nil];
    }];
}

- (void)getDataFinish:(BOOL)success Data:(id)result
{
    [self hideToastActivity];
    self.userInteractionEnabled = YES;
    if (success) {
        NSMutableArray *indexArray = [NSMutableArray array];
        NSArray *data = [result valueForKey:@"datalist"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id sub in data) {
            NSError *error;
            FamilyListModel *model = [[FamilyListModel alloc] initWithDictionary:sub error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [indexArray addObject:model];
        }
        _dataSource = indexArray;
        [self createTableFooterView];
        [_tableView reloadData];
    }
    else {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *familyStudentCell = @"CreateFamilyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:familyStudentCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:familyStudentCell];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, self.frameWidth - 40, 30)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTag:10];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *lineImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_line")];
        [lineImgView setFrame:CGRectMake(20, 43, self.frameWidth - 40, 1)];
        [cell.contentView addSubview:lineImgView];
    }
    FamilyListModel *model = [_dataSource objectAtIndex:indexPath.row];
    UILabel *_nameLabel = (UILabel *)[cell.contentView viewWithTag:10];
    if (_nameLabel) {
        [_nameLabel setText:model.title ?: @""];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(createToFamilys:)]) {
        FamilyListModel *model = [_dataSource objectAtIndex:indexPath.row];
        [_delegate createToFamilys:model];
    }
}

@end
