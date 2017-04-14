//
//  ClassSelectedViewController2.h
//  NewTeacher
//
//  Created by songzhanglong on 15/6/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
@class MileageThumbItem;

@protocol ClassSelectedDelegate <NSObject>

@optional
- (void)selectClass:(NSArray *)array;
- (void)selectAlbumsFromPre:(NSArray *)array;

@end

@interface ClassSelectedViewController : DJTTableViewController
{
    NSInteger _pageIdx,_pageCount;
}

@property (nonatomic,strong)MileageThumbItem *photoItem;
@property (nonatomic,assign)NSInteger nMaxCount;
@property (nonatomic,assign)id<ClassSelectedDelegate> delegate;
@property (nonatomic,strong)NSMutableArray *otherArr;

@end
