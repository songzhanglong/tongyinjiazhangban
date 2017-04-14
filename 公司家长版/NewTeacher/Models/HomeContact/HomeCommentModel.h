//
//  DJTFootContactModel.h
//  TY
//
//  Created by songzhanglong on 14-6-10.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeCommentModel : NSObject

@property (nonatomic,strong)NSString *card_school_comment_type;  //评论类型(0代表文字，1代表录音)
@property (nonatomic,strong)NSString *card_school_content;    //评论内容(文字或者录音URL)
@property (nonatomic,strong)NSString *card_home_comment_type; //评论类型(0代表文字，1代表录音)
@property (nonatomic,strong)NSString *card_home_content;  //评论内容(文字或者录音URL)

@end
