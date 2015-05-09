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
    TYDrawAlignmentButtom,  // 顶部齐平 向下伸展
} TYDrawAlignment;

extern NSString *const kTYTextRunAttributedName;

@protocol TYTextStorageProtocol <NSObject>
@required

/**
 *  范围（如果是appendStorage,range只针对追加的文本）
 */
@property (nonatomic,assign) NSRange range;
//- (NSRange)range;

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

@protocol TYDrawStorageProtocol <TYAppendTextStorageProtocol>

/**
 *  添加View 或 绘画 到该区域
 *
 *  @param rect 绘画区域
 */
- (void)drawStorageWithRect:(CGRect)rect;

/**
 *  设置所属的view
 *
 *  @param ownerView ownerView
 */
- (void)setOwnerView:(UIView *)ownerView;

@optional

/**
 *  不会把你绘画出来
 */
- (void)didNotDrawRun;

@end

