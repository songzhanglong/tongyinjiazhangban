//
//  SelectItemCell.m
//  ChildrenKing
//
//  Created by songzhanglong on 15/3/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectItemCell.h"
#import "DJTGlobalDefineKit.h"

@implementation SelectItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 11.5, 120, 21)];
        [self.contentView addSubview:_tipLabel];
        
        CGFloat itemHei = 20;//iPhone6Plus ? 35.0 : (iPhone6 ? 32 : 27);
        _itemView = [[SelectItemView alloc] initWithFrame:CGRectMake(180-20, (44 - itemHei) / 2, winSize.width - 200, itemHei)];
        //_itemView.nCurIndex = [_currSex isEqualToString:@"男"] ? 0 : 1;
        _itemView.delegate = self;
        [self.contentView addSubview:_itemView];
    }
    
    return self;
}
- (void)setCurrSex:(NSString *)currSex
{
    _itemView.nCurIndex = [currSex isEqualToString:@"男"] ? 0 : 1;
}
#pragma mark - SelectItemViewDelegate
- (void)changeSelectItem
{
    if (_delegate && [_delegate respondsToSelector:@selector(changeItemIndex:By:)]) {
        [_delegate changeItemIndex:self By:_itemView];
    }
}

@end
