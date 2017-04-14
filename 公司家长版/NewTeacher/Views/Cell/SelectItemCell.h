//
//  SelectItemCell.h
//  ChildrenKing
//
//  Created by songzhanglong on 15/3/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectItemView.h"

@class SelectItemCell;
@protocol SelectItemCellDelegate <NSObject>

@optional
- (void)changeItemIndex:(SelectItemCell *)cell By:(SelectItemView *)itemView;

@end

@interface SelectItemCell : UITableViewCell<SelectItemViewDelegate>

@property (nonatomic,assign)id<SelectItemCellDelegate> delegate;
@property (nonatomic,strong)SelectItemView *itemView;
@property (nonatomic,strong)UILabel *tipLabel;
@property (nonatomic,strong)NSString *currSex;
@end
