//
//  FindPeopleViewController.h
//  NewTeacher
//
//  Created by szl on 15/12/31.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@protocol FindMyBabyViewControllerDelegate <NSObject>

@optional
- (void)findMyBabyFininsh:(UIViewController *)controller;

@end

@interface FindMyBabyViewController : DJTTableViewController

@property (nonatomic,strong)NSDictionary *reqParam;
@property (nonatomic,strong)NSArray *themeItems;
@property (nonatomic,assign)id<FindMyBabyViewControllerDelegate> delegate;

@end
