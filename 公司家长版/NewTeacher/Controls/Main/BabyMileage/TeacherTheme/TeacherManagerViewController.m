//
//  TeacherManagerViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "TeacherManagerViewController.h"

@interface TeacherManagerViewController ()

@end

@implementation TeacherManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)changeToClassSelected
{
    TeacherClassViewController *teaCla = [self.subControls objectAtIndex:1];
    teaCla.autoFind = YES;
    _channelView.nCurIdx = 1;
    [self changeControlToIndex:1];
}

@end
