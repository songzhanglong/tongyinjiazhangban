//
//  DJDBOperation.m
//  NewTeacher
//
//  Created by yanghaibo on 15/2/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJDBOperation.h"

@implementation DJDBOperation

#pragma mark - 数据库的打开与关闭
+ (DJDBOperation *)shareInstance
{
    static DJDBOperation *databaseOperation = nil;
    static dispatch_once_t onceTokenDatabase;
    dispatch_once(&onceTokenDatabase, ^{
        databaseOperation = [[DJDBOperation alloc] init];
    });
    
    return databaseOperation;
}

-(id)init
{
    NSString *dbPath = [APPDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",@"DataWarehouse"]];
    NSLog(@"%@",dbPath);
    self=[super init];
    if (self) {
        _databaseQueue=[FMDatabaseQueue databaseQueueWithPath:dbPath];
        [self createTableByType:kTableClass];
        [self createTableByType:kTableActivity];
        [self createTableByType:kTableNotUpload];
    }
    return  self;
}

/**
 *	@brief	打开数据库
 *
 *	@param 	filePath 	数据库路径
 */
- (void)openDataBase:(NSString *)filePath
{
    if (_databaseQueue) {
        [self releaseDatabaseQueue];
    }
    
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [_databaseQueue inDatabase:^(FMDatabase *db) {
       // [self createTableByType:kTableClass];
    }];
    [_databaseQueue close];
    self.databaseName = [filePath lastPathComponent];
}

/**
 *	@brief	关闭数据库
 */
- (void)close
{
    if (_databaseQueue) {
        [_databaseQueue close];
    }
    _databaseQueue = nil;
}

/**
 *	@brief	释放队列
 */
- (void)releaseDatabaseQueue
{
    if (_databaseQueue) {
        [_databaseQueue close];
    }
    _databaseQueue = nil;
}

/*
 *  创建表
 */

-(void)createTableByType:(int)tableType
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            if (tableType == kTableClass) {
                NSString *classTable = [NSString stringWithFormat:@"create table if not exists %@(%@ text primary key,%@ text,%@ text,%@ text,%@ text,%@ text ,%@ text ,%@ text ,%@ text ,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text);",CLASS_TABLE,TID,ALBUMS_ID,ALBUM_NAME,AUTHOR,AUTHORID,DATELINE,DIGEST,DISPLAYORDER,FACE,HAVE_DIGG,IS_TEACHER,LASTPOST,LASTPOSTER,MESSAGE,NAME,PICTURE,PICTURE_THUMB,SUBJECT,TAG,VIEWS,ATTENTION,LOGIN_ACCOUNT];   //班级圈动态
                
                NSString *replyTable = [NSString stringWithFormat:@"create table if not exists %@(%@ text  primary key,%@ text,%@ text,%@ integer,%@ text,%@ text ,%@ text,%@ text,%@ text,%@ text,%@ text);",REPLY_TABLE,DATELINE,FACE,IS_TEACHER,NAME,REPLAY_MESSAGE,REPLY_ID,REPLY_IS_TEACHER,REPLY_NAME,SEND_ID,SEND_NAME,TID];   //班级圈评论
                
                NSString *diggTable = [NSString stringWithFormat:@"create table if not exists %@(%@ text,%@ text,%@ text,%@ text,%@ text primary key);",DIGG_TABLE,FACE,IS_TEACHER,NAME,TID,USERID];   //班级圈点赞
            
               
                [db executeStatements:classTable];
                [db executeStatements:replyTable];
                [db executeStatements:diggTable];
            }
            else if (tableType == kTableActivity)
            {
                
               NSString *activityTable = [NSString stringWithFormat:@"create table if not exists %@(ac_id integer  primary key autoincrement,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text);",ACTIVITY_TABLE,ID,NAME,PHOTOS_NUM,THUMB,ITEMS,LOGIN_ACCOUNT];
               NSString *activityItemTable = [NSString stringWithFormat:@"create table if not exists %@(ac_id integer  primary key autoincrement,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text);",ACTIVITY_ITEM_TABLE,ACTIVITY_ID,PATH,RECORD_URL,THUMB,PHOTO_ID,TYPE];
                
                [db executeStatements:activityTable];
                [db executeStatements:activityItemTable];
            }
            else if(tableType == kTableNotUpload){
                NSString *notUpload = [NSString stringWithFormat:@"create table if not exists %@(%@ text  primary key ,%@ text ,%@ blob);",NOTUPLOAD_TABLE,DATETIME,ACCOUNT,MODEL];
                
               BOOL  isCreat =  [db executeStatements:notUpload];
                if (!isCreat) {
                    NSLog(@"表创建失败");
                }
            }

        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}


/*
 * 查询班级里程
 *
 */

-(NSArray *)queryActivity
{
    NSMutableArray *array = [NSMutableArray array];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *login_account = [userDefault valueForKey:LOGIN_ACCOUNT];
    [_databaseQueue inDatabase:^(FMDatabase *db){
        FMResultSet *classSet=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@='%@' ",ACTIVITY_TABLE,LOGIN_ACCOUNT,login_account]];
        while ([classSet next]) {
            ClassActivityModel *activityModel=[[ClassActivityModel alloc]init];
            [activityModel reflectDataFromFMResultSet:classSet];
            [array addObject:activityModel];
            
        }

    }];
    return array;
}


/*
 * 查询班级里程图片列表
 *
 */

-(NSArray *)queryActivityItem:(NSString *)activity_id
{
    NSMutableArray *array = [NSMutableArray array];
    [_databaseQueue inDatabase:^(FMDatabase *db){
        FMResultSet *classSet=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@='%@' ",ACTIVITY_ITEM_TABLE,ACTIVITY_ID,activity_id]];
        while ([classSet next]) {
            ClassActivityItem *activityItemModel=[[ClassActivityItem alloc]init];
            [activityItemModel reflectDataFromFMResultSet:classSet];
            [array addObject:activityItemModel];
            
        }
        
    }];
    return array;
}


/*
 * 查询班级圈
 * page 当前页   number 每一页的条数
 */

-(NSArray *)queryClass :(int)page number:(int)number
{
    NSMutableArray *array = [NSMutableArray array];
    [_databaseQueue inDatabase:^(FMDatabase *db) {
       // if (![db tableExists:CLASS_TABLE]) {
         //   [self createTableByType:kTableClass];
        //}
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *login_account = [userDefault valueForKey:LOGIN_ACCOUNT];
        FMResultSet *classSet=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@='%@' order by date(DATELINE) desc limit %d,%d",CLASS_TABLE,LOGIN_ACCOUNT,login_account,page*number,number]];
        while ([classSet next]) {
            ClassCircleModel *circlModel=[[ClassCircleModel alloc]init];
            [circlModel reflectDataFromFMResultSet:classSet];
             NSMutableArray *replyArray = [NSMutableArray array];
            FMResultSet *replySet=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@='%@' ",REPLY_TABLE,TID,circlModel.tid]];
            while ([replySet next]) {
                ReplyItem *replyItem=[[ReplyItem alloc]init];
                [replyItem reflectDataFromFMResultSet:replySet];
               // circlModel setr
                [replyArray addObject:replyItem];
            }
            
            circlModel.reply = (NSMutableArray<ReplyItem> *)replyArray;
            circlModel.replies=[NSNumber numberWithInt: (int)[replyArray count]];
            
             NSMutableArray *diggArray = [NSMutableArray array];
            FMResultSet *diggSet=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@='%@' ",DIGG_TABLE,TID,circlModel.tid]];
            while ([diggSet next]) {
                DiggItem *diggItem=[[DiggItem alloc]init];
                [diggItem reflectDataFromFMResultSet:diggSet];
                [diggArray addObject:diggItem];
            }
            
            circlModel.digg = (NSMutableArray<DiggItem> *)diggArray;
            circlModel.digg_count=[NSNumber numberWithInt: (int)[diggArray count]];
            [circlModel calculateGroupCircleRects];
            
            [array addObject:circlModel];
            
        }
        
    }];
    return array;
}



/*
 *插入班级里程
 *
 */

-(BOOL)insertActivity:(ClassActivityModel *)classActivityModel
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *login_account = [userDefault valueForKey:LOGIN_ACCOUNT];
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db beginTransaction];
        @try {
            NSString *insertActivity=[NSString stringWithFormat:@"insert INTO %@ (%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@')",ACTIVITY_TABLE,ID,NAME,PHOTOS_NUM,THUMB,ITEMS,LOGIN_ACCOUNT,classActivityModel.id,classActivityModel.name,classActivityModel.photos_num,classActivityModel.thumb,[NSString jsonStringWithObject:classActivityModel.items],login_account];
            if (![db executeUpdate:insertActivity]) {
                NSLog(@"执行失败！");
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            
        }
        
        [db commit];
        
    }];


    
    return YES;
}

/*
 *插入班级里程图片列表
 *
 */

-(BOOL)insertActivityItem:(ClassActivityItem *)classActivityItemModel activity_id:(NSString *)activity_id
{
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db beginTransaction];
        @try {
            NSString *insertActivity=[NSString stringWithFormat:@"insert INTO %@ (%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@')",ACTIVITY_ITEM_TABLE,ACTIVITY_ID,PATH,RECORD_URL,THUMB,PHOTO_ID,TYPE,activity_id,classActivityItemModel.path,classActivityItemModel.record_url,classActivityItemModel.thumb,classActivityItemModel.photo_id,classActivityItemModel.type];
            
            
           // NSLog(@"%@-------",insertActivity );
            
            if (![db executeUpdate:insertActivity]) {
                NSLog(@"执行失败！");
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            
        }
        
        [db commit];
        
    }];
    
    
    
    return YES;
}
/*
 * 插入班级圈数据
 * type 根据类型  0 登录时插入数据库 1 新增评论  2新增关注
 */

-(BOOL )insertClass :(ClassCircleModel *)classCirclModel atIndex:(int)type
{
    //[self createTableByType:kTableClass];
    //return YES;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *login_account = [userDefault valueForKey:LOGIN_ACCOUNT];
    [_databaseQueue inDatabase:^(FMDatabase *db) {

        [db beginTransaction];
        @try {
        NSString *classTable = [NSString stringWithFormat:@"Replace Into %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",CLASS_TABLE,ALBUMS_ID,ALBUM_NAME,AUTHOR,AUTHORID,DATELINE,DIGEST,DISPLAYORDER,FACE,HAVE_DIGG,IS_TEACHER,LASTPOST,LASTPOSTER,MESSAGE,NAME,PICTURE,PICTURE_THUMB,SUBJECT,TAG,TID,VIEWS,ATTENTION,LOGIN_ACCOUNT,classCirclModel.albums_id,classCirclModel.album_name,classCirclModel.author,classCirclModel.authorid,classCirclModel.dateline,classCirclModel.digest,classCirclModel.displayorder,classCirclModel.face,classCirclModel.have_digg,classCirclModel.is_teacher,classCirclModel.lastpost,classCirclModel.lastposter,classCirclModel.message,classCirclModel.name,classCirclModel.picture,classCirclModel.picture_thumb,classCirclModel.subject,classCirclModel.tag,classCirclModel.tid,classCirclModel.views,[NSString jsonStringWithObject:classCirclModel.attention],login_account];   //班级圈动态
        
        if (![db executeUpdate:classTable]) {
            NSLog(@"执行失败！");
        }
        
        
        NSArray *replyArray=classCirclModel.reply;
        NSArray *diggArray=classCirclModel.digg;
        if(type==0){
            for (ReplyItem *replyItem in replyArray) {
                NSString *replyTable = [NSString stringWithFormat:@"Replace Into %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",REPLY_TABLE,DATELINE,FACE,IS_TEACHER,NAME,REPLAY_MESSAGE,REPLY_ID,REPLY_IS_TEACHER,REPLY_NAME,SEND_ID,SEND_NAME,TID,replyItem.dateline,replyItem.face,replyItem.is_teacher,replyItem.name,replyItem.replay_message,replyItem.reply_id,replyItem.reply_is_teacher,replyItem.reply_name,replyItem.send_id,replyItem.send_name,replyItem.tid];   //班级圈评论
                
                
                if (![db executeUpdate:replyTable]) {
                    NSLog(@"执行失败！");
                }
            }
            
            for (DiggItem *diggItem in diggArray) {
                NSString *diggTable = [NSString stringWithFormat:@"Replace Into %@ (%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@');",DIGG_TABLE,FACE,IS_TEACHER,NAME,USERID,TID,diggItem.face,diggItem.is_teacher,diggItem.name,diggItem.userid,classCirclModel.tid];   //班级圈点赞
                NSLog(@"%@",diggTable);
                if (![db executeUpdate:diggTable]) {
                    NSLog(@"执行失败！");
                }
                
            }

        }else if (type==1){
            ReplyItem *replyItem=[replyArray objectAtIndex:0];
            NSString *replyTable = [NSString stringWithFormat:@"Replace Into %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",REPLY_TABLE,FACE,IS_TEACHER,NAME,REPLAY_MESSAGE,REPLY_ID,REPLY_IS_TEACHER,REPLY_NAME,SEND_ID,SEND_NAME,TID,replyItem.face,replyItem.is_teacher,replyItem.name,replyItem.replay_message,replyItem.reply_id,replyItem.reply_is_teacher,replyItem.reply_name,replyItem.send_id,replyItem.send_name,replyItem.tid];   //班级圈评论

            
            
            if (![db executeUpdate:replyTable]) {
                NSLog(@"执行失败！");
            }
        }else if (type==2){
            DiggItem *diggItem=[diggArray lastObject];
            NSString *diggTable = [NSString stringWithFormat:@"Replace Into %@ (%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@');",DIGG_TABLE,FACE,IS_TEACHER,NAME,USERID,TID,diggItem.face,diggItem.is_teacher,diggItem.name,diggItem.userid,classCirclModel.tid];   //班级圈点赞
            if (![db executeUpdate:diggTable]) {
                NSLog(@"执行失败！");
            }
        }
   
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
           // [db rollback];
        }
        @finally {
        
        }
        
        [db commit];
        
    }];
    
    return YES;
}

/*
 * 插入未上传数据
 *uploadModel ： 未上传模型
 */
-(BOOL)insertNotUploadModel:(UploadModel *)uploadModel
{
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db beginTransaction];
        @try {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:uploadModel];
            NSString *classTable = [NSString stringWithFormat:@"insert INTO %@ (%@,%@,%@) values (?,?,?)",NOTUPLOAD_TABLE,DATETIME,ACCOUNT,MODEL];
            if (![db executeUpdate:classTable,uploadModel.dateTime,uploadModel.account,data]) {
                NSLog(@"执行失败！");
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
            // [db rollback];
        }
        @finally {
            
        }
        
        [db commit];
        
    }];
    
    return YES;
}

/*
 * 更新未上传数据
 *uploadModel ： 更新后模型
 */
-(BOOL)updateNotUploadModel:(UploadModel *)uploadModel
{
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db beginTransaction];
        @try {
            NSString *login_account = [USERDEFAULT valueForKey:LOGIN_ACCOUNT];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:uploadModel];
            NSString *classTable = [NSString stringWithFormat:@"update  %@ set %@= ? where %@='%@' and %@='%@'",NOTUPLOAD_TABLE,MODEL,DATETIME,uploadModel.dateTime,ACCOUNT,login_account];
            if (![db executeUpdate:classTable,data]) {
                NSLog(@"执行失败！");
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
            // [db rollback];
        }
        @finally {
            
        }
        
        [db commit];
        
    }];
    
    return YES;
}

/*
 * 上传数据完成后删除模型
 * dateTime：查询条件时间
 */
-(BOOL)deleteNotUploadModel:(NSString *)dateTime
{
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db beginTransaction];
        @try {
            NSString *login_account = [USERDEFAULT valueForKey:LOGIN_ACCOUNT];
            NSString *classTable = [NSString stringWithFormat:@"delete from %@ where %@='%@' and %@='%@'",NOTUPLOAD_TABLE,DATETIME,dateTime,ACCOUNT,login_account];
            if (![db executeUpdate:classTable]) {
                NSLog(@"执行失败！");
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
            // [db rollback];
        }
        @finally {
            
        }
        
        [db commit];
        
    }];
    
    return YES;
}

/*
 * 查询所有未上传模型
 */
-(NSArray *)queryNotUploadModel
{
    NSMutableArray *array = [NSMutableArray array];
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *login_account = [userDefault valueForKey:LOGIN_ACCOUNT];
        FMResultSet *classSet=[db executeQuery:[NSString stringWithFormat:@"select %@ from %@ where %@='%@' ",MODEL,NOTUPLOAD_TABLE,ACCOUNT,login_account]];
        while ([classSet next]) {
            id model = [classSet objectForColumnName:MODEL];
            if ([model isKindOfClass:[NSData class]]) {
                UploadModel *uploadModel=[[UploadModel alloc]init];
                uploadModel = [NSKeyedUnarchiver unarchiveObjectWithData:[classSet objectForColumnName:MODEL]];
                [array addObject:uploadModel];
            }

        }
        
    }];
    return array;
}
@end
