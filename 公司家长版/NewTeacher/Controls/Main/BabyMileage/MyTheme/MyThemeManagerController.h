//
//  MyThemeManagerController.h
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageBaseViewController.h"
#import "ClassmateViewController.h"
#import "FindPeopleViewController.h"
#import "MileageModel.h"

@interface MyThemeManagerController : MileageBaseViewController

@property (nonatomic, strong) MileageModel *indexModel;

- (void)changeRightType:(NSInteger)type;

- (void)addTheme:(id)sender;

@end
