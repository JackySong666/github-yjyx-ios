//
//  StudentEntity.h
//  Yjyx
//
//  Created by  yjyx-ios1 on 16/5/4.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentEntity : NSObject

@property (nonatomic, copy) NSString *avatar_url;// 头像
@property (nonatomic, strong) NSNumber *user_id;// 学生ID
@property (nonatomic, copy) NSString *realname;// 学生真实姓名

@property (nonatomic, strong) NSNumber *isyjmember;// 是否是会员

@property (assign, nonatomic) BOOL isSelect;
- (void)initStudentWithDic:(NSDictionary *)dic;

@end
