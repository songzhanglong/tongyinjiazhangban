//
//  MileageViewController.h
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "MileageModel.h"
#import "MileageBaseViewController.h"
#import "AddThemeViewController.h"

@interface MileageViewController : DJTTableViewController<AddThemeViewControllerDelegate>

@property (nonatomic,assign)NSInteger nInitIdx;

@end
