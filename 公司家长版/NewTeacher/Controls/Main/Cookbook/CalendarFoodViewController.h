//
//  CalendarFoodViewController.h
//  NewTeacher
//
//  Created by mac on 15/7/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"
#import "CookBookModel.h"

@interface CalendarFoodViewController : DJTBaseViewController
{
    CookBookModel *_currModel;
    BOOL isRefresh;
    
    NSMutableArray *allArray;
}
@property (nonatomic,strong) CookBookModel *cookbookModel;
@property (nonatomic,strong) NSMutableArray *dataArray;;
@end
