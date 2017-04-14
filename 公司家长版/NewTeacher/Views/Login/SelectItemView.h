//
//  SelectItemView.h
//  ChildrenKing
//
//  Created by songzhanglong on 15/3/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectItemViewDelegate <NSObject>

@optional
- (void)changeSelectItem;

@end

@interface SelectItemView : UIView

@property (nonatomic,assign)id<SelectItemViewDelegate> delegate;
@property (nonatomic,assign)NSInteger nCurIndex;

- (void)setItems:(NSArray *)array;

@end
