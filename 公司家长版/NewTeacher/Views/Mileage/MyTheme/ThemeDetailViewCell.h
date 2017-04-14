//
//  ThemeDetailViewCell.h
//  NewTeacher
//
//  Created by szl on 15/12/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeDetailViewCell : UITableViewCell

@property (nonatomic,strong)UIView *backView;

- (void)resetReplyDetail:(id)object;

- (void)resetHead:(NSString *)url Name:(NSString *)name Time:(NSString *)time Con:(NSString *)content Hei:(CGFloat)hei;

@end
