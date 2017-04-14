//
//  FamilyStudentModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FamilyStudentModel : JSONModel

@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *face_school;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *school_id;
@property (nonatomic,strong)NSString *student_id;
@property (nonatomic,strong)NSString *totals;
@property (nonatomic,strong)NSString *form_date;
@property (nonatomic,strong)NSString *form_id;
@property (nonatomic,strong)NSString *title;

@end
