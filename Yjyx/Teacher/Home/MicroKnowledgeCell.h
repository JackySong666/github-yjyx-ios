//
//  MicroKnowledgeCell.h
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/6/25.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MicroDetailModel, YjyxMicroWorkModel;
@interface MicroKnowledgeCell : UITableViewCell

@property (strong, nonatomic) MicroDetailModel *model;

@property (strong, nonatomic) YjyxMicroWorkModel *workModel;
@end
