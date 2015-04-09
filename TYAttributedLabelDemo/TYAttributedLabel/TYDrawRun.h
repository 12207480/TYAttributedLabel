//
//  TYDrawRun.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYTextRunProtocol.h"

@interface TYDrawRun : NSObject<TYTextRunProtocol>
@property (nonatomic, assign)   NSRange         range;  // 文本范围
@property (nonatomic, assign)   UIEdgeInsets    margin; // 图片四周间距
@property (nonatomic, assign)   CGSize          size;   // 绘画物大小

@property (nonatomic, assign)   CGFloat         fontAscent;
@property (nonatomic, assign)   CGFloat         fontDescent;

/**
 *  获取绘画区域高度(上行高度 一般只要改写这个即可)
 */
- (CGFloat)getDrawRunAscentHeight;

/**
 *  获取绘画区域下行高度 默认为0 （一般不需要改写）
 */
- (CGFloat)getDrawRunDescentHeight;

/**
 *  获取绘画区域宽度
 */
- (CGFloat)getDrawRunWidth;

/**
 *  释放内存 （一般不需要 已注释 需要在打开）
 */
//- (void)DrawRunDealloc;

@end
