//
//  CookbookCell.m
//  NewTeacher
//
//  Created by mac on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CookbookCell.h"
#import "DJTGlobalManager.h"
#import "CookBookModel.h"

@implementation CookbookCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.frame = CGRectMake((self.contentView.bounds.size.width-103)/2, 15, 103, 29.5);
        [editButton setBackgroundImage:[UIImage imageNamed:@"sp6.png"] forState:UIControlStateNormal];
        [editButton setTitle:@"暂无食谱" forState:UIControlStateNormal];
        [editButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:editButton];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 200, 25)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 200, 25)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.numberOfLines = 0;
        [self.contentView addSubview:contentLabel];
    }
    return self;
}

- (void)resetClassCookbookData:(id)object isHidden:(BOOL)hidden
{
    CookBookItem *item = (CookBookItem *)object;
    if ([item.teacher_id length] > 0) {
        editButton.hidden = YES;
        nameLabel.hidden = NO;
        contentLabel.hidden = NO;
        
        nameLabel.frame = CGRectMake(20, 0, item.nameSize.width+10, 20+item.nameSize.height);
        nameLabel.text = [NSString stringWithFormat:@"%@:",item.name];
        
        contentLabel.frame = CGRectMake(20+item.nameSize.width+10, 0, [UIScreen mainScreen].bounds.size.width-40-item.nameSize.width, 20+MAX(item.nameSize.height, item.contentSize.height));
        contentLabel.text = item.content;
    }else{
        editButton.hidden = NO;
        nameLabel.hidden = YES;
        contentLabel.hidden = YES;
    }
    
    //nameLabel.hidden = !hidden;
    //if (hidden) {
    
    //}
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
