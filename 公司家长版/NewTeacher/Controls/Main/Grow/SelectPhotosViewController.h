//
//  SelectPhotosViewController.h
//  NewTeacher
//
//  Created by szl on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@protocol SelectPhotosViewControllerDelegate <NSObject>

@optional
- (void)selectPhotosImages:(NSArray *)images;

@end

@interface SelectPhotosViewController : DJTTableViewController

@property (nonatomic,assign)NSInteger nMaxCount;
@property (nonatomic,assign)id<SelectPhotosViewControllerDelegate> delegate;
@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *buttonTitle;
@property (nonatomic,strong)NSArray *selectArray;
@property (nonatomic,assign)CGFloat minWei;
@property (nonatomic,assign)CGFloat minHei;
@property (nonatomic,assign)BOOL isSmallPicLimit;

- (void)backToPreControl:(id)sender;

@end
