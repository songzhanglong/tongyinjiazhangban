//
//  DJDBOperation.h
//  NewTeacher
//
//  Created by yanghaibo on 15/2/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "DJBaseColumn.h"
#import "DJTGlobalDefineKit.h"
#import "ClassCircleModel.h"
#import "ClassActivityModel.h"
#import "UploadManager.h"
#import "CommonUtil.h"
#import "NSObject+Reflect.h"
#import "NSString+HXAddtions.h"
@interface DJDBOperation : NSObject
@property (nonatomic,readonly)FMDatabaseQueue *databaseQueue;
@property (nonatomic,copy)NSString *databaseName;

+ (DJDBOperation *)shareInstance;
/*
 * 查询班级圈
 * page 当前页   number 每一页的条数
 */
-(NSArray *)queryClass :(int)page number:(int)number;

/*
 * 插入班级圈数据
 * type 根据类型  0 登录时插入数据库 1 新增评论  2新增关注
 */

-(BOOL )insertClass :(ClassCircleModel *)classCirclModel atIndex:(int)type;

/*
 *插入班级里程
 *
 */
-(BOOL)insertActivity:(ClassActivityModel *)classActivityModel;
/*
 * 查询班级里程
 *
 */
-(NSArray *)queryActivity;
/*
 * 查询班级里程图片列表
 *
 */
-(NSArray *)queryActivityItem:(NSString *)activity_id;

/*
 *插入班级里程图片列表
 *
 */
-(BOOL)insertActivityItem:(ClassActivityItem *)classActivityItemModel activity_id:(NSString *)activity_id;

/*
 * 插入未上传数据
 *uploadModel ： 未上传模型
 */
-(BOOL)insertNotUploadModel:(UploadModel *)uploadModel;

/*
 * 更新未上传数据
 *uploadModel ： 更新后模型
 */
-(BOOL)updateNotUploadModel:(UploadModel *)uploadModel;
/*
 * 上传数据完成后删除模型
 * dateTime：查询条件时间
 */
-(BOOL)deleteNotUploadModel:(NSString *)dateTime;
/*
 * 查询所有未上传模型
 */
-(NSArray *)queryNotUploadModel;
@end
