//
//  CommonUtil.h
//  bdws
//
//  Created by yanghaibo on 15/1/19.
//  Copyright (c) 2015年 cgpu456. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject
@property (nonatomic,assign) BOOL isOpen;
- (BOOL) isFileExist:(NSString *)fileName;
-(void)writeFile:(id)uploadModel;
-(id)readFile;
-(BOOL)removeObject:(id)uploadModel;
-(BOOL)replaceObject:(id)uploadModel;
+ (CommonUtil *)shareInstance;
@end
