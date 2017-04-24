//
//  UIBezierPath+Arrow.h
//  02-圆形裁剪
//
//  Created by lucky－ios on 2017/4/20.
//  Copyright © 2017年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ENUM_BUTTON_CHOICE) {
    LINE = 1001,
    ARROW,
    RECTANGLE,
    OVAL,
    WORD,
    CLEAR,
    UNDO,
    CANCEL,
    FINISH
};

@interface UIBezierPath (Arrow)

@property(nonatomic, assign)NSInteger pathType;

@property (nonatomic, strong) UIColor *color;

+ (instancetype)pathWitchColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;

+ (UIBezierPath *)arrow:(CGPoint)start toEnd:(CGPoint)end tailWidth:(CGFloat)tailWidth headWidth:(CGFloat)headWidth headLength:(CGFloat)headLength;

@end
