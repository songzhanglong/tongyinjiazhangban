//
//  DJTInputBar.h
//  MZJD
//
//  Created by songzhanglong on 14-4-29.
//  Copyright (c) 2014年 DIGIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputBarDelegate <NSObject>

@optional
- (void)changeViewHeight:(CGFloat)height;
- (void)sendComment:(NSString *)content;
- (void)cancelIndexPath;
@end

@interface InputBar : UIView<UITextFieldDelegate>
@property (nonatomic,assign)id<InputBarDelegate> delegate;
@property (nonatomic,readonly)UITextField *textField;

- (void)setBackgroundColorToType;
@end
