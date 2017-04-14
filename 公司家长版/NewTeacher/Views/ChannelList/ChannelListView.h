//
//  ChannelListView.h
//  NewTeacher
//
//  Created by szl on 16/4/21.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChannelListDelegate <NSObject>

@optional
- (void)channelViewSelectAt:(NSInteger)index;

@end

@interface ChannelListView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign)id<ChannelListDelegate> delegate;
@property (nonatomic,strong)NSArray *dataSource;
@property (nonatomic,assign)NSInteger curIdx;

- (id)initWithFrame:(CGRect)frame TabHei:(CGFloat)hei;

- (void)showInView;
- (void)hiddenInView;

@end
