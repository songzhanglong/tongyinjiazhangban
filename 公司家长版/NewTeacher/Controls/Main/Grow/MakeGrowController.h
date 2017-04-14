//
//  DJTMakeGrowController.h
//  TYWorld
//
//  Created by songzhanglong on 14-10-14.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"
#import "GrowTermModel.h"

@protocol MakeGrowControllerDelegate <NSObject>

@optional
- (void)makeFinishImg:(NSString *)imgPath Data:(id)data url:(NSString *)url;

@end

@interface MakeGrowController : DJTBaseViewController

@property (nonatomic,strong)GrowAlbumModel *growAlbum;
@property (nonatomic,strong)UIImage *targerImg;
@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *album_title;
@property (nonatomic,strong)NSString *growId;
@property (nonatomic,strong)NSString *templist_id;
@property (nonatomic,strong)NSNumber *tpl_height;
@property (nonatomic,strong)NSNumber *tpl_width;
@property (nonatomic,assign)BOOL isSmallPicLimit;
@property (nonatomic,assign)id<MakeGrowControllerDelegate> delegate;

@end
