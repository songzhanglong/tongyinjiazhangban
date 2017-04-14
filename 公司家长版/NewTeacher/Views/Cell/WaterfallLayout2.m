//
//  WaterfallLayout2.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/27.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "WaterfallLayout2.h"

@interface WaterfallLayout2 ()

@end

@implementation WaterfallLayout2

#pragma mark - Accessors
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.groupLayout = YES;
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.groupLayout = YES;
    }
    
    return self;
}

#pragma mark - Methods to Override
- (void)prepareLayout
{
    [super prepareLayout];
    
    UICollectionView *collectionView = [self collectionView];
    
    NSUInteger sections = [collectionView numberOfSections];
    for (NSInteger i = 0; i < sections; i++) {
        UICollectionViewLayoutAttributes *sectionAtt = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
        sectionAtt.frame = CGRectMake(0, _contentSizeHeight, collectionView.frame.size.width, 20);
        [self.allItemAttributes addObject:sectionAtt];
        
        nextStyleY = 25 + _contentSizeHeight;
        
        NSUInteger totalItemCount = [collectionView numberOfItemsInSection:i];
        if (totalItemCount == 0) {
            continue;
        }
        
        countForStyle = 0;
        //新风格
        if (totalItemCount <= _nColomns) {
            style = 0;
        }
        else if (totalItemCount == _nColomns + 1)
        {
            style = arc4random() % 2 + 1;
        }
        else if (totalItemCount == _nColomns + 2)
        {
            style = 3;
        }
        else
        {
            style = arc4random() % (MIN(totalItemCount, _nColomns + 2));//0, 1, 2, 3
        }
        
        NSMutableArray *itemAttributes = [NSMutableArray array];
        for (NSInteger j = 0; j < totalItemCount; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            CGRect rect = [self calculateRectFrom:itemAttributes];
            attributes.frame = rect;
            if (rect.origin.y + rect.size.height >= _contentSizeHeight) {
                _contentSizeHeight = rect.origin.y + rect.size.height + 5;
            }
            
            if (j == totalItemCount - 1) {
                countForStyle = 0;
            }
            
            if (needNewStyle) {
                //剩余部分另分配风格
                NSUInteger remainder = totalItemCount - j - 1;
                if (remainder <= _nColomns) {
                    style = 0;
                }
                else if (remainder == _nColomns + 1)
                {
                    style = arc4random() % 2 + 1;
                }
                else if (remainder == _nColomns + 2)
                {
                    style = 3;
                }
                else
                {
                    NSUInteger originStyle = style;
                    style = arc4random() % (MIN(remainder, _nColomns + 2));//0, 1, 2, 3
                    //连续两个避免相同
                    if (originStyle == style) {
                        if (style >= 1) {
                            style--;
                        }
                        else
                        {
                            style = _nColomns + 1;
                        }
                    }
                }
            }
            [itemAttributes addObject:attributes];
        }
        [self.allItemAttributes addObjectsFromArray:itemAttributes];
    }
}

@end
