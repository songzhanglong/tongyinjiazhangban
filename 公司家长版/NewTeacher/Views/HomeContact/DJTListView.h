//
//  DJTListView.h
//  TY
//
//  Created by songzhanglong on 14-6-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)

@protocol ListViewDelegate <NSObject>

@optional
- (void)selectData:(id)object IndexPath:(NSIndexPath *)indexPath;

@end

@interface DJTListView : UIView<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSArray *titleArray;
@property(nonatomic,assign)BOOL isExpand;
@property(nonatomic,assign)NSInteger  curIndex;
@property(nonatomic,assign)id<ListViewDelegate> delegate;
@property(nonatomic,strong)UIImageView *imageView;

- (void)setPSource:(NSArray *)pSource;

/**
 *	@brief	获取当前选择的数据源
 *
 *	@return	数据源
 */
- (id)getCurrentSelected;

@end
