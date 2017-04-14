//
//  EditFamilyViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "FamilyStudentModel.h"

@interface EditFamilyViewController : DJTTableViewController

@property (nonatomic, strong) NSMutableArray *create_data;
@property (nonatomic, assign) BOOL isRefreshData;

@end
