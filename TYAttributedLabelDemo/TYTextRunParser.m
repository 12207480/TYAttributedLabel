//
//  TYParseData.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/22.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYTextRunParser.h"
#import "TYTextStorage.h"
#import "TYDrawImageStorage.h"
#import "TYLinkTextStorage.h"

@implementation TYTextRunParser

+ (NSArray *)parseWithJsonFilePath:(NSString *)filePath
{
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    
    return [self parseWithJsonData:jsonData];
}

+ (NSArray *)parseWithJsonData:(NSData *)jsonData
{
    if (jsonData == nil)  return nil ;
    
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingAllowFragments
                                                       error:nil];
    return [self parseWithJsonArray:array];
}

+ (NSArray *)parseWithJsonArray:(NSArray *)jsonArray
{
    if (jsonArray) {
        NSMutableArray *textRunArray = [NSMutableArray array];
        
        if ([jsonArray isKindOfClass:[NSArray class]]){
        
            for (NSDictionary *dic in jsonArray) {
                NSString *type = dic[@"type"];
                id<TYAppendTextStorageProtocol> textRun = nil;
                
                if ([type isEqualToString:@"txt"]) {
                    // 解析文本
                    textRun = [self parseTextRunFromDictinary:dic];
                } else if ([type isEqualToString:@"img"]) {
                    // 解析图片
                    textRun = [self parseImageRunFromDictinary:dic];
                } else if ([type isEqualToString:@"link"]) {
                    // 解析链接
                    textRun = [self parseLinkRunFromDictinary:dic];
                }
                
                if (textRun) {
                    [textRunArray addObject:textRun];
                }
            }

        }
        return [textRunArray copy];
    }
    return nil;
}

+ (id<TYAppendTextStorageProtocol>)parseTextRunFromDictinary:(NSDictionary *)dic
{
    TYTextStorage *textRun = [[TYTextStorage alloc]init];
    textRun.text = dic[@"content"];
    NSInteger fontSize = [dic[@"size"] integerValue];
    if (fontSize > 0) {
        textRun.font = [UIFont systemFontOfSize:fontSize];
    }
    textRun.textColor = [self colorFromTemplate:dic[@"color"]];
    
    return textRun;
}

+ (id<TYDrawStorageProtocol>)parseImageRunFromDictinary:(NSDictionary *)dic
{
    TYDrawImageStorage *imageRun = [[TYDrawImageStorage alloc]init];
    imageRun.imageContent = dic[@"name"];
    imageRun.size = CGSizeMake([dic[@"width"] doubleValue], [dic[@"height"] doubleValue]);
    
    return imageRun;
}

+ (id<TYAppendTextStorageProtocol>)parseLinkRunFromDictinary:(NSDictionary *)dic
{
    TYLinkTextStorage *linkRun = [[TYLinkTextStorage alloc]init];
    linkRun.text = dic[@"content"];
    linkRun.font = [UIFont systemFontOfSize:[dic[@"size"] integerValue]];
    linkRun.textColor = [self colorFromTemplate:dic[@"color"]];
    linkRun.linkStr = dic[@"url"];
    
    return linkRun;
}

+ (UIColor *)colorFromTemplate:(NSString *)name
{
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else if ([name isEqualToString:@"orange"]) {
        return [UIColor orangeColor];
    }else if ([name isEqualToString:@"green"]) {
        return [UIColor greenColor];
    }else if ([name isEqualToString:@"default"]){
        return [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    }else {
        return nil;
    }
}

@end
