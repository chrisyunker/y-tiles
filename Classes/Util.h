//
//  Util.h
//  Y-Tiles
//
//  Created by Chris Yunker on 3/1/09.
//  Copyright 2009 chrisyunker.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Util : NSObject {}

+ (CGContextRef)createBitmapContextForWidth:(float)width height:(float)height;
+ (void)drawRoundedRectForPath:(CGMutablePathRef)path rect:(CGRect)rect radius:(float)radius;
+ (UIImageView *)createPausedViewWithFrame:(CGRect)frame;

@end
