# downloadManager
下载管理器，只要传递下载的url来进行下载，支持ios 和macos
 
## 下载管理器实现的功能：
- 传递url进行下载
- 支持最大的下载任务个数
- 可以暂停全部
- 可以暂停某一首
- 可以取消全部
- 可以取消某一首
- 可以恢复下载一首
- 可以恢复全部下载
- 支持断点续传
## 安装
- 只需要将 LDGDownloadManager拖入工程中，目前还没有时间弄cocoapod
## 使用
````objc
1.开始下载
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
也可以
[[MiguDowmloadBaseManager shareManager] downloadWithUrl:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
2.暂停全部
 [[MiguDowmloadBaseManager shareManager] suspendAllSong];
3.暂停某一首
[[MiguDowmloadBaseManager shareManager] suspendWithUrl:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
4.取消全部
 [[MiguDowmloadBaseManager shareManager] cancelAllSong];
5.取消某一首歌曲
 [[MiguDowmloadBaseManager shareManager] downloadWithUrl:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
6.恢复所有的歌曲
 [[MiguDowmloadBaseManager shareManager] resumeAllSong];
7.恢复一首歌曲
 [[MiguDowmloadBaseManager shareManager] resumeWithSong:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
8.修改最大的下载的任务数量
 全局搜索 MAXTASK_COUNT 修改其值  默认最大任务数量是 3
````

 






