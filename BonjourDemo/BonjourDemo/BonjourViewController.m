//
//  BonjourViewController.m
//  BonjourDemo
//
//  Created by Victor Chee on 16/5/26.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "BonjourViewController.h"
#import "Bonjour.h"

@interface BonjourViewController () {
    Bonjour *bonjour;
}

@end

@implementation BonjourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    bonjour = [[Bonjour alloc] init];
    [bonjour publish];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
