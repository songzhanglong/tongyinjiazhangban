//
//  TemplateModel.h
//  NewTeacher
//
//  Created by 张雪松 on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface TemplateModel : JSONModel
@property (nonatomic,strong)NSString *digst;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *status;
@end
