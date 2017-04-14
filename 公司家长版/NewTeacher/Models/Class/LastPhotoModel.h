//
//  LastPhotoModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface LastPhotoFace : JSONModel

@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *face;

@end

@protocol LastPhotoList

@end
@interface LastPhotoList : JSONModel

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *creater;
@property (nonatomic,strong)NSString *thumb;

@end

@interface LastPhotoModel : JSONModel

@property (nonatomic,strong)LastPhotoFace *face;
@property (nonatomic,strong)NSArray<LastPhotoList> *photos;

@end
