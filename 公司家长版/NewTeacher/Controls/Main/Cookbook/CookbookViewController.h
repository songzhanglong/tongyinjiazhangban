//
//  CookbookViewController.h
//  NewTeacher
//
//  Created by mac on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@interface CookbookViewController : DJTTableViewController
{
    NSMutableArray          *_dailyFoodArray;     //食谱数组
    NSMutableArray          *_titleArray;         //标题数组
    NSMutableArray          *_keyArray;           //字典key数组
    NSMutableArray          *_dataArray;
    NSString                *start_time;          //开始时间
    NSString                *end_time;            //结束时间
    
    BOOL isRefresh;
}
@end
