//
//  OneSubjectModel.m
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/6/20.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "OneSubjectModel.h"

@implementation OneSubjectModel

+ (instancetype)oneSubjectModelWithDict:(NSDictionary *)dict
{
     NSArray *arr = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", nil];
    OneSubjectModel *model = [[self alloc] init];
    model.content = dict[@"content"];
    model.videourl = dict[@"videourl"];
    model.explanation = dict[@"explanation"];
    model.level = [dict[@"level"] integerValue];
    // 填空题答案与选择题答案的处理
    NSLog(@"%@", [dict[@"answer"] JSONValue]);
    if([[dict[@"answer"] JSONValue] isKindOfClass:[NSArray class]]){
        NSArray *arr = @[@"①",@"②",@"③",@"④",@"⑤",@"⑥",@"⑦",@"⑧",@"⑨",@"⑩",@"⑪",@"⑫",@"⑬",@"⑭",@"⑮",@"⑯",@"⑰",@"⑱",@"⑲",@"⑳"];
        NSArray *tempArr = [dict[@"answer"] JSONValue];
        if ([[dict[@"answer"] JSONValue] isKindOfClass:[NSArray class]]) {
            NSString *tempStr = nil;
            NSInteger i = 0;
            for (NSString *b_answer in tempArr) {
                if (tempStr == nil) {
                    tempStr = [NSString stringWithFormat:@"%@%@",arr[i],b_answer];
                }else{
                    tempStr = [NSString stringWithFormat:@"%@\n%@%@", tempStr, arr[i], b_answer];
                }
                i++;
            }
            model.answer = tempStr;
        }
    }else{
    NSString *str = nil;
    if([dict[@"answer"] containsString:@"|"]){
    NSArray *answerArr = [dict[@"answer"] componentsSeparatedByString:@"|"];
    for(int j = 0; j < answerArr.count; j++){
        if (str == nil) {
            str = arr[[answerArr[j] integerValue]];
        }else{
            str = [NSString stringWithFormat:@"%@%@", str, arr[[answerArr[j] integerValue]]];
        }
        model.answer = str;
    }
    }else{
        NSInteger j = [dict[@"answer"] integerValue];
        model.answer = [NSString stringWithFormat:@"%@", arr[j]];
    }
    }
    model.t_id = [dict[@"id"] integerValue];
    return model;
}

- (CGFloat)secondCellHeight
{
    CGFloat cellHeight = 0;
    cellHeight += 30;
    
    if ([self.answer containsString:@"①"]){
           CGRect rect = [self.answer boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@
             {NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
            cellHeight += rect.size.height + 10;

    }else{
        cellHeight += 30;
    }
    return cellHeight;
}



@end
