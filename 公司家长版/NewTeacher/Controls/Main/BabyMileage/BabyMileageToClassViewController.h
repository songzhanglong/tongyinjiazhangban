//
//  BabyMileageToClassViewController.h
//  NewTeacher
//
//  Created by 张雪松 on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "MileageModel.h"

@protocol BabyMileageToClassDelegate <NSObject>

@optional

- (void)synchronizedTheme:(MileageModel *)model PermissionsType:(int)indexType;
- (void)setDesSelectButton;

@end

@interface BabyMileageToClassViewController : DJTTableViewController

@property (nonatomic,strong) MileageModel *selectModel;
@property (nonatomic,assign)id<BabyMileageToClassDelegate> delegate;

@end
