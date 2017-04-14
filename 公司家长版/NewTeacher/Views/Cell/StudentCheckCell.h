//
//  StudentCheckCell.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentCheckCell : UICollectionViewCell

@property (strong,nonatomic) UIImageView *faceImageView;
@property (strong,nonatomic) UILabel     *nameLabel;
@property (strong,nonatomic) UIImageView *coverImage;
@property (strong,nonatomic) UILabel     *sickLabel;
@property (strong,nonatomic) UIImageView *downImageView;
@property (assign,nonatomic) BOOL        isShowDownImage;

@end
