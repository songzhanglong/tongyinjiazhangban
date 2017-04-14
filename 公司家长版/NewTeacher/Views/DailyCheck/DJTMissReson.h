//
//  DJTMissReson.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DJTMissReson;
@protocol DJTMissResonDelegate <NSObject>

-(void)sickBtnTouch:(DJTMissReson   *)btn;
-(void)busyBtnTouch:(DJTMissReson   *)btn;
-(void)telePhoenTouch:(DJTMissReson *)btn;
@end
@interface DJTMissReson : UIView

@end
