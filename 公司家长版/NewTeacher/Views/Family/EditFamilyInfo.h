//
//  EditFamilyInfo.h
//  NewTeacher
//
//  Created by songzhanglong on 15/5/18.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FamilNumberModel.h"
@class EditFamilyInfo;

@protocol EditFamilyInfoDelegate <NSObject>

@optional
- (void)checkAddressBook:(EditFamilyInfo *)editFamily;
- (void)editFamilyInfo:(EditFamilyInfo *)editFamily Name:(NSString *)name Phone:(NSString *)phone;
- (void)selectFamilyDynamic:(EditFamilyInfo *)editFamily;
- (void)changeFace:(EditFamilyInfo *)editFamily;
- (void)cancelEditInfo:(EditFamilyInfo *)editFamily;

@end

typedef enum
{
    kEditTypeCheck = 0, //不可改名字
    kEditTypeCheck2,    //可改名字，查看
    kEditTypeAdd
}kEditType;

typedef enum
{
    kCommitTypeNone = 0,//
    kCommitTypeImage,   //图片
    kCommitTypeName,    //姓名
    kCommitTypePhone,   //电话
    kCommitTypeAll
}kCommitType;

@interface EditFamilyInfo : UIView<UITextFieldDelegate>

@property (nonatomic,assign)kEditType editTyppe;
@property (nonatomic,assign)kCommitType commitType;
@property (nonatomic,assign)id<EditFamilyInfoDelegate> delegate;
@property (nonatomic,strong)FamilNumberModel *familyModel;
@property (nonatomic,strong)UITextField *phoneField;
@property (nonatomic,strong)UITextField *nameField;
@property (nonatomic,strong)NSString *faceNew;
@property (nonatomic,strong)UIButton *headBut;

- (void)cancelPhoneEdit;
- (void)cancelNameEdit;

@end
