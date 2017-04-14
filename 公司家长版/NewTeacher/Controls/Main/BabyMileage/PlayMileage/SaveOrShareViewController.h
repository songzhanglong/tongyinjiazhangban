//
//  SaveOrShareViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/4/1.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"
#import "GrowAlbumListItem.h"

@interface SaveOrShareViewController : DJTBaseViewController

@property (nonatomic, strong) NSString *album_id;
@property (nonatomic, strong) NSString *theme_id;
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSString *shareName;
@property (nonatomic, strong) GrowAlbumListItem *albumItem;
@end
