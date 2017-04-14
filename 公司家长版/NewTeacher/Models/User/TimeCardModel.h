//
//  TimeCardModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface TimeCardModel : JSONModel

@property (nonatomic,strong)NSString *holder_name;
@property (nonatomic,strong)NSString *status;   //0-未激活， 1-已激活，2-已挂失，-1-已删除
@property (nonatomic,strong)NSString *holder_rel;
@property (nonatomic,strong)NSString *holder_face;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *holder_mobile;
@property (nonatomic,strong)NSString *card_no;
@property (nonatomic,strong)NSString *card_id;

@end
