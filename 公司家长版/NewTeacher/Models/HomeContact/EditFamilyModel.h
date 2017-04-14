//
//  EditFamilyModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol Options

@end

@interface Options : JSONModel

@property (nonatomic,strong)NSString *count_option;
@property (nonatomic,strong)NSString *option;

@end

@interface EditFamilyModel : JSONModel

@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *comment;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *create_user;
@property (nonatomic,strong)NSString *create_user_type;
@property (nonatomic,strong)NSString *finish_count;
@property (nonatomic,strong)NSArray<Options> *options;
@property (nonatomic,strong)NSString *form_date;
@property (nonatomic,strong)NSString *form_id;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *reply_count;
@property (nonatomic,strong)NSString *school_id;
@property (nonatomic,strong)NSString *student_id;
@property (nonatomic,strong)NSString *teacher_name;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *voice_url;
@property (nonatomic,strong)NSString *update_time;
@property (nonatomic,assign)CGFloat class_commentHei;

- (void)caculateClass_commentHei;
@end
