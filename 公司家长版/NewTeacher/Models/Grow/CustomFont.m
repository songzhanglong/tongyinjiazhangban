//
//  CustomFont.m
//  TYSociety
//
//  Created by szl on 16/8/16.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CustomFont.h"

@implementation CustomFont

- (void)dealloc
{
    [self clearRequest];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)clearRequest
{
    if (_httpOperation && (![_httpOperation isCancelled] && ![_httpOperation isFinished])) {
        [_httpOperation cancel];
        NSLog(@"[_httpOperation cancel];");
    }
    self.httpOperation = nil;
}

- (void)startDownLoadTTFFile
{
    if (_download.length == 0) {
        return;
    }
    if (_httpOperation) {
        [self clearRequest];
    }
    NSString *url = [G_IMAGE_ADDRESS stringByAppendingString:_download];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:url parameters:nil filePath:nil ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
        NSString *name =  [weakSelf.font_key stringByAppendingString:@".ttf"];
        NSString *path = [APPDocumentsDirectory stringByAppendingPathComponent:name];
        [(NSData *)data writeToFile:path atomically:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.downLoadBlock) {
                weakSelf.downLoadBlock(weakSelf,nil,[NSURL fileURLWithPath:path]);
            }
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.downLoadBlock) {
                weakSelf.downLoadBlock(weakSelf,[NSError errorWithDomain:description code:0 userInfo:nil],nil);
            }
        });
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
    }];
}

- (BOOL)fileHasDownLoaded
{
    if (_download.length == 0) {
        return NO;
    }
    
    NSString *filePath = [APPDocumentsDirectory stringByAppendingPathComponent:[_font_key stringByAppendingString:@".ttf"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

@end
