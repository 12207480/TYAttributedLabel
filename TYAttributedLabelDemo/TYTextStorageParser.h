//
//  TYParseData.h
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/22.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYTextStorageParser : NSObject

+ (NSArray *)parseWithJsonFilePath:(NSString *)filePath;

+ (NSArray *)parseWithJsonData:(NSData *)jsonData;

+ (NSArray *)parseWithJsonArray:(NSArray *)jsonArray;

@end
