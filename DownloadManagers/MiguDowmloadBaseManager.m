//
//  MiguDowmloadBaseManager.m
//  MiguMusic
//
//  Created by 刘殿阁 on 2017/9/24.
//  Copyright © 2017年 刘殿阁. All rights reserved.
//

#import "MiguDowmloadBaseManager.h"
#import "MiguFileManager.h"
#import "NSDataAdditions.h"

@interface MiguDowmloadBaseManager ()
// 锁
@property(nonatomic, strong)NSLock *lock;

@end
@implementation MiguDowmloadBaseManager
+ (instancetype)shareManager {
    static MiguDowmloadBaseManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}
-(instancetype)init {
    if (self == [super init]) {
        _lock = [[NSLock alloc] init];
    }
    return self;
}
#pragma mark - 重新书写下载管理器
- (NSMutableArray *)downloadArray {
    if (!_downloadArray) {
        _downloadArray = [NSMutableArray array];
    }
    return _downloadArray;
}
/**
 *
 *   便利数组获取item
 */
- (MiguDownloadItem *)getItemFromArray:(NSArray <MiguDownloadItem *>*)itemArray withUrl:(NSString *)url {
    MiguDownloadItem *getItem = nil;
    for (MiguDownloadItem *item in itemArray) {
        if ([item.requestUrl isEqualToString:url]) {
            getItem = item;
            break;
        }
    }
    return getItem;
}
/**
 *
 *  获取临时文件夹 (全路径）
 */
-  (NSString *)getTemPath:(NSString *)downloadUrl {
    
    if (downloadUrl.length <= 0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *temPath = NSTemporaryDirectory();
    NSString *nameStr =[[[downloadUrl dataUsingEncoding:NSUTF8StringEncoding] tk_MD5HashString] stringByAppendingString:@".download"];
    temPath = [temPath stringByAppendingPathComponent:nameStr];
    if (![fileManager fileExistsAtPath:temPath]) {
        [fileManager createFileAtPath:temPath contents:nil attributes:nil];
    }
    return temPath;
}
/**
 *
 *   获取缓存的文件夹的路径
 */
- (NSString *)getCache:(NSString *)downloadUrl withResponse:(NSURLResponse *)response{
    
    if (downloadUrl.length <= 0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Music"];
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    cachePath = [cachePath stringByAppendingPathComponent:response.suggestedFilename];
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createFileAtPath:cachePath contents:nil attributes:nil];
    }
    return cachePath;
}
/**
 *
 *  取消正在下载的任务
 */
- (void)cancelTask:(MiguDownloadItem *)item {
    
    if (item.task) {
        [item.task cancel];
        item.task = nil;
    }
    item.progress = 0;
    [item.manager setDataTaskDidReceiveDataBlock:NULL];
    item.response = nil;
    item.error = nil;
}
/**
 *
 *    开始下载
 */
- (void)downloadWithUrl:(NSString *)downloadUrl {
   
    if (downloadUrl.length == 0) {
        return;
    }
    [_lock lock];
    // 取消下载相关的东西
    MiguDownloadItem *item = [self getItemFromArray:_downloadArray withUrl:downloadUrl];
    if (!item) {
        item = [[MiguDownloadItem alloc] init];
        item.requestUrl = downloadUrl;
        item.downloadStatus = MiguDownloadStatusWaiting;
        item.progress = 0.0;
        item.temPath = [self getTemPath:downloadUrl];
        item.requestMethod = @"GET";
        item.paramDic = nil;
        [self.downloadArray addObject:item];
    }
    // 设置最大线程来进行下载任务
    [self checkDownload];
    [_lock unlock];
}
/**
 *
 *  下载开始检查，并且开启最大的线程数进行下载
 */
- (void)checkDownload {
    
    NSInteger downloadingCount = 0;
    BOOL flag = YES;
    for (MiguDownloadItem *item in _downloadArray) {
        if (item.downloadStatus == MiguDownloadStatusDownloading) {
            downloadingCount ++;
        }
        if (downloadingCount >= MAXTASK_COUNT) {
            flag = NO;
            break;
        }
    }
    NSLog(@"当前的下载数量是:%zd",downloadingCount);
    if (flag) {
        for (MiguDownloadItem *item in _downloadArray) {
            if (item.downloadStatus == MiguDownloadStatusWaiting) {
                if (MAXTASK_COUNT - downloadingCount > 0) {
                    NSLog(@"开始任务了");
                    [self beginDownloadWithItem:item];
                    downloadingCount ++;
                }else {
                    break;
                }
            }
        }
    }
}
/**
 *
 *  开始下载
 */
- (void)beginDownloadWithItem:(MiguDownloadItem *)item {
    
    if (item.requestUrl.length == 0) {
        return;
    }
    item.downloadStatus = MiguDownloadStatusDownloading;
    //  如果任务正在进行 取消
    [self cancelTask:item];
    //  取消请求的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //  开始下载任务
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:item.requestMethod URLString:item.requestUrl parameters:item.paramDic error:nil];
    // 读取数据
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:item.temPath error:nil];
    unsigned long long cacheNumber = dic.fileSize;
    // 断点续传
    if (cacheNumber > 0) {
        NSString *rangStr = [NSString stringWithFormat:@"bytes=%llu-",cacheNumber];
        [request setValue:rangStr forHTTPHeaderField:@"Range"];
    }
    [manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        [_lock lock];
        
        item.downloadStatus = MiguDownloadStatusDownloading;
        // 写入数据
        if (!item.itemFileHandle) {
            item.itemFileHandle = [NSFileHandle fileHandleForWritingAtPath:item.temPath];
        }
        [item.itemFileHandle seekToEndOfFile];
        [item.itemFileHandle writeData:data];
        // 计算进度
        unsigned long long receiveNumber = (unsigned long long )dataTask.countOfBytesReceived + cacheNumber;
        unsigned long long expectNumber = (unsigned long long)dataTask.countOfBytesExpectedToReceive + cacheNumber;
        CGFloat progress = (CGFloat)receiveNumber/expectNumber *1.0;
        item.progress = progress;
        NSLog(@"接收的数据 --- %llu 期望的数据 ---- %llu 下载的进度 --- %f",receiveNumber,expectNumber,progress);
        if (item.MiguDownloadProgressBlock) {
            item.MiguDownloadProgressBlock(progress);
        }
        [_lock unlock];
    }];
    __weak typeof(self)weakSelf = self;
    // 完成
    item.task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [_lock lock];
        item.error = error;
        if (error) {
            NSLog(@"下载失败 %@",error);
            item.downloadStatus = MiguDownloadStatusError;
            if (item.MiguDownloadCompletionHandler) {
                item.MiguDownloadCompletionHandler(error);
            }
        }else {
            item.downloadStatus = MiguDownloadStatusDownloadFinish;
            // 这个路径要根据自己的实际情况处理
            item.cachePath = [weakSelf getCache:item.requestUrl withResponse:response];
            NSLog(@"下载成功 -- 成功的文件的路径是%@",item.cachePath);
            // 删除文件
            [[NSFileManager defaultManager] removeItemAtPath:item.cachePath error:nil];
            // 存放到自己想存放的路径
            NSError *transError = nil;
            [[NSFileManager defaultManager] moveItemAtPath:item.temPath toPath:item.cachePath error:&transError];
            NSLog(@"转换的错误信息是 %@",transError);
            // 从数组中移除成功的
            [_downloadArray removeObject:item];
            if (item.MiguDownloadCompletionHandler) {
                item.MiguDownloadCompletionHandler(nil);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadFinish object:nil];
            item.response = response;
            // 递归调用
            [weakSelf checkDownload];
        }
        [_lock unlock];
    }];
    
    [item.task resume];
    item.manager = manager;
}
/**
 *
 *    暂停某一首歌曲下载
 */
- (void)suspendWithUrl:(NSString *)url{
    if (url.length == 0) {
        return;
    }
    [_lock lock];
    MiguDownloadItem *item = [self getItemFromArray:_downloadArray withUrl:url];
    [item.task suspend];
    item.downloadStatus = MiguDownloadStatusDownloadSuspend;
    // 暂停某一首歌曲
    [[NSNotificationCenter defaultCenter] postNotificationName:SuspendOneSong object:nil];
    [_lock unlock];
}
/**
 *
 *   暂停所有的歌曲
 */
- (void)suspendAllSong{
    [_lock lock];
    for (MiguDownloadItem *item in _downloadArray) {
        if (item.downloadStatus == MiguDownloadStatusDownloading || item.downloadStatus == MiguDownloadStatusWaiting || item.downloadStatus == MiguDownloadStatusError) {
            [item.task suspend];
            item.downloadStatus = MiguDownloadStatusDownloadSuspend;
        }
    }
    [_lock unlock];
   // 暂停所有的歌曲（通知）
   [[NSNotificationCenter defaultCenter] postNotificationName:SuspendAllSong object:nil];
}
/**
 *
 *   恢复下载一首歌曲
 */
- (void)resumeWithSong:(NSString *)url{
    if (url.length == 0) {
        return;
    }
    [_lock lock];
    MiguDownloadItem *item = [self getItemFromArray:_downloadArray withUrl:url];
    if (!item) {
        item = [[MiguDownloadItem alloc] init];
        item.requestUrl = url;
        item.downloadStatus = MiguDownloadStatusWaiting;
        item.progress = 0.0;
        item.temPath = [self getTemPath:url];
        item.requestMethod = @"GET";
        item.paramDic = nil;
        [_downloadArray addObject:item];
    }else {
       item.downloadStatus = MiguDownloadStatusWaiting;
    }
    [self checkDownload];
    [_lock unlock];
    [[NSNotificationCenter defaultCenter] postNotificationName:ResumeOneSong object:nil];
}
/**
 *
 *   恢复所有暂停的歌曲
 */
- (void)resumeAllSong{
   
    [_lock lock];
    for (MiguDownloadItem *item in _downloadArray) {
        if (item.downloadStatus != MiguDownloadStatusError || item.downloadStatus != MiguDownloadStatusDownloadFinish) {
            item.downloadStatus = MiguDownloadStatusWaiting;
        }
    }
    [self checkDownload];
    [_lock unlock];
    [[NSNotificationCenter defaultCenter] postNotificationName:ResumeAllSong object:nil];
}
/**
 *
 *   取消一首歌曲
 */
- (void)cancelWithSong:(NSString *)url{
    
    if (url.length == 0) {
        return;
    }
    [_lock lock];
    MiguDownloadItem *item = [self getItemFromArray:_downloadArray withUrl:url];
    if (item.downloadStatus == MiguDownloadStatusDownloadFinish) {
        return;
    }else {
        [item.task cancel];
        item.task = nil;
        // 删除临时文件夹的缓存东西
        [[NSFileManager defaultManager] removeItemAtPath:item.temPath error:nil];
    }
    if (item) {
        [_downloadArray removeObject:item];
    }
    [_lock unlock];
    [[NSNotificationCenter defaultCenter] postNotificationName:CancelOneSong object:nil];
}
/**
 *
 *   取消所有歌曲
 */
- (void)cancelAllSong{
    
    [_lock lock];
    for (MiguDownloadItem *item in _downloadArray) {
        [item.task cancel];
        item.task = nil;
        // 删除临时文件夹的缓存东西
        [[NSFileManager defaultManager] removeItemAtPath:item.temPath error:nil];
    }
    [_downloadArray removeAllObjects];
    _downloadArray = nil;
    [_lock unlock];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CancelAllSong object:nil];
}

@end
