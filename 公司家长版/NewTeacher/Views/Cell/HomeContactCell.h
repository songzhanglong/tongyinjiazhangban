//
//  HomeContactCell.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeContactCell : UICollectionViewCell
@property (nonatomic,retain) UIImageView    *faceImageView;
@property (nonatomic,retain) UILabel        *nameLabel;
@property (nonatomic,retain) UIImageView    *coverImage;
@property (nonatomic,retain) UILabel        *sickLabel;
@property (nonatomic,retain) UIImageView    *downImageView;
@property (nonatomic,assign) BOOL           isShowDownImage;
@end
