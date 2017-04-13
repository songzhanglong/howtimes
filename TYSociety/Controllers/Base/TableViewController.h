//
//  DJTTableViewVC.h
//  TY
//
//  Created by songzhanglong on 14-5-28.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "BaseViewController.h"
#import "MJRefresh.h"
#import "MJChiBaoZiHeader.h"
#import "MJChiBaoZiFooter2.h"
#import "Toast+UIView.h"

@interface TableViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong)id dataSource;
@property (nonatomic,strong)NSString *action;       //请求接口
@property (nonatomic,strong)NSDictionary *param;    //请求参数
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,assign)BOOL silentAnimation;   //静默加载动画

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

#pragma mark - 上下拉刷新
/**
 *	@brief	开始刷新
 */
- (void)beginRefresh;

/**
 *	@brief	开始刷新
 */
- (void)startPullRefresh;
- (void)startPullRefresh2;

/**
 *	@brief	结束下拉刷新
 */
- (void)finishRefresh;

- (BOOL)isRefreshing;

#pragma mark - 网络请求结束
/**
 *	@brief	数据请求结果
 *
 *	@param 	success 	yes－成功
 *	@param 	result 	服务器返回数据
 */
- (void)requestFinish:(NSError *)error Data:(id)result;
- (void)requestFinish2:(NSError *)error Data:(id)result;

#pragma mark - 动画停止
- (void)startAnimation;
- (void)stopAnimation;

@end
