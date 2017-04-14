//
//  EditGrowBar.h
//  NewTeacher
//
//  Created by songzhanglong on 15/6/11.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditGrowBarDelegate <NSObject>

@optional
- (void)commitEditInfo:(NSString *)text;

@end

@interface EditGrowBar : UIView<UITextFieldDelegate>

@property (nonatomic,assign)NSInteger maxNum;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,assign)id<EditGrowBarDelegate> delegate;

@end
