//
//  CHZLogModel.m
//  CHZLogViewDemo
//
//  Created by OwenChen on 2020/6/12.
//  Copyright © 2020 CHZ. All rights reserved.
//

#import "CHZLogModel.h"

@implementation CHZLogModel

-(void)setLog:(NSString *)log {
    _log = log;
    [self createAttributedString];
}

-(void)setColor:(UIColor *)color {
    _color = color ? color : [UIColor whiteColor];
    [self createAttributedString];
}

- (void)createAttributedString {
    if (_log.length > 0 && _color) {
        NSMutableAttributedString *addAttString = [[NSMutableAttributedString alloc] initWithString:_log];
        [addAttString addAttribute:NSForegroundColorAttributeName value:_color range:NSMakeRange(0, _log.length)];
        [addAttString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, 19)];
        [addAttString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, _log.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 3;// 字体的行间距
        [addAttString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _log.length)];
        _attributedString = [addAttString copy];
    }
}

@end
