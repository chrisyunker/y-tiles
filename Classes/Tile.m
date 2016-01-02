//
//  Tile.m
//  Y-Tiles
//
//  Created by Chris Yunker on 1/11/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "Tile.h"

@implementation Tile

@synthesize tileId;
@synthesize solved;
@synthesize moveType;
@synthesize pushTile;

static CGMutablePathRef tilePhotoBorderPath = NULL;
static CGMutablePathRef tileNumberBorderPath = NULL;
static int tileWidth = 0;
static int tileHeight = 0;


+ (Tile *)tileWithId:(int)aId board:(Board *)aBoard coord:(Coord)aCoord photo:(UIImage *)aPhoto
{
	int height = (int) aPhoto.size.height;
	int width = (int) aPhoto.size.width;
	
	if ((height != tileHeight) || (width != tileWidth))
	{
		tileWidth = width;
		tileHeight = height;
		[Tile setTilePhotoBorderPath];
		[Tile setTileNumberBorderPath];
	}
    
	return [[[Tile alloc] initWithBoard:aBoard tileId:aId coord:aCoord photo:aPhoto] autorelease];
}


- (id)initWithBoard:(Board *)aBoard tileId:(int)aTileId coord:(Coord)aCoord photo:(UIImage *)aPhoto
{
	CGRect rect = CGRectMake(0, 0, aPhoto.size.width, aPhoto.size.height);
	
	if (self = [super initWithFrame:rect])
	{		
		board = [aBoard retain];
		photoImage = [aPhoto retain];
		
		tileId = aTileId;
		homeCoord = aCoord;
		coord = aCoord;		
		moveType = None;
		solved = YES;
		haveLock = NO;
        
		[self createNumberImage];
		[self createPhotoImage];
		[self drawTile];
		[self updateFrame];
		[self setUserInteractionEnabled:YES];
		[self setMultipleTouchEnabled:NO];
	}
    
	return self;
}

- (void)dealloc
{
	[photoImage release];
	[numberedPhotoImage release];
	[numberImage release];
	[board release];
    [super dealloc];
}

- (void)drawTile
{
	if (board.config.photoEnabled)
	{
		if (board.config.numbersEnabled)
		{
			[self setImage:numberedPhotoImage];
		}
		else
		{
			[self setImage:photoImage];
		}
	}
	else
	{
		[self setImage:numberImage];
	}
}

- (void)moveToCoord:(Coord)aCoord;
{
	coord.x = aCoord.x;
	coord.y = aCoord.y;
	[self updateFrame];
}

- (void)moveToCoordX:(int)x coordY:(int)y
{
	coord.x = x;
	coord.y = y;
	[self updateFrame];
}
				
- (void)moveInDirection:(Direction)type
{
	// Need to move the furthest tile first
	if (pushTile != nil) [pushTile moveInDirection:type];
	
	Coord prevLoc = coord;
		
	switch (type)
	{
		case Left:
			coord.x--;
			[board moveTileFromCoordinate:prevLoc toCoordinate:coord];
			break;
		case Right:
			coord.x++;
			[board moveTileFromCoordinate:prevLoc toCoordinate:coord];
			break;
		case Up:
			coord.y--;
			[board moveTileFromCoordinate:prevLoc toCoordinate:coord];
			break;
		case Down:
			coord.y++;
			[board moveTileFromCoordinate:prevLoc toCoordinate:coord];
			break;
		default:
			// No move
			break;
	}
	[self updateFrame];
}

- (void)slideInDirection:(Direction)direction distance:(CGFloat)distance
{
	if (pushTile != nil) [pushTile slideInDirection:direction distance:distance];
	
	CGRect frame = [self frame];
	switch (direction)
	{
		case Left:
			frame.origin.x -= distance;
			break;
		case Right:
			frame.origin.x += distance;
			break;
		case Up:
			frame.origin.y -= distance;
			break;
		case Down:
			frame.origin.y += distance;
			break;
        case None:
            break;
	}
	[self setFrame:frame];
}


#pragma mark UIResponder callback methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!moveType) return;
	
	// Get lock
	if ([[board tileLock] tryLock])
	{
		haveLock = YES;
	}
	else
	{		
		return;
	}
	
	// Set start point for sliding tile
	startPoint = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!haveLock) return;
		
	CGRect frame = [self frame];
	CGPoint endPoint = [[touches anyObject] locationInView:self];
	
	if (moveType == Up)
	{
		CGFloat initY = frame.origin.y;

		frame.origin.y += endPoint.y - startPoint.y;
		if (frame.origin.y > startOrigin.y) frame.origin.y = startOrigin.y;
		if (frame.origin.y < (startOrigin.y - tileHeight)) frame.origin.y = startOrigin.y - tileHeight;
		
		if (pushTile != nil) [pushTile slideInDirection:moveType distance:(initY - frame.origin.y)];		
	}
	else if (moveType == Down)
	{
		CGFloat initY = frame.origin.y;
		
		frame.origin.y += endPoint.y - startPoint.y;
		if (frame.origin.y < startOrigin.y) frame.origin.y = startOrigin.y;
		if (frame.origin.y > (startOrigin.y + tileHeight)) frame.origin.y = startOrigin.y + tileHeight;
		
		if (pushTile != nil) [pushTile slideInDirection:moveType distance:(frame.origin.y - initY)];
	}
	else if (moveType == Left)
	{
		CGFloat initX = frame.origin.x;
		
		frame.origin.x += endPoint.x - startPoint.x;
		if (frame.origin.x > startOrigin.x) frame.origin.x = startOrigin.x;
		if (frame.origin.x < (startOrigin.x - tileWidth)) frame.origin.x = startOrigin.x - tileWidth;
		
		if (pushTile != nil) [pushTile slideInDirection:moveType distance:(initX - frame.origin.x)];
	}
	else if (moveType == Right)
	{
		CGFloat initX = frame.origin.x;
		
		frame.origin.x += endPoint.x - startPoint.x;
		if (frame.origin.x < startOrigin.x) frame.origin.x = startOrigin.x;
		if (frame.origin.x > (startOrigin.x + tileWidth)) frame.origin.x = startOrigin.x + tileWidth;
		
		if (pushTile != nil) [pushTile slideInDirection:moveType distance:(frame.origin.x - initX)];
	}
	
	[self setFrame:frame];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!haveLock) return;

	CGRect frame = [self frame];
	if ((frame.origin.x == startOrigin.x) && (frame.origin.y == startOrigin.y))
	{
		// NOP
	}
	else if ((frame.origin.x - startOrigin.x) > (tileWidth / 2))
	{		
		// Move Right

		[self moveInDirection:Right];
		[board updateGrid];
	}
	else if ((startOrigin.x - frame.origin.x) > (tileWidth / 2))
	{		
		// Move Left

		[self moveInDirection:Left];
		[board updateGrid];
	}
	else if ((frame.origin.y - startOrigin.y) > (tileHeight / 2))
	{
		// Move Down

		[self moveInDirection:Down];
		[board updateGrid];
	}
	else if ((startOrigin.y - frame.origin.y) > (tileHeight / 2))
	{
		// Move Up

		[self moveInDirection:Up];
		[board updateGrid];
	}
	else
	{
		[self moveInDirection:None];
	}
	
	if (haveLock)
	{
		// Release lock
		[[board tileLock] unlock];
		haveLock = NO;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	DLog("touchesCancelled tileId:[%d]", tileId);

	if (haveLock)
	{
		DLog("Lock Released tileId:[%d]", tileId);
		[[board tileLock] unlock];
		haveLock = NO;
	}	
}

- (void)createPhotoImage
{
	CGContextRef context = [Util newBitmapContextForWidth:tileWidth height:tileHeight];

	// Create photo with rounded border
	CGImageRef baseImageRef = [photoImage CGImage];
	CGContextDrawImage(context, [self frame], baseImageRef);
	CGContextSetRGBFillColor(context,
							 kBgColorRed,
							 kBgColorGreen,
							 kBgColorBlue,
							 kBgColorAlpha);
	CGContextAddPath(context, tilePhotoBorderPath);
	CGContextEOFillPath(context);
	
	[photoImage release];
	
	CGImageRef photoImageRef = CGBitmapContextCreateImage(context);
	photoImage = [[UIImage imageWithCGImage:photoImageRef] retain];
	CGImageRelease(photoImageRef);
	
	// Create tile ID number
    
    // Create number string
    CFStringRef number = CFStringCreateWithFormat(NULL, NULL, CFSTR("%d"), tileId);
    CFStringRef fontName = CFStringCreateWithFormat(NULL, NULL, CFSTR("%s"), kPhotoFontType);
    CTFontRef font = CTFontCreateWithName(fontName, kPhotoFontSize, NULL);
    CGFloat fontColorComponents[4] = {
        kPhotoFontColorRed,
        kPhotoFontColorGreen,
        kPhotoFontColorBlue,
        kPhotoFontColorAlpha};
    CGColorRef fontColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), fontColorComponents);
    
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { font, fontColor };
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **) &keys,
                                                    (const void **) &values, sizeof(keys) / sizeof(keys[0]),
                                                    &kCFTypeDictionaryKeyCallBacks,
                                                    &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, number, attributes);
    CFRelease(number);
    CFRelease(fontName);
    CFRelease(font);
    CFRelease(fontColor);
    CFRelease(attributes);
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CGRect numberBounds = CTLineGetImageBounds(line, context);

	// Draw background
	CGContextSetRGBFillColor(context,
							 kPhotoBgColorRed,
							 kPhotoBgColorGreen,
							 kPhotoBgColorBlue,
							 kPhotoBgColorAlpha);
    CGContextSetTextDrawingMode(context, kCGTextFill);
	CGMutablePathRef numberBorderPath = [self newNumberBorderPathForTextWidth:numberBounds.size.width];
	CGContextAddPath(context, numberBorderPath);
	CGContextFillPath(context);
	
	// Draw number
    //DLog("T NUMBER %d  (%f x %f) (%f x %f)", tileId, numberBounds.size.width, numberBounds.size.height,
    //     (tileWidth - numberBounds.size.width - kPhotoBgBorder - kPhotoBgOffset),
    //     (tileHeight - kPhotoFontSize - kPhotoBgOffset));
    CGContextSetTextPosition(context,
                             (tileWidth - numberBounds.size.width - kPhotoBgBorder - kPhotoBgOffset),
                             (tileHeight - kPhotoFontSize - kPhotoBgOffset));
    CTLineDraw(line, context);
    CFRelease(line);
    CFRelease(attrString);
	
	CGImageRef numberedPhotoImageRef = CGBitmapContextCreateImage(context);
	numberedPhotoImage = [[UIImage imageWithCGImage:numberedPhotoImageRef] retain];
	CGPathRelease(numberBorderPath);
	CGImageRelease(numberedPhotoImageRef);
	
	CGContextRelease(context);
}

- (void)createNumberImage
{
    CGContextRef context = [Util newBitmapContextForWidth:tileWidth height:tileHeight];
    
    // Create tile background
	CGContextSetRGBFillColor(context,
							 kNumberBgColorRed,
							 kNumberBgColorGreen,
							 kNumberBgColorBlue,
							 kNumberBgColorAlpha);
	
	CGContextAddPath(context, tileNumberBorderPath);
	CGContextFillPath(context);
    
    // Create number string
    CFStringRef number = CFStringCreateWithFormat(NULL, NULL, CFSTR("%d"), tileId);
    CFStringRef fontName = CFStringCreateWithFormat(NULL, NULL, CFSTR("%s"), kNumberFontType);
    CTFontRef font = CTFontCreateWithName(fontName, kNumberFontSize, NULL);
    CGFloat fontColorComponents[4] = {kNumberFontColorRed,
                                      kNumberFontColorGreen,
                                      kNumberFontColorBlue,
                                      kNumberFontColorAlpha};
    CGColorRef fontColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), fontColorComponents);
    
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { font, fontColor };
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **) &keys,
                                                    (const void **) &values, sizeof(keys) / sizeof(keys[0]),
                                                    &kCFTypeDictionaryKeyCallBacks,
                                                    &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, number, attributes);
    CFRelease(font);
    CFRelease(fontName);
    CFRelease(fontColor);
    CFRelease(number);
    CFRelease(attributes);
	
    // Center and render number string
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CGRect numberBounds = CTLineGetImageBounds(line, context);
    //DLog("NUMBER %d  %f x %f", tileId, numberBounds.size.width, numberBounds.size.height);
    CGContextSetTextPosition(context,
                             ((tileWidth - numberBounds.size.width) * 0.5),
                             ((tileHeight - kPhotoFontSize) * 0.5));
    CTLineDraw(line, context);
    CFRelease(line);
    CFRelease(attrString);

    // Create number tile image
    CGImageRef numberImageRef = CGBitmapContextCreateImage(context);
    numberImage = [[UIImage imageWithCGImage:numberImageRef] retain];
    CGImageRelease(numberImageRef);
    
	CGContextRelease(context);
}

- (void)updateFrame
{
	startOrigin.x = tileWidth * coord.x;
	startOrigin.y = tileHeight * coord.y;
	
	// Update solved state
	if ((coord.x == homeCoord.x) && (coord.y == homeCoord.y))
	{
		solved = YES;
	}
	else
	{
		solved = NO;
	}
	
	CGRect frame = [self frame];
	frame.origin = startOrigin;
	[self setFrame:frame];
}


- (CGMutablePathRef)newNumberBorderPathForTextWidth:(float)textWidth;
{
	CGMutablePathRef numberBorderPath = CGPathCreateMutable();
	
	CGRect frame = CGRectMake((tileWidth - textWidth - (2 * kPhotoBgBorder) - kPhotoBgOffset),
							  (tileHeight - kPhotoFontSize - kPhotoBgBorder - kPhotoBgOffset),
							  (textWidth + (2 * kPhotoBgBorder)),
							  (kPhotoFontSize + kPhotoBgBorder));
	
	[Util drawRoundedRectForPath:numberBorderPath
							rect:frame
						  radius:kPhotoBgCornerRadius];
	
	return numberBorderPath;
}


// All tiles are the same size so we only need to create
// the rounded border once. The following static methods
// set static CGPathRef variables.

+ (void)setTilePhotoBorderPath
{
	if (tilePhotoBorderPath != NULL)
	{
		CGPathRelease(tilePhotoBorderPath);
	}
    
	tilePhotoBorderPath = CGPathCreateMutable();
	
	CGPathMoveToPoint(tilePhotoBorderPath, NULL, 0, 0);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, tileWidth, 0);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, tileWidth, tileHeight);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, 0, tileHeight);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, 0, 0);
	
	[Util drawRoundedRectForPath:tilePhotoBorderPath
							rect:CGRectMake(kTileSpacingWidth,
											kTileSpacingWidth,
											tileWidth,
											tileHeight)
						  radius:kTileCornerRadius];
}

+ (void)setTileNumberBorderPath
{
	if (tileNumberBorderPath != NULL)
	{
		CGPathRelease(tileNumberBorderPath);
	}
	
	tileNumberBorderPath = CGPathCreateMutable();
    
	[Util drawRoundedRectForPath:tileNumberBorderPath
							rect:CGRectMake(kTileSpacingWidth,
											kTileSpacingWidth,
											(tileWidth - (2 * kTileSpacingWidth)),
											(tileHeight - (2 * kTileSpacingWidth)))
						  radius:kTileCornerRadius];
}

@end
