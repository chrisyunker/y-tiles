//
//  WaitImageView.m
//  Y-Tiles
//
//  Created by Chris Yunker on 3/1/09.
//  Copyright 2009 chrisyunker.com. All rights reserved.
//

#import "WaitImageView.h"

@implementation WaitImageView

- (id)initWithSize:(CGSize)size
{
	if (self = [super initWithFrame:CGRectMake(kWaitViewX, kWaitViewY, size.width, size.height)])
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
		[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleLarge];
		[dialog addSubview:activityIndicator];
		
		[self addSubview:dialog];
	}
	return self;
}

- (void)dealloc
{
	DLog("dealloc");
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
    CFStringRef waitLable = CFStringCreateWithFormat(NULL, NULL, CFSTR("%@"), NSLocalizedString(@"WaitImageLabel", @""));
    CFStringRef fontName = CFStringCreateWithFormat(NULL, NULL, CFSTR("%s"), kWaitViewFontType);
    CTFontRef font = CTFontCreateWithName(fontName, kWaitViewFontSize, NULL);
    CGFloat fontColorComponents[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    CGColorRef fontColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), fontColorComponents);
    
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { font, fontColor };
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **) &keys,
                                                    (const void **) &values, sizeof(keys) / sizeof(keys[0]),
                                                    &kCFTypeDictionaryKeyCallBacks,
                                                    &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, waitLable, attributes);
    CFRelease(font);
    CFRelease(fontName);
    CFRelease(fontColor);
    CFRelease(waitLable);
    CFRelease(attributes);
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CGRect waitBounds = CTLineGetImageBounds(line, context);
    
    CGContextSetTextPosition(context,
                             ((kWaitViewDialogWidth - waitBounds.size.width) * 0.5),
                             ((kWaitViewDialogHeight - kNumberFontSize) * 0.25));
    CTLineDraw(line, context);
    CFRelease(line);
    CFRelease(attrString);
    
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	UIImage *image = [UIImage imageWithCGImage:imageRef];
	
	CGPathRelease(pathRef);
	CGImageRelease(imageRef);
	CGContextRelease(context);
	
	return image;
}

@end
