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
		
		[self setBackgroundColor:[UIColor colorWithRed:kWaitBgColorRed
												 green:kWaitBgColorGreen
												  blue:kWaitBgColorBlue
												 alpha:kWaitBgColorAlpha]];
		
		UIImageView *dialog = [[UIImageView alloc] initWithFrame:CGRectMake(kWaitViewDialogX,
																			kWaitViewDialogY,
																			kWaitViewDialogWidth,
																			kWaitViewDialogHeight)];
		[dialog setImage:[self createImage]];
		
		activityIndicator = [[UIActivityIndicatorView alloc]
							 initWithFrame:CGRectMake(kWaitIndicatorX,
													  kWaitIndicatorY,
													  kWaitIndicatorWidth,
													  kWaitIndicatorHeight)];
		[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[dialog addSubview:activityIndicator];
		
		[self addSubview:dialog];
		[dialog release];
	}
	return self;
}

- (void)dealloc
{
	DLog("dealloc");
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
	CGContextRef context = [Util newBitmapContextForWidth:kWaitViewDialogWidth height:kWaitViewDialogHeight];
	
	CGMutablePathRef pathRef = CGPathCreateMutable();
	[Util drawRoundedRectForPath:pathRef
							rect:CGRectMake(0, 0, kWaitViewDialogWidth, kWaitViewDialogHeight)
						  radius:kTileCornerRadius];
	CGContextAddPath(context, pathRef);
	
	CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
	CGContextFillPath(context);

	[Util drawRoundedRectForPath:pathRef
							rect:CGRectMake(0, 0, kWaitViewDialogWidth, kWaitViewDialogHeight)
						  radius:kTileCornerRadius];
	CGContextAddPath(context, pathRef);
	
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
	CGContextStrokePath(context);
	
	// Draw Label
	CGContextSelectFont(context, kWaitViewFontType,  kWaitViewFontSize, kCGEncodingMacRoman);
	NSString *label = [NSString stringWithFormat:@"%@", NSLocalizedString(@"WaitImageLabel", @"")];
	
	// Calculate text width
	CGPoint start = CGContextGetTextPosition(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	CGContextShowText(context, [label UTF8String], [label length]);
	CGPoint end = CGContextGetTextPosition(context);
	float textWidth = end.x - start.x;
	
	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	
	CGContextShowTextAtPoint(context,
							 ((kWaitViewDialogWidth - textWidth) * 0.5),
							 ((kWaitViewDialogHeight - kNumberFontSize) * 0.25),
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
