//
//  TYTextStorageProtocol.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TYDrawAlignmentTop,     // 底部齐平 向上伸展
    TYDrawAlignmentCenter,  // 中心齐平
    TYDrawAlignmentBottom,  // 顶部齐平 向下伸展
} TYDrawAlignment;

extern NSString *const kTYTextRunAttributedName;

@protocol TYTextStorageProtocol <NSObject>
@required

/**
 *  范围（如果是appendStorage,range只针对追加的文本）
 */
@property (nonatomic,assign) NSRange range;

/**
 *  文本中实际位置,因为某些文本被替换，会导致位置偏移
 */
@property (nonatomic,assign) NSRange realRange;

/**
 *  添加属性到全文attributedString addTextStorage调用
 *
 *  @param attributedString 属性字符串
 */
- (void)addTextStorageWithAttributedString:(NSMutableAttributedString *)attributedString;

@end

@protocol TYAppendTextStorageProtocol <TYTextStorageProtocol>

@required

/**
 *  追加attributedString属性 appendTextStorage调用
 *
 *  @return 返回需要追加的attributedString属性
 */
- (NSAttributedString *)appendTextStorageAttributedString;

@end

@protocol TYLinkStorageProtocol <TYAppendTextStorageProtocol>

@property (nonatomic, strong) UIColor   *textColor;     // 文本颜色

@end

@protocol TYDrawStorageProtocol <TYAppendTextStorageProtocol>

@property (nonatomic, assign)   UIEdgeInsets    margin; // 四周间距

/**
 *  添加View 或 绘画 到该区域
 *
 *  @param rect 绘画区域
 */
- (void)drawStorageWithRect:(CGRect)rect;

/**
 *  设置字体高度 当前字符串替换数
 */
- (void)setTextfontAscent:(CGFloat)ascent descent:(CGFloat)descent;

// 当前替换字符数
- (void)currentReplacedStringNum:(NSInteger)replacedStringNum;

@end

@protocol TYViewStorageProtocol <NSObject>

/**
 *  设置所属的view
 */
- (void)setOwnerView:(UIView *)ownerView;

/**
 *  不会把你绘画出来
 */
- (void)didNotDrawRun;

@end

