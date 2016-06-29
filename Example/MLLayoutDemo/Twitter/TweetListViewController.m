//
//  TweetListViewController.m
//  MLLayoutDemo
//
//  Created by molon on 16/6/28.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "TweetListViewController.h"
#import "TweetTableViewCell.h"
#import <MLAutoRecordFrameTableView.h>
#import "Tweet.h"

@interface TweetListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) MLAutoRecordFrameTableView *tableView;

@property (nonatomic, strong) NSArray<Tweet*> *tweets;

@end

@implementation TweetListViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _tableView = ({
            MLAutoRecordFrameTableView *tableView = [[MLAutoRecordFrameTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[TweetTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TweetTableViewCell class])];
            tableView;
        });
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Twitter Demo";
    [self.view addSubview:_tableView];
    
    NSMutableArray *tweets = [NSMutableArray array];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"twitter" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *ts = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d/yy";
    [formatter setLocale:[NSLocale currentLocale]];
    
    for (NSDictionary *dict in ts) {
        //just for test
        Tweet *t = [Tweet new];
        t.name = dict[@"name"];
        t.nickname = dict[@"nickname"];
        t.avatarURL = [NSURL URLWithString:dict[@"avatarURL"]];
        t.content = dict[@"content"];
        t.time = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[dict[@"time"] doubleValue]]];
        t.favCount = [dict[@"favCount"] integerValue];
        t.retweetCount = [dict[@"retweetCount"] integerValue];
        t.detailImageURL = [NSURL URLWithString:dict[@"detailImageURL"]];
        [tweets addObject:t];
    }
    _tweets = tweets;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TweetTableViewCell class]) forIndexPath:indexPath];
    
    cell.tweet = _tweets[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     The method only support for cells whose all subviews'frame can be determined with it's `layoutOfContentView` property.
    */
    return [TweetTableViewCell heightForRowUsingPureMLLayoutAtIndexPath:indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:^(UITableViewCell * _Nonnull protypeCell) {
        ((TweetTableViewCell*)protypeCell).tweet = _tweets[indexPath.row];
    }];
    
    /*
     The method's performance is lower than `heightForRowUsingPureMLLayoutAtIndexPath:tableView:beforeLayout:`.
     But it has no limit of method upon.
    */
//    return [TweetTableViewCell heightForRowAtIndexPath:indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:^(UITableViewCell * _Nonnull protypeCell) {
//        ((TweetTableViewCell*)protypeCell).tweet = _tweets[indexPath.row];
//    }];
}

@end
