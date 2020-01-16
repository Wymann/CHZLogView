//
//  CHZLogView.h
//  TclIntelliCom
//
//  Created by Wymann Chan on 2019/4/28.
//  Copyright © 2019 tcl. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APPLogWithFormat(log, ...) dispatch_async(dispatch_get_main_queue(), ^{[[CHZLogView sharedLogView] logWithFormat:log, ##__VA_ARGS__];});

@interface CHZLogView : UIView

/// 单例
+ (CHZLogView *)sharedLogView;

/// 初始化
/// @param open 初始化时候是否展开
- (instancetype)initWithOpen:(BOOL)open;

/// 输入日志
/// @param text 日志
/// @param color 日志颜色
- (void)inputText:(NSString *)text color:(UIColor *)color;

/// 输入日志
/// @param object 日志
/// @param color 颜色
- (void)inputObject:(id)object color:(UIColor *)color;

/// 清空日志
- (void)clearLog;

/// 关闭CHZLogView
- (void)closeLogView;

/// 输入日志
/// @param object 日志
- (void)logObject:(id)object;

/// 输入日志format
/// @param format format
- (void)logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

@end
