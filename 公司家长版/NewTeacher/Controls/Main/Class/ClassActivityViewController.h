//
//  ClassActivityViewController.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@protocol SelectClassActivityDelegate <NSObject>

- (void)selectClassActivity:(NSArray *)array;

@end

@interface ClassActivityViewController : DJTTableViewController

@property (nonatomic,assign)NSInteger maxCount;
@property (nonatomic,assign)id<SelectClassActivityDelegate> delegate;

@end
