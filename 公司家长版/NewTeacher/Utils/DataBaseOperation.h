//
//  DataBaseOperation.h
//  TY
//
//  Created by songzhanglong on 14-6-12.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class MyMsgModel;

typedef enum
{
    kTableMyMsg = 0,    //我的消息
}kTableType;

@interface DataBaseOperation : NSObject

@property (nonatomic,readonly)FMDatabaseQueue *databaseQueue;
@property (nonatomic,copy)NSString *databaseName;

+ (DataBaseOperation *)shareInstance;

#pragma mark - 数据库的打开与关闭
/**
 *	@brief	打开数据库
 *
 *	@param 	filePath 	数据库路径
 */
- (void)openDataBase:(NSString *)filePath;

/**
 *	@brief	关闭数据库
 */
- (void)close;

/**
 *	@brief	释放队列
 */
- (void)releaseDatabaseQueue;

#pragma mark - 建表
/**
 *	@brief	创建表
 *
 *	@param 	type 	表类型
 */
- (void)createTableByType:(kTableType)type;

#pragma mark - 我的消息表
- (void)insertMyMsg:(MyMsgModel *)model;

- (void)deleteMyMsg:(NSArray *)array;

- (NSArray *)selectMyMsgByDateAsc:(BOOL)success;

@end
