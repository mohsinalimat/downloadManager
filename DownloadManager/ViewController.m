//
//  ViewController.m
//  DownloadManager
//
//  Created by 刘殿阁 on 2017/11/17.
//  Copyright © 2017年 刘殿阁. All rights reserved.
//

#import "ViewController.h"
#import "MiguDowmloadBaseManager.h"
#import "downloadCell.h"
#define  TEST_URL @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=6005970S6G0&ua=Mac_sst&version=1.0"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ViewController

static NSString * const CELL_ID = @"cell_id";
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"downloadCell" bundle:nil] forCellReuseIdentifier:CELL_ID];
    NSArray *list = @[
                     @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=6990539Z0K8&ua=Mac_sst&version=1.0",
                     @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=63880300430&ua=Mac_sst&version=1.0",
                     @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=6005970S6G0&ua=Mac_sst&version=1.0",
                     @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=63273401896&ua=Mac_sst&version=1.0",
                     @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"
                     ];
    for (NSString *downloadUrl in list) {
        [[MiguDowmloadBaseManager shareManager] downloadWithUrl:downloadUrl];
    }
    [self.dataArray addObjectsFromArray:[MiguDowmloadBaseManager shareManager].downloadArray];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAction:) name:DownloadFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAction:) name:CancelAllSong object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAction:) name:CancelOneSong object:nil];
}
#pragma mark - 方法的响应

/**
 *
 *  更新ui
 */
- (void)changeAction:(NSNotification *)info {
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[MiguDowmloadBaseManager shareManager].downloadArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
/**
 *
 *  取消全部
 */
- (IBAction)cancleAllAction:(UIButton *)sender {
    [[MiguDowmloadBaseManager shareManager] cancelAllSong];
    
}
/**
 *
 *  取消某一首歌曲
 */
- (IBAction)cancleOneAction:(UIButton *)sender {
    [[MiguDowmloadBaseManager shareManager] cancelWithSong:TEST_URL];
}
/**
 *
 *   暂停全部
 */

- (IBAction)suspendAllAction:(id)sender {
    
    [[MiguDowmloadBaseManager shareManager] suspendAllSong];
}
/**
 *
 *   暂停某一首歌曲
 */
- (IBAction)suspendOneAction:(id)sender {
    [[MiguDowmloadBaseManager shareManager] suspendWithUrl:TEST_URL];
}
/**
 *
 *  恢复全部
 */
- (IBAction)resumeAllAction:(id)sender {
    [[MiguDowmloadBaseManager shareManager] resumeAllSong];
}
/**
 *
 *  恢复某一首歌曲
 */
- (IBAction)resumeOneAction:(id)sender {
    
    [[MiguDowmloadBaseManager shareManager] resumeWithSong:TEST_URL];
}
#pragma mark - datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MiguDownloadItem *item = self.dataArray[indexPath.row];
    downloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    cell.item = item;
    return cell;
}



@end
