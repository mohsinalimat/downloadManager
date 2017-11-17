//
//  MiguFileManager.m
//  MiguMusic
//
//  Created by 刘殿阁 on 2017/10/30.
//  Copyright © 2017年 刘殿阁. All rights reserved.
//

#import "MiguFileManager.h"

@implementation MiguFileManager
/**
 *
 *   创建目录
 */
+ (BOOL)creatPath:(NSString *)path {
    if (path.length > 0) {
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        BOOL flag = [manager createFileAtPath:path contents:nil attributes:nil];
        return flag;
    }
    return NO;
}
/**
 *
 *   判断路径是否存在
 */
+ (BOOL)fileIsExist:(NSString *)path {
    if (path.length > 0) {
        NSFileManager *manager = [NSFileManager defaultManager];
        return [manager fileExistsAtPath:path];
    }
    return NO;
}
/**
 *
 *   删除文件
 */
+ (BOOL )deleteFile:(NSString *)path  {
    if (path.length > 0) {
        NSFileManager * manager = [NSFileManager defaultManager];
        return [manager removeItemAtPath:path error:nil];
    }
    return NO;
}
/**
 *
 *   获取缓存的文件夹路径
 */
+ (NSString *)getCachePath {
    
    return [[NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/咪咕音乐"];
}
@end
