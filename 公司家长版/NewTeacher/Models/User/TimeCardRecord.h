//
//  TimeCardRecord.h
//  NewTeacher
//
//  Created by songzhanglong on 15/7/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeCardRecord : NSObject

@property (nonatomic,strong)NSString *check_face;
@property (nonatomic,strong)NSString *card_no;
@property (nonatomic,strong)NSString *check_date;
@property (nonatomic,strong)NSString *type;     //car－校车考勤
@property (nonatomic,strong)NSString *check_time;
@property (nonatomic,strong)NSString *card_name;

@end
