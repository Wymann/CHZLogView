//
//  CHZLogView.m
//  TclIntelliCom
//
//  Created by Wymann Chan on 2019/4/28.
//  Copyright © 2019 tcl. All rights reserved.
//

#import "CHZLogView.h"
#import "WMDragView.h"
#import "CHZLogCell.h"

@interface CHZLogView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL firstInput;
@property (nonatomic, strong) WMDragView *dragView;
@property (nonatomic, strong) UILabel *toastLabel;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITableView *logTableView;
@property (nonatomic) CGRect bottomFrame;
@property (nonatomic) CGRect textViewFrame;
@property (nonatomic, strong) NSMutableArray <CHZLogModel *>*logArray;
@property (nonatomic, assign) BOOL isInputting;

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
        
        _logTableView = [[UITableView alloc] initWithFrame:_textViewFrame style:UITableViewStyleGrouped];
        _logTableView.backgroundColor = _bottomView.backgroundColor;
        _logTableView.layer.cornerRadius = 5.0;
        _logTableView.clipsToBounds = YES;
        _logTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _logTableView.delegate = self;
        _logTableView.dataSource = self;
        [_logTableView registerClass:[CHZLogCell class] forCellReuseIdentifier:@"CHZLogCell"];
        [_bottomView addSubview:_logTableView];
        _bottomView.clipsToBounds = YES;
        
        //双击清空日志
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] init];
        tapGest.numberOfTapsRequired = 2;
        [_logTableView addGestureRecognizer:tapGest];
        [tapGest addTarget:self action:@selector(clearLog)];
        
        [keyView bringSubviewToFront:self.dragView];
    }
    
    return _bottomView;
}

-(UILabel *)toastLabel {
    if (!_toastLabel) {
        _toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.bottomView.frame) - toastHeight - 10.0, toastWidth, toastHeight)];
        _toastLabel.backgroundColor = self.bottomView.backgroundColor;
        _toastLabel.textColor = [UIColor whiteColor];
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.font = [UIFont systemFontOfSize:13.0];
        _toastLabel.alpha = 0;
        _toastLabel.layer.cornerRadius = 5.0;
        _toastLabel.clipsToBounds = YES;
        UIView *keyView;
        if (@available(iOS 13.0, *)) {
            keyView = [[UIApplication sharedApplication].windows firstObject];
        } else {
            keyView = [UIApplication sharedApplication].keyWindow;
        }
        [keyView addSubview:_toastLabel];
    }
    return _toastLabel;
}

-(NSMutableArray<CHZLogModel *> *)logArray {
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
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf hideToast];
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.bottomView.alpha = 0.0;
            weakSelf.bottomView.frame = weakSelf.dragView.frame;
        }];
    });
}

- (void)inputText:(NSString *)text color:(UIColor *)color {
    if (!_bottomView) {
        [self setUI];
    }
    NSString *string = [NSString stringWithFormat:@"%@\n%@",[self currentTimeString] , text];
    CHZLogModel *model = [[CHZLogModel alloc] init];
    model.log = string;
    model.color = color;
    [self.logArray addObject:model];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.logTableView reloadData];
        [self.logTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.logArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    NSString *string = [NSString stringWithFormat:@"%@\n清空日志",[self currentTimeString]];
    CHZLogModel *model = [[CHZLogModel alloc] init];
    model.log = string;
    model.color = [UIColor redColor];
    [self.logArray addObject:model];
    __weak typeof (self)weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.logTableView reloadData];
    });
}

- (void)closeLogView {
    [self.logArray removeAllObjects];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.dragView.alpha = 0;
            weakSelf.bottomView.alpha = 0;
            weakSelf.logTableView.alpha = 0;
        }completion:^(BOOL finished) {
            [weakSelf.dragView removeFromSuperview];
            [weakSelf setDragView:nil];
            
            [weakSelf.bottomView removeFromSuperview];
            [weakSelf setLogTableView:nil];
            [weakSelf setBottomView:nil];
        }];
    });
}

- (void)logObject:(id)object{
    [self inputObject:object color:nil];
}

- (void)showToast:(NSString *)toast {
    self.toastLabel.text = toast;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.toastLabel.alpha = 1.0;
    }completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf hideToast];
        });
    }];
}

- (void)hideToast {
    if (_toastLabel) {
        [UIView animateWithDuration:0.2 animations:^{
            self.toastLabel.alpha = 0.0;
        }completion:^(BOOL finished) {
            [self.toastLabel removeFromSuperview];
            [self setToastLabel:nil];
        }];
    }
}

#pragma mark - tableViewDelegate & tableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHZLogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CHZLogCell"];
    if (!cell) {
        cell = [[CHZLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CHZLogCell"];
    }
    cell.model = self.logArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    __weak typeof (self)weakself = self;
    cell.pastBlock = ^{
        [weakself showToast:@"复制成功！"];
    };
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHZLogModel *model = self.logArray[indexPath.row];
    CGFloat cellHeight = [CHZLogCell textHeightWithAttributedText:model.attributedString Width:CHZ_SCREEN_WIDTH - leftGap - rightGap - textLeftGap - textRightGap];
    return cellHeight + textTopGap + textBottomGap;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self hideToast];
}

@end
