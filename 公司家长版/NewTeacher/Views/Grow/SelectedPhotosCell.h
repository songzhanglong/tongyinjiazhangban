//
//  SelectedPhotosCell.h
//  NewTeacher
//
//  Created by szl on 16/2/22.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedPhotosCell : UICollectionViewCell

@property (nonatomic,readonly)UIImageView *contentImg;
@property (nonatomic,readonly)UIImageView *fmImgView;
@property (nonatomic,strong)UIImageView *hdImg;

- (void)resetDataSource:(id)data;

@end
