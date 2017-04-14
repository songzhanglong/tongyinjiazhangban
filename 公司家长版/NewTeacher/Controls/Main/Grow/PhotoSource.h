//
//  PhotoSource.h
//  NewTeacher
//
//  Created by szl on 16/6/22.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJTCollectionViewFlowLayout.h"

@class SelectPhotosModel;

@protocol PhotoSourceDelegate <NSObject>

@optional
- (void)actionDidIndex:(NSInteger)index PhotoModel:(SelectPhotosModel *)photoModel;  //0-查看大图，1－删除,2-设为封面

@end

@interface PhotoSource : NSObject<DJTCollectionViewDataSource,DJTCollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic,assign)id<PhotoSourceDelegate> delegate;
@property (nonatomic,strong)NSMutableArray *resource;
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,assign)CGFloat minWei;
@property (nonatomic,assign)CGFloat minHei;
@property (nonatomic,assign)BOOL isSmallPicLimit;

- (void)createCollectionViewTo:(UIView *)view;

@end
