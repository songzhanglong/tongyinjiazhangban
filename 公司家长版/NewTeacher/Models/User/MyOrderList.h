//
//  MyOrderList.h
//  NewTeacher
//
//  Created by szl on 16/5/12.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface MyOrderList : JSONModel

@property (nonatomic,strong)NSString *order_no;     //订单编号
@property (nonatomic,strong)NSString *product_name;
@property (nonatomic,strong)NSString *product_type_name;
@property (nonatomic,strong)NSString *cover_url;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSNumber *status;
@property (nonatomic,strong)NSString *status_name;
@property (nonatomic,strong)NSString *delivery_time;
@property (nonatomic,strong)NSString *delivery_remark;

@end
