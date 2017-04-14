//
//  DJTHttpClient.h
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface DJTHttpClient : NSObject

#pragma mark - 单任务请求

+ (AFHTTPRequestOperation *)asynchronousNormalRequest:(NSString *)url parameters:(NSDictionary *)parameters successBlcok:(void (^)(BOOL success,id data,NSString *msg)) successBlock failedBlock:(void (^)(NSString *description))failedBlock;

/**
 *	@brief	json序列数据提交到http服务器
 *
 *	@param 	url 	链接地址
 *	@param 	parameters 	传输参数
 *
 *	@return	AFHTTPRequestOperation，供调用方获取，以便可以手动取消网络请求
 */
+ (AFHTTPRequestOperation *)asynchronousRequest:(NSString *)url parameters:(NSDictionary *)parameters successBlcok:(void (^)(BOOL success,id data,NSString *msg)) successBlock failedBlock:(void (^)(NSString *description))failedBlock;


#pragma mark - 单个文件上传
/**
 *	@brief	文件上传,下载进度
 *
 *	@param 	url 	链接地址
 *	@param 	parameter 	传输参数
 *	@param 	filePath    文件路径
 *
 *	@return	AFHTTPRequestOperation，供调用方获取，以便可以手动取消网络请求
 */
+ (AFHTTPRequestOperation *)asynchronousRequestWithProgress:(NSString *)url parameters:(NSDictionary *)parameter filePath:(NSString *)filePath ssuccessBlcok:(void (^)(BOOL success,id data,NSString *msg)) successBlock failedBlock:(void (^)(NSString *description))failedBlock progressBlock:(void (^)(NSUInteger bytesRead,long long totalBytesRead,long long totalBytesExpectedToRead))progressBlock;

/**
 *	@brief	文件上传
 *
 *	@param 	url 	路径
 *	@param 	filePath 	文件路径
 *	@param 	parameter 	参数
 *
 *	@return	AFURLSessionManager
 */
+ (AFURLSessionManager *)uploadFile:(NSString *)url FilePath:(NSString *)filePath parameters:(NSDictionary *)parameter ssuccessBlcok:(void (^)(BOOL success,id data,NSString *msg)) successBlock failedBlock:(void (^)(NSString *description))failedBlock;

#pragma mark - 多任务请求
/**
 *	@brief	多文件上传
 *
 *	@param 	images 	图片数组
 *	@param 	url 	链接地址
 *	@param 	parameter 	传输参数
 */
+ (void)uploadMutiImages:(NSArray*)images url:(NSString *)url parameters:(NSDictionary *)parameter singleSuccessBlock:(void (^)(id result,NSInteger index))singleSuccessBlock singleFailureBlock:(void (^)(NSString *desc,NSInteger index))singleFailureBlock allCompletionBlock:(void (^)(NSArray *operations))allCompletionBlock singleUploadSuccess:(void (^)(NSInteger index))singleUploadSuccess;

+ (void)uploadMutiImagesOrVideo:(NSArray*)images url:(NSString *)url parameters:(NSDictionary *)parameter singleSuccessBlock:(void (^)(id result,NSInteger index))singleSuccessBlock singleFailureBlock:(void (^)(NSString *desc,NSInteger index))singleFailureBlock;
@end
