//
//  SelectPhotosCell.h
//  NewTeacher
//
//  Created by szl on 16/2/22.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectPhotosCellDelegate <NSObject>

@optional
- (void)preShowBigView:(UICollectionViewCell *)cell;
- (void)checkItemToController:(UICollectionViewCell *)cell;
@end

@interface SelectPhotosCell : UICollectionViewCell

@property (nonatomic,readonly)UIImageView *contentImg;
@property (nonatomic,readonly)UIButton *selBut;
@property (nonatomic,readonly)UILabel *fromLab;
@property (nonatomic,readonly)UIButton *checkBtn;
@property (nonatomic,readonly)UIView *bgView;
@property (nonatomic,assign)id<SelectPhotosCellDelegate> delegate;
@property (nonatomic,strong)UIImageView *hdImg;

- (void)resetDataSource:(id)data;

@end
