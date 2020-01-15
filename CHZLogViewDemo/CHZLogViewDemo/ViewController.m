//
//  ViewController.m
//  CHZLogViewDemo
//
//  Created by Wymann Chan on 2020/1/15.
//  Copyright © 2020 CHZ. All rights reserved.
//

#import "ViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    APPLogWithFormat(@"当前控制器:%@", [self class]);
}

- (IBAction)gotoFirstViewController:(id)sender {
    APPLogWithFormat(@"点击了第一个按钮");
    FirstViewController *vc = [[FirstViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoSecondViewController:(id)sender {
    APPLogWithFormat(@"点击了第二个按钮");
    SecondViewController *vc = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    APPLogWithFormat(@"点击了控制器：%@ 的空白处", [self class]);
}

@end
