//
//  HomeCardTemplateModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeCardTemplateModel : NSObject

@property (nonatomic,strong)NSString *card_template_id;
@property (nonatomic,strong)NSString *card_title;

@property (nonatomic,assign)BOOL isExcellent;   //yes-优秀，老师
@property (nonatomic,assign)BOOL isFine;    //yes-优秀，家长

@property (nonatomic,assign)CGSize carSize;

- (void)calculateSizeBy:(UIFont *)font Wei:(CGFloat)maxWei;

@end
