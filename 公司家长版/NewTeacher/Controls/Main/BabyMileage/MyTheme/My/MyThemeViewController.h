//
//  MyThemeViewController.h
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "ThemeBatchModel.h"
@class MileageModel;

@interface MyThemeViewController : DJTTableViewController
{
    NSInteger _pageIdx,_pageCount;
    BOOL _lastPage;
    
    NSIndexPath *_indexPath;
}

@property (nonatomic,strong)MileageModel *mileage;
@property (nonatomic,assign)BOOL shouldRefresh;

- (void)beginToFindBaby;

- (void)deleteThisBatch;

- (void)startRefreshToCurrController;
@end
