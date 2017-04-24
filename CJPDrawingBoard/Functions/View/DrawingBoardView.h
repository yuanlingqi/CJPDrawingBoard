//
//  DrawingBoardView.h
//  CJPDrawingBoard
//
//  Created by lucky－ios on 2017/4/24.
//  Copyright © 2017年 com.chint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBezierPath+Arrow.h"
#import "NSString+Extension.h"

#define NOTI_HIDE_TOOLVIEW @"NOTI_HIDE_TOOLVIEW"
#define NOTI_SELECTED_TAG @"NOTI_SELECTED_TAG"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DrawingBoardView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIImage *image;
@property(nonatomic, assign)NSInteger selectedTag;

/**
 画板图片
 */
@property(nonatomic, strong)UIImage *bgImage;

/**
 *  记录所有路径
 */
@property (nonatomic, strong) NSMutableArray *layers;

/**
 被撤销的路径
 */
@property(nonatomic, strong)NSMutableArray *removedLayers;

// 清屏
- (void)clearScreen;

// 撤销
- (void)undo;

@end
