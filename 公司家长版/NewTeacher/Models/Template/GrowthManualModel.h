//
//  GrowthManualModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrowthManualItem : NSObject

@property (nonatomic,strong)NSString *image_path;
@property (nonatomic,strong)NSString *image_thumb;
@property (nonatomic,strong)NSString *student_id;

@end

@interface GrowthManualModel : NSObject

@property (nonatomic,strong)NSString *ctime;
@property (nonatomic,strong)NSString *grow_id;
@property (nonatomic,strong)NSString *grow_name;
@property (nonatomic,strong)NSString *nums;//模板中已经制作的相册的个数
@property (nonatomic,strong)NSString *school_id;
@property (nonatomic,strong)NSString *school_name;
@property (nonatomic,strong)NSString *term;
@property (nonatomic,strong)NSString *templist_nums;//模板中相册的总个数
@property (nonatomic,strong)NSString *thumb;
@property (nonatomic,strong)NSMutableArray *items;

@end
