//
//  DJTUser.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"
#import "LastPhotoModel.h"

typedef enum{
    ePayNull    = 0,        //未支付，未绑定
    ePayMoney   = 1 << 0,   //支付
    ePayBind    = 1 << 1    //绑定
}ePayType;

@protocol TeacherData

@end

@interface TeacherData : JSONModel

@property (nonatomic,strong)NSString *teacher_face;
@property (nonatomic,strong)NSString *teacher_name;
@property (nonatomic,strong)NSString *teacher_tel;

@end

@protocol DJTButton

@end

@interface DJTButton : JSONModel

@property (nonatomic,strong)NSString *b_key;        //应用key
@property (nonatomic,strong)NSString *b_name;
@property (nonatomic,strong)NSString *b_picture;
@property (nonatomic,strong)NSString *b_url;        //h5网页地址
@property (nonatomic,strong)NSString *type;         //1客户端功能，2 h5网页
@property (nonatomic,assign)BOOL fromDef;           //来源于本地

@end

@interface DJTUser : JSONModel

@property (nonatomic,strong)NSString *album_id;           //相册id
@property (nonatomic,strong)NSString *mid;                  //家长id
@property (nonatomic,strong)NSString *android_version;    //android版本
@property (nonatomic,strong)NSString *baby_count;         //宝贝数量，家长端
@property (nonatomic,strong)NSString *baby_id;            //宝贝id
@property (nonatomic,strong)NSString *birthday;           //生日
@property (nonatomic,strong)NSString *city;               //城市
@property (nonatomic,strong)NSString *class_id;           //班级id
@property (nonatomic,strong)NSString *class_name;         //班级名称
@property (nonatomic,strong)NSString *days;               //天数
@property (nonatomic,strong)NSString *face;               //头像地址
@property (nonatomic,strong)NSString *ios_version;        //ios版本
@property (nonatomic,strong)NSString *msg_count;          //消息数量
@property (nonatomic,strong)NSString *province;           //省份
@property (nonatomic,strong)NSString *realname;           //学生姓名
@property (nonatomic,strong)NSString *relation;           //关系
@property (nonatomic,strong)NSString *school_id;          //学校id
@property (nonatomic,strong)NSString *school_name;        //学校名称
@property (nonatomic,strong)NSString *sex;                //性别
@property (nonatomic,strong)NSString *grade_name;         //年级
@property (nonatomic,strong)NSString *grade_id;
@property (nonatomic,strong)NSString *term_id;            //学期ID
@property (nonatomic,strong)NSString *uname;              //家长名字
@property (nonatomic,strong)NSString *user_code;          //用户code
@property (nonatomic,strong)NSString *userid;             //用户id
@property (nonatomic,strong)NSString *school_logo;        //学校logo
@property (nonatomic,strong)NSString *teacher_face;       //教师头像
@property (nonatomic,strong)NSString *teacher_tel;        //教师电话
@property (nonatomic,strong)NSString *teacher_name;       //教师姓名
@property (nonatomic,strong)NSString *intro;              //简介
@property (nonatomic,strong)NSString *token;
@property (nonatomic,strong)NSString *status;             //2-缺勤,0-未考勤,1-到勤
@property (nonatomic,strong)NSString *level;              //1、小小班  2、小班 3、中班  4、大班 5、学期班  6、非幼儿园
@property (nonatomic,strong)NSString *h5_url;
@property (nonatomic,strong)NSString *show_type;    //office-首页就是办公

@property (nonatomic,strong)NSArray<DJTButton> *button;
@property (nonatomic,strong)NSArray<TeacherData> *teacher_datas;
@property (nonatomic,strong)LastPhotoModel *photoModel;

/* ----------视眼-----------*/
@property (nonatomic,strong)NSString *device_pwd;
@property (nonatomic,strong)NSString *device_port;
@property (nonatomic,strong)NSString *device_account;
@property (nonatomic,strong)NSString *device_ip;
/* ----------视眼-----------*/

@property (nonatomic,strong)NSString *mainTipStr;
@property (nonatomic,strong)NSString *mainTipNum;
@property (nonatomic,strong)NSString *mainFace;

@property (nonatomic,strong)NSNumber *dynamic_open; //发送班级圈权限,0是没权限  1是有权限
@property (nonatomic,strong)NSNumber *home_comment_open;    //班级圈回复权限

@property (nonatomic,strong)NSArray *decorationArr;
@property (nonatomic,strong)NSArray *adsSource;

@property (nonatomic,assign)BOOL hasTimeCard;   //园所已绑定考勤卡
@property (nonatomic,assign)ePayType payType;   //判断用户当前是否已支付,与绑定

@property (nonatomic,assign)CGFloat class_nameWei;
;
- (void)caculateClass_nameWei;
@end
