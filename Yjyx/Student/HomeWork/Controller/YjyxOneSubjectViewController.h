//
//  YjyxOneSubjectViewController.h
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/7/5.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YjyxOneSubjectViewController : UITableViewController

@property (strong, nonatomic) NSString *navTitle;
@property (strong, nonatomic) NSNumber *subjectid;

@property (assign, nonatomic) NSInteger isFinished; // 1代表昨晚作业回来
@end
