//
//  CHZLogCell.h
//  CHZLogViewDemo
//
//  Created by OwenChen on 2020/6/12.
//  Copyright © 2020 CHZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHZLogModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^PastBlock)(void);

@interface CHZLogCell : UITableViewCell

@property (nonatomic, strong) CHZLogModel *model;
@property (nonatomic, copy) PastBlock pastBlock;

/**
 获取富文本高度
 
 @param attributted 需要操作的富文本
 @param width 宽度
 @return 计算出的富文本高度
 */
+ (CGFloat)textHeightWithAttributedText:(NSAttributedString *)attributted Width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
