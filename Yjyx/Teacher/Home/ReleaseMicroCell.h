//
//  ReleaseMicroCell.h
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/6/27.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YjyxMicroWorkModel;
@interface ReleaseMicroCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundIV;

@property (strong, nonatomic) YjyxMicroWorkModel *model;
@end
