//
//  UIBezierPath+Arrow.m
//  02-圆形裁剪
//
//  Created by lucky－ios on 2017/4/20.
//  Copyright © 2017年 itcast. All rights reserved.
//

#import "UIBezierPath+Arrow.h"
#import <objc/runtime.h>

#define kArrowPointCount 7

@implementation UIBezierPath (Arrow)

static NSString *ptString = @"pathType";

static NSString *colorString = @"color";

#pragma mark - Setter
- (void)setColor:(UIColor *)color{
    objc_setAssociatedObject(self, &colorString, color, OBJC_ASSOCIATION_COPY);
}

- (void)setPathType:(NSInteger)pathType{
    objc_setAssociatedObject(self, &ptString, @(pathType), OBJC_ASSOCIATION_COPY);
}

#pragma mark - Getter

- (UIColor *)color{
    return objc_getAssociatedObject(self, &colorString);
}

- (NSInteger)pathType{
    return [objc_getAssociatedObject(self, &ptString) intValue];
}

#pragma mark - Custom Methods

+ (instancetype)pathWitchColor:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    UIBezierPath *path = [[self alloc] init];
    path.color = color;
    path.lineWidth = lineWidth;
    
    return path;
}

+ (UIBezierPath *)arrow:(CGPoint)start toEnd:(CGPoint)end tailWidth:(CGFloat)tailWidth headWidth:(CGFloat)headWidth headLength:(CGFloat)headLength{

    CGFloat length = hypot(end.x - start.x, end.y - start.y);
    CGFloat tailLength = length - headLength;

    CGPoint points[7] =
    {
        {0, tailWidth / 2},
        {tailLength, tailWidth / 2},
        {tailLength, headWidth / 2},
        {length, 0},
        {tailLength, -headWidth / 2},
        {tailLength, -tailWidth / 2},
        {0, -tailWidth / 2}
    };
    
    CGFloat cosine = (end.x - start.x) / length;
    CGFloat sine = (end.y - start.y) / length;
    CGAffineTransform transform = CGAffineTransformMake(cosine, sine, -sine, cosine, start.x, start.y);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines(path, &transform, points, 7);
    CGPathCloseSubpath(path);
    UIBezierPath *uiPath = [UIBezierPath bezierPathWithCGPath:path];
    uiPath.pathType = ARROW;
    
    CGPathRelease(path);
    return uiPath;
}

@end
