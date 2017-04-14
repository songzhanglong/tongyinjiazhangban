//
//  DJTGlobalDefineKit.h
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#ifndef TY_DJTGlobalDefineKit_h
#define TY_DJTGlobalDefineKit_h

#define APPDELEGETE                 ((AppDelegate *)[[UIApplication sharedApplication]delegate])

#define USERDEFAULT                 ([NSUserDefaults standardUserDefaults])

#pragma mark - 路径
#define APPDocumentsDirectory       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]                            //document路径
#define APPCacheDirectory           [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]                         //cache路径
#define APPTmpDirectory             [NSHomeDirectory()  stringByAppendingPathComponent:@"tmp"]   //tmp路径

#pragma mark - 屏幕参数
#define SCREEN_WIDTH                ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT               ([UIScreen mainScreen].bounds.size.height)

#pragma mark - 接口地址
#define G_INTERFACE_ADDRESS         @"http://interface.goonbaby.com/mycen/interface3.0/"     //http服务器地址(生产)
#define URLFACE                     @"http://v1.goonbaby.com/api/client.php?action="
#define G_IMAGE_ADDRESS             @"http://static.goonbaby.com"   //图片地址前缀(生产)
#define G_IMAGE_GROW_ADDRESS        @"http://static.goonbaby.com"   //成长档案封面和zip包（生产）
#define G_UPLOAD_IMAGE              @"http://upload.goonbaby.com/uploadImg?param="  //图片上传（生产）
#define G_UPLOAD_NEWAUDIO           @"http://upload.goonbaby.com/uploadVideo?type=1&id="
#define WEBSOCKET_URL               @"ms.goonbaby.com:8091"
//#define WEBSOCKET_URL               @"121.199.37.92:8303"

#pragma mark - HmacSHA1加密密钥
#define SERCET_KEY                  @"abcdefghijklmnopqrstuvwx" //HMac1加密秘钥
#define LOGIN_VEFIFICATION          @"cookieValue"              //签名验证
#define LOGIN_ACCOUNT               @"loginAccount"             //登录账号
#define LOGIN_PASSWORD              @"loginPassword"            //登录密码
#define LOGIN_REMBER                @"loginRember"              //记住密码
#define LOGIN_SCHOOL                @"loginSchool"              //登录幼儿园
#define LOGIN_FACE                  @"loginFace"                //头像
#define LOGIN_MEMBERID              @"userMemberId"             //用户id
#define LOGIN_FACEIMAGE             @"picture"                  //登录用户的头像
#define LOGIN_USER                  @"user"                     //获取用户信息
#define LOGIN_ATTENDANCE            @"attendance"               //是否查看考勤
#define REFRESH_MAIN_HEADVIEW       @"refreshMainHeadView"      //刷新Main表头
#define REFRESH_LICHENT             @"refreshLiChen"            //刷新里程

#pragma mark - 通知
#define STOP_SCROLL_ENABLE          @"stopScrollEnable"         //停止滑动
#define CHANGE_HEAD_FINISH          @"changeHeadFinish"         //头像修改完成
#define CHANGE_USER_HEADER          @"changeUserHeader"         //修改用户头像
#define APP_FIRST_LAUNCH            @"firstLaunch2"             //头次启动
#define JS_FILE_NAME                @"parent"                   //js文件名称

#define EDIT_INDEX                  @"editIndex"
#define PICTURE_TIP                 @"photoimgTip"
#define CHECKMORE_PICTURE           @"checkMorePicture"
#define Seperate_RowStr             @"#r#"

#pragma mark - 背景颜色
#define G_BACKGROUND_COLOR          [UIColor colorWithRed:239.0 / 255.0 green:239.0 / 255.0 blue:239.0 / 255.0 alpha:1.0]
#define CreateColor(x,y,z)          [UIColor colorWithRed:x / 255.0 green:y / 255.0 blue:z / 255.0 alpha:1.0]
#define rgba(r,g,b,a)               [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define BACKGROUND_COLOR            CreateColor(220, 220, 221)

#pragma mark - 基调色
#define BASELINE_COLOR              rgba(154,125,251,1)
#define UnEditTextColor             rgba(233,231,231,1)
#define TextSelectColor             rgba(61, 61, 61, 1)
#define PortfolioColor              rgba(240, 239, 245, 1)

#define CREATE_IMG(name)    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]]
#define CREATE_JPG(name)    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"jpg"]]


#pragma mark - 标记特殊文字
#define BEGIN_PATH                  @"<@#"
#define END_PATH                    @"#@>"

#pragma mark - 友盟APPKEY
#define UMENG_APPKEY                @"54f93a5afd98c5b0ca000c52" //公司

#define NET_WORK_TIP                @"无法连接服务器，请检查你的网络设置。"
#define REQUEST_FAILE_TIP           @"无法连接服务器，请尝试重新打开客户端。"
#define SHARE_TIP_INFO              @"您还需要安装对应的APP"

#endif
