//
//  SelectMileageView.h
//  NewTeacher
//
//  Created by szl on 16/1/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectMileageViewDelegate <NSObject>

@optional
- (void)selectMileageAt:(NSInteger)index;
- (void)selectButtonAt:(NSInteger)index;

@end

@interface SelectMileageView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign)id<SelectMileageViewDelegate> delegate;
@property (nonatomic,strong)NSArray *dataSource;
@property (nonatomic,strong)NSString *selectedAlbumId;

- (void)showInView:(UIView *)view;

- (id)initWithFrame:(CGRect)frame Hei:(CGFloat)hei;

@end
