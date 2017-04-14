//
//  MileagePermissionsViewController.h
//  NewTeacher
//
//  Created by 张雪松 on 15/12/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@protocol MileagePermissionsDelegate <NSObject>

@optional

- (void)permissionsToSelect:(int)indexType;

@end

@interface MileagePermissionsViewController : DJTBaseViewController
@property (nonatomic, strong) NSString *indexToType;
@property (nonatomic,assign)id<MileagePermissionsDelegate> delegate;

@end
