//
//  TeacherEntity.h
//  Yjyx
//
//  Created by  yjyx-ios1 on 16/4/23.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeacherEntity : NSObject

@property (nonatomic, copy) NSString *phone;// 电话
@property (nonatomic, copy) NSString *coins;// 积分
@property (nonatomic, copy) NSString *avatar;// 头像
@property (nonatomic, copy) NSString *birth;// 生日
@property (nonatomic, copy) NSString *address;// 地址
@property (nonatomic, copy) NSString *email;//邮箱
@property (nonatomic, copy) NSString *name;// 姓名
@property (nonatomic, copy) NSString *age;// 年龄
@property (nonatomic, copy) NSString *sessionid;


@property (nonatomic, copy) NSString *school_province;// 省份
@property (nonatomic, copy) NSString *school_city;// 城市
@property (nonatomic, copy) NSString *school_district;// 区
@property (nonatomic, copy) NSString *school_name;// 学校名称
@property (nonatomic, copy) NSString *school_id;
@property (nonatomic, copy) NSString *school_typeid;// 判断是否是重点中学
@property (nonatomic, copy) NSString *school_typename;// 重点
@property (nonatomic, copy) NSString *school_classes;// 班级


@property (nonatomic, copy) NSString *receive_notify;// 是否接收通知
@property (nonatomic, copy) NSString *notify_with_sound;// 是否有提示音
@property (nonatomic, copy) NSString *notify_sound;// 提示音标识
@property (nonatomic, copy) NSString *notify_shake;// 是否有震动


+ (TeacherEntity *)wrapTeacherWithDic:(NSDictionary *)dic;

@end
