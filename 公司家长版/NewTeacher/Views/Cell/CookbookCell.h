//
//  CookbookCell.h
//  NewTeacher
//
//  Created by mac on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CookbookCell;

@interface CookbookCell : UITableViewCell
{
    UIButton *editButton;
    
    UILabel *nameLabel;
    
    UILabel *contentLabel;
}

- (void)resetClassCookbookData:(id)object isHidden:(BOOL)hidden;
@end
