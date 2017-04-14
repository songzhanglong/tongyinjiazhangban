//
//  FamilyListModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FamilyListModel : JSONModel

@property (nonatomic,strong)NSString *form_date;
@property (nonatomic,strong)NSString *form_id;
@property (nonatomic,strong)NSString *repeat_end;
@property (nonatomic,strong)NSString *repeat_start;
@property (nonatomic,strong)NSString *repeat_type;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *cou_stu;
@property (nonatomic,strong)NSString *count_score;

@end
