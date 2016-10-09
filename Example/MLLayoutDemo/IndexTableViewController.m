//
//  IndexTableViewController.m
//  MLFlexLayout
//
//  Created by molon on 16/6/20.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "IndexTableViewController.h"

@interface IndexTableViewController ()

@property (nonatomic, strong) NSArray *demoNames;

@end

@implementation IndexTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MLLayout";
    
    self.demoNames = @[@"SimpleViewController",@"TweetListViewController",@"NibTweetListViewController"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    cell.textLabel.text = self.demoNames[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Class cls = NSClassFromString(self.demoNames[indexPath.row]);
    UIViewController *vc = [cls new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
