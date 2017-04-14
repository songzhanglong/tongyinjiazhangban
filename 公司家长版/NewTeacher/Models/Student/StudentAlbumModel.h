//
//  StudentAlbumModel.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface StudentItem : JSONModel

@property (nonatomic,strong)NSString *path;       //图片路径
@property (nonatomic,strong)NSString *record_url; //音频路径
@property (nonatomic,strong)NSString *thumb;      //缩略图路径
@property (nonatomic,strong)NSString *photo_id;   //图片id
@property (nonatomic,strong)NSString *type;

@end

@interface StudentAlbumModel : JSONModel

@property (nonatomic,strong)NSString *ctime;      //日期
@property (nonatomic,strong)NSMutableArray *photos;    //图片数组

@end
