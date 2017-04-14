//
//  ResuableImageViews.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColleagueImageViewDelegate <NSObject>

@optional
- (void)clickedImageWithIndex:(NSInteger)index;
-(void)clickedMorePicture;

@end

@interface ResuableImageViews : UIView
{
    NSInteger _nMaxCount;
}
@property (nonatomic,strong)UIButton *morePicture;
@property (nonatomic,assign)id<ColleagueImageViewDelegate> delegate;
@property (nonatomic,strong)NSArray *images;
@property (nonatomic,strong)NSString *type;     //0-图片，1-视频
@property (nonatomic,assign)CGFloat changeMargin;

@end
