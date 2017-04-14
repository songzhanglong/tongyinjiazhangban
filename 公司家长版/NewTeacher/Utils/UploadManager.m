//
//  UploadManager.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "UploadManager.h"
#import "DJTHttpClient.h"
#import "NSString+Common.h"
#import "DJTGlobalDefineKit.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Toast+UIView.h"
#import "YQSlideMenuController.h"
#import "MainViewController.h"
#import "MyTableBarViewController.h"
#import "CommonUtil.h"
@implementation UploadModel

//将对象编码(即:序列化)
-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_isVideo forKey:@"isVideo"];
    [aCoder encodeObject:_imgs forKey:@"imgs"];
    [aCoder encodeObject:_uploadUrl forKey:@"uploadUrl"];
    [aCoder encodeObject:_param forKey:@"param"];
    [aCoder encodeObject:_endUrl forKey:@"endUrl"];
    [aCoder encodeObject:_endParam forKey:@"endParam"];
    [aCoder encodeObject:_dataSource forKey:@"dataSource"];
    [aCoder encodeObject:_dateTime forKey:@"dateTime"];
    [aCoder encodeObject:_account forKey:@"account"];
    [aCoder encodeObject:_froType forKey:@"froType"];
}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
        _isVideo = [aDecoder decodeBoolForKey:@"isVideo"];
        _imgs = [aDecoder decodeObjectForKey:@"imgs"];
        _uploadUrl = [aDecoder decodeObjectForKey:@"uploadUrl"];
        _param = [aDecoder decodeObjectForKey:@"param"];
        _endUrl = [aDecoder decodeObjectForKey:@"endUrl"];
        _endParam = [aDecoder decodeObjectForKey:@"endParam"];
        _dataSource = [aDecoder decodeObjectForKey:@"dataSource"];
        _dateTime = [aDecoder decodeObjectForKey:@"dateTime"];
        _account = [aDecoder decodeObjectForKey:@"account"];
        _froType = [aDecoder decodeObjectForKey:@"froType"];
    }
    return (self);
}

- (id)init
{
    if (self = [super init]) {
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)removeFileBy:(NSString *)value
{
    if (value && ![value isKindOfClass:[NSNull class]]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:value]) {
            [fileManager removeItemAtPath:value error:nil];
        }
    }
    
}

- (void)refreshMainTip
{
    YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    if ([sideCon isKindOfClass:[YQSlideMenuController class]]) {
        MyTableBarViewController *tabBarCon = (MyTableBarViewController *)sideCon.contentViewController;
        if (tabBarCon.selectedIndex == 0) {
            UINavigationController *mainNav = (UINavigationController *)tabBarCon.selectedViewController;
            if (mainNav.viewControllers.count == 1) {
                MainViewController *main = [[mainNav viewControllers] firstObject];
                [main refreshTipInfo];
            }
        }
    }
}

- (void)startUploadImgs
{
    UploadManager *manager = [UploadManager shareInstance];
    __weak typeof(self)weakSelf = self;
    __weak typeof(_dataSource)weakSource = _dataSource;
    __weak typeof(manager)weakManager = manager;
    NSMutableArray *imgsArr = [NSMutableArray arrayWithArray:_imgs];
    NSMutableArray *otherImgs = [NSMutableArray arrayWithArray:_imgs];
    if (weakSelf.isVideo) {
        [DJTHttpClient uploadMutiImagesOrVideo:imgsArr url:_uploadUrl parameters:_param singleSuccessBlock:^(id result,NSInteger index) {
            
            //上传数量控制
            weakManager.curCount += 1;
            if (weakManager.curCount >= weakManager.totalCount) {
                weakManager.curCount = 0;
                weakManager.totalCount = 0;
            }
            [weakSelf refreshMainTip];
            for (NSString *str in weakSelf.imgs) {
                [weakSelf removeFileBy:str];
            }
            if ([result isKindOfClass:[NSArray class]]) {
                result = [result firstObject];
            }
            NSString *original = [result valueForKey:@"original"];
            if (original && [original length] > 0)
            {
                [weakSource addObject:original];
                
                NSString *picture = [result valueForKey:@"picture"];
                [weakSource addObject:picture];
                weakSelf.imgs  = [NSArray array];
                
                [[CommonUtil shareInstance] replaceObject:weakSelf];
            }
            
            [weakSelf comletionUpload];
            
        } singleFailureBlock:^(NSString *desc,NSInteger index) {
            //上传数量控制
            weakManager.curCount += 1;
            if (weakManager.curCount >= weakManager.totalCount) {
                weakManager.curCount = 0;
                weakManager.totalCount = 0;
            }
            [weakSelf refreshMainTip];
            
            [weakSelf comletionUpload];
        }];
    }else{
        [DJTHttpClient uploadMutiImages:imgsArr url:_uploadUrl parameters:_param singleSuccessBlock:^(id result,NSInteger index) {
            if ([result isKindOfClass:[NSArray class]]) {
                result = [result firstObject];
            }
            NSString *original = [result valueForKey:@"original"];
            if (original && [original length] > 0) {
                NSString *extension = [original pathExtension];
                NSString *thumbnail = [NSString stringWithFormat:@"%@_290_290.%@",[[original stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"],extension];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:original,@"path",thumbnail,@"thumb", nil];
                [weakSource addObject:dic];
                
                NSString *value = [otherImgs objectAtIndex:index];
                NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:weakSelf.imgs];
                [tmpArr removeObject:value];
                weakSelf.imgs = tmpArr;
                [[CommonUtil shareInstance] replaceObject:weakSelf];
                [weakSelf removeFileBy:value];
            }
            
            //上传数量控制
            weakManager.curCount += 1;
            if (weakManager.curCount >= weakManager.totalCount) {
                weakManager.curCount = 0;
                weakManager.totalCount = 0;
            }
            [weakSelf refreshMainTip];
        } singleFailureBlock:^(NSString *desc,NSInteger index) {
            //上传数量控制
            weakManager.curCount += 1;
            if (weakManager.curCount >= weakManager.totalCount) {
                weakManager.curCount = 0;
                weakManager.totalCount = 0;
            }
            [weakSelf refreshMainTip];
        } allCompletionBlock:^(NSArray *operations) {
            
            //判断图片是否上传完全
            if ([weakSelf.imgs count] > 0) {
                weakManager.netWorking = NO;
                [weakManager.upModels removeObject:weakSelf];
                [weakManager startNextRequest];
            }else if([weakSource count] == 0){
                weakManager.netWorking = NO;
                [[CommonUtil shareInstance] removeObject:weakSelf];
                [weakManager.upModels removeObject:weakSelf];
                [weakManager startNextRequest];
            }else{
                [weakSelf comletionUpload];
            }
        } singleUploadSuccess:^(NSInteger index){
            
        }];
    }
}

- (void)comletionUpload
{
    UploadManager *manager = [UploadManager shareInstance];
    if (_dataSource.count == 0) {
        manager.netWorking = NO;
        [manager.upModels removeObject:self];
        [manager startNextRequest];
    }
    else
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_endParam];
        if (_isVideo) {
            [dic setObject:[_dataSource firstObject] forKey:@"video"];
            [dic setObject:[_dataSource lastObject] forKey:@"video_thumb"];
        }
        else
        {
            NSData *json = [NSJSONSerialization dataWithJSONObject:_dataSource options:NSJSONWritingPrettyPrinted error:nil];
            NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            NSString *notLine = [lstJson stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
            notLine = [notLine stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            notLine = [notLine stringByReplacingOccurrencesOfString:@" " withString:@""];
            notLine = [notLine stringByReplacingOccurrencesOfString:@"\\" withString:@""];  //去除反斜杠
            [dic setObject:notLine forKey:@"img"];
        }
        
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
        [dic setObject:text forKey:@"signature"];
        
        __weak typeof(self)weakSelf = self;
        __weak typeof(dic)weakDic = dic;
        [DJTHttpClient asynchronousRequest:_endUrl parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf endUpload:success Data:data];
        } failedBlock:^(NSString *description) {
            [weakSelf endUpload:NO Data:weakDic];
        }];
    }
}

- (void)endUpload:(BOOL)suc Data:(id)result
{
    
    NSString *type = _froType;
    BOOL classCircle = ([type integerValue] != 1);
    if (suc) {
        NSString *tipStr =  classCircle ? @"班级圈动态有更新" : @"宝宝里程有更新";
        [[CommonUtil shareInstance] removeObject:self];
        
        AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (![del.window.rootViewController isKindOfClass:[LoginViewController class]]) {
            [del.window makeToast:tipStr duration:1.0 position:@"center"];
            if (!classCircle) {
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_LICHENT object:@"REFRESH"];
            }
        }
    }
    
    UploadManager *manager = [UploadManager shareInstance];
    manager.netWorking = NO;
    [manager.upModels removeObject:self];
    [manager startNextRequest];
}

@end

@implementation UploadManager

+ (UploadManager *)shareInstance
{
    static UploadManager *uploadManager = nil;
    static dispatch_once_t onceUpload;
    dispatch_once(&onceUpload, ^{
        uploadManager = [[UploadManager alloc] init];
    });
    
    return uploadManager;
}

- (id)init
{
    if (self = [super init]) {
        _upModels = [NSMutableArray array];
    }
    return self;
}

- (void)startNextRequest
{
    if (_netWorking) {
        UploadModel *lastModel = [_upModels lastObject];
        _totalCount += lastModel.isVideo ? 1 : lastModel.imgs.count;
        return;
    }
    
    if (_upModels.count == 0) {
        return;
    }
    
    _netWorking = YES;
    UploadModel *model = [_upModels firstObject];
    [model startUploadImgs];
    if (_totalCount == 0) {
        //表示连续请求中第一个上传请求开始
        _totalCount += model.isVideo ? 1 : model.imgs.count;
    }
}

@end
