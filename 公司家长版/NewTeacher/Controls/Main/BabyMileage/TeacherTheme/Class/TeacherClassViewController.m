//
//  TeacherClassViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "TeacherClassViewController.h"
#import "Toast+UIView.h"

@interface TeacherClassViewController ()

@end

@implementation TeacherClassViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.httpOperation) {
        if (_autoFind) {
            _autoFind = NO;
            [self beginToFindBaby];
        }
    }
}

#pragma mark - 重载
- (void)createTableHeaderView{
    if (_autoFind) {
        _autoFind = NO;
        _tableView.tableHeaderView = [[UIView alloc] init];
        if ([self.dataSource count] > 0) {
            [self beginToFindBaby];
        }
        else{
            [self.view makeToast:@"还未添加图片，无法查找" duration:1.0 position:@"center"];
        }
    }
    else{
        if ([self.dataSource count] > 0) {
            if (!_tableView.tableHeaderView) {
                [self myInitTableHeadView];
            }
        }
        else{
            [_tableView setTableHeaderView:nil];
        }
    }
}

@end
