//
//  YjxService.m
//  yijiaoyixue
//
//  Created by zhujianyu on 16/2/1.
//  Copyright © 2016年 zhujianyu. All rights reserved.
//

#import "YjxService.h"
@implementation YjxService

+ (instancetype)sharedInstance{
    //xs 单例化创建修改 , 普通那样创建的话多线程下是不安全的
    static YjxService * instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[YjxService alloc] init];
    });
    return instance;
}

//文件传输接口  青牛云
-(void)getAboutqinniu:(NSDictionary*)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/qiniu/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
}

//上报家长头像
-(void)uploadFile:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager POST:[BaseURL stringByAppendingString:@"/api/teacher/avatar/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
   
}

/*家长相关接口*/

//邀请码验证
-(void)registcheckcode:(NSDictionary*)params withBlock:(void(^)(id result, NSError *error))block
{
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[BaseURL stringByAppendingString:@"/api/parents/register/?action=checkcode"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
}

//家长注册
-(void)parentsRegist:(NSDictionary*)params withBlock:(void(^)(id result,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[BaseURL stringByAppendingString:@"/api/parents/register/?action=submit"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[responseObject objectForKey:@"sessionid"] forKey:@"SessionID"];
            [defaults synchronize];
        }else{
            block(nil,nil);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

//家长登录
-(void)parentsLogin:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[BaseURL stringByAppendingString:@"/api/parents/login/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[responseObject objectForKey:@"sessionid"] forKey:@"SessionID"];
            [defaults synchronize];

        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

//家长添加小孩时验证码验证
-(void)parentsAboutChildrenSetting:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))blocK
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager POST:[BaseURL stringByAppendingString:@"/api/parents/setting/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            blocK(responseObject,nil);
        }else{
            blocK(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        blocK(nil,error);
    }];
    
}


//家长登出
-(void)parentsLoginout:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager POST:[BaseURL stringByAppendingString:@"/api/parents/logout/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

//获取孩子动态
-(void)getchildrenActivity:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    NSLog(@"SESSIONID == %@",SESSIONID);
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/children/activity/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
}

//题目统计
-(void)getChildrenachievement:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/children/statistic/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
}


//获取小孩作业结构
-(void)getChildrenTaskResult:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/children/taskresult/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

//获取小孩作业预览
-(void)getChildrenPreviewResult:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/previewtask/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
    
}

//会员中心，商品列表
-(void)getProductList:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/product/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
}

//查看小孩对某一学科会员的状态
-(void)getsubjectStatus:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/product/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

//小孩试用某个会员产品
-(void)trialProduct:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager POST:[BaseURL stringByAppendingString:@"/api/parents/product/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
}

//获取单个会员商品详情
-(void)getOneMemberProduct:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/product/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];
}

//学生购买某个会员产品
-(void)purchaseProduct:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager POST:[BaseURL stringByAppendingString:@"/api/parents/product/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

-(void)isCanLookProduct:(NSDictionary *)params withBlock:(void(^)(id result, NSError *error))block;
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/parents/product/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

-(void)getSMSsendcode:(NSDictionary *)params withBlock:(void(^)(id result,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/sms/sendcode/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

-(void)checkOutVerfirycode:(NSDictionary *)params withBlock:(void(^)(id result,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager GET:[BaseURL stringByAppendingString:@"/api/sms/checkcode/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

-(void)getRestpasswordSms:(NSDictionary *)params withBlock:(void(^)(id result,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[BaseURL stringByAppendingString:@"/api/utils/password/get_reset_password_sms/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

-(void)restPassWord:(NSDictionary *)params withBlock:(void(^)(id result,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager POST:[BaseURL stringByAppendingString:@"/api/utils/password/reset_password/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

-(void)getUserPhone:(NSDictionary *)params withBlock:(void(^)(id result,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[BaseURL stringByAppendingString:@"/api/utils/password/get_user_phone/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

//用户反馈
-(void)feedBack:(NSDictionary *)params withBlock:(void(^)(id result,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:SESSIONID  forHTTPHeaderField:@"sessionid"];
    [manager POST:[BaseURL stringByAppendingString:@"/api/feedback/"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            block(responseObject,nil);
        }else{
            block(nil,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        block(nil,error);
    }];

}

@end
