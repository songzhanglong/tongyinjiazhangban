//
//  DJTparentView.h
//  GoOnBaby
//
//  Created by zl on 14-5-22.
//  Copyright (c) 2014年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Guardian;
@protocol GuardianDelegate <NSObject>

@optional
/**
 *	@brief	委托
 *
 *	@param 	guardian 	对象视图
 *	@param 	index 	索引 0-关闭,1-发消息,2-打电话
 */
-(void)contactGrardian:(Guardian *)guardian Item:(NSInteger)index;

@end

@interface Guardian : UIView
@property (nonatomic, assign) id<GuardianDelegate>delegate;

@property (weak, nonatomic) IBOutlet UILabel *parentLabel;
@property (weak, nonatomic) IBOutlet UILabel *relationLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;

- (IBAction)buttonPressed:(id)sender;


@end
