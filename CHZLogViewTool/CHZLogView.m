//
//  CHZLogView.m
//  TclIntelliCom
//
//  Created by Wymann Chan on 2019/4/28.
//  Copyright © 2019 tcl. All rights reserved.
//

#import "CHZLogView.h"
#import "WMDragView.h"

#define CHZ_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width //手机屏幕宽
#define CHZ_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height //手机屏幕高
static const CGFloat dragWidth = 60.0;
static const CGFloat dragHeight = 60.0;
static const CGFloat bottomHeight = 250.0;
static const CGFloat topGap = 10.0;
static const CGFloat rightGap = 10.0;
static const CGFloat leftGap = 10.0;
static const CGFloat bottomGap = 10.0;

@interface CHZLogView()

@property (nonatomic) BOOL firstInput;
@property (nonatomic, strong) WMDragView *dragView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic) CGRect bottomFrame;
@property (nonatomic) CGRect textViewFrame;
@property (nonatomic, strong) NSMutableArray <NSString *>*logArray;

@end

static CHZLogView *sharedPointer = nil;

@implementation CHZLogView
{
    BOOL isOpen;
}

+ (CHZLogView *)sharedLogView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPointer = [[CHZLogView alloc] initWithOpen:YES];
    });
    return sharedPointer;
}

- (instancetype)initWithOpen:(BOOL)open
{
    self = [super init];
    if (self) {
        isOpen = open;
        _firstInput = YES;
        [self configData];
        [self setUI];
    }
    return self;
}

#pragma mark - setUI
- (void)configData {
    CGFloat fixHeight;
    if (@available(iOS 11.0, *)) {
        CGFloat a =  [[UIApplication sharedApplication].windows firstObject].safeAreaInsets.bottom;
        if (a > 0) {
            fixHeight = 34.0;
        } else {
            fixHeight = 0.0;
        }
    } else {
        fixHeight = 0;
    }
    _bottomFrame = CGRectMake(0, CHZ_SCREEN_HEIGHT - bottomHeight - fixHeight, CHZ_SCREEN_WIDTH, bottomHeight + fixHeight);
    _textViewFrame = CGRectMake(leftGap, topGap, CHZ_SCREEN_WIDTH - leftGap - rightGap, CGRectGetHeight(self.bottomFrame) - topGap - fixHeight - bottomGap);
}

- (void)setUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dragView.isKeepBounds = YES;
        [self bottomView];
    });
}

#pragma mark - 懒加载
-(WMDragView *)dragView {
    if (!_dragView) {
        _dragView = [[WMDragView alloc] initWithFrame:CGRectMake(CHZ_SCREEN_WIDTH - dragWidth, (CHZ_SCREEN_HEIGHT - dragHeight)/2, dragWidth, dragHeight)];
        _dragView.button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_dragView.button setTitle:@"ON" forState:UIControlStateNormal];
        [_dragView.button setTitle:@"OFF" forState:UIControlStateSelected];
        _dragView.button.selected = isOpen;
        _dragView.layer.cornerRadius = 5.0;
        _dragView.isKeepBounds = YES;
        _dragView.backgroundColor = [UIColor colorWithRed:40/255 green:43/255 blue:53/255 alpha:0.8];
        UIView *keyView;
        if (@available(iOS 13.0, *)) {
            keyView = [[UIApplication sharedApplication].windows firstObject];
        } else {
            keyView = [UIApplication sharedApplication].keyWindow;
        }
        [keyView addSubview:_dragView];
        
        __weak typeof (self)weakself = self;
        _dragView.clickDragViewBlock = ^(WMDragView *dragView){
            dragView.button.selected = !dragView.button.selected;
            if (dragView.button.selected) {
                [weakself openLog];
            } else {
                [weakself closeLog];
            }
        };
        
        _dragView.longPressBlock = ^(WMDragView *dragView) {
            [weakself closeLogView];
        };
    }
    
    return _dragView;
}

-(UIView *)bottomView {
    if (!_bottomView) {
        if (isOpen) {
            _bottomView = [[UIView alloc] initWithFrame:_bottomFrame];
            _bottomView.alpha = 1;
        } else {
            _bottomView = [[UIView alloc] initWithFrame:self.dragView.frame];
            _bottomView.alpha = 0;
        }
        _bottomView.backgroundColor = [UIColor colorWithRed:40/255 green:43/255 blue:53/255 alpha:0.6];
        _bottomView.layer.cornerRadius = 5.0;
        _bottomView.clipsToBounds = YES;
        UIView *keyView;
        if (@available(iOS 13.0, *)) {
            keyView = [[UIApplication sharedApplication].windows firstObject];
        } else {
            keyView = [UIApplication sharedApplication].keyWindow;
        }
        [keyView addSubview:_bottomView];
        
        _logTextView = [[UITextView alloc] initWithFrame:_textViewFrame];
        _logTextView.layoutManager.allowsNonContiguousLayout = NO;
        _logTextView.backgroundColor = _bottomView.backgroundColor;
        _logTextView.textColor = [UIColor whiteColor];
        _logTextView.editable = NO;
        _logTextView.alwaysBounceVertical = YES;
        _logTextView.layer.cornerRadius = 5.0;
        _logTextView.clipsToBounds = YES;
        [_bottomView addSubview:_logTextView];
        _bottomView.clipsToBounds = YES;
        
        //双击清空日志
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] init];
        tapGest.numberOfTapsRequired = 2;
        [_logTextView addGestureRecognizer:tapGest];
        [tapGest addTarget:self action:@selector(clearLog)];
        
        [keyView bringSubviewToFront:self.dragView];
    }
    
    return _bottomView;
}

-(NSMutableArray<NSString *> *)logArray {
    if (!_logArray) {
        _logArray = [NSMutableArray array];
    }
    return _logArray;
}

#pragma mark - methods
- (void)openLog {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomView.frame = self.dragView.frame;
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomView.alpha = 1.0;
            self.bottomView.frame = self.bottomFrame;
        }];
    });
}

- (void)closeLog {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomView.alpha = 0.0;
            self.bottomView.frame = self.dragView.frame;
        }];
    });
}

- (void)inputText:(NSString *)text color:(UIColor *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self->_dragView) {
            self.dragView.isKeepBounds = YES;
            [self bottomView];
        }
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithAttributedString:self->_logTextView.attributedText];
        
        NSString *string;
        if (self.firstInput) {
            string = [NSString stringWithFormat:@"Welcome to CHZLogView\n\n%@\n%@",[self currentTimeString] , text];
        } else {
            string = [NSString stringWithFormat:@"\n%@\n%@",[self currentTimeString] , text];
        }
        
        [self.logArray addObject:string];
        
        NSMutableAttributedString *addAttString = [[NSMutableAttributedString alloc] initWithString:string];
        UIColor *addColor = color ? color : [UIColor whiteColor];
        [addAttString addAttribute:NSForegroundColorAttributeName value:addColor range:NSMakeRange(0, string.length)];
        if (self.firstInput) {
            [addAttString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:[string rangeOfString:@"Welcome to CHZLogView"]];
            self.firstInput = NO;
        }
        [addAttString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, string.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 3;// 字体的行间距
        [addAttString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
        
        [attString appendAttributedString:addAttString];
        self.logTextView.attributedText = attString;
        
        [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.text.length, 1)];
    });
}

- (void)inputObject:(id)object color:(UIColor *)color {
    NSString *text = [NSString stringWithFormat:@"%@", object];
    [self inputText:text color:color];
}

- (void)logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
    va_list args;
    va_start(args, format);
    NSString *rst = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [self inputText:rst color:nil];
}

- (NSString *)currentTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
}

- (void)clearLog {
    _firstInput = YES;
    [self.logArray removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.logTextView setText:@""];
        [self.logTextView setAttributedText:nil];
    });
    
    [self inputText:@"清空日志成功\n" color:[UIColor redColor]];
}

- (void)closeLogView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dragView removeFromSuperview];
        [self setDragView:nil];
        
        [self.bottomView removeFromSuperview];
        [self setLogTextView:nil];
        [self setBottomView:nil];
    });
}

- (void)logObject:(id)object{
    [self inputObject:object color:nil];
}

@end
