//
//  MyTableBar.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyTableBarDelegate <NSObject>

@optional
- (void)selectTableIndex:(NSInteger)index;

@end

@interface MyTableBar : UIView

@property (nonatomic,assign)id<MyTableBarDelegate> delegate;

@property (nonatomic,assign)NSInteger nSelectedIndex;

@end
