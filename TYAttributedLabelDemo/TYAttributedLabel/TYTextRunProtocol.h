//
//  TYTextRunProtocol.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TYDrawAlignmentTop,     // 底部齐平 向上伸展
    TYDrawAlignmentCenter,  // 中心齐平
    TYDrawAlignmentButtom,  // 顶部齐平 向下伸展
} TYDrawAlignment;

extern NSString *const kTYTextRunAttributedName;
extern NSString *const kTYAttributedLabelNeedDisplayNotification;
//#define kTYAttributedLabelNeedDisplayNotification @"TYAttributedLabelNeedDisplayNotification"

@protocol TYTextRunProtocol <NSObject>
@required

/**
 *  范围
 */
@property (nonatomic,assign) NSRange range;
//- (NSRange)range;

/**
 *  添加属性到全文attributedString addTextRun调用
 *
 *  @param attributedString 属性字符串
 */
- (void)addTextRunWithAttributedString:(NSMutableAttributedString *)attributedString;

@end

@protocol TYAppendTextRunProtocol <TYTextRunProtocol>

@required
/**
 *  追加attributedString属性 appendTextRun调用
 *
 *  @return 返回需要追加的attributedString属性
 */
- (NSAttributedString *)appendTextRunAttributedString;

@end

@protocol TYDrawRunProtocol <TYAppendTextRunProtocol>

/**
 *  添加View 或 绘画 到该区域
 *
 *  @param rect 绘画区域
 */
- (void)drawRunWithRect:(CGRect)rect;

/**
 *  设置文本字符 上行高度 和下行高度
 *
 *  @param replaceStringNumPtr  已经替换的字符数目指针
 *  @param ascent  上行高度
 *  @param descent 下行高度
 */
- (void)setTextReplaceStringNum:(NSInteger *)replaceStringNumPtr fontAscent:(CGFloat)ascent descent:(CGFloat)descent;

@optional

/**
 *  不会把你绘画出来
 */
- (void)didNotDrawRun;

@end

@protocol TYDrawViewRunProtocol <TYDrawRunProtocol>

/**
 *  设置引用label
 */
- (void)setSuperView:(UIView *)supView;

@end
