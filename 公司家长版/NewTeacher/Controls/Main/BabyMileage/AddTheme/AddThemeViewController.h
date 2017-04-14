//
//  AddThemeViewController.h
//  NewTeacher
//
//  Created by szl on 15/12/2.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"
#import "MileageModel.h"
#import "MileageBaseViewController.h"

@protocol AddThemeViewControllerDelegate <NSObject>

@optional
- (void)editThemeFinish;
- (void)addNewTheme:(MileageModel *)model;

@end

@interface AddThemeViewController : DJTBaseViewController

@property (nonatomic, assign) MileageThemeType themeType;
@property (nonatomic, strong) MileageModel *mileage;
@property (nonatomic, assign) id<AddThemeViewControllerDelegate> delegate;

@end
