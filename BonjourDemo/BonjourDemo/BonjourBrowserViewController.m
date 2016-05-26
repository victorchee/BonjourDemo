//
//  BonjourBrowserViewController.m
//  BonjourDemo
//
//  Created by Victor Chee on 16/5/26.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "BonjourBrowserViewController.h"
#import "BonjourBrowser.h"

@interface BonjourBrowserViewController () <BonjourBrowserDelegate> {
    BonjourBrowser *browser;
    NSArray *bonjourServices;
}

@end

@implementation BonjourBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    browser = [[BonjourBrowser alloc] init];
    browser.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [browser search];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [browser stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BonjourBrowserDelegate
- (void)bonjourBrowswer:(BonjourBrowser *)browser didUpdateServices:(NSArray *)services {
    bonjourServices = services;
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return bonjourServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSNetService *service = bonjourServices[indexPath.row];
    cell.textLabel.text = service.domain;
    cell.detailTextLabel.text = service.name;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNetService *service = bonjourServices[indexPath.row];
    [service resolveWithTimeout:5];
}

@end
