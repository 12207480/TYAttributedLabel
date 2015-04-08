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
    if (_imageName) {
        image = [UIImage imageNamed:_imageName];
    }else if (_urlStr){
        
    }
    
    if (image) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, rect, image.CGImage);
    }
}

@end
