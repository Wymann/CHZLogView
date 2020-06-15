//
//  CHZLogModel.h
//  CHZLogViewDemo
//
//  Created by OwenChen on 2020/6/12.
//  Copyright © 2020 CHZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CHZ_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width //手机屏幕宽
#define CHZ_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height //手机屏幕高
static const CGFloat dragWidth = 60.0;
static const CGFloat dragHeight = 60.0;
static const CGFloat bottomHeight = 250.0;
static const CGFloat toastHeight = 20.0;
static const CGFloat toastWidth = 80.0;
static const CGFloat topGap = 10.0;
static const CGFloat rightGap = 10.0;
static const CGFloat leftGap = 10.0;
static const CGFloat bottomGap = 10.0;

static const CGFloat textTopGap = 5.0;
static const CGFloat textRightGap = 10.0;
static const CGFloat textLeftGap = 10.0;
static const CGFloat textBottomGap = 0.0;

NS_ASSUME_NONNULL_BEGIN

@interface CHZLogModel : NSObject

@property (nonatomic, copy) NSString *log;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSAttributedString *attributedString;

@end

NS_ASSUME_NONNULL_END
