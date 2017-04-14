//
//  WaterfallLayout.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/6.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterfallLayout : UICollectionViewLayout
{
    CGFloat _contentSizeHeight;
    CGFloat nextStyleY;
    NSUInteger countForStyle;
    
    NSUInteger style;
    
    BOOL needNewStyle;
    
    NSUInteger _nColomns;
}

@property (nonatomic,assign)NSInteger itemCount;
@property (nonatomic,strong)NSMutableArray *columnHeights;
@property (nonatomic,strong)NSMutableArray *allItemAttributes;
@property (nonatomic,assign)BOOL groupLayout;

- (void)clearLayoutArrributes;

- (CGRect)calculateRectFrom:(NSArray *)itemsAttributes;

@end
