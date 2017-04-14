//
//  ThemeBatchDetailModel.h
//  NewTeacher
//
//  Created by szl on 15/12/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol BatchDetailPictureItem

@end
@interface BatchDetailPictureItem : JSONModel

@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *thumb;

@end

@protocol BatchDetailReplyItem

@end
@interface BatchDetailReplyItem : JSONModel

@property (nonatomic,strong)NSString *message;
@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *is_teacher;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *author_id;
@property (nonatomic,strong)NSString *dateline;
@property (nonatomic,strong)NSString *mid;
@property (nonatomic,assign)CGFloat contentHei;

@end

@protocol BatchDetailDiggItem

@end
@interface BatchDetailDiggItem : JSONModel

@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *is_teacher;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *author_id;
@property (nonatomic,strong)NSString *mid;

@end

@interface ThemeBatchDetailModel : JSONModel

@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *is_teacher;
@property (nonatomic,strong)NSNumber *digg;
@property (nonatomic,strong)NSString *userid;
@property (nonatomic,strong)NSString *digst;
@property (nonatomic,strong)NSMutableArray<BatchDetailPictureItem> *picture;
@property (nonatomic,strong)NSString *batch_id;
@property (nonatomic,strong)NSMutableArray<BatchDetailReplyItem> *replyList;
@property (nonatomic,strong)NSMutableArray<BatchDetailDiggItem> *diggList;
@property (nonatomic,strong)NSNumber *replies;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *create_term;
@property (nonatomic,strong)NSString *mid;
@property (nonatomic,strong)NSString *have_digg;
@property (nonatomic,strong)NSString *relation;

@property (nonatomic,assign)CGFloat diggHei;

@end
