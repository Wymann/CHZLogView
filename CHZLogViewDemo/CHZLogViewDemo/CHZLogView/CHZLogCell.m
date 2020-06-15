//
//  CHZLogCell.m
//  CHZLogViewDemo
//
//  Created by OwenChen on 2020/6/12.
//  Copyright © 2020 CHZ. All rights reserved.
//

#import "CHZLogCell.h"

@interface CHZLogCell()

@property (nonatomic, strong) UILabel *textLab;

@end

@implementation CHZLogCell

-(void)setModel:(CHZLogModel *)model {
    _model = model;
    
    CGFloat textheight = [CHZLogCell textHeightWithAttributedText:_model.attributedString Width:CHZ_SCREEN_WIDTH - leftGap - rightGap - textLeftGap - textRightGap];
    CGRect newTextFrame = CGRectMake(textLeftGap, textTopGap, CHZ_SCREEN_WIDTH - leftGap - rightGap - textLeftGap - textRightGap, textheight);
    self.textLab.frame = newTextFrame;
    self.textLab.attributedText = _model.attributedString;
}

-(UILabel *)textLab {
    if (!_textLab) {
        _textLab = [[UILabel alloc] initWithFrame:CGRectMake(textLeftGap, textTopGap, CHZ_SCREEN_WIDTH - leftGap - rightGap - textLeftGap - textRightGap, 0)];
        _textLab.backgroundColor = [UIColor clearColor];
        _textLab.textColor = [UIColor whiteColor];
        _textLab.textAlignment = NSTextAlignmentLeft;
        _textLab.numberOfLines = 0;
        [self.contentView addSubview:_textLab];
        
        _textLab.userInteractionEnabled = YES;
        //初始化一个长按手势
        UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressView:)];
        //长按等待时间
        longPressGest.minimumPressDuration = 1;
        [_textLab addGestureRecognizer:longPressGest];
    }
    return _textLab;
}

//长按
- (void)longPressView:(UILongPressGestureRecognizer *)longPressRecognizer {
    if (longPressRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    if (self.model.log.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.model.log;
        
        if (self.pastBlock) {
            self.pastBlock();
        }
    }
}

//获取富文本高度
+ (CGFloat)textHeightWithAttributedText:(NSAttributedString *)attributted Width:(CGFloat)width {
    if(width<=0){
        return 0.0;
    }
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0,0, width, MAXFLOAT)];
    lab.attributedText = attributted;
    lab.numberOfLines =0;
    
    CGSize labSize = [lab sizeThatFits:lab.bounds.size];
    
    return labSize.height + 5.0;
}

@end
