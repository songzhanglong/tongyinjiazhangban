//
//  ChannelModel.h
//  NewTeacher
//
//  Created by szl on 16/5/13.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface PowerOpen : JSONModel

@property (nonatomic,strong)NSString *open_time;
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSNumber *is_valid; //1-open,0-close

@end

@interface ChannelModel : NSObject

@property (nonatomic,strong)NSString *name;
@property (nonatomic,assign)int nodeIdx;
@property (nonatomic,strong)NSString *open_time;
@property (nonatomic,strong)NSNumber *is_valid; //1-open,0-close

@end
