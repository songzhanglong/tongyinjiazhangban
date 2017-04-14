//
//  WaterfallLayout.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/6.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "WaterfallLayout.h"

@implementation WaterfallLayout
{
    BOOL _initStyle;
}

- (void)clearLayoutArrributes
{
    needNewStyle = YES;
    countForStyle = 0;
    style = 0;
    _contentSizeHeight = 0;
    
    nextStyleY = 5.0;
    
    self.allItemAttributes = [NSMutableArray array];
}

- (UICollectionViewLayoutAttributes *)lastAttributesFrom:(NSArray *)itemsAttributes Count:(NSInteger)lastCount
{
    NSInteger count = itemsAttributes.count;
    if (count >= lastCount) {
        return itemsAttributes[count - lastCount];
    }
    else
    {
        return _allItemAttributes[_allItemAttributes.count - (lastCount - count)];
    }
}

#pragma mark - Accessors
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        nextStyleY = 5.0;
        self.allItemAttributes = [NSMutableArray array];
        _nColomns = 2;
        _initStyle = YES;
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        nextStyleY = 5.0;
        self.allItemAttributes = [NSMutableArray array];
        _nColomns = 2;
        _initStyle = YES;
    }
    
    return self;
}

#pragma mark - 计算不同风格下的布局
- (CGRect)calculateFirstStyle:(NSArray *)itemsAttributes
{
    CGFloat contentWidth = self.collectionView.frame.size.width - 10;
    
    NSUInteger X = 0;
    NSUInteger Y = 0;
    
    NSUInteger min = contentWidth / (_nColomns + _nColomns - 1);
    
    CGFloat width = 0;
    CGFloat height = 0;
    if (countForStyle == 0) {
        X = 5;
        Y = nextStyleY;
        
        width = arc4random() % min + min;
        height = arc4random() % 30 + min;
    }
    else
    {
        UICollectionViewLayoutAttributes *attributes = [self lastAttributesFrom:itemsAttributes Count:1];
        CGRect lastFrame0 = attributes.frame;
        
        X = lastFrame0.origin.x + lastFrame0.size.width + 5.0;
        Y = lastFrame0.origin.y;
        height = lastFrame0.size.height;
        
        width = contentWidth - lastFrame0.size.width - 5.0;
        nextStyleY = Y + height + 5.0;
    }
    
    return CGRectMake(X, Y, width, height);
}

- (CGRect)calculateSecondStyle:(NSArray *)itemsAttributes
{
    CGFloat contentWidth = self.collectionView.frame.size.width - 10;
    
    NSUInteger X = 0;
    NSUInteger Y = 0;
    NSUInteger min = contentWidth / 3;
    CGFloat width = 0;
    CGFloat height = 0;
    if (countForStyle == 0) {
        X = 5;
        Y = nextStyleY;
        
        width = arc4random() % min + min;
        height = min * 2 + arc4random() % 60;
    }
    else if(countForStyle == 1)
    {
        UICollectionViewLayoutAttributes *attributes = [self lastAttributesFrom:itemsAttributes Count:1];
        CGRect lastFrame0 = attributes.frame;
        
        X = lastFrame0.origin.x + lastFrame0.size.width + 5.0;
        Y = lastFrame0.origin.y;
        height = arc4random() % 30 + min;
        width = contentWidth - lastFrame0.size.width - 5.0;
        nextStyleY = Y + height + 5.0;
    }
    else
    {
        UICollectionViewLayoutAttributes *attributes1 = [self lastAttributesFrom:itemsAttributes Count:2];
        UICollectionViewLayoutAttributes *attributes = [self lastAttributesFrom:itemsAttributes Count:1];
        CGRect lastFrame1 = attributes1.frame;
        CGRect lastFrame0 = attributes.frame;
        
        X = lastFrame0.origin.x;
        Y = lastFrame0.origin.y + lastFrame0.size.height + 5.0;
        width = lastFrame0.size.width;
        height = lastFrame1.size.height - lastFrame0.size.height - 5.0;
        nextStyleY = Y + height + 5.0;
    }
    
    return CGRectMake(X, Y, width, height);
}

- (CGRect)calculateThirdStyle:(NSArray *)itemsAttributes
{
    CGFloat contentWidth = self.collectionView.frame.size.width - 10;
    NSUInteger X = 0;
    NSUInteger Y = 0;
    NSUInteger min = contentWidth / (_nColomns + _nColomns - 1);
    
    CGFloat width = 0;
    CGFloat height = 0;
    if (countForStyle == 0) {
        X = 5;
        Y = nextStyleY;
        
        width = arc4random() % min + min;
        height = arc4random() % 30 + min;
    }
    else if(countForStyle == 1)
    {
        UICollectionViewLayoutAttributes *attributes = [self lastAttributesFrom:itemsAttributes Count:1];
        CGRect lastFrame0 = attributes.frame;
        
        X = lastFrame0.origin.x;
        Y = lastFrame0.origin.y + lastFrame0.size.height + 5.0;
        width = lastFrame0.size.width;
        height = arc4random() % 30 + min;
    }
    else
    {
        UICollectionViewLayoutAttributes *attributes1 = [self lastAttributesFrom:itemsAttributes Count:2];
        UICollectionViewLayoutAttributes *attributes = [self lastAttributesFrom:itemsAttributes Count:1];
        CGRect lastFrame1 = attributes1.frame;
        CGRect lastFrame0 = attributes.frame;
        
        X = lastFrame0.origin.x + lastFrame0.size.width + 5.0;
        Y = lastFrame1.origin.y;
        
        width = (contentWidth - lastFrame1.size.width - 5.0);
        height = lastFrame1.size.height + lastFrame0.size.height + 5.0;
        
        nextStyleY = Y + height + 5.0;
    }
    
    return CGRectMake(X, Y, width, height);
}

- (CGRect)calculateFourStyle:(NSArray *)itemsAttributes
{
    CGFloat contentWidth = self.collectionView.frame.size.width - 10;
    NSUInteger X = 0;
    NSUInteger Y = 0;
    NSUInteger min = contentWidth / 3;
    
    CGFloat width = 0;
    CGFloat height = 0;
    if (countForStyle == 0) {
        X = 5;
        Y = nextStyleY;
        
        width = arc4random() % min + min;
        height = arc4random() % 30 + min;
    }
    else if(countForStyle == 1)
    {
        UICollectionViewLayoutAttributes *attributes = [self lastAttributesFrom:itemsAttributes Count:1];
        CGRect lastFrame0 = attributes.frame;
        
        X = lastFrame0.origin.x;
        Y = lastFrame0.origin.y + lastFrame0.size.height + 5.0;
        
        width = lastFrame0.size.width;
        height = arc4random() % 30 + min;
    }
    else if(countForStyle == 2)
    {
        UICollectionViewLayoutAttributes *attributes1 = [self lastAttributesFrom:itemsAttributes Count:2];
        UICollectionViewLayoutAttributes *attributes = [self lastAttributesFrom:itemsAttributes Count:1];
        CGRect lastFrame1 = attributes1.frame;
        CGRect lastFrame0 = attributes.frame;
        
        X = lastFrame0.origin.x + lastFrame0.size.width + 5.0;
        Y = lastFrame1.origin.y;
        width = contentWidth - lastFrame1.size.width - 5.0;
        height = arc4random() % 30 + min;
        nextStyleY = Y + height + 5.0;
    }
    else
    {
        UICollectionViewLayoutAttributes *attributes2 = [self lastAttributesFrom:itemsAttributes Count:3];
        UICollectionViewLayoutAttributes *attributes1 = [self lastAttributesFrom:itemsAttributes Count:2];
        UICollectionViewLayoutAttributes *attributes = [self lastAttributesFrom:itemsAttributes Count:1];
        CGRect lastFrame2 = attributes2.frame;
        CGRect lastFrame1 = attributes1.frame;
        CGRect lastFrame0 = attributes.frame;
        
        X = lastFrame0.origin.x;
        Y = lastFrame0.origin.y + lastFrame0.size.height + 5.0;
        
        width = lastFrame0.size.width;
        height = lastFrame2.size.height + lastFrame1.size.height - lastFrame0.size.height;
        
        nextStyleY = Y + height + 5.0;
    }
    return CGRectMake(X, Y, width, height);
    
}

- (CGRect)calculateRectFrom:(NSArray *)itemsAttributes
{
    NSUInteger maxCount = 0;
    CGRect rect = CGRectZero;
    switch (style) {
        case 0:
        {
            maxCount = 2;
            rect = [self calculateFirstStyle:itemsAttributes];
        }
            break;
        case 1:
        {
            maxCount = 3;
            rect = [self calculateSecondStyle:itemsAttributes];
        }
            break;
        case 2:
        {
            maxCount = 3;
            rect = [self calculateThirdStyle:itemsAttributes];
        }
            break;
        case 3:
        {
            maxCount = 4;
            rect = [self calculateFourStyle:itemsAttributes];
        }
            break;
        default:
            break;
    }
    
    countForStyle++;
    if (countForStyle >= maxCount) {
        countForStyle = 0;
        needNewStyle = YES;
    }
    else
    {
        needNewStyle = NO;
    }
    
    return rect;
}

#pragma mark - first load
- (void)checkFirstLoad:(NSInteger)count
{
    if (_initStyle) {
        _initStyle = NO;
        if (count <= _nColomns) {
            style = 0;
        }
        else if (count == _nColomns + 1)
        {
            style = arc4random() % 2 + 1;
        }
        else if (count == _nColomns + 2)
        {
            style = 3;
        }
        else
        {
            style = arc4random() % (MIN(count, _nColomns + 2));//0, 1, 2, 3
        }
        
    }
}

#pragma mark - Methods to Override
- (void)prepareLayout
{
    [super prepareLayout];
    
    if (_groupLayout) {
        return;
    }
    
    UICollectionView *collectionView = [self collectionView];
    NSUInteger totalItemCount = [collectionView numberOfItemsInSection:0];
    if (totalItemCount == 0) {
        return;
    }
    
    NSUInteger start = _allItemAttributes.count;
    NSMutableArray *itemAttributes = [NSMutableArray array];
    [self checkFirstLoad:totalItemCount];
    
    for (NSInteger idx = start; idx < totalItemCount; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        CGRect rect = rect = [self calculateRectFrom:itemAttributes];
        attributes.frame = rect;
        if (rect.origin.y + rect.size.height >= _contentSizeHeight) {
            _contentSizeHeight = rect.origin.y + rect.size.height;
        }
        
        if (needNewStyle) {
            //剩余部分另分配风格
            NSUInteger remainder = totalItemCount - (idx - start) - 1;
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
    [_allItemAttributes addObjectsFromArray:itemAttributes];
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = self.collectionView.frame.size;
    contentSize.height = _contentSizeHeight + 5.0;
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _allItemAttributes[indexPath.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:_allItemAttributes];
    
    return muArr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

@end
