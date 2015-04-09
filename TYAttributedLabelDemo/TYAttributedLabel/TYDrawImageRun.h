//
//  TYDrawImageRun.h
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawRun.h"

@interface TYDrawImageRun : TYDrawRun

/**
 *  支持格式:NSString - 本地image名， NSURL - image图片网址，UIImage - image数据
 */
@property (nonatomic, strong) id    imageContent;

@end
