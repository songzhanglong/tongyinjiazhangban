//
//  DJTLoginView.h
//  GoOnBaby
//
//  Created by user7 on 11/18/14.
//  Copyright (c) 2014 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LoginViewDelegate <NSObject>
@optional
- (void)loginWithUsername:(NSString *)userName Password:(NSString *)password;
- (void)forgetPassword;
- (void)openAgreement;
@end

@interface DJTLoginView : UIView<UITextFieldDelegate>

@property (nonatomic,assign)id<LoginViewDelegate> delegate;
@property (nonatomic,strong)UITextField *nameField;
@property (nonatomic,strong)UITextField *passField;
@property (nonatomic,strong)UIButton *remberBut;

@end
