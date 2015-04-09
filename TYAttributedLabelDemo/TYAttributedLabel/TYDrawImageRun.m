//
//  TYDrawImageRun.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawImageRun.h"

@implementation TYDrawImageRun

- (void)drawRunWithRect:(CGRect)rect
{
    UIImage *image = nil;
    
    if ([_imageContent isKindOfClass:[NSString class]]) {
        // 本地图片名
        image = [UIImage imageNamed:_imageContent];
    }else if ([_imageContent isKindOfClass:[NSURL class]]){
        // 图片网址
        image = [self imageForUrl:_imageContent];
    } else if ([_imageContent isKindOfClass:[UIImage class]]){
        // 图片数据
        image = _imageContent;
    } else {
        NSLog(@"不能识别 imageContent 格式");
        return;
    }
    
    if (image) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, rect, image.CGImage);
    }
}

// 从网络获取图片
- (UIImage *)imageForUrl:(NSURL *)imageUrl
{
    return nil;
}

@end
