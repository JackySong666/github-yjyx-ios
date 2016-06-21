//
//  YjyxWrongSubModel.m
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/6/20.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "YjyxWrongSubModel.h"
#import "RCLabel.h"
@implementation YjyxWrongSubModel

+ (instancetype)wrongSubjectModelWithDict:(NSDictionary *)dict
{
   NSArray *arr = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", nil];
    YjyxWrongSubModel  *model = [[self alloc] init];
    NSInteger i = [dict[@"answer"] integerValue];
    NSString *str = nil;
    if([dict[@"answer"] containsString:@"|"]){
    NSArray *answerArr = [dict[@"answer"] componentsSeparatedByString:@"|"];
    
    for(int j = 0; j < answerArr.count; j++){
        if (str == nil) {
            str = arr[[answerArr[i] integerValue] ];
        }else{
            str = [NSString stringWithFormat:@"%@%@", str, arr[[answerArr[i] integerValue]]];
        }
        
    }
        model.answer = str;
    }else{
        NSInteger j = [dict[@"answer"] integerValue];
        model.answer = [NSString stringWithFormat:@"%@", arr[j]];
    }
    
    model.content = dict[@"content"];
    model.t_id = [dict[@"id"] integerValue];
    model.level = [dict[@"level"] integerValue];
    model.questionid = [dict[@"questionid"] integerValue];
    model.questiontype = [dict[@"questiontype"] integerValue];
    model.total_wrong_num = [NSString stringWithFormat:@"%@次", dict[@"total_wrong_num"]];
    
    return model;
}

- (CGFloat)cellHeight
{
    CGFloat cellHeight = 0;
    cellHeight += 30;
    NSString *content = self.content;
    content = [content stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    RCLabel *templabel = [[RCLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 999)];
    templabel.userInteractionEnabled = NO;
    templabel.font = [UIFont systemFontOfSize:14];
    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:content];
    templabel.componentsAndPlainText = componentsDS;
    CGSize optimalSize = [templabel optimumSize];
    cellHeight += optimalSize.height;
    self.cellFrame = CGRectMake(2, 2, optimalSize.width, optimalSize.height);
    cellHeight += 60;
    return cellHeight + 10;
}

@end
