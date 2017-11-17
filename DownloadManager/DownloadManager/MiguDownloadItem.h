//
//  MiguDownloadItem.h
//  MiguMusic
//
//  Created by 刘殿阁 on 2017/11/8.
//  Copyright © 2017年 刘殿阁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MiguDownloadItem.h"
#import <AFNetworking/AFNetworking.h>
#import "MiguHttpConfig.h"

// 是否下载 1.未下载 2.等待中 3.正在下载  4.下载完成  5.暂停 6.下载失败
typedef NS_ENUM(NSUInteger,MiguDownloadStatus) {
    
    MiguDownloadStatusUnKnown            = 0,
    MiguDownloadStatusUndownload         = 1,
    MiguDownloadStatusWaiting            = 2,
    MiguDownloadStatusDownloading        = 3,
    MiguDownloadStatusDownloadFinish     = 4,
    MiguDownloadStatusDownloadSuspend    = 5,
    MiguDownloadStatusError              = 6
};

@interface MiguDownloadItem : NSObject

//   请求的url
@property (nonatomic, copy) NSString *requestUrl;
//   下载的任务
@property (nonatomic, strong) NSURLSessionTask *task;
//   管理者
@property (nonatomic, strong) AFHTTPSessionManager *manager;
//   下载的状态
@property (nonatomic, assign) MiguDownloadStatus downloadStatus;
//   返回的response
@property (nonatomic, strong) NSURLResponse *response;
//   错误的信息
@property (nonatomic, strong) NSError *error;
//   下载的进度
 @property (nonatomic, assign) CGFloat progress;
//   临时存储的文件路径
 @property (nonatomic, copy) NSString *temPath;
//   缓存的文件的路径
 @property (nonatomic, copy) NSString *cachePath;
//   请求的方法
@property (nonatomic, copy) NSString *requestMethod;
//   参数
@property (nonatomic, strong) NSDictionary *paramDic;
//   NSFileHandle
@property (nonatomic, strong) NSFileHandle *itemFileHandle;
//   下载进度的block
@property (nonatomic, strong) void (^MiguDownloadProgressBlock)(CGFloat progress);
//   下载信息反馈
@property (nonatomic, strong) void (^MiguDownloadCompletionHandler)(NSError *error);

@end
