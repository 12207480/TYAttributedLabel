//
//  TYDrawImageStorage.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawStorage.h"

@interface TYImageStorage : TYDrawStorage<TYViewStorageProtocol>

@property (nonatomic, strong) UIImage   *image;

@property (nonatomic, strong) NSString  *imageName;

@property (nonatomic, strong) NSURL     *imageURL;

@property (nonatomic, strong) NSString  *placeholdImageName;

@property (nonatomic, assign) BOOL cacheImageOnMemory; // default NO ,if YES can improve performance，but increase memory
@end
