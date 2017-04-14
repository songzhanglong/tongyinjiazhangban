//
//  MyOrderCell.h
//  NewTeacher
//
//  Created by szl on 16/4/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyOrderList.h"

@interface MyOrderCell : UITableViewCell

- (void)resetDataSource:(MyOrderList *)order;

@end
