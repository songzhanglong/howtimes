//
//  DecorateModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/6/2.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface DecorateModel : JSONModel

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *image_url;
@property (nonatomic,strong)NSString *label;

@end
