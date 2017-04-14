//
//  MyMsgModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/2/26.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyMsgModel : NSObject

@property (nonatomic,strong)NSString *date;
@property (nonatomic,strong)NSString *eachData;
@property (nonatomic,strong)NSString *flag;
@property (nonatomic,strong)NSString *mdFlag;
@property (nonatomic,strong)NSString *sender;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,assign)NSInteger primaryKey;
@property (nonatomic,assign)CGSize conSize;

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font;

@end
