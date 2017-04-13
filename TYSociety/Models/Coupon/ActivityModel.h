//
//  activityModel.h
//  TYSociety
//
//  Created by zhangxs on 16/8/8.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ActivityModel : JSONModel

@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *active_name;
@property (nonatomic,strong)NSString *user_nums;
@property (nonatomic,strong)NSString *end_time;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *start_time;
@property (nonatomic,strong)NSString *active_pic;
@property (nonatomic,strong)NSString *url;

@end
