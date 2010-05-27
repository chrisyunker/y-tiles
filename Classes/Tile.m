//
//  Tile.m
//  Y-Tiles
//
//  Created by Chris Yunker on 1/11/09.
//  Copyright 2009 Chris Yunker. All rights reserved.
//

#import "Tile.h"

@interface Tile (Private)

+ (void)getTilePhotoBorderPathForWidth:(int)width height:(int)height;
+ (void)getTileNumberBorderPathForWidth:(int)width height:(int)height;

- (id)initWithBoard:(Board *)aBoard tileId:(int)aTileId loc:(Coordinate)aLoc photo:(UIImage *)aPhoto;
- (void)createPhotoImage;
- (void)createNumberImage;
- (void)updateFrame;
- (CGMutablePathRef)getNumberBorderPathForTextWidth:(float)textWidth;

@end


@implementation Tile

@synthesize tileId;
@synthesize solved;
@synthesize moveType;
@synthesize pushTile;

static CGMutablePathRef tilePhotoBorderPath = NULL;
static CGMutablePathRef tileNumberBorderPath = NULL;
static int tileWidth = 0;
static int tileHeight = 0;


+ (Tile *)tileWithId:(int)aId board:(Board *)aBoard loc:(Coordinate)aLoc photo:(UIImage *)aPhoto
{
	int height = (int) aPhoto.size.height;
	int width = (int) aPhoto.size.width;
	
	if ((height != tileHeight) || (width != tileWidth))
	{
		[Tile getTilePhotoBorderPathForWidth:width height:height];
		[Tile getTileNumberBorderPathForWidth:width height:height];
	}
	
	tileWidth = width;
	tileHeight = height;
	
	return [[[Tile alloc] initWithBoard:aBoard tileId:aId loc:aLoc photo:aPhoto] autorelease];
}


- (id)initWithBoard:(Board *)aBoard tileId:(int)aTileId loc:(Coordinate)aLoc photo:(UIImage *)aPhoto;
{
	CGRect rect = CGRectMake(0, 0, aPhoto.size.width, aPhoto.size.height);
	
	if (self = [super initWithFrame:rect])
	{		
		board = [aBoard retain];
		photoImage = [aPhoto retain];
		
		tileId = aTileId;
		home = aLoc;
		loc = aLoc;
		//tileHeight = (int) aPhoto.size.height;
		//tileWidth = (int) aPhoto.size.width;
		
		moveType = MoveNone;
		solved = YES;
		haveLock = NO;
		
		[self createNumberImage];
		[self createPhotoImage];
		[self drawTile];
		[self updateFrame];
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = NO;
	}
	return self;
}

- (void)dealloc
{
	DLog(@"dealloc tileId:[%d]", tileId);
	
	CGPathRelease(numberBorder);
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
			self.image = numberedPhotoImage;
		}
		else
		{
			self.image = photoImage;
		}
	}
	else
	{
		self.image = numberImage;
	}
}

- (void)moveToHomeCoordinate
{
	Coordinate prevLoc = loc;
	loc = home;
	
	[board moveTileFromCoordinate:prevLoc toCoordinate:loc];
	
	[self updateFrame];
}

- (void)moveToCoordinate:(Coordinate)aLoc
{
	loc = aLoc;
	
	[self updateFrame];
}

- (void)moveInDirection:(MoveType)type
{
	// Need to move the furthest tile first
	if (pushTile != nil) [pushTile moveInDirection:type];
	
	Coordinate prevLoc = loc;
		
	switch (type)
	{
		case MoveLeft:
			loc.x--;
			[board moveTileFromCoordinate:prevLoc toCoordinate:loc];
			break;
		case MoveRight:
			loc.x++;
			[board moveTileFromCoordinate:prevLoc toCoordinate:loc];
			break;
		case MoveUp:
			loc.y--;
			[board moveTileFromCoordinate:prevLoc toCoordinate:loc];
			break;
		case MoveDown:
			loc.y++;
			[board moveTileFromCoordinate:prevLoc toCoordinate:loc];
			break;
		default:
			// No move
			break;
	}
	
	[self updateFrame];
}

- (void)slideTileInDirection:(MoveType)type distance:(CGFloat)distance
{
	if (pushTile != nil) [pushTile slideTileInDirection:type distance:distance];
	
	CGRect frame = [self frame];
	if (type == MoveLeft)
	{
		frame.origin.x -= distance;
	}
	if (type == MoveRight)
	{
		frame.origin.x += distance;
	}
	if (type == MoveUp)
	{
		frame.origin.y -= distance;
	}
	if (type == MoveDown)
	{
		frame.origin.y += distance;
	}
	[self setFrame:frame];	
}


#pragma mark UIResponder callback methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!moveType) return;
	
	// Get lock
	if ([board.tileLock tryLock])
	{
		haveLock = YES;
	}
	else
	{		
		return;
	}
	
	CGPoint pt = [[touches anyObject] locationInView:self];
	startLocation = pt;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!haveLock) return;
		
	if (moveType == MoveUp)
	{
		CGRect frame = [self frame];
		CGPoint pt = [[touches anyObject] locationInView:self];
		CGFloat initY = frame.origin.y;
				
		frame.origin.y += pt.y - startLocation.y;
		if (frame.origin.y > point.y) frame.origin.y = point.y;
		if (frame.origin.y < (point.y - (tileHeight))) frame.origin.y = point.y - (tileHeight);
		
		if (pushTile != nil) [pushTile slideTileInDirection:moveType distance:(initY - frame.origin.y)];
		[self setFrame:frame];
		return;
	}
	if (moveType == MoveDown)
	{
		CGPoint pt = [[touches anyObject] locationInView:self];
		CGRect frame = [self frame];
		CGFloat initY = frame.origin.y;
		
		frame.origin.y += pt.y - startLocation.y;
		if (frame.origin.y < point.y) frame.origin.y = point.y;
		if (frame.origin.y > (point.y + (tileHeight))) frame.origin.y = point.y + (tileHeight);
		
		if (pushTile != nil) [pushTile slideTileInDirection:moveType distance:(frame.origin.y - initY)];
		[self setFrame:frame];
		return;
	}
	if (moveType == MoveLeft)
	{
		CGPoint pt = [[touches anyObject] locationInView:self];
		CGRect frame = [self frame];
		CGFloat initX = frame.origin.x;
		
		frame.origin.x += pt.x - startLocation.x;
		if (frame.origin.x > point.x) frame.origin.x = point.x;
		if (frame.origin.x < (point.x - (tileWidth))) frame.origin.x = point.x - (tileWidth);
		
		if (pushTile != nil) [pushTile slideTileInDirection:moveType distance:(initX - frame.origin.x)];
		[self setFrame:frame];
		return;
	}
	if (moveType == MoveRight)
	{
		CGPoint pt = [[touches anyObject] locationInView:self];
		CGRect frame = [self frame];
		CGFloat initX = frame.origin.x;
		
		frame.origin.x += pt.x - startLocation.x;
		if (frame.origin.x < point.x) frame.origin.x = point.x;
		if (frame.origin.x > (point.x + (tileWidth))) frame.origin.x = point.x + (tileWidth);
		
		if (pushTile != nil) [pushTile slideTileInDirection:moveType distance:(frame.origin.x - initX)];
		
		[self setFrame:frame];
		return;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!haveLock) return;

	CGRect frame = [self frame];
	if ((frame.origin.x == point.x) && (frame.origin.y == point.y))
	{
		// Do nothing
	}
	else if ((frame.origin.x - point.x) > (tileWidth / 2))
	{		
		// Move Right

		[self moveInDirection:MoveRight];
		[board updateGrid];
	}
	else if ((point.x - frame.origin.x) > (tileWidth / 2))
	{		
		// Move Left

		[self moveInDirection:MoveLeft];
		[board updateGrid];
	}
	else if ((frame.origin.y - point.y) > (tileHeight / 2))
	{
		// Move Down

		[self moveInDirection:MoveDown];
		[board updateGrid];
	}
	else if ((point.y - frame.origin.y) > (tileHeight / 2))
	{
		// Move Up

		[self moveInDirection:MoveUp];
		[board updateGrid];
	}
	else
	{
		[self moveInDirection:MoveNone];
	}
	
	// Release lock
	[board.tileLock unlock];
	haveLock = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	DLog(@"touchesCancelled tileId:[%d]", tileId);

	if (haveLock)
	{
		DLog(@"Lock Released tileId:[%d]", tileId);
		
		[board.tileLock unlock];
		haveLock = NO;
	}	
}


#pragma mark Private methods

- (void)createPhotoImage
{
	CGContextRef context = [Util createBitmapContextForWidth:tileWidth height:tileHeight];
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
	
	CGContextSelectFont(context, kPhotoFontType,  kPhotoFontSize, kCGEncodingMacRoman);
	NSString *number = [NSString stringWithFormat:@"%d", tileId];
	
	// Calculate text width
	CGPoint start = CGContextGetTextPosition(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	CGContextShowText(context, [number UTF8String], [number length]);
	CGPoint end = CGContextGetTextPosition(context);
	float textWidth = end.x - start.x;
	
	// Draw background
	CGContextSetRGBFillColor(context,
							 kPhotoBgColorRed,
							 kPhotoBgColorGreen,
							 kPhotoBgColorBlue,
							 kPhotoBgColorAlpha);
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	
	CGContextAddPath(context, [self getNumberBorderPathForTextWidth:textWidth]);
	CGContextFillPath(context);
	
	// Draw number
	CGContextSetRGBFillColor(context,
							 kPhotoFontColorRed,
							 kPhotoFontColorGreen,
							 kPhotoFontColorBlue,
							 kPhotoFontColorAlpha);
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	CGContextShowTextAtPoint(context,
							 (tileWidth - textWidth - kPhotoBgBorder - kPhotoBgOffset),
							 (tileHeight - kPhotoFontSize - kPhotoBgOffset),
							 [number UTF8String],
							 [number length]);	
	
	CGImageRef numberedPhotoImageRef = CGBitmapContextCreateImage(context);
	
	numberedPhotoImage = [[UIImage imageWithCGImage:numberedPhotoImageRef] retain];
	
	CGImageRelease(numberedPhotoImageRef);
	CGContextRelease(context);
}

- (void)createNumberImage
{
	CGContextRef context = [Util createBitmapContextForWidth:tileWidth height:tileHeight];
	
	// Draw tile
	CGContextSetRGBFillColor(context,
							 kNumberBgColorRed,
							 kNumberBgColorGreen,
							 kNumberBgColorBlue,
							 kNumberBgColorAlpha);
	
	CGContextAddPath(context, tileNumberBorderPath);
	CGContextFillPath(context);
	
	// Draw font
	CGContextSelectFont(context, kNumberFontType,  kNumberFontSize, kCGEncodingMacRoman);
	NSString *number = [NSString stringWithFormat:@"%d", tileId];
	
	// Calculate text width
	CGPoint start = CGContextGetTextPosition(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	CGContextShowText(context, [number UTF8String], [number length]);
	CGPoint end = CGContextGetTextPosition(context);
	float textWidth = end.x - start.x;
	
	CGContextSetRGBFillColor(context,
							 kNumberFontColorRed,
							 kNumberFontColorGreen,
							 kNumberFontColorBlue,
							 kNumberFontColorAlpha);
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	CGContextShowTextAtPoint(context,
							 ((tileWidth - textWidth) * 0.5),
							 ((tileHeight - kNumberFontSize) * 0.5),
							 [number UTF8String],
							 [number length]);
	
	CGImageRef numberImageRef = CGBitmapContextCreateImage(context);
	
	numberImage = [[UIImage imageWithCGImage:numberImageRef] retain];
	
	CGImageRelease(numberImageRef);
	
	CGContextRelease(context);
}

- (void)updateFrame
{
	point.x = tileWidth * loc.x;
	point.y = tileHeight * loc.y;
	
	// Update solved state
	if ((loc.x == home.x) && (loc.y == home.y))
	{
		solved = YES;
	}
	else
	{
		solved = NO;
	}
	
	CGRect frame = [self frame];
	frame.origin.x = point.x;
	frame.origin.y = point.y;
	[self setFrame:frame];
}


- (CGMutablePathRef)getNumberBorderPathForTextWidth:(float)textWidth;
{
	CFNumberRef textWidthRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &textWidth);
	
	if (numberBorder != nil)
	{
		CFRelease(textWidthRef);
		
		return numberBorder;
	}
	
	numberBorder = CGPathCreateMutable();
	
	CGRect frame = CGRectMake((tileWidth - textWidth - (2 * kPhotoBgBorder) - kPhotoBgOffset),
							  (tileHeight - kPhotoFontSize - kPhotoBgBorder - kPhotoBgOffset),
							  (textWidth + (2 * kPhotoBgBorder)),
							  (kPhotoFontSize + kPhotoBgBorder));
	
	[Util drawRoundedRectForPath:numberBorder
							rect:frame
						  radius:kPhotoBgCornerRadius];
	
	return numberBorder;
}

// Static Methods for creating/reusing CGPaths for Tiles

+ (void)getTilePhotoBorderPathForWidth:(int)width height:(int)height
{	
	if (tilePhotoBorderPath != NULL)
	{
		CGPathRelease(tilePhotoBorderPath);
	}
	
	tilePhotoBorderPath = CGPathCreateMutable();
	
	CGPathMoveToPoint(tilePhotoBorderPath, NULL, 0, 0);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, width, 0);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, width, height);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, 0, height);
	CGPathAddLineToPoint(tilePhotoBorderPath, NULL, 0, 0);
	
	[Util drawRoundedRectForPath:tilePhotoBorderPath
							rect:CGRectMake(kTileSpacingWidth,
											kTileSpacingWidth,
											width,
											height)
						  radius:kTileCornerRadius];	
}

+ (void)getTileNumberBorderPathForWidth:(int)width height:(int)height
{	
	if (tileNumberBorderPath != NULL)
	{
		CGPathRelease(tileNumberBorderPath);
	}
	
	tileNumberBorderPath = CGPathCreateMutable();
	
	[Util drawRoundedRectForPath:tileNumberBorderPath
							rect:CGRectMake(kTileSpacingWidth,
											kTileSpacingWidth,
											(width - (2 * kTileSpacingWidth)),
											(height - (2 * kTileSpacingWidth)))
						  radius:kTileCornerRadius];	
}

@end
