//
//  WaitImageView.m
//  Y-Tiles
//
//  Created by Chris Yunker on 3/1/09.
//  Copyright 2009 chrisyunker.com. All rights reserved.
//

#import "WaitImageView.h"

@interface WaitImageView (Private)

- (UIImage *)createImage;

@end


@implementation WaitImageView

- (id)init
{
	if (self = [super initWithFrame:CGRectMake(kWaitViewX, kWaitViewY, kWaitViewWidth, kWaitViewHeight)])
	{
		[self setImage:[self createImage]];
		
		activityIndicator = [[UIActivityIndicatorView alloc]
							 initWithFrame:CGRectMake(kWaitIndicatorX,
													  kWaitIndicatorY,
													  kWaitIndicatorWidth,
													  kWaitIndicatorHeight)];
		[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[self addSubview:activityIndicator];
	}
	return self;
}

- (void)dealloc
{
	[activityIndicator release];
    [super dealloc];
}

- (void)startAnimating
{
	[activityIndicator startAnimating];
}

- (void)stopAnimating
{
	[activityIndicator stopAnimating];
}

- (UIImage *)createImage
{
	// Wait View
	CGContextRef context = [Util newBitmapContextForWidth:kWaitViewWidth height:kWaitViewHeight];
	
	CGMutablePathRef pathRef = CGPathCreateMutable();
	[Util drawRoundedRectForPath:pathRef
							rect:CGRectMake(0, 0, kWaitViewWidth, kWaitViewHeight)
						  radius:kTileCornerRadius];
	CGContextAddPath(context, pathRef);
	
	CGContextSetRGBFillColor(context,
							 kWaitViewBgColorRed,
							 kWaitViewBgColorGreen,
							 kWaitViewBgColorBlue,
							 kWaitViewBgColorAlpha);
	CGContextFillPath(context);
	
	// Draw Label
	CGContextSelectFont(context, kWaitViewFontType,  kWaitViewFontSize, kCGEncodingMacRoman);
	NSString *label = [NSString stringWithFormat:@"%@", NSLocalizedString(@"WaitImageLabel", @"")];
	
	// Calculate text width
	CGPoint start = CGContextGetTextPosition(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	CGContextShowText(context, [label UTF8String], [label length]);
	CGPoint end = CGContextGetTextPosition(context);
	float textWidth = end.x - start.x;
	
	CGContextSetRGBFillColor(context,
							 kWaitViewFontColorRed,
							 kWaitViewFontColorGreen,
							 kWaitViewFontColorBlue,
							 kWaitViewFontColorAlpha);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	
	CGContextShowTextAtPoint(context,
							 ((kWaitViewWidth - textWidth) * 0.5),
							 ((kWaitViewHeight - kNumberFontSize) * 0.25),
							 [label UTF8String],
							 [label length]);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	UIImage *image = [UIImage imageWithCGImage:imageRef];
	
	CGPathRelease(pathRef);
	CGImageRelease(imageRef);
	CGContextRelease(context);
	
	return image;
}

@end
