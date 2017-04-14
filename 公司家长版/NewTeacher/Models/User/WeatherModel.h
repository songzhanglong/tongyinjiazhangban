//
//  WeatherModel.h
//  NewTeacher
//
//  Created by 张雪松 on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface PMModel : JSONModel

@property (nonatomic,strong)NSString *HCHO;     //甲醛
@property (nonatomic,strong)NSString *PM25;     //PM2.5
@property (nonatomic,strong)NSString *humity;   //室内湿度
@property (nonatomic,strong)NSString *temp;     //室内温度
@property (nonatomic,strong)NSString *time;
@property (nonatomic,strong)NSString *pm25Str;
@property (nonatomic,strong)NSString *hchoStr;
- (void)setPM25Value;

@end

@interface WeatherModel : JSONModel

@property (nonatomic,strong)NSString *city_id;
@property (nonatomic,strong)NSString *city_name;
@property (nonatomic,strong)NSString *lowest;       //低温
@property (nonatomic,strong)NSString *hightest;     //高温
@property (nonatomic,strong)NSString *weather;      //天气
@property (nonatomic,strong)NSString *fx;           //风向id
@property (nonatomic,strong)NSString *fl;           //风力id
@property (nonatomic,strong)NSString *pubtime;      //发布时间
@property (nonatomic,strong)NSString *fx_name;      //风向名称
@property (nonatomic,strong)NSString *fl_name;      //风力名称
@property (nonatomic,strong)NSString *aqi;          //aqi指数
@property (nonatomic,strong)NSString *aqi_desc;     //污染程度
@property (nonatomic,strong)NSString *tip;          //温馨提示
@property (nonatomic,strong)PMModel *pmMdel;
@property (nonatomic,assign)CGSize descSize;
@property (nonatomic,assign)CGSize contSize;

- (void)calculeteConSize;

@end
