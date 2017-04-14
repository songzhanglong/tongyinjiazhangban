//
//  UploadManager.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadModel : NSObject

@property (nonatomic,assign)BOOL isVideo;   //视频

@property (nonatomic,strong)NSArray *imgs;
@property (nonatomic,strong)NSString *uploadUrl;
@property (nonatomic,strong)NSDictionary *param;

@property (nonatomic,strong)NSString *endUrl;   //
@property (nonatomic,strong)NSDictionary *endParam;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)NSString *dateTime;
@property (nonatomic,strong)NSString *account;
@property (nonatomic,strong)NSString *froType;
- (void)startUploadImgs;

@end

@interface UploadManager : NSObject

@property (nonatomic,assign)NSUInteger totalCount;  //总的数量
@property (nonatomic,assign)NSUInteger curCount;    //成功或失败上传数量
@property (nonatomic,assign)BOOL netWorking;
@property (nonatomic,strong)NSMutableArray *upModels;

+ (UploadManager *)shareInstance;

- (void)startNextRequest;


@end
