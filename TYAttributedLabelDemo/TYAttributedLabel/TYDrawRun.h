//
//  TYDrawRun.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYTextRunProtocol.h"

@interface TYDrawRun : NSObject<TYTextRunProtocol>
@property (nonatomic, assign)   NSRange         range;
@property (nonatomic, assign)   UIEdgeInsets    margin;
@property (nonatomic, assign)   CGSize          size;

@end
