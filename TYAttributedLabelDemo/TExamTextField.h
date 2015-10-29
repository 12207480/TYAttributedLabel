//
//  TExamTextField.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/10/10.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TExamTextFieldState) {
    TExamTextFieldStateNormal,
    TExamTextFieldStateCorrect,
    TExamTextFieldStateError,
};

@interface TExamTextField : UITextField

@property (nonatomic, assign) TExamTextFieldState examState;

@end
