//
//  DJTTableViewVC.h
//  TY
//
//  Created by songzhanglong on 14-5-28.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"
#import "MWPhotoBrowser.h"

@interface DJTTableViewController : DJTBaseViewController<MWPhotoBrowserDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    UITableView *_tableView;
    UICollectionView *_collectionView;
    NSMutableArray *_browserPhotos;
}

@property (nonatomic,retain)NSString *action;       //请求接口
@property (nonatomic,retain)NSDictionary *param;    //请求参数
@property (nonatomic,strong)id dataSource;
@property (nonatomic,assign)BOOL useNewInterface;   //使用新接口

/**
 *	@brief	创建表和网络请求
 *
 *	@param 	action 	接口动作类型
 *	@param 	param 	接口参数
 *	@param 	header 	下拉
 *	@param 	foot 	上拉
 */
- (void)createTableViewAndRequestAction:(NSString *)action Param:(NSDictionary *)param Header:(BOOL)header Foot:(BOOL)foot;

- (void)createCollectionViewLayout:(UICollectionViewLayout *)layout Action:(NSString *)action Param:(NSDictionary *)param Header:(BOOL)header Foot:(BOOL)foot;

/**
 *	@brief	开始刷新
 */
- (void)beginRefresh;

- (BOOL)isRefreshing;

/**
 *	@brief	开始刷新
 */
- (void)startPullRefresh;
- (void)startPullRefresh2;  //上拉

/**
 *	@brief	结束下拉刷新
 */
- (void)finishRefresh;

/**
 *	@brief	清除刷新试图
 */

#pragma mark - 网络请求结束
/**
 *	@brief	数据请求结果
 *
 *	@param 	success 	yes－成功
 *	@param 	result 	服务器返回数据
 */
- (void)requestFinish:(BOOL)success Data:(id)result;
- (void)requestFinish2:(BOOL)success Data:(id)result;   //上拉

@end
