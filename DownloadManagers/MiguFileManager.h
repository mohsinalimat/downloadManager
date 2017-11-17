//
//  MiguFileManager.h
//  MiguMusic
//
//  Created by 刘殿阁 on 2017/10/30.
//  Copyright © 2017年 刘殿阁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MiguFileManager : NSObject
/**
 *
 *   创建目录
 */
+ (BOOL)creatPath:(NSString *)path;
/**
 *
 *   判断路径是佛存在
 */
+ (BOOL)fileIsExist:(NSString *)path;
/**
 *
 *   删除文件
 */
+ (BOOL)deleteFile:(NSString *)path;
/**
 *
 *   获取缓存的文件夹路径
 */
+ (NSString *)getCachePath;
@end
