//
//  CookBookModel.h
//  NewTeacher
//
//  Created by mac on 15/7/24.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CookBookItem : NSObject

@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *date;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *is_del;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *teacher_id;
@property (nonatomic,strong)NSString *update_time;
@property (nonatomic,assign)CGSize nameSize;
@property (nonatomic,assign)CGSize contentSize;

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font;


@end

@interface CookBookModel : NSObject

@property (nonatomic,strong)NSString *date;
@property (nonatomic,strong)NSString *indexDate;
@property (nonatomic,strong)NSMutableArray *items;  //CookBookItem object

@end
