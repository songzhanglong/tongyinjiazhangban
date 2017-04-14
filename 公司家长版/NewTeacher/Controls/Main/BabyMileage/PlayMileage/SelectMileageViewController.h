//
//  SelectMileageViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@interface SelectMileageViewController : DJTTableViewController

@property (nonatomic,strong)NSString *theme_id;
@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,assign)NSInteger editType;
@property (nonatomic,strong)NSString *editTitle;
@property (nonatomic,strong)NSMutableArray *otherArr;

@end
