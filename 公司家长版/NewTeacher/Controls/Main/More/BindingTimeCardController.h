//
//  BindingTimeCardControllerViewController.h
//  NewTeacher
//
//  Created by songzhanglong on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@class TimeCardModel;

@protocol TimeCardBindingDelegate <NSObject>

@optional
- (void)bindTimeCardCount;
- (void)reloadTimeCardCell;

@end

@interface BindingTimeCardController : DJTBaseViewController

@property (nonatomic,assign)id<TimeCardBindingDelegate> delegate;
@property (nonatomic,strong)TimeCardModel *cardModel;

@end
