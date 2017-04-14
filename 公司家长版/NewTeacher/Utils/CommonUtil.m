//
//  CommonUtil.m
//  bdws
//
//  Created by yanghaibo on 15/1/19.
//  Copyright (c) 2015年 cgpu456. All rights reserved.
//

#import "CommonUtil.h"
#import "DJTGlobalDefineKit.h"
#import "UploadManager.h"
#import "DJDBOperation.h"
//[locatePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
@implementation CommonUtil

+ (CommonUtil *)shareInstance
{
    static CommonUtil *commonUtil = nil;
    static dispatch_once_t onceUpload;
    dispatch_once(&onceUpload, ^{
        commonUtil = [[CommonUtil alloc] init];
    });
    
    return commonUtil;
}

- (id)init
{
    if (self = [super init]) {
        _isOpen=false;
    }
    return self;
}

- (BOOL) isFileExist:(NSString *)fileName
{
    NSString *namePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                        stringByAppendingPathComponent:fileName];;
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:namePath];
}


//写文件
-(void)writeFile:(id)uploadModel{
    if ([uploadModel isKindOfClass:[UploadModel class]]) {
        [[DJDBOperation shareInstance] insertNotUploadModel:uploadModel];
    }
}

-(id)readFile{
    NSArray *uploadArray = [[DJDBOperation shareInstance] queryNotUploadModel];
    if (uploadArray==nil) {
        return [NSMutableArray array];
    }else{
        return [uploadArray mutableCopy];
    }
    return uploadArray;
}

-(BOOL)removeObject:(id)uploadModel
{
    if ([uploadModel isKindOfClass:[UploadModel class]]) {
        UploadModel *model = (UploadModel *)uploadModel;
        [[DJDBOperation shareInstance] deleteNotUploadModel:model.dateTime];
    }
    return true;
}

-(BOOL)replaceObject:(id)uploadModel
{
    if ([uploadModel isKindOfClass:[UploadModel class]]) {
        [[DJDBOperation shareInstance]updateNotUploadModel:uploadModel];
    }
    return true;
}



@end
