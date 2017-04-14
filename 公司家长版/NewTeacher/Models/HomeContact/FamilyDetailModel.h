//
//  FamilyDetailModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol ReplysItem

@end

@interface ReplysItem : JSONModel

@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *create_user;
@property (nonatomic,strong)NSString *create_user_name;
@property (nonatomic,strong)NSString *create_user_type;
@property (nonatomic,strong)NSString *flag;
@property (nonatomic,strong)NSString *form_id;
//@property (nonatomic,strong)NSString *huifu_replys;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *relate_id;
@property (nonatomic,strong)NSString *relate_user_name;
@property (nonatomic,strong)NSString *reply_id;
@property (nonatomic,strong)NSString *school_id;
@property (nonatomic,strong)NSString *score_id;
@property (nonatomic,strong)NSString *student_id;
@property (nonatomic,strong)NSString *face_school;
@property (nonatomic,strong)NSString *relation;
@property (nonatomic,assign)CGFloat class_contHei;

- (void)caculateClass_contHei;
@end

@protocol OptionsItem

@end

@interface OptionsItem : JSONModel

@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *create_user;
@property (nonatomic,strong)NSString *create_user_type;
@property (nonatomic,strong)NSString *flag;
@property (nonatomic,strong)NSString *form_id;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *p_id;
@property (nonatomic,strong)NSString *checked_option;
@property (nonatomic,assign)NSInteger nIdx;
@property (nonatomic,assign)BOOL nSeclect;
@property (nonatomic,assign)CGFloat class_contHei;
@property (nonatomic,assign)CGFloat class_optionWei;

- (void)caculateClass_contHei;
@end

@interface FamilyDetailModel : JSONModel

@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *create_user;
@property (nonatomic,strong)NSString *create_user_type;
@property (nonatomic,strong)NSString *flag;
@property (nonatomic,strong)NSString *form_id;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSArray<OptionsItem> *item_list;
@property (nonatomic,strong)NSString *title;

@end
