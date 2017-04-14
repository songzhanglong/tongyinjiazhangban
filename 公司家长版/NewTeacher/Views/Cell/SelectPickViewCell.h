//
//  SelectPickViewCell.h
//  ChildrenKing
//
//  Created by songzhanglong on 15/3/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectPickViewCellDelegate <NSObject>

@optional
- (void)pickChangeContent:(NSString *)timer;

@end

@interface SelectPickViewCell : UITableViewCell

@property (nonatomic,assign)id<SelectPickViewCellDelegate> delegate;
@property (nonatomic,strong)UILabel *tipLabel;
@property (nonatomic,strong)UITextField *textField;

@end
