//
//  DJTHttpClient.m
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTHttpClient.h"
#import "NSString+Common.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"
#import "AppDelegate.h"

@implementation DJTHttpClient

#if ! __has_feature(objc_arc)
    #define HTTPAutorelease(__v) ([__v autorelease]);
    #define HTTPRetain(__v) ([__v retain]);
    #define HTTPRelease(__v) ([__v release]);

#else
    // -fobjc-arc
    #define HTTPAutorelease(__v) (__v)
    #define HTTPRetain(__v)
    #define HTTPRelease(__v)

#endif

#pragma mark - 单任务请求
+ (AFHTTPRequestOperation *)asynchronousNormalRequest:(NSString *)url parameters:(NSDictionary *)parameters successBlcok:(void (^)(BOOL success,id data,NSString *msg)) successBlock failedBlock:(void (^)(NSString *description))failedBlock
{
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    serializer.timeoutInterval = 30;
    NSMutableDictionary *newParam = [NSMutableDictionary dictionaryWithDictionary:parameters];  //数据统计
    [newParam setObject:@"0" forKey:@"is_teacher"];
    DJTUser *userInfo = [DJTGlobalManager shareInstance].userInfo;
    if (userInfo) {
        [newParam setObject:userInfo.userid ?: @"" forKey:@"userid"];
        [newParam setObject:userInfo.mid ?: @"" forKey:@"mid"];
        [newParam setObject:userInfo.token ?: @"" forKey:@"token"];
    }

    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:url parameters:newParam error:nil];
    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json",@"text/xml", nil];
    httpOperation.responseSerializer = response;
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        id notNullObject = responseObject ?: [NSData data];
        id result = [NSJSONSerialization JSONObjectWithData:notNullObject options:NSJSONReadingMutableLeaves error:nil];
        if (!result && [operation.responseString length] > 0) {
            NSString * responseString = operation.responseString;
            responseString = [responseString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            result = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        }
        NSString *str1 = [result valueForKey:@"result"];
        if (result && [str1 isEqualToString:@"0"]) {
            successBlock(YES,result,nil);
        }
        else
        {
            NSString *msg = [result valueForKey:@"message"];
            if (msg && [msg hasPrefix:@"鉴权失败"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //鉴权失败
                    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) failToLgoin];
                });
            }
            else
            {
                successBlock(NO,result,nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failedBlock(error.localizedDescription);
        
    }];
    
    [httpOperation start];
    
    return HTTPAutorelease(httpOperation);
}

/**
 *	@brief	json序列数据提交到http服务器
 *
 *	@param 	url 	链接地址
 *	@param 	parameters 	传输参数
 *
 *	@return	AFHTTPRequestOperation，供调用方获取，以便可以手动取消网络请求
 */
+ (AFHTTPRequestOperation *)asynchronousRequest:(NSString *)url parameters:(NSDictionary *)parameters successBlcok:(void (^)(BOOL success,id data,NSString *msg)) successBlock failedBlock:(void (^)(NSString *description))failedBlock
{
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    serializer.timeoutInterval = 30;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *json = [NSString encrypt:jsonStr];
    HTTPRelease(jsonStr);
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    [request setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json",@"text/xml", nil];
    httpOperation.responseSerializer = response;
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = operation.responseString;
        NSString *retJson = [NSString decrypt:responseString];
        if (retJson == nil) {
            successBlock(NO,nil,nil);
        }
        else{
            id result = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            //此处针对新开发的接口，做签名认证等一系列处理
            NSString *str1 = [result valueForKey:@"ret_code"];
            if ([str1 isEqualToString:@"0000"] || [str1 isEqualToString:@"2001"] || [str1 isEqualToString:@"2002"] || [str1 isEqualToString:@"2003"]) {
                successBlock(YES,result,nil);
            }
            else
            {
                if ([str1 isEqualToString:@"8888"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //鉴权失败
                        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) failToLgoin];
                    });
                }
                else
                {
                    successBlock(NO,result,nil);
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failedBlock(error.localizedDescription);
        
    }];
    
    [httpOperation start];
    
    return HTTPAutorelease(httpOperation);
}

#pragma mark - 单个文件上传
/**
 *	@brief	文件下载进度
 *
 *	@param 	url 	链接地址
 *	@param 	parameter 	传输参数
 *	@param 	filePath    文件路径
 *
 *	@return	AFHTTPRequestOperation，供调用方获取，以便可以手动取消网络请求
 */
+ (AFHTTPRequestOperation *)asynchronousRequestWithProgress:(NSString *)url parameters:(NSDictionary *)parameter filePath:(NSString *)filePath ssuccessBlcok:(void (^)(BOOL success,id data,NSString *msg)) successBlock failedBlock:(void (^)(NSString *description))failedBlock progressBlock:(void (^)(NSUInteger bytesRead,long long totalBytesRead,long long totalBytesExpectedToRead))progressBlock
{
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = nil;
    if (filePath) {
        request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" error:nil];
        } error:nil];
    }
    else
    {
        request = [requestSerializer requestWithMethod:@"GET" URLString:url parameters:parameter error:nil];
    }

    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"audio/mpeg",@"text/plain",@"application/zip",@"audio/x-aac",@"application/json",@"text/xml",@"image/png",@"image/jpg",@"image/jpeg",@"image/gif",@"application/octet-stream", nil];
    requestOperation.responseSerializer = response;
    if (filePath) {
        [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            progressBlock(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        }];
    }
    else
    {
        [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            progressBlock(bytesRead,totalBytesRead,totalBytesExpectedToRead);
        }];
    }
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (filePath) {
            NSString *retJson = [operation.responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //单条成功处理
            id result1 = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            if ([result1 isKindOfClass:[NSArray class]]) {
                result1 = [result1 lastObject];
            }
            NSString *str1 = [result1 valueForKey:@"result"];
            if (!str1 || [str1 isEqualToString:@"0"]) {
                successBlock(YES,result1,nil);
            }
            else
            {
                successBlock(NO,result1,nil);
            }
        }
        else
        {
            successBlock(YES,responseObject,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error.localizedDescription);
    }];
    
    [requestOperation start];
    
    return HTTPAutorelease(requestOperation);
}

/**
 *	@brief	文件上传
 *
 *	@param 	url 	路径
 *	@param 	filePath 	文件路径
 *	@param 	parameter 	参数
 *
 *	@return	AFURLSessionManager
 */
+ (AFURLSessionManager *)uploadFile:(NSString *)url FilePath:(NSString *)filePath parameters:(NSDictionary *)parameter ssuccessBlcok:(void (^)(BOOL success,id data,NSString *msg)) successBlock failedBlock:(void (^)(NSString *description))failedBlock
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = response;

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            successBlock(NO,nil,nil);
        }
        else
        {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            if ([[result valueForKey:@"result"] isEqualToString:@"0"]) {
                successBlock(YES,result,nil);
            }
            else
            {
                successBlock(NO,result,nil);
            }
        }
    }];
    
    [uploadTask resume];
    
    return HTTPAutorelease(manager);
}

#pragma mark - 多任务请求
/**
 *	@brief	多文件上传
 *
 *	@param 	images 	图片数组
 *	@param 	url 	链接地址
 *	@param 	parameter 	传输参数
 */
+ (void)uploadMutiImages:(NSArray*)images url:(NSString *)url parameters:(NSDictionary *)parameter singleSuccessBlock:(void (^)(id result,NSInteger index))singleSuccessBlock singleFailureBlock:(void (^)(NSString *desc,NSInteger index))singleFailureBlock allCompletionBlock:(void (^)(NSArray *operations))allCompletionBlock singleUploadSuccess:(void (^)(NSInteger index))singleUploadSuccess
{
    NSMutableArray *mutableOperations = [NSMutableArray array];
    NSInteger index = 0;
    for (NSString *file in images) {
        NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:[file lastPathComponent]];
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" error:nil];
        } error:nil];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *retJson = [operation.responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //单条成功处理
            id retData = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            
            
            singleSuccessBlock(retData,index);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //单条失败处理
            singleFailureBlock(error.localizedDescription,index);
        }];
        [mutableOperations addObject:operation];
        index++;
        HTTPRelease(operation);
        //[operation release];
    }
    
    NSArray *connectOperations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        //NSLog(@"%ld of %ld complete", (long)numberOfFinishedOperations, (long)totalNumberOfOperations);
        singleUploadSuccess(numberOfFinishedOperations);
    } completionBlock:^(NSArray *operations) {
        allCompletionBlock(operations);
    }];
    
    [[NSOperationQueue mainQueue] addOperations:connectOperations waitUntilFinished:NO];
}

+ (void)uploadMutiImagesOrVideo:(NSArray*)images url:(NSString *)url parameters:(NSDictionary *)parameter singleSuccessBlock:(void (^)(id result,NSInteger index))singleSuccessBlock singleFailureBlock:(void (^)(NSString *desc,NSInteger index))singleFailureBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         // 上传 多张图片
         for(NSString *file in images)
         {
             NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:[file lastPathComponent]];
             NSError *error;
             [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"images[]" error:&error];
         }
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSString *retJson = [operation.responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         //单条成功处理
         id retData = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
         singleSuccessBlock(retData,1);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         singleFailureBlock(error.localizedDescription,1);
     }];
}

@end
