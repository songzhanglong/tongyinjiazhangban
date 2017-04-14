//
//  SendToMotherViewController.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@protocol SendToMotherDelegate <NSObject>

@optional
- (void)sendToPeople:(NSArray *)people IndexArray:(NSArray *)index;

@end

@interface SendToMotherViewController : DJTBaseViewController

@property (nonatomic,assign)id<SendToMotherDelegate> delegate;
@property (nonatomic,strong) NSArray *selectIndexArray;
@end
