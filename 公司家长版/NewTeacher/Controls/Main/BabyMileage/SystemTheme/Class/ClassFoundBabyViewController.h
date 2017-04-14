//
//  ClassNotFoundViewController.h
//  NewTeacher
//
//  Created by szl on 15/12/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
@class MileageModel;

@protocol ClassNotFoundViewControllerDelegate <NSObject>

- (void)foundBabyFinish:(UIViewController *)controller Param:(NSDictionary *)param Items:(NSArray *)items;

@end

@interface ClassFoundBabyViewController : DJTTableViewController

@property (nonatomic,strong)MileageModel *mileage;
@property (nonatomic,assign)id<ClassNotFoundViewControllerDelegate> delegate;
@property (nonatomic,assign)NSInteger pageIdx;
@property (nonatomic,assign)NSInteger pageCount;
@property (nonatomic,assign)BOOL lastPage;

@end
