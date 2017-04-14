//
//  GrowAlbumItem.h
//  NewTeacher
//
//  Created by szl on 16/1/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface GrowAlbumItem : JSONModel

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *photo_id;
@property (nonatomic,strong)NSNumber *pic_num;
@property (nonatomic,strong)NSString *thumb;
@property (nonatomic,strong)NSNumber *video_num;
@property (nonatomic,strong)NSNumber *h5_num;
@property (nonatomic,strong)NSNumber *type;
@property (nonatomic,strong)NSString *digst;

@end
